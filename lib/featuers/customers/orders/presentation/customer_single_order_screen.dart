import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../constants/app_assets/assets_icons.dart';
import '../../../../helpers/di.dart';
import '../data/customer_orders_rx.dart';
import 'customer_orders_screen.dart';

class CustomerSingleOrderScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? orderData;

  const CustomerSingleOrderScreen({
    super.key,
    required this.orderId,
    this.orderData,
  });

  @override
  State<CustomerSingleOrderScreen> createState() => _CustomerSingleOrderScreenState();
}

class _CustomerSingleOrderScreenState extends State<CustomerSingleOrderScreen> {
  late CustomerSingleOrderRx _rx;

  Map<String, dynamic>? _resolveMergedOrderData(Map<String, dynamic>? source) {
    Map<String, dynamic> result = source != null ? Map<String, dynamic>.from(source) : {};

    final cleanOrderId = widget.orderId.replaceAll('#', '').trim().toLowerCase();
    final candidateKeys = {
      cleanOrderId,
      (result['order_number'] ?? '').toString().replaceAll('#', '').trim().toLowerCase(),
      (result['id'] ?? '').toString().replaceAll('#', '').trim().toLowerCase(),
      (result['order_id'] ?? '').toString().replaceAll('#', '').trim().toLowerCase(),
    }..removeWhere((k) => k.isEmpty);

    Map<String, dynamic>? localMatch;
    for (final storeKey in ['customer_placed_orders', 'wholesale_placed_orders']) {
      final list = appData.read(storeKey);
      if (list is List) {
        for (final ord in list) {
          if (ord is Map) {
            final k1 = (ord['order_number'] ?? '').toString().replaceAll('#', '').trim().toLowerCase();
            final k2 = (ord['id'] ?? '').toString().replaceAll('#', '').trim().toLowerCase();
            final k3 = (ord['order_id'] ?? '').toString().replaceAll('#', '').trim().toLowerCase();
            if (candidateKeys.contains(k1) || candidateKeys.contains(k2) || candidateKeys.contains(k3)) {
              localMatch = Map<String, dynamic>.from(ord);
              break;
            }
          }
        }
      }
      if (localMatch != null) break;
    }

    if (localMatch != null) {
      if (result.isEmpty) {
        return localMatch;
      }
      final resultItems = result['items'] ?? result['order_items'] ?? result['products'] ?? result['lines'];
      final localItems = localMatch['items'] ?? localMatch['order_items'] ?? localMatch['products'] ?? localMatch['lines'];

      if ((resultItems == null || (resultItems is List && resultItems.isEmpty)) && localItems is List && localItems.isNotEmpty) {
        result['items'] = localItems;
      } else if (resultItems is List && localItems is List && resultItems.length == localItems.length) {
        final mergedItems = [];
        for (int i = 0; i < resultItems.length; i++) {
          final sIt = resultItems[i] is Map ? Map<String, dynamic>.from(resultItems[i]) : {};
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
        result['items'] = mergedItems;
      }

      for (final f in [
        'shipping_address', 'delivery_address', 'fulfillment_type', 'delivery_type',
        'delivery_date', 'delivery_slot', 'payment_method', 'customer_name',
        'customer_phone', 'customer_email', 'order_notes', 'subtotal', 'total', 'total_amount'
      ]) {
        if ((result[f] == null || result[f].toString().trim().isEmpty) && localMatch[f] != null) {
          result[f] = localMatch[f];
        }
      }
    }

    return result.isNotEmpty ? result : (localMatch ?? source);
  }

  @override
  void initState() {
    super.initState();
    Map<String, dynamic>? initialData = _resolveMergedOrderData(
      widget.orderData != null && widget.orderData!.isNotEmpty
          ? Map<String, dynamic>.from(widget.orderData!)
          : null,
    );

    _rx = CustomerSingleOrderRx(empty: initialData ?? {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
    if (initialData != null && initialData.isNotEmpty) {
      _rx.dataFetcher.sink.add(initialData);
    }

    final cleanId = widget.orderId.replaceAll('#', '').trim().toLowerCase();
    const invalidWords = {
      'placed', 'pending', 'confirmed', 'confirmation', 'shipped', 'delivered',
      'cancelled', 'canceled', 'received', 'details', 'notification', 'history',
      'status', 'success', 'failed', 'update', 'created', 'new', 'order', 'orders',
      'pedido', 'pedidos', 'null', 'undefined', 'view', 'item', 'items', 'processing'
    };
    if (widget.orderId.isNotEmpty && !invalidWords.contains(cleanId)) {
      _rx.fetchSingleOrder(widget.orderId);
    }
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  String _formatDateTimeOnly(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('d MMM yyyy, h:mm a').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  String _formatStatus(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'canceled' || s == 'cancelled' || s == 'cancel' || s == 'rejected' || s == 'returned') {
      return 'Cancelled';
    }
    if (s == 'confirmed') return 'Confirmed';
    if (s == 'processing' || s == 'in_transit' || s == 'shipped' || s == 'out_for_delivery') {
      return 'Processing';
    }
    if (s == 'delivered' || s == 'completed') return 'Delivered';
    if (s == 'pending') return 'Pending';
    return raw.isEmpty ? 'Pending' : '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  int _getStatusStep(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'delivered' || s == 'completed') return 4;
    if (s == 'processing' || s == 'shipped' || s == 'in_transit' || s == 'out_for_delivery') return 3;
    if (s == 'confirmed') return 2;
    return 1; // Placed / Pending
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

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase().trim();
    switch (s) {
      case 'cancelled':
      case 'canceled':
      case 'cancel':
      case 'rejected':
      case 'returned':
        return Icons.cancel_outlined;
      case 'delivered':
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'processing':
      case 'in_transit':
      case 'shipped':
      case 'out_for_delivery':
        return Icons.local_shipping_outlined;
      case 'confirmed':
        return Icons.verified_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _resolveImageUrl(dynamic rawUrl) {
    if (rawUrl == null) return '';
    final str = rawUrl.toString().trim();
    if (str.isEmpty) return '';
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    if (str.startsWith('/')) {
      return 'https://apielarbol.icommerce.com.bd$str';
    }
    return 'https://apielarbol.icommerce.com.bd/$str';
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Order #${widget.orderId}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => _rx.fetchSingleOrder(widget.orderId),
            tooltip: 'Refresh Details',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        initialData: widget.orderData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && widget.orderData == null) {
            return const CustomAppLoading.detail(message: 'Loading order details...');
          }
          final rawData = (snapshot.hasData && snapshot.data != null && (snapshot.data as Map).isNotEmpty)
              ? snapshot.data
              : widget.orderData;
          final mergedData = _resolveMergedOrderData(rawData is Map ? Map<String, dynamic>.from(rawData) : null);

          if (mergedData == null || mergedData.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long_outlined, size: 48.sp, color: Colors.orange.shade800),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Order Details Not Found',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: const Color(0xFF151E13)),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'We could not load details for order #${widget.orderId}. Please try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: () => _rx.fetchSingleOrder(widget.orderId),
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                      label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final orderData = Map<String, dynamic>.from(mergedData);
          final rawStatus = orderData['status']?.toString() ?? 'Pending';
          final formattedStatus = _formatStatus(rawStatus);
          final bool isCancelled = formattedStatus == 'Cancelled';
          final int currentStep = _getStatusStep(rawStatus);

          // Extract Items
          List<dynamic> items = [];
          if (orderData['items'] is List) {
            items = orderData['items'];
          } else if (orderData['order_items'] is List) {
            items = orderData['order_items'];
          } else if (orderData['products'] is List) {
            items = orderData['products'];
          } else if (orderData['lines'] is List) {
            items = orderData['lines'];
          } else if (orderData['cart_items'] is List) {
            items = orderData['cart_items'];
          }

          // Calculate Subtotal from Items
          double calculatedSubtotal = 0.0;
          for (var it in items) {
            if (it is Map) {
              final double p = _extractItemUnitPrice(it);
              final int q = int.tryParse(it['quantity']?.toString() ?? it['qty']?.toString() ?? it['count']?.toString() ?? '1') ?? 1;
              calculatedSubtotal += (p * q);
            }
          }

          final shippingStr = (orderData['shipping'] ?? orderData['shipping_charge'] ?? orderData['shipping_cost'] ?? orderData['delivery_fee'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim();
          final discountStr = (orderData['discount'] ?? orderData['discount_amount'] ?? orderData['coupon_discount'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim();
          final taxStr = (orderData['tax'] ?? orderData['tax_amount'] ?? orderData['vat'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim();

          final sh = double.tryParse(shippingStr) ?? 0.0;
          final d = double.tryParse(discountStr) ?? 0.0;
          final t = double.tryParse(taxStr) ?? 0.0;

          final rawSubtotal = (orderData['subtotal'] ?? orderData['sub_total'] ?? orderData['items_total'] ?? '').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim();
          final parsedRawSubtotal = double.tryParse(rawSubtotal) ?? 0.0;

          final double finalSubtotal = calculatedSubtotal > 0
              ? calculatedSubtotal
              : (parsedRawSubtotal > 0 ? parsedRawSubtotal : 0.0);

          final subtotalStr = finalSubtotal.toStringAsFixed(2);

          final calcTotal = (finalSubtotal + sh + t - d);
          final rawTotal = (orderData['total'] ?? orderData['total_amount'] ?? orderData['grand_total'] ?? orderData['final_amount'] ?? '').toString().replaceAll('€', '').replaceAll('\$', '').replaceAll(',', '').trim();
          final parsedRawTotal = double.tryParse(rawTotal) ?? 0.0;

          final double finalTotal = (calcTotal > 0)
              ? calcTotal
              : ((parsedRawTotal > 0 && (finalSubtotal == 0 || parsedRawTotal <= finalSubtotal + sh + t))
                  ? parsedRawTotal
                  : (finalSubtotal > 0 ? finalSubtotal : 0.0));

          final totalStr = finalTotal.toStringAsFixed(2);

          final dateStr = orderData['created_at'] ?? orderData['date'] ?? orderData['ordered_at'] ?? '';
          final deliveryAddress = orderData['shipping_address'] ?? orderData['delivery_address'] ?? orderData['street_address'] ?? orderData['address'];
          final fulfillmentType = orderData['fulfillment_type'] ?? orderData['delivery_type'] ?? (deliveryAddress != null && deliveryAddress.toString().isNotEmpty ? 'Home Delivery' : 'Click & Collect');
          
          final customerName = orderData['customer_name'] ?? orderData['user_name'] ?? orderData['name'] ?? (orderData['customer'] is Map ? orderData['customer']['name'] : null) ?? (orderData['user'] is Map ? orderData['user']['name'] : null);
          final customerPhone = orderData['customer_phone'] ?? orderData['phone_number'] ?? orderData['phone'] ?? orderData['contact_number'] ?? (orderData['customer'] is Map ? orderData['customer']['phone'] : null) ?? (orderData['user'] is Map ? orderData['user']['phone'] : null);
          final customerEmail = orderData['customer_email'] ?? orderData['email'] ?? (orderData['customer'] is Map ? orderData['customer']['email'] : null) ?? (orderData['user'] is Map ? orderData['user']['email'] : null);

          final scheduledDate = orderData['delivery_date'] ?? orderData['scheduled_date'] ?? orderData['delivery_slot_date'];
          final scheduledSlot = orderData['delivery_slot'] ?? orderData['time_slot'] ?? orderData['slot'];
          final orderNotes = orderData['order_notes'] ?? orderData['notes'] ?? orderData['note'] ?? orderData['instructions'];
          final paymentMethod = orderData['payment_method'] ?? orderData['payment_type'] ?? orderData['payment_mode'] ?? 'Cash on Delivery';
          final txId = orderData['transaction_id'] ?? orderData['transaction_number'] ?? orderData['tx_id'];

          final displayOrderId = (orderData['order_number'] ?? orderData['order_id'] ?? orderData['id'] ?? widget.orderId).toString();

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status Header Card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: _getStatusColor(rawStatus).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getStatusIcon(rawStatus), color: _getStatusColor(rawStatus), size: 26.sp),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Order #$displayOrderId',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.5.sp,
                                                color: const Color(0xFF151E13),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          InkWell(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: displayOrderId));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Order ID #$displayOrderId copied'),
                                                  duration: const Duration(seconds: 2),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(2.r),
                                              child: Icon(Icons.copy_rounded, size: 14.sp, color: Colors.grey.shade500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(rawStatus).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(color: _getStatusColor(rawStatus).withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        formattedStatus,
                                        style: TextStyle(
                                          color: _getStatusColor(rawStatus),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.5.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                if (dateStr.toString().isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded, size: 13.sp, color: Colors.grey.shade500),
                                      SizedBox(width: 4.w),
                                      Text(
                                        _formatDateTimeOnly(dateStr),
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (isCancelled) ...[
                        SizedBox(height: 14.h),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.red.shade700, size: 18.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'This order has been cancelled. If you have questions, please contact our support team.',
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 11.5.sp, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        SizedBox(height: 18.h),
                        Divider(height: 1, color: Colors.grey.shade100),
                        SizedBox(height: 14.h),
                        // 4-Step Tracker
                        Row(
                          children: [
                            _buildProgressStep(title: 'Placed', isActive: currentStep >= 1, isCurrent: currentStep == 1, primaryColor: primaryColor),
                            _buildProgressConnector(isActive: currentStep >= 2, primaryColor: primaryColor),
                            _buildProgressStep(title: 'Confirmed', isActive: currentStep >= 2, isCurrent: currentStep == 2, primaryColor: primaryColor),
                            _buildProgressConnector(isActive: currentStep >= 3, primaryColor: primaryColor),
                            _buildProgressStep(title: 'Processing', isActive: currentStep >= 3, isCurrent: currentStep == 3, primaryColor: primaryColor),
                            _buildProgressConnector(isActive: currentStep >= 4, primaryColor: primaryColor),
                            _buildProgressStep(title: 'Delivered', isActive: currentStep >= 4, isCurrent: currentStep == 4, primaryColor: primaryColor),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // 2. Customer Information Card (if available)
                if (customerName != null || customerPhone != null || customerEmail != null) ...[
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, color: primaryColor, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Customer Information',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5.sp, color: const Color(0xFF151E13)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        if (customerName != null && customerName.toString().isNotEmpty)
                          _buildDetailRow(Icons.account_circle_outlined, 'Name', customerName.toString()),
                        if (customerPhone != null && customerPhone.toString().isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          _buildDetailRow(Icons.phone_outlined, 'Phone', customerPhone.toString()),
                        ],
                        if (customerEmail != null && customerEmail.toString().isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          _buildDetailRow(Icons.email_outlined, 'Email', customerEmail.toString()),
                        ],
                      ],
                    ),
                  ),
                ],

                // 3. Delivery & Fulfillment Card
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, color: primaryColor, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Fulfillment Details',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5.sp, color: const Color(0xFF151E13)),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              fulfillmentType.toString(),
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (deliveryAddress != null && deliveryAddress.toString().isNotEmpty)
                        _buildDetailRow(
                          Icons.location_on_outlined,
                          fulfillmentType.toString().contains('Collect') || fulfillmentType.toString().contains('Pickup') ? 'Store Location' : 'Delivery Address',
                          deliveryAddress.toString(),
                        ),
                      if (scheduledDate != null && scheduledDate.toString().isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _buildDetailRow(Icons.calendar_month_outlined, 'Scheduled Date', scheduledDate.toString()),
                      ],
                      if (scheduledSlot != null && scheduledSlot.toString().isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _buildDetailRow(Icons.access_time, 'Preferred Time Slot', scheduledSlot.toString()),
                      ],
                      if (orderNotes != null && orderNotes.toString().trim().isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _buildDetailRow(Icons.notes_rounded, 'Special Instructions', orderNotes.toString()),
                      ],
                    ],
                  ),
                ),

                // 4. Ordered Items Section
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ordered Items (${items.length})',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14.5.sp, color: const Color(0xFF151E13)),
                    ),
                    Text(
                      '€$subtotalStr',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5.sp, color: primaryColor),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                if (items.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text(
                        'No line item details found for this order.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final item = items[index] is Map ? (items[index] as Map) : <String, dynamic>{};
                      final name = item['product_name'] ??
                          item['name'] ??
                          item['product_title'] ??
                          item['title'] ??
                          (item['product'] is Map ? (item['product']['name'] ?? item['product']['title']) : null) ??
                          (item['product_details'] is Map ? (item['product_details']['name'] ?? item['product_details']['title']) : null) ??
                          'Organic Product';

                      final rawImg = item['product_image'] ??
                          item['image'] ??
                          item['thumbnail'] ??
                          item['thumbnail_url'] ??
                          (item['product'] is Map ? (item['product']['thumbnailUrl'] ?? item['product']['image'] ?? item['product']['thumbnail_url']) : null) ??
                          (item['product_details'] is Map ? (item['product_details']['thumbnail_url'] ?? item['product_details']['image'] ?? item['product_details']['thumbnailUrl']) : null);

                      final imageUrl = _resolveImageUrl(rawImg);
                      final unitPrice = _extractItemUnitPrice(item);
                      final qty = int.tryParse(item['quantity']?.toString() ?? item['qty']?.toString() ?? item['count']?.toString() ?? '1') ?? 1;
                      final itemTotal = (unitPrice * qty).toStringAsFixed(2);

                      return Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          padding: EdgeInsets.all(10.r),
                                          child: Image.asset(AssetsIcons.logoIcons, fit: BoxFit.contain),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(10.r),
                                      child: Image.asset(AssetsIcons.logoIcons, fit: BoxFit.contain),
                                    ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                      color: const Color(0xFF151E13),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'Qty: $qty',
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '€${unitPrice.toStringAsFixed(2)} / unit',
                                        style: TextStyle(
                                          color: const Color(0xFF00694C),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '€$itemTotal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5.sp,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                // 5. Payment & Order Summary Card
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment & Summary',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14.sp, color: const Color(0xFF151E13)),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              paymentMethod.toString(),
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (txId != null && txId.toString().isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Transaction ID: $txId',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500, fontFamily: 'monospace'),
                        ),
                      ],
                      SizedBox(height: 14.h),
                      _buildSummaryRow('Items Subtotal', '€$subtotalStr'),
                      SizedBox(height: 8.h),
                      _buildSummaryRow(
                        'Delivery Fee',
                        (double.tryParse(shippingStr) ?? 0.0) == 0 ? 'FREE' : '€$shippingStr',
                        valueColor: (double.tryParse(shippingStr) ?? 0.0) == 0 ? primaryColor : null,
                      ),
                      if ((double.tryParse(discountStr) ?? 0.0) > 0) ...[
                        SizedBox(height: 8.h),
                        _buildSummaryRow('Discount Applied', '-€$discountStr', valueColor: Colors.green.shade700),
                      ],
                      if ((double.tryParse(taxStr) ?? 0.0) > 0) ...[
                        SizedBox(height: 8.h),
                        _buildSummaryRow('Tax / VAT', '€$taxStr'),
                      ],
                      SizedBox(height: 12.h),
                      Divider(height: 1, color: Colors.grey.shade200),
                      SizedBox(height: 12.h),
                      _buildSummaryRow('Total Paid', '€$totalStr', isTotal: true, primaryColor: primaryColor),
                    ],
                  ),
                ),

                // 6. Navigation Buttons
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46.h,
                        child: OutlinedButton.icon(
                          onPressed: () => Get.off(() => const CustomerOrdersScreen()),
                          icon: const Icon(Icons.list_alt_rounded, size: 18),
                          label: const Text('All Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 46.h,
                        child: ElevatedButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                          label: const Text('Go Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: Colors.grey.shade600),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontFamily: 'Poppins'),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF151E13))),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? primaryColor, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? const Color(0xFF151E13) : Colors.grey.shade700,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 14.sp : 12.5.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? (primaryColor ?? const Color(0xFF151E13)) : (valueColor ?? const Color(0xFF151E13)),
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16.sp : 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStep({required String title, required bool isActive, required bool isCurrent, required Color primaryColor}) {
    return Column(
      children: [
        Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: const Color(0xFF4EFA8B), width: 2) : null,
          ),
          child: Center(
            child: Icon(
              isActive ? Icons.check : Icons.circle,
              size: 11.r,
              color: isActive ? Colors.white : Colors.grey.shade400,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? primaryColor : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressConnector({required bool isActive, required Color primaryColor}) {
    return Expanded(
      child: Container(
        height: 2.5.h,
        margin: EdgeInsets.only(bottom: 14.h),
        color: isActive ? primaryColor : Colors.grey.shade200,
      ),
    );
  }
}
