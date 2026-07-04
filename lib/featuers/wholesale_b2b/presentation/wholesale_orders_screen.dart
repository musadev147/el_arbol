import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WholesaleOrder {
  final String id;
  final DateTime date;
  final double total;
  final String status; // 'Pending', 'Confirmed', 'Processing', 'Delivered', 'Cancelled'
  final int itemsCount;
  final double adjustments; // Admin payment adjustments
  final double refunds; // Admin refunds processed

  WholesaleOrder({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.itemsCount,
    required this.adjustments,
    required this.refunds,
  });
}

class WholesaleOrderState {
  static final RxList<WholesaleOrder> orders = <WholesaleOrder>[
    WholesaleOrder(
      id: 'WHS-40812',
      date: DateTime.now().subtract(const Duration(days: 2)),
      total: 350.00,
      status: 'Confirmed',
      itemsCount: 5,
      adjustments: -25.00, // Admin adjusted price downwards
      refunds: 0.0,
    ),
    WholesaleOrder(
      id: 'WHS-39908',
      date: DateTime.now().subtract(const Duration(days: 6)),
      total: 580.00,
      status: 'Delivered',
      itemsCount: 12,
      adjustments: 0.0,
      refunds: 50.00, // Admin refunded due to bad crop batch
    ),
  ].obs;

  static void addOrder(WholesaleOrder order) {
    orders.insert(0, order);
  }
}

class WholesaleOrdersScreen extends StatelessWidget {
  const WholesaleOrdersScreen({super.key});

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

  void _showOrderTimeline(BuildContext context, WholesaleOrder order) {
    final stages = ['Pending', 'Confirmed', 'Processing', 'Delivered'];
    final currentStageIndex = stages.indexOf(order.status);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Pipeline Status',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ...stages.map((stage) {
              final idx = stages.indexOf(stage);
              final isCompleted = idx <= currentStageIndex;
              final isCurrent = idx == currentStageIndex;

              return Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? const Color(0xFF00694C) : Colors.grey.shade300,
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 12)
                            : null,
                      ),
                      if (stage != 'Delivered')
                        Container(
                          width: 2.w,
                          height: 30.h,
                          color: isCompleted ? const Color(0xFF00694C) : Colors.grey.shade300,
                        )
                    ],
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    stage,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? const Color(0xFF00694C) : Colors.grey.shade700,
                    ),
                  )
                ],
              );
            }).toList()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'B2B Wholesale Orders',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (WholesaleOrderState.orders.isEmpty) {
            return Center(
              child: Text(
                'No orders placed yet.',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            itemCount: WholesaleOrderState.orders.length,
            itemBuilder: (context, index) {
              final order = WholesaleOrderState.orders[index];
              final statusColor = _getStatusColor(order.status);

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.id,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.date)}  •  ${order.itemsCount} items bulk catalog order',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    const Divider(height: 20),

                    // Admin Adjustments Details if any
                    if (order.adjustments != 0.0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Admin Payment Adjustment',
                            style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${order.adjustments >= 0 ? '+' : ''}€ ${order.adjustments.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(height: 4.h),
                    ],

                    if (order.refunds != 0.0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Admin Refunds Applied',
                            style: TextStyle(fontSize: 12.sp, color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '-€ ${order.refunds.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12.sp, color: Colors.redAccent, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(height: 4.h),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Net Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '€ ${(order.total + order.adjustments - order.refunds).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    OutlinedButton.icon(
                      onPressed: () => _showOrderTimeline(context, order),
                      icon: const Icon(Icons.timeline, color: primaryColor, size: 16),
                      label: const Text('Track Pipeline Status', style: TextStyle(color: primaryColor)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
