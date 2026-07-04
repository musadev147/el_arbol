import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'wholesale_cart_state.dart';
import 'wholesale_orders_screen.dart';

class WholesaleCartScreen extends StatelessWidget {
  const WholesaleCartScreen({super.key});

  void _checkout(BuildContext context) {
    if (WholesaleCartState.cartItems.isEmpty) return;

    final order = WholesaleOrder(
      id: 'WHS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: DateTime.now(),
      total: WholesaleCartState.totalAmount,
      status: 'Pending',
      itemsCount: WholesaleCartState.cartItems.length,
      adjustments: 0.0,
      refunds: 0.0,
    );

    WholesaleOrderState.addOrder(order);
    WholesaleCartState.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Order Placed'),
        content: Text('Your B2B wholesale bulk order ${order.id} has been submitted to the warehouse pipeline.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Get.back(); // Back to catalog
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
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
        title: Text(
          'Wholesale Cart',
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
          if (WholesaleCartState.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 64.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text('Wholesale cart is empty.', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: WholesaleCartState.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = WholesaleCartState.cartItems[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF151E13),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '€ ${item.wholesalePrice.toStringAsFixed(2)} / ${item.unit}',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                onPressed: () {
                                  WholesaleCartState.updateQuantity(item.name, item.quantity.value - 1);
                                },
                              ),
                              Obx(() => Text(
                                '${item.quantity.value.toInt()}',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                              )),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: primaryColor),
                                onPressed: () {
                                  WholesaleCartState.updateQuantity(item.name, item.quantity.value + 1);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Checkout Card
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: [
                    // Payment Adjustment disclaimer
                    Container(
                      padding: EdgeInsets.all(12.r),
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade200),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Admin can edit wholesale orders, process refunds, or adjust payments directly from the control panel.',
                              style: TextStyle(fontSize: 11.sp, color: Colors.amber.shade900, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        Text(
                          '€ ${WholesaleCartState.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () => _checkout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Submit Wholesale Order',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
