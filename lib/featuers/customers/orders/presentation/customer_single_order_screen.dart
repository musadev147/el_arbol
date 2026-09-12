import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../data/customer_orders_rx.dart';
import '../../../../common_wigdets/custom_app_loading.dart';

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

  @override
  void initState() {
    super.initState();
    _rx = CustomerSingleOrderRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
    if (widget.orderData != null && widget.orderData!.isNotEmpty) {
      _rx.dataFetcher.sink.add(Map<String, dynamic>.from(widget.orderData!));
    }
    if (widget.orderId.isNotEmpty) {
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
    if (s == 'canceled' || s == 'cancelled' || s == 'cancel' || s == 'rejected') {
      return 'Cancelled';
    }
    if (s == 'confirmed') return 'Confirmed';
    if (s == 'processing') return 'Processing';
    if (s == 'delivered') return 'Delivered';
    if (s == 'pending') return 'Pending';
    return raw;
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase().trim();
    switch (s) {
      case 'pending':
        return Colors.orange.shade800;
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
        return Icons.cancel_outlined;
      case 'delivered':
        return Icons.check_circle_outline_rounded;
      case 'processing':
        return Icons.hourglass_top_rounded;
      case 'confirmed':
        return Icons.verified_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text('Order #${widget.orderId}', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _rx.fetchSingleOrder(widget.orderId),
            tooltip: 'Refresh',
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
          final data = (snapshot.hasData && snapshot.data != null && (snapshot.data as Map).isNotEmpty) 
              ? snapshot.data 
              : widget.orderData;
              
          if (data == null || (data as Map).isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Loading order details..."),
                  if (snapshot.hasError) ...[
                    const SizedBox(height: 10),
                    const Text("Could not fetch latest details.", style: TextStyle(color: Colors.red, fontSize: 12)),
                  ]
                ],
              )
            );
          }

          final orderData = data as Map<String, dynamic>;
          final status = orderData['status']?.toString() ?? 'Pending';
          
          List<dynamic> items = [];
          if (orderData['items'] is List) {
            items = orderData['items'];
          } else if (orderData['order_items'] is List) {
            items = orderData['order_items'];
          } else if (orderData['products'] is List) {
            items = orderData['products'];
          } else if (orderData['lines'] is List) {
            items = orderData['lines'];
          }

          double calculatedSubtotal = 0.0;
          for (var it in items) {
            if (it is Map) {
              final rawPrice = it['price'] ?? it['unit_price'] ?? it['product_price'] ?? (it['product'] is Map ? it['product']['price'] : null) ?? 0.0;
              final p = double.tryParse(rawPrice.toString().replaceAll('€', '').replaceAll('\$', '').trim()) ?? 0.0;
              final q = int.tryParse(it['quantity']?.toString() ?? it['qty']?.toString() ?? '1') ?? 1;
              calculatedSubtotal += (p * q);
            }
          }

          final rawSubtotal = orderData['subtotal'] ?? orderData['sub_total'] ?? orderData['items_total'];
          final subtotalStr = (rawSubtotal != null && rawSubtotal.toString() != '0' && rawSubtotal.toString() != '0.0')
              ? rawSubtotal.toString().replaceAll('€', '').replaceAll('\$', '')
              : calculatedSubtotal.toStringAsFixed(2);

          final taxStr = (orderData['tax'] ?? orderData['tax_amount'] ?? orderData['vat'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '');
          final shippingStr = (orderData['shipping'] ?? orderData['shipping_charge'] ?? orderData['shipping_cost'] ?? orderData['delivery_fee'] ?? '0.00').toString().replaceAll('€', '').replaceAll('\$', '');
          
          final rawTotal = orderData['total'] ?? orderData['total_amount'] ?? orderData['grand_total'] ?? orderData['final_amount'];
          String totalStr = (rawTotal != null && rawTotal.toString() != '0' && rawTotal.toString() != '0.0')
              ? rawTotal.toString().replaceAll('€', '').replaceAll('\$', '')
              : '';
          if (totalStr.isEmpty || totalStr == '0.0' || totalStr == '0.00') {
            final s = double.tryParse(subtotalStr) ?? 0.0;
            final t = double.tryParse(taxStr) ?? 0.0;
            final sh = double.tryParse(shippingStr) ?? 0.0;
            totalStr = (s + t + sh).toStringAsFixed(2);
          }

          final dateStr = orderData['created_at'] ?? orderData['date'] ?? orderData['ordered_at'] ?? '';
          final deliveryAddress = orderData['delivery_address'] ?? orderData['street_address'] ?? orderData['address'];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header Card
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
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 28.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${widget.orderId}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: const Color(0xFF151E13),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    _formatStatus(status),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
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
                                      fontSize: 12.sp,
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
                ),

                if (deliveryAddress != null && deliveryAddress.toString().isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: primaryColor),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivery Address', style: TextStyle(color: Colors.grey.shade600, fontSize: 11.sp)),
                              SizedBox(height: 2.h),
                              Text(
                                deliveryAddress.toString(),
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 20.h),
                Text('Order Items (${items.length})', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15.sp)),
                SizedBox(height: 12.h),

                // Items List
                if (items.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Center(child: Text("No item details found for this order")),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = items[index] as Map<String, dynamic>;
                      final name = item['product_name'] ?? item['name'] ?? item['product_title'] ?? (item['product'] is Map ? item['product']['name'] : null) ?? 'Organic Product';
                      final image = item['product_image'] ?? item['image'] ?? item['thumbnail'] ?? (item['product'] is Map ? (item['product']['thumbnailUrl'] ?? item['product']['image']) : null);
                      final rawP = item['price'] ?? item['unit_price'] ?? item['product_price'] ?? (item['product'] is Map ? item['product']['price'] : null) ?? '0.00';
                      final price = rawP.toString().replaceAll('€', '').replaceAll('\$', '').trim();
                      final qty = item['quantity'] ?? item['qty'] ?? item['count'] ?? 1;

                      return Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: image != null && image.toString().isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.network(
                                        image.toString(),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.grass, color: primaryColor),
                                      ),
                                    )
                                  : const Icon(Icons.grass, color: primaryColor),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.toString(),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text('Quantity: $qty', style: TextStyle(color: Colors.grey.shade600, fontSize: 11.sp)),
                                ],
                              ),
                            ),
                            Text(
                              '€$price',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: primaryColor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                SizedBox(height: 20.h),

                // Order Summary
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
                      Text('Order Summary', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      SizedBox(height: 16.h),
                      _buildSummaryRow('Subtotal', '€$subtotalStr'),
                      SizedBox(height: 8.h),
                      _buildSummaryRow('Tax (VAT)', '€$taxStr'),
                      SizedBox(height: 8.h),
                      _buildSummaryRow('Shipping / Delivery', '€$shippingStr'),
                      SizedBox(height: 12.h),
                      const Divider(height: 1),
                      SizedBox(height: 12.h),
                      _buildSummaryRow('Total Paid', '€$totalStr', isTotal: true, primaryColor: primaryColor),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? primaryColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey.shade600,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14.sp : 13.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? (primaryColor ?? Colors.black) : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16.sp : 13.sp,
          ),
        ),
      ],
    );
  }
}
