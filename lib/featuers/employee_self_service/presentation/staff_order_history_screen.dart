import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../helpers/di.dart';
import 'package:el_arbol/featuers/employee_self_service/data/rx.dart';
import 'package:rxdart/rxdart.dart';
import '../../customers/orders/presentation/customer_single_order_screen.dart';

class StaffOrderHistoryScreen extends StatefulWidget {
  const StaffOrderHistoryScreen({super.key});

  @override
  State<StaffOrderHistoryScreen> createState() => _StaffOrderHistoryScreenState();
}

class _StaffOrderHistoryScreenState extends State<StaffOrderHistoryScreen> {
  late StaffOrderHistoryRx _orderHistoryRx;
  final Set<String> _deletedOrderKeys = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load previously deleted order keys from storage
    try {
      final savedDeleted = appData.read('staff_deleted_orders_keys');
      if (savedDeleted is List) {
        _deletedOrderKeys.addAll(savedDeleted.map((e) => e.toString().trim().toLowerCase().replaceAll('#', '')));
      }
    } catch (_) {}

    _orderHistoryRx = StaffOrderHistoryRx(empty: null, dataFetcher: BehaviorSubject<dynamic>());
    _orderHistoryRx.fetchOrderHistory();
  }

  @override
  void dispose() {
    _orderHistoryRx.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase().trim();
    switch (s) {
      case 'pending':
        return Colors.orange.shade800;
      case 'confirmed':
        return Colors.blue.shade700;
      case 'processing':
      case 'in_transit':
      case 'shipped':
      case 'out_for_delivery':
        return Colors.purple.shade700;
      case 'delivered':
      case 'completed':
        return const Color(0xFF00694C);
      case 'cancelled':
      case 'canceled':
      case 'cancel':
      case 'rejected':
      case 'returned':
        return Colors.red.shade700;
      default:
        return const Color(0xFF00694C);
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('d MMM yyyy, h:mm a').format(dt);
    } catch (_) {
      final str = raw.toString();
      return str.length > 10 ? str.substring(0, 10) : str;
    }
  }

  void _confirmDeleteOrder(Map<String, dynamic> order) {
    final displayId = (order['order_number'] ?? order['id'] ?? order['order_id'] ?? '').toString();
    final cleanKey = displayId.replaceAll('#', '').trim().toLowerCase();

    if (displayId.isEmpty) return;

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
              child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
            ),
            SizedBox(width: 10.w),
            const Text('Delete Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete order #$displayId? This action will remove the order permanently.',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteOrder(displayId, cleanKey);
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

  Future<void> _deleteOrder(String displayId, String cleanKey) async {
    setState(() {
      _deletedOrderKeys.add(cleanKey);
      _deletedOrderKeys.add(displayId.toLowerCase());
    });

    try {
      appData.write('staff_deleted_orders_keys', _deletedOrderKeys.toList());

      // Remove from customer_placed_orders
      if (appData.read('customer_placed_orders') is List) {
        final list = List<dynamic>.from(appData.read('customer_placed_orders'));
        list.removeWhere((o) {
          if (o is! Map) return false;
          final key = (o['order_number'] ?? o['id'] ?? o['order_id'] ?? '').toString().toLowerCase().replaceAll('#', '').trim();
          return key == cleanKey || key == displayId.toLowerCase();
        });
        appData.write('customer_placed_orders', list);
      }

      // Remove from wholesale_placed_orders
      if (appData.read('wholesale_placed_orders') is List) {
        final list = List<dynamic>.from(appData.read('wholesale_placed_orders'));
        list.removeWhere((o) {
          if (o is! Map) return false;
          final key = (o['order_number'] ?? o['id'] ?? o['order_id'] ?? '').toString().toLowerCase().replaceAll('#', '').trim();
          return key == cleanKey || key == displayId.toLowerCase();
        });
        appData.write('wholesale_placed_orders', list);
      }

      // Call API in background
      await _orderHistoryRx.deleteOrder(displayId);
    } catch (_) {}

    AppToast.success('Order #$displayId deleted successfully');
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Orders',
            onPressed: () => _orderHistoryRx.fetchOrderHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.white,
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search order by ID or #...',
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: Colors.grey.shade500),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18.sp, color: Colors.grey.shade500),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                filled: true,
                fillColor: const Color(0xFFF4F6F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEBECEE)),

          // Orders List
          Expanded(
            child: StreamBuilder(
              stream: _orderHistoryRx.valueStreamData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomAppLoading(message: 'Loading order history...');
                }
                final data = snapshot.data;
                if (data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48.r, color: Colors.grey.shade400),
                        SizedBox(height: 12.h),
                        Text('Failed to load order history', style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp)),
                        SizedBox(height: 12.h),
                        ElevatedButton.icon(
                          onPressed: () => _orderHistoryRx.fetchOrderHistory(),
                          icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                          label: const Text('Retry', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        ),
                      ],
                    ),
                  );
                }

                List<dynamic> rawOrders = [];
                if (data is Map && data['results'] is List) {
                  rawOrders = data['results'] as List;
                } else if (data is List) {
                  rawOrders = data;
                }

                // Filter out deleted orders and apply search query
                final List<Map<String, dynamic>> orders = [];
                for (final item in rawOrders) {
                  if (item is Map) {
                    final map = Map<String, dynamic>.from(item);
                    final k1 = (map['order_number'] ?? '').toString().toLowerCase().replaceAll('#', '').trim();
                    final k2 = (map['id'] ?? '').toString().toLowerCase().replaceAll('#', '').trim();
                    final k3 = (map['order_id'] ?? '').toString().toLowerCase().replaceAll('#', '').trim();

                    if (_deletedOrderKeys.contains(k1) || _deletedOrderKeys.contains(k2) || _deletedOrderKeys.contains(k3)) {
                      continue;
                    }

                    if (_searchQuery.isNotEmpty) {
                      final displayId = (map['order_number'] ?? map['id'] ?? map['order_id'] ?? '').toString().toLowerCase();
                      if (!displayId.contains(_searchQuery)) {
                        continue;
                      }
                    }

                    orders.add(map);
                  }
                }

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_edu, size: 64.r, color: Colors.grey.shade300),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isNotEmpty ? 'No matching orders found' : 'No orders found',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () => _orderHistoryRx.fetchOrderHistory(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final displayId = (order['order_number'] ?? order['id'] ?? order['order_id'] ?? '#').toString();
                      final status = (order['status'] ?? 'PENDING').toString();

                      double calculatedTotal = 0.0;
                      List<dynamic> items = [];
                      if (order['items'] is List) {
                        items = order['items'];
                      } else if (order['order_items'] is List) {
                        items = order['order_items'];
                      } else if (order['products'] is List) {
                        items = order['products'];
                      }

                      if (items.isNotEmpty) {
                        for (var it in items) {
                          if (it is Map) {
                            dynamic pDetails = it['product_details'] ?? (it['product'] is Map ? it['product'] : null);
                            dynamic rawPrice;
                            if (pDetails is Map) {
                              final double dP = double.tryParse(pDetails['discount_price']?.toString() ??
                                      pDetails['discountPrice']?.toString() ??
                                      pDetails['sale_price']?.toString() ??
                                      pDetails['selling_price']?.toString() ??
                                      pDetails['final_price']?.toString() ??
                                      '') ??
                                  0.0;
                              final double rP = double.tryParse(
                                      pDetails['price']?.toString() ?? pDetails['regular_price']?.toString() ?? '') ??
                                  0.0;
                              rawPrice = dP > 0 ? dP : rP;
                            }
                            if (rawPrice == null || rawPrice == 0 || rawPrice == 0.0) {
                              final double dP = double.tryParse(it['discount_price']?.toString() ??
                                      it['discountPrice']?.toString() ??
                                      it['sale_price']?.toString() ??
                                      it['selling_price']?.toString() ??
                                      it['final_price']?.toString() ??
                                      '') ??
                                  0.0;
                              final double rP = double.tryParse(it['price']?.toString() ??
                                      it['unit_price']?.toString() ??
                                      it['product_price']?.toString() ??
                                      '') ??
                                  0.0;
                              rawPrice = dP > 0 ? dP : rP;
                            }
                            final p = double.tryParse(rawPrice.toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0.0;
                            final q = int.tryParse(it['quantity']?.toString() ?? it['qty']?.toString() ?? '1') ?? 1;
                            calculatedTotal += (p * q);
                          }
                        }
                      }

                      final rawTotal = (order['total_amount'] ?? order['total'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim();
                      final total = calculatedTotal > 0 ? calculatedTotal.toStringAsFixed(2) : (double.tryParse(rawTotal) ?? 0.0).toStringAsFixed(2);
                      final date = _formatDate(order['created_at'] ?? order['date'] ?? order['ordered_at']);

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14.r),
                            onTap: () {
                              Get.to(() => CustomerSingleOrderScreen(
                                    orderId: displayId,
                                    orderData: order,
                                  ));
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Order #$displayId',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: const Color(0xFF151E13)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(status).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(20.r),
                                              border: Border.all(color: _getStatusColor(status).withValues(alpha: 0.25)),
                                            ),
                                            child: Text(
                                              status.toUpperCase(),
                                              style: TextStyle(
                                                color: _getStatusColor(status),
                                                fontSize: 10.5.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade400, size: 20.sp),
                                            tooltip: 'Delete Order',
                                            onPressed: () => _confirmDeleteOrder(order),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total: €$total',
                                        style: TextStyle(color: primaryColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
                                      ),
                                      if (date.isNotEmpty)
                                        Text(
                                          date,
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5.sp),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
