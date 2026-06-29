import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'order_models.dart';
import 'order_state.dart';

class TrackOrdersScreen extends StatelessWidget {
  const TrackOrdersScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete order $orderId? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              OrderState.deleteOrder(orderId);
              Navigator.pop(ctx);
              Get.snackbar(
                'Order Deleted',
                'Order $orderId has been deleted.',
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, StaffOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: EdgeInsets.all(20.r),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: const Color(0xFFF59E0B),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.date)}  •  Type: ${order.type}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            const Divider(height: 24),
            if (order.fvItems.isNotEmpty) ...[
              Text(
                'Fruits & Vegetables',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00694C),
                ),
              ),
              SizedBox(height: 8.h),
              ...order.fvItems.map((item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                    Text(
                      'A: ${item.classAQty} ${item.classAUnit}  |  B: ${item.classBQty} ${item.classBUnit}',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                    )
                  ],
                ),
              )),
              const Divider(height: 24),
            ],
            if (order.groceryItems.isNotEmpty) ...[
              Text(
                'Groceries',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00694C),
                ),
              ),
              SizedBox(height: 8.h),
              ...order.groceryItems.map((item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.name} (${item.category})', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                        Text('${item.quantity} ${item.unit}', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                      ],
                    ),
                    if (item.details.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          'Note: ${item.details}',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      )
                  ],
                ),
              )),
            ],
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, order.id);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Delete Order', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
            ),
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
        title: Text(
          'Track Current Orders',
          style: TextStyle(
            color: const Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontSize: 18.sp,
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
          final pendingOrders = OrderState.orders
              .where((o) => o.status == 'Pending Warehouse Approval')
              .toList();

          if (pendingOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'No active orders pending approval.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            itemCount: pendingOrders.length,
            itemBuilder: (context, index) {
              final order = pendingOrders[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.id,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF151E13),
                        ),
                      ),
                      Text(
                        order.type,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h),
                      Text(
                        'Items: ${order.fvItems.length} F&V, ${order.groceryItems.length} Grocery',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(order.date),
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showOrderDetails(context, order),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
