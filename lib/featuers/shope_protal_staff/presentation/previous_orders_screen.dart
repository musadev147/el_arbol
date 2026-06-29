import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'order_models.dart';
import 'order_state.dart';

class PreviousOrdersScreen extends StatefulWidget {
  const PreviousOrdersScreen({super.key});

  @override
  State<PreviousOrdersScreen> createState() => _PreviousOrdersScreenState();
}

class _PreviousOrdersScreenState extends State<PreviousOrdersScreen> {
  DateTime? _selectedDate;

  void _shareOrder(StaffOrder order) {
    final buffer = StringBuffer();
    buffer.writeln('El Árbol Order Invoice: ${order.id}');
    buffer.writeln('Date: ${DateFormat('yyyy-MM-dd').format(order.date)}');
    buffer.writeln('Type: ${order.type}');
    buffer.writeln('Status: ${order.status}');
    buffer.writeln('-----------------------------------');
    if (order.fvItems.isNotEmpty) {
      buffer.writeln('\n[Fruits & Vegetables]');
      for (var item in order.fvItems) {
        buffer.writeln('- ${item.name}: A: ${item.classAQty}${item.classAUnit} | B: ${item.classBQty}${item.classBUnit}');
      }
    }
    if (order.groceryItems.isNotEmpty) {
      buffer.writeln('\n[Grocery]');
      for (var item in order.groceryItems) {
        buffer.writeln('- ${item.name}: ${item.quantity}${item.unit} (${item.category})');
        if (item.details.isNotEmpty) buffer.writeln('  Note: ${item.details}');
      }
    }
    Share.share(buffer.toString(), subject: 'El Árbol Order ${order.id}');
  }

  void _downloadInvoice(StaffOrder order) {
    Get.snackbar(
      'Invoice Downloaded',
      'Invoice PDF for ${order.id} saved to Downloads.',
      backgroundColor: const Color(0xFF00694C),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showOrderDetails(StaffOrder order) {
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: Colors.green,
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
                    onPressed: () => _shareOrder(order),
                    icon: const Icon(Icons.share, color: Color(0xFF00694C)),
                    label: const Text('Share Invoice', style: TextStyle(color: Color(0xFF00694C))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00694C)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadInvoice(order),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00694C),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'Previous Orders',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Color(0xFF00694C)),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () => setState(() => _selectedDate = null),
            )
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          var filteredOrders = OrderState.orders.toList();
          if (_selectedDate != null) {
            filteredOrders = filteredOrders.where((o) {
              return o.date.year == _selectedDate!.year &&
                  o.date.month == _selectedDate!.month &&
                  o.date.day == _selectedDate!.day;
            }).toList();
          }

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'No orders found for this selection.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade100),
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
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: order.status == 'Approved'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: order.status == 'Approved' ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(order.date)}  •  Type: ${order.type}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () => _showOrderDetails(order),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
