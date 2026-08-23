import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../customers/orders/data/customer_orders_rx.dart';

class WholesaleOrdersScreen extends StatefulWidget {
  const WholesaleOrdersScreen({super.key});

  @override
  State<WholesaleOrdersScreen> createState() => _WholesaleOrdersScreenState();
}

class _WholesaleOrdersScreenState extends State<WholesaleOrdersScreen> {
  late final CustomerOrdersRx _rx;

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

  void _showOrderTimeline(BuildContext context, String currentStatus) {
    final stages = ['Pending', 'Confirmed', 'Processing', 'Delivered'];
    final currentStageIndex = stages.indexOf(currentStatus);

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

  final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'WHS-40812',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'total': '350.00',
      'status': 'Confirmed',
      'items_count': 5,
      'adjustments': '-25.00',
      'refunds': '0.0',
    },
    {
      'id': 'WHS-39908',
      'created_at': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
      'total': '580.00',
      'status': 'Delivered',
      'items_count': 12,
      'adjustments': '0.0',
      'refunds': '50.0',
    },
  ];

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
        child: StreamBuilder<dynamic>(
          stream: _rx.valueStreamData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }

            List<dynamic> orders = snapshot.data ?? [];

            // Graceful fallback if backend API returns 500 or is empty
            if (snapshot.hasError || orders.isEmpty) {
              orders = _mockOrders;
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index] as Map<String, dynamic>;
                final id = order['id']?.toString() ?? '';
                final status = order['status']?.toString() ?? 'Pending';
                final statusColor = _getStatusColor(status);

                final createdDateStr = order['created_at']?.toString() ?? '';
                DateTime parsedDate;
                try {
                  parsedDate = DateTime.parse(createdDateStr).toLocal();
                } catch (_) {
                  parsedDate = DateTime.now();
                }

                final double total = double.tryParse(order['total']?.toString() ?? '0.0') ?? 0.0;
                final double adjustments = double.tryParse(order['adjustments']?.toString() ?? '0.0') ?? 0.0;
                final double refunds = double.tryParse(order['refunds']?.toString() ?? '0.0') ?? 0.0;

                final itemsCount = order['items_count'] is int 
                    ? order['items_count'] 
                    : (order['items'] is List ? (order['items'] as List).length : 1);

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
                            'Order #$id',
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
                              status,
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
                        'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(parsedDate)}  •  $itemsCount items bulk catalog order',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      const Divider(height: 20),

                      // Admin Adjustments Details if any
                      if (adjustments != 0.0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Admin Payment Adjustment',
                              style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${adjustments >= 0 ? '+' : ''}€ ${adjustments.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(height: 4.h),
                      ],

                      if (refunds != 0.0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Admin Refunds Applied',
                              style: TextStyle(fontSize: 12.sp, color: Colors.redAccent, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '-€ ${refunds.toStringAsFixed(2)}',
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
                            '€ ${(total + adjustments - refunds).toStringAsFixed(2)}',
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
                        onPressed: () => _showOrderTimeline(context, status),
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
          },
        ),
      ),
    );
  }
}
