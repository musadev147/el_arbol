import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import '../data/customer_orders_rx.dart';

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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return const Color(0xFF00694C);
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
            return const Center(child: CircularProgressIndicator(color: primaryColor));
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
                // Status Header
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
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
                          color: _getStatusColor(status).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.inventory_2_outlined, color: _getStatusColor(status), size: 28.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order Status', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                            SizedBox(height: 4.h),
                            Text(
                              status,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _getStatusColor(status)),
                            ),
                            if (dateStr.toString().isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text('Placed: $dateStr', style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp)),
                            ],
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
