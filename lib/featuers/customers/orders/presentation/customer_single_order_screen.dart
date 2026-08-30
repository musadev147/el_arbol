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
    if (widget.orderData != null) {
      _rx.dataFetcher.sink.add(Map<String, dynamic>.from(widget.orderData!));
    } else {
      _rx.fetchSingleOrder(widget.orderId);
    }
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Processing':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
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
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        initialData: widget.orderData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(child: Text("Failed to load order details"));
          }

          final orderData = data as Map<String, dynamic>;
          final status = orderData['status'] ?? 'Pending';
          final items = orderData['items'] ?? [];
          final subtotal = orderData['subtotal']?.toString() ?? '0.0';
          final tax = orderData['tax']?.toString() ?? '0.0';
          final shipping = orderData['shipping']?.toString() ?? '0.0';
          final total = orderData['total']?.toString() ?? '0.0';

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
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.inventory, color: _getStatusColor(status)),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Status', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                          SizedBox(height: 4.h),
                          Text(status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _getStatusColor(status))),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20.h),
                Text('Order Items', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 12.h),

                // Items List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: item['image'] != null
                                ? Image.network(item['image'], fit: BoxFit.cover)
                                : const Icon(Icons.image, color: Colors.grey),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? 'Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                                SizedBox(height: 4.h),
                                Text('Qty: ${item['quantity']}', style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                              ],
                            ),
                          ),
                          Text('\$${item['price']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: primaryColor)),
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
                      _buildSummaryRow('Subtotal', '\$$subtotal'),
                      SizedBox(height: 8.h),
                      _buildSummaryRow('Tax', '\$$tax'),
                      SizedBox(height: 8.h),
                      _buildSummaryRow('Shipping', '\$$shipping'),
                      SizedBox(height: 12.h),
                      const Divider(height: 1),
                      SizedBox(height: 12.h),
                      _buildSummaryRow('Total', '\$$total', isTotal: true, primaryColor: primaryColor),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
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
