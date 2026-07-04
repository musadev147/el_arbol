import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../wholesale_b2b/presentation/wholesale_orders_screen.dart';

class ManageWholesaleOrdersScreen extends StatefulWidget {
  const ManageWholesaleOrdersScreen({super.key});

  @override
  State<ManageWholesaleOrdersScreen> createState() => _ManageWholesaleOrdersScreenState();
}

class _ManageWholesaleOrdersScreenState extends State<ManageWholesaleOrdersScreen> {
  void _editOrderStatus(WholesaleOrder order) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        final statuses = ['Pending', 'Confirmed', 'Processing', 'Delivered', 'Cancelled'];
        return Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Order Status (${order.id})',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              ...statuses.map((status) => ListTile(
                    title: Text(status, style: TextStyle(fontWeight: order.status == status ? FontWeight.bold : FontWeight.normal)),
                    trailing: order.status == status ? const Icon(Icons.check, color: Color(0xFF00694C)) : null,
                    onTap: () {
                      final updated = WholesaleOrder(
                        id: order.id,
                        date: order.date,
                        total: order.total,
                        status: status,
                        itemsCount: order.itemsCount,
                        adjustments: order.adjustments,
                        refunds: order.refunds,
                      );
                      final index = WholesaleOrderState.orders.indexOf(order);
                      if (index != -1) {
                        WholesaleOrderState.orders[index] = updated;
                      }
                      Fluttertoast.showToast(msg: 'Status updated to $status');
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _adjustPayment(WholesaleOrder order) {
    final controller = TextEditingController(text: order.adjustments.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Adjust Payment (${order.id})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter positive/negative adjustment amount (€):'),
            SizedBox(height: 8.h),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(hintText: 'e.g. -25.00 or 15.00'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                final updated = WholesaleOrder(
                  id: order.id,
                  date: order.date,
                  total: order.total,
                  status: order.status,
                  itemsCount: order.itemsCount,
                  adjustments: val,
                  refunds: order.refunds,
                );
                final index = WholesaleOrderState.orders.indexOf(order);
                if (index != -1) {
                  WholesaleOrderState.orders[index] = updated;
                }
                Fluttertoast.showToast(msg: 'Payment adjustment saved.');
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _processRefund(WholesaleOrder order) {
    final controller = TextEditingController(text: order.refunds.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Process Refund (${order.id})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter refund amount to apply (€):'),
            SizedBox(height: 8.h),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'e.g. 50.00'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val >= 0) {
                final updated = WholesaleOrder(
                  id: order.id,
                  date: order.date,
                  total: order.total,
                  status: order.status,
                  itemsCount: order.itemsCount,
                  adjustments: order.adjustments,
                  refunds: val,
                );
                final index = WholesaleOrderState.orders.indexOf(order);
                if (index != -1) {
                  WholesaleOrderState.orders[index] = updated;
                }
                Fluttertoast.showToast(msg: 'Refund of €${val.toStringAsFixed(2)} processed.');
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
            child: const Text('Refund'),
          )
        ],
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
          'Manage Wholesale B2B',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (WholesaleOrderState.orders.isEmpty) {
            return Center(
              child: Text(
                'No wholesale orders available to manage.',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(20.r),
            itemCount: WholesaleOrderState.orders.length,
            itemBuilder: (context, index) {
              final order = WholesaleOrderState.orders[index];
              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
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
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(color: primaryColor, fontSize: 11.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.date)}  •  ${order.itemsCount} bulk items',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Original Invoice Total', style: TextStyle(color: Colors.grey)),
                        Text('€ ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (order.adjustments != 0.0) ...[
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Adjustments', style: TextStyle(color: Colors.amber)),
                          Text('€ ${order.adjustments.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                    if (order.refunds != 0.0) ...[
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Refunds Sourced', style: TextStyle(color: Colors.redAccent)),
                          Text('-€ ${order.refunds.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Adjusted Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '€ ${(order.total + order.adjustments - order.refunds).toStringAsFixed(2)}',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _editOrderStatus(order),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text('Status', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _adjustPayment(order),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryColor),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text('Adjust', style: TextStyle(color: primaryColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _processRefund(order),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text('Refund', style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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
