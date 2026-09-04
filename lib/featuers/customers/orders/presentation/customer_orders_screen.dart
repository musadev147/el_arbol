import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../data/customer_orders_rx.dart';
import 'customer_single_order_screen.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  late CustomerOrdersRx _rx;

  @override
  void initState() {
    super.initState();
    _rx = CustomerOrdersRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _rx.fetchOrders();
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
        title: const Text(
          'My Orders',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _rx.fetchOrders(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomAppLoading(message: 'Loading orders...');
          }
          final data = snapshot.data;
          if (snapshot.hasError || data == null) {
            return NoInternetOrDataWidget(
              title: 'Failed to Load Orders',
              message: 'Could not fetch your orders. Please check your internet connection.',
              onRetry: () => _rx.fetchOrders(),
            );
          }

          final List<dynamic> orders = data as List<dynamic>;

          if (orders.isEmpty) {
            return NoInternetOrDataWidget(
              title: 'No Orders Found',
              message: 'You have not placed any orders yet.',
              onRetry: () => _rx.fetchOrders(),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: orders.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final order = orders[index] as Map<String, dynamic>;
              final id = (order['id'] ?? order['order_number'] ?? order['order_id'] ?? '${index + 1}').toString();
              final status = order['status']?.toString() ?? 'Pending';
              final dateStr = order['created_at'] ?? order['date'] ?? order['ordered_at'] ?? 'Recent';
              final rawTotal = order['total'] ?? order['total_amount'] ?? order['grand_total'] ?? '0.00';
              final total = rawTotal.toString().replaceAll('€', '').replaceAll('\$', '').trim();
              
              return InkWell(
                onTap: () {
                  Get.to(() => CustomerSingleOrderScreen(orderId: id, orderData: order));
                },
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #$id',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      const Divider(height: 1),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date Ordered', style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                              SizedBox(height: 2.h),
                              Text(dateStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                              SizedBox(height: 2.h),
                              Text('\$$total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: primaryColor)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
