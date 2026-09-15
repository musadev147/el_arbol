import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../data/customer_orders_rx.dart';
import 'customer_single_order_screen.dart';
import 'package:el_arbol/helpers/di.dart';

enum OrderSortOption {
  newest,
  oldest,
  priceHighToLow,
  priceLowToHigh,
}

enum OrderDateFilter {
  all,
  today,
  last7Days,
  last30Days,
  custom,
}

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  late CustomerOrdersRx _rx;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  OrderSortOption _sortOption = OrderSortOption.newest;
  OrderDateFilter _dateFilter = OrderDateFilter.all;
  String _statusFilter = 'All';
  DateTimeRange? _customDateRange;

  final Set<String> _deletedOrderKeys = {};

  @override
  void initState() {
    super.initState();
    _loadDeletedKeys();
    _rx = CustomerOrdersRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _rx.fetchOrders();
  }

  void _loadDeletedKeys() {
    try {
      final saved = appData.read('deleted_customer_orders_keys');
      if (saved is List) {
        _deletedOrderKeys.addAll(saved.map((e) => e.toString()));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _rx.dispose();
    super.dispose();
  }

  void _confirmDeleteOrder(Map<String, dynamic> order) {
    final orderKey = order['order_number']?.toString() ?? order['id']?.toString() ?? order['order_id']?.toString() ?? '';
    if (orderKey.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            ),
            SizedBox(width: 10.w),
            const Text('Delete Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove Order #$orderKey from your order history?',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteOrder(orderKey);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(String orderKey) {
    setState(() {
      _deletedOrderKeys.add(orderKey);
    });

    try {
      appData.write('deleted_customer_orders_keys', _deletedOrderKeys.toList());

      // Remove from customer_placed_orders
      if (appData.read('customer_placed_orders') is List) {
        final list = List<dynamic>.from(appData.read('customer_placed_orders'));
        list.removeWhere((o) {
          if (o is! Map) return false;
          final key = o['order_number']?.toString() ?? o['id']?.toString() ?? o['order_id']?.toString() ?? '';
          return key == orderKey;
        });
        appData.write('customer_placed_orders', list);
      }

      // Remove from wholesale_placed_orders
      if (appData.read('wholesale_placed_orders') is List) {
        final list = List<dynamic>.from(appData.read('wholesale_placed_orders'));
        list.removeWhere((o) {
          if (o is! Map) return false;
          final key = o['order_number']?.toString() ?? o['id']?.toString() ?? o['order_id']?.toString() ?? '';
          return key == orderKey;
        });
        appData.write('wholesale_placed_orders', list);
      }
    } catch (_) {}

    AppToast.success("Order #$orderKey deleted successfully");
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'confirmed':
        return Colors.blue.shade700;
      case 'processing':
        return Colors.purple.shade700;
      case 'delivered':
        return const Color(0xFF00694C);
      case 'cancelled':
      case 'canceled':
      case 'cancel':
      case 'rejected':
      case 'returned':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatStatus(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'canceled' || s == 'cancelled' || s == 'cancel' || s == 'rejected') {
      return 'Cancelled';
    }
    if (s == 'confirmed') return 'Confirmed';
    if (s == 'processing') return 'Processing';
    if (s == 'delivered') return 'Delivered';
    if (s == 'pending') return 'Pending';
    return status;
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return 'Recent';
    try {
      final str = raw.toString();
      final dt = DateTime.parse(str).toLocal();
      return DateFormat('MMM d, y • h:mm a').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  DateTime? _parseOrderDate(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  double _extractItemUnitPrice(Map<dynamic, dynamic> it) {
    dynamic pDetails = it['product_details'] ?? (it['product'] is Map ? it['product'] : null);

    double getSalePriceFromMap(Map m) {
      final keys = [
        'discount_price', 'discountPrice', 'discount', 'sale_price', 'salePrice', 'saleprice',
        'selling_price', 'sellingPrice', 'offer_price', 'offerPrice', 'final_price', 'finalPrice',
        'special_price', 'specialPrice', 'deal_price', 'dealPrice', 'promo_price', 'promoPrice',
        'sell_price', 'sellPrice', 'price_discounted', 'discounted_price'
      ];
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) {
          final d = double.tryParse(m[k].toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim());
          if (d != null && d > 0) return d;
        }
      }
      return 0.0;
    }

    double getRegularPriceFromMap(Map m) {
      final keys = ['price', 'regular_price', 'regularPrice', 'unit_price', 'unitPrice', 'product_price', 'total_price', 'amount'];
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) {
          final d = double.tryParse(m[k].toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim());
          if (d != null && d > 0) return d;
        }
      }
      return 0.0;
    }

    double salePrice = 0.0;
    double regularPrice = 0.0;

    if (pDetails is Map) {
      salePrice = getSalePriceFromMap(pDetails);
      regularPrice = getRegularPriceFromMap(pDetails);
    }
    if (salePrice == 0.0) {
      salePrice = getSalePriceFromMap(it);
    }
    if (regularPrice == 0.0) {
      regularPrice = getRegularPriceFromMap(it);
    }

    if (salePrice > 0) {
      return salePrice;
    }
    return regularPrice;
  }

  double _parseOrderTotal(Map<String, dynamic> order) {
    List<dynamic> items = [];
    if (order['items'] is List) {
      items = order['items'];
    } else if (order['order_items'] is List) {
      items = order['order_items'];
    } else if (order['products'] is List) {
      items = order['products'];
    } else if (order['lines'] is List) {
      items = order['lines'];
    } else if (order['cart_items'] is List) {
      items = order['cart_items'];
    }

    final double shipping = double.tryParse((order['shipping'] ?? order['shipping_charge'] ?? order['shipping_cost'] ?? order['delivery_fee'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0.0;
    final double discount = double.tryParse((order['discount'] ?? order['discount_amount'] ?? order['coupon_discount'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0.0;
    final double tax = double.tryParse((order['tax'] ?? order['tax_amount'] ?? order['vat'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0.0;

    if (items.isNotEmpty) {
      double itemsSubtotal = 0.0;
      for (var it in items) {
        if (it is Map) {
          final double p = _extractItemUnitPrice(it);
          final int q = int.tryParse(it['quantity']?.toString() ?? it['qty']?.toString() ?? it['count']?.toString() ?? '1') ?? 1;
          itemsSubtotal += (p * q);
        }
      }
      final double finalCalc = (itemsSubtotal + shipping + tax - discount);
      if (finalCalc > 0) {
        return finalCalc;
      }
    }

    final sub = double.tryParse((order['subtotal'] ?? order['sub_total'] ?? order['items_total'] ?? '').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0.0;
    final total = double.tryParse((order['total'] ?? order['total_amount'] ?? order['grand_total'] ?? order['final_amount'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0.0;

    if (sub > 0 && total == 0) {
      final calcWithSub = sub + shipping + tax - discount;
      if (calcWithSub > 0) return calcWithSub;
      return sub;
    }
    if (total > 0 && sub > 0 && sub < total) {
      final calcWithSub = sub + shipping + tax - discount;
      if (calcWithSub > 0 && calcWithSub < total) {
        return calcWithSub;
      }
    }

    return total;
  }

  List<Map<String, dynamic>> _filterAndSortOrders(List<Map<String, dynamic>> allOrders) {
    final now = DateTime.now();

    var filtered = allOrders.where((order) {
      final key = order['order_number']?.toString() ?? order['id']?.toString() ?? order['order_id']?.toString() ?? '';
      if (_deletedOrderKeys.contains(key)) return false;

      // Search Query Filter (Matches Order ID / Number OR Product Names)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final orderId = (order['id'] ?? '').toString().toLowerCase();
        final orderNum = (order['order_number'] ?? '').toString().toLowerCase();
        bool matchesProduct = false;

        final items = order['items'] as List? ?? [];
        for (var it in items) {
          if (it is Map) {
            final pName = (it['product_name'] ?? it['name'] ?? it['title'] ?? it['product_details']?['name'] ?? '').toString().toLowerCase();
            if (pName.contains(query)) {
              matchesProduct = true;
              break;
            }
          }
        }

        if (!orderId.contains(query) && !orderNum.contains(query) && !matchesProduct) {
          return false;
        }
      }

      // Status Filter
      if (_statusFilter != 'All') {
        final status = (order['status'] ?? 'Pending').toString().toLowerCase();
        if (status != _statusFilter.toLowerCase()) {
          return false;
        }
      }

      // Date Filter
      final orderDate = _parseOrderDate(order['created_at'] ?? order['date'] ?? order['ordered_at']);
      if (orderDate != null) {
        if (_dateFilter == OrderDateFilter.today) {
          final isToday = orderDate.year == now.year && orderDate.month == now.month && orderDate.day == now.day;
          if (!isToday) return false;
        } else if (_dateFilter == OrderDateFilter.last7Days) {
          final diff = now.difference(orderDate).inDays;
          if (diff > 7 || diff < 0) return false;
        } else if (_dateFilter == OrderDateFilter.last30Days) {
          final diff = now.difference(orderDate).inDays;
          if (diff > 30 || diff < 0) return false;
        } else if (_dateFilter == OrderDateFilter.custom && _customDateRange != null) {
          final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
          final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
          if (orderDate.isBefore(start) || orderDate.isAfter(end)) return false;
        }
      }

      return true;
    }).toList();

    // Sort Orders
    filtered.sort((a, b) {
      final dateA = _parseOrderDate(a['created_at'] ?? a['date'] ?? a['ordered_at']) ?? DateTime(2000);
      final dateB = _parseOrderDate(b['created_at'] ?? b['date'] ?? b['ordered_at']) ?? DateTime(2000);
      final priceA = _parseOrderTotal(a);
      final priceB = _parseOrderTotal(b);

      switch (_sortOption) {
        case OrderSortOption.newest:
          return dateB.compareTo(dateA);
        case OrderSortOption.oldest:
          return dateA.compareTo(dateB);
        case OrderSortOption.priceHighToLow:
          return priceB.compareTo(priceA);
        case OrderSortOption.priceLowToHigh:
          return priceA.compareTo(priceB);
      }
    });

    return filtered;
  }

  Future<void> _selectCustomDateRange() async {
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00694C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF151E13),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _dateFilter = OrderDateFilter.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _rx.fetchOrders(),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Sort Header
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by Order ID or Product name...',
                    hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, color: primaryColor, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Sort & Custom Date Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sort Dropdown
                    Row(
                      children: [
                        Icon(Icons.sort, size: 16.r, color: Colors.grey.shade700),
                        SizedBox(width: 4.w),
                        DropdownButton<OrderSortOption>(
                          value: _sortOption,
                          underline: const SizedBox.shrink(),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF151E13),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: OrderSortOption.newest,
                              child: Text('Newest First'),
                            ),
                            DropdownMenuItem(
                              value: OrderSortOption.oldest,
                              child: Text('Oldest First'),
                            ),
                            DropdownMenuItem(
                              value: OrderSortOption.priceHighToLow,
                              child: Text('Price: High to Low'),
                            ),
                            DropdownMenuItem(
                              value: OrderSortOption.priceLowToHigh,
                              child: Text('Price: Low to High'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _sortOption = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Custom Date Picker Action
                    InkWell(
                      onTap: _selectCustomDateRange,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _dateFilter == OrderDateFilter.custom ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: _dateFilter == OrderDateFilter.custom ? primaryColor : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 14.r,
                              color: _dateFilter == OrderDateFilter.custom ? primaryColor : Colors.grey.shade700,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _dateFilter == OrderDateFilter.custom && _customDateRange != null
                                  ? '${DateFormat('MMM d').format(_customDateRange!.start)} - ${DateFormat('MMM d').format(_customDateRange!.end)}'
                                  : 'Date Range',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _dateFilter == OrderDateFilter.custom ? primaryColor : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Date Filter Chips
                SizedBox(height: 6.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDateFilterChip('All Time', OrderDateFilter.all),
                      _buildDateFilterChip('Today', OrderDateFilter.today),
                      _buildDateFilterChip('Last 7 Days', OrderDateFilter.last7Days),
                      _buildDateFilterChip('Last 30 Days', OrderDateFilter.last30Days),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEBECEE)),

          // Orders Stream List
          Expanded(
            child: StreamBuilder(
              stream: _rx.valueStreamData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomAppLoading(message: 'Loading your orders...');
                }
                final data = snapshot.data;
                if (snapshot.hasError || data == null) {
                  return NoInternetOrDataWidget(
                    title: 'Failed to Load Orders',
                    message: 'Could not fetch your orders. Please check your internet connection.',
                    onRetry: () => _rx.fetchOrders(),
                  );
                }

                final List<dynamic> serverOrders = data is List ? data : [];
                final List<dynamic> localOrders = [
                  if (appData.read('customer_placed_orders') is List)
                    ...List<dynamic>.from(appData.read('customer_placed_orders')),
                  if (appData.read('wholesale_placed_orders') is List)
                    ...List<dynamic>.from(appData.read('wholesale_placed_orders')),
                ];

                final Map<String, Map<String, dynamic>> localOrdersByKey = {};
                for (final o in localOrders) {
                  if (o is Map) {
                    final map = Map<String, dynamic>.from(o);
                    for (final k in [map['order_number'], map['id'], map['order_id'], map['order_code']]) {
                      if (k != null && k.toString().trim().isNotEmpty) {
                        localOrdersByKey[k.toString().trim().toLowerCase().replaceAll('#', '')] = map;
                      }
                    }
                  }
                }

                final Map<String, dynamic> mergedMap = {};
                for (final o in localOrders) {
                  if (o is Map) {
                    final key = o['order_number']?.toString() ?? o['id']?.toString() ?? o['order_id']?.toString() ?? '';
                    if (key.isNotEmpty) mergedMap[key] = Map<String, dynamic>.from(o);
                  }
                }

                for (final o in serverOrders) {
                  if (o is Map) {
                    final key = o['order_number']?.toString() ?? o['id']?.toString() ?? o['order_id']?.toString() ?? '';
                    if (key.isNotEmpty) {
                      final serverOrderMap = Map<String, dynamic>.from(o);
                      final cleanK = key.toLowerCase().replaceAll('#', '').trim();
                      final localOrderMatch = localOrdersByKey[cleanK] ?? (mergedMap.containsKey(key) ? mergedMap[key] : null);

                      if (localOrderMatch != null) {
                        final merged = Map<String, dynamic>.from(localOrderMatch);
                        final serverItems = serverOrderMap['items'] ?? serverOrderMap['order_items'] ?? serverOrderMap['products'] ?? serverOrderMap['lines'];
                        final localItems = localOrderMatch['items'] ?? localOrderMatch['order_items'] ?? localOrderMatch['products'] ?? localOrderMatch['lines'];

                        merged.addAll(serverOrderMap);

                        if ((serverItems == null || (serverItems is List && serverItems.isEmpty)) && localItems is List && localItems.isNotEmpty) {
                          merged['items'] = localItems;
                        } else if (serverItems is List && localItems is List && serverItems.length == localItems.length) {
                          final mergedItems = [];
                          for (int i = 0; i < serverItems.length; i++) {
                            final sIt = serverItems[i] is Map ? Map<String, dynamic>.from(serverItems[i]) : {};
                            final lIt = localItems[i] is Map ? Map<String, dynamic>.from(localItems[i]) : {};
                            final mIt = {...lIt, ...sIt};
                            if ((sIt['product_details'] == null || (sIt['product_details'] is Map && (sIt['product_details'] as Map).isEmpty)) && lIt['product_details'] != null) {
                              mIt['product_details'] = lIt['product_details'];
                            }
                            if (sIt['discount_price'] == null && lIt['discount_price'] != null) {
                              mIt['discount_price'] = lIt['discount_price'];
                            }
                            if (sIt['sale_price'] == null && lIt['sale_price'] != null) {
                              mIt['sale_price'] = lIt['sale_price'];
                            }
                            mergedItems.add(mIt);
                          }
                          merged['items'] = mergedItems;
                        }

                        for (final f in [
                          'shipping_address', 'delivery_address', 'fulfillment_type', 'delivery_type',
                          'delivery_date', 'delivery_slot', 'payment_method', 'customer_name',
                          'customer_phone', 'customer_email', 'order_notes', 'subtotal', 'total', 'total_amount'
                        ]) {
                          if ((merged[f] == null || merged[f].toString().trim().isEmpty) && localOrderMatch[f] != null) {
                            merged[f] = localOrderMatch[f];
                          }
                        }
                        mergedMap[key] = merged;
                      } else {
                        mergedMap[key] = serverOrderMap;
                      }
                    }
                  }
                }

                final List<Map<String, dynamic>> allOrders = mergedMap.values.map((e) => Map<String, dynamic>.from(e)).toList();
                final List<Map<String, dynamic>> filteredOrders = _filterAndSortOrders(allOrders);

                if (filteredOrders.isEmpty) {
                  if (allOrders.isEmpty) {
                    return NoInternetOrDataWidget(
                      title: 'No Orders Yet',
                      message: 'You have not placed any orders yet. Start exploring our organic products!',
                      onRetry: () => _rx.fetchOrders(),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64.r, color: Colors.grey.shade400),
                          SizedBox(height: 12.h),
                          Text(
                            'No matching orders found',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF151E13)),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Try clearing search queries or adjusting your date/status filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                          SizedBox(height: 16.h),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _dateFilter = OrderDateFilter.all;
                                _statusFilter = 'All';
                                _customDateRange = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            ),
                            child: Text('Reset All Filters', style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Check for live/active order to display Live Order Tracking Card at top
                Map<String, dynamic>? activeOrder;
                if (_searchQuery.isEmpty && _statusFilter == 'All' && _dateFilter == OrderDateFilter.all) {
                  for (final ord in filteredOrders) {
                    final s = (ord['status'] ?? '').toString().toLowerCase().trim();
                    if (s == 'processing' || s == 'confirmed' || s == 'pending' || s == 'dispatched' || s == 'out for delivery') {
                      activeOrder = ord;
                      break;
                    }
                  }
                }

                final int itemCount = filteredOrders.length + (activeOrder != null ? 1 : 0);

                return ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: itemCount,
                  separatorBuilder: (context, index) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    if (activeOrder != null && index == 0) {
                      return _buildLiveOrderTrackingCard(activeOrder, primaryColor);
                    }
                    final orderIndex = activeOrder != null ? index - 1 : index;
                    final order = filteredOrders[orderIndex];
                    return _buildOrderCard(order, primaryColor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveOrderTrackingCard(Map<String, dynamic> order, Color primaryColor) {
    final orderId = (order['order_number'] ?? order['id'] ?? order['order_id'] ?? '').toString();
    final status = (order['status'] ?? 'Processing').toString();
    final formattedStatus = _formatStatus(status);
    final total = _parseOrderTotal(order).toStringAsFixed(2);
    final items = (order['items'] as List?) ?? [];
    final itemsCount = order['items_count'] ?? (items.isNotEmpty ? items.length : 1);

    // Progress step logic (1: Placed, 2: Confirmed, 3: Processing/Shipped, 4: Delivered)
    int currentStep = 1;
    final s = status.toLowerCase().trim();
    if (s == 'confirmed') {
      currentStep = 2;
    } else if (s == 'processing' || s == 'dispatched' || s == 'out for delivery') {
      currentStep = 3;
    } else if (s == 'delivered') {
      currentStep = 4;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00694C),
            const Color(0xFF004D38),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00694C).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: () {
            Get.to(() => CustomerSingleOrderScreen(orderId: orderId, orderData: order));
          },
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Live Tracking Header with Order ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4EFA8B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'LIVE ORDER TRACKING',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: const Color(0xFF4EFA8B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        formattedStatus,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Prominent Order ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Order #$orderId',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '€$total',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '$itemsCount item${itemsCount == 1 ? '' : 's'} in transit',
                  style: TextStyle(fontSize: 11.5.sp, color: Colors.white70),
                ),
                SizedBox(height: 14.h),

                // 4-Step Progress Bar
                Row(
                  children: [
                    _buildStepIndicator(title: 'Placed', isActive: currentStep >= 1, isCurrent: currentStep == 1),
                    _buildStepConnector(isActive: currentStep >= 2),
                    _buildStepIndicator(title: 'Confirmed', isActive: currentStep >= 2, isCurrent: currentStep == 2),
                    _buildStepConnector(isActive: currentStep >= 3),
                    _buildStepIndicator(title: 'Transit', isActive: currentStep >= 3, isCurrent: currentStep == 3),
                    _buildStepConnector(isActive: currentStep >= 4),
                    _buildStepIndicator(title: 'Delivered', isActive: currentStep >= 4, isCurrent: currentStep == 4),
                  ],
                ),
                SizedBox(height: 14.h),

                // Button to Open Details
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_searching_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6.w),
                      Text(
                        'View Live Details & Receipt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required String title, required bool isActive, required bool isCurrent}) {
    return Column(
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white24,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: const Color(0xFF4EFA8B), width: 2) : null,
          ),
          child: Center(
            child: Icon(
              isActive ? Icons.check : Icons.circle,
              size: 10.r,
              color: isActive ? const Color(0xFF00694C) : Colors.white38,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.only(bottom: 14.h),
        color: isActive ? Colors.white : Colors.white24,
      ),
    );
  }

  Widget _buildDateFilterChip(String label, OrderDateFilter filter) {
    const Color primaryColor = Color(0xFF00694C);
    final bool isSelected = _dateFilter == filter;

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _dateFilter = filter;
              if (filter != OrderDateFilter.custom) {
                _customDateRange = null;
              }
            });
          }
        },
        selectedColor: primaryColor,
        backgroundColor: Colors.grey.shade100,
        labelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.grey.shade800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.transparent,
          ),
        ),
        showCheckmark: false,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, Color primaryColor) {
    final id = (order['order_number'] ?? order['id'] ?? order['order_id'] ?? '').toString();
    final status = (order['status'] ?? 'Processing').toString();
    final formattedStatus = _formatStatus(status);
    final dateStr = _formatDate(order['created_at'] ?? order['date'] ?? order['ordered_at']);
    final total = _parseOrderTotal(order).toStringAsFixed(2);
    final items = (order['items'] as List?) ?? [];
    final itemsCount = order['items_count'] ?? (items.isNotEmpty ? items.length : 1);
    final paymentMethod = (order['payment_method'] ?? 'Card').toString().toUpperCase();

    // Summary item preview text
    String itemsSummary = '';
    if (items.isNotEmpty) {
      final names = items.take(2).map((it) {
        if (it is Map) {
          final n = it['product_name'] ?? it['name'] ?? it['title'] ?? it['product_details']?['name'] ?? 'Item';
          final q = it['quantity'] ?? 1;
          return '$n x$q';
        }
        return 'Item';
      }).toList();
      itemsSummary = names.join(', ');
      if (items.length > 2) {
        itemsSummary += ' +${items.length - 2} more';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () {
            Get.to(() => CustomerSingleOrderScreen(orderId: id, orderData: order));
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header: Order # & Status Badge & Delete Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF00694C), size: 20),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #$id',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: const Color(0xFF151E13),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  dateStr,
                                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        formattedStatus,
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Delete Icon Button
                    SizedBox(width: 4.w),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
                      tooltip: 'Delete Order',
                      onPressed: () => _confirmDeleteOrder(order),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                    ),
                  ],
                ),

                if (itemsSummary.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 14.r, color: Colors.grey.shade600),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            itemsSummary,
                            style: TextStyle(fontSize: 11.5.sp, color: Colors.grey.shade800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 12.h),
                Divider(height: 1, color: Colors.grey.shade100),
                SizedBox(height: 12.h),

                // Card Footer: Items count, Payment method, Total amount & Details Arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$itemsCount item${itemsCount == 1 ? '' : 's'}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
                        Text(
                          paymentMethod,
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Text(
                          '€$total',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF00694C)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
