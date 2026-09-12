import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import 'package:el_arbol/featuers/employee_self_service/data/rx.dart';
import 'package:rxdart/rxdart.dart';

class StaffOrderHistoryScreen extends StatefulWidget {
  const StaffOrderHistoryScreen({super.key});

  @override
  State<StaffOrderHistoryScreen> createState() => _StaffOrderHistoryScreenState();
}

class _StaffOrderHistoryScreenState extends State<StaffOrderHistoryScreen> {
  late StaffOrderHistoryRx _orderHistoryRx;

  @override
  void initState() {
    super.initState();
    _orderHistoryRx = StaffOrderHistoryRx(empty: null, dataFetcher: BehaviorSubject<dynamic>());
    _orderHistoryRx.fetchOrderHistory();
  }

  @override
  void dispose() {
    _orderHistoryRx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: _orderHistoryRx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomAppLoading(message: 'Loading order history...');
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text("Failed to load order history."));
          }
          
          List<dynamic> orders = [];
          if (data is Map && data['results'] is List) {
            orders = data['results'] as List;
          } else if (data is List) {
            orders = data;
          }
          
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 64.r, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text('No orders found', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final displayId = order['order_number'] ?? order['id']?.toString() ?? '#';
              final status = order['status'] ?? 'COMPLETED';
              final total = order['total_amount'] ?? order['total'] ?? '0.00';
              final date = order['created_at']?.toString() ?? '';
              
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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
                          'Order #$displayId',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            status.toString().toUpperCase(),
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total: €$total', style: TextStyle(color: const Color(0xFF00694C), fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        if (date.isNotEmpty)
                           Text(
                             date.length > 10 ? date.substring(0, 10) : date,
                             style: TextStyle(color: Colors.grey, fontSize: 12.sp)
                           ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
      ),
    );
  }
}
