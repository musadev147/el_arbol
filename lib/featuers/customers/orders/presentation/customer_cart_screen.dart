import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:el_arbol/common_wigdets/custom_navigation.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import 'package:el_arbol/common_wigdets/user_role.dart';
import '../data/customer_orders_rx.dart';
import 'customer_checkout_screen.dart';

class CustomerCartScreen extends StatefulWidget {
  final RxList<Map<String, dynamic>> cartItems;

  const CustomerCartScreen({
    super.key,
    required this.cartItems,
  });

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  late final CustomerCartRx _cartRx;

  @override
  void initState() {
    super.initState();
    _cartRx = CustomerCartRx.instance;
    _cartRx.fetchBasket();
  }

  @override
  void dispose() {
    _cartRx.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAll(() => const CustomNavigation(role: UserRole.customer, selectedIndex: 0));
    }
  }

  double getSubtotal(List<dynamic> items) {
    double sum = 0.0;
    for (var item in items) {
      final details = item['product_details'] ?? {};
      final price = double.tryParse(details['price']?.toString() ?? '0.0') ?? 0.0;
      final quantity = item['quantity'] as int? ?? 1;
      sum += price * quantity;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'My Cart',
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
          onPressed: _handleBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF151E13)),
            onPressed: () => _cartRx.fetchBasket(),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _cartRx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomAppLoading(message: 'Loading your basket...');
          }

          final basketData = snapshot.data;
          final List<dynamic> items = (basketData != null && basketData is Map) ? (basketData['items'] as List? ?? []) : [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80.r,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Add some items from the shop to get started.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: _handleBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                    child: const Text(
                      'Browse Products',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final itemId = item['id']?.toString() ?? '';
                    final details = item['product_details'] ?? {};
                    final productId = details['id'] ?? item['product'] ?? '';
                    final name = details['name'] ?? 'Product';
                    final price = double.tryParse(details['price']?.toString() ?? '0.0') ?? 0.0;
                    final imageUrl = details['thumbnail_url'] ?? details['image_url'] ?? details['image'] ?? 'https://via.placeholder.com/150';
                    final quantity = item['quantity'] as int? ?? 1;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: (imageUrl.toString().startsWith('http'))
                                ? Image.network(
                                    imageUrl,
                                    width: 70.w,
                                    height: 70.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 70.w,
                                      height: 70.w,
                                      color: Colors.green.shade50,
                                      child: const Icon(Icons.eco, size: 36, color: Color(0xFF00694C)),
                                    ),
                                  )
                                : Container(
                                    width: 70.w,
                                    height: 70.w,
                                    color: Colors.green.shade50,
                                    child: const Icon(Icons.eco, size: 36, color: Color(0xFF00694C)),
                                  ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF151E13),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '€${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    // Minus Button
                                    InkWell(
                                      onTap: () {
                                        if (quantity > 1) {
                                          _cartRx.updateQuantity(itemId, quantity - 1);
                                        } else {
                                          _cartRx.removeItem(itemId);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.remove, size: 16),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    // Plus Button
                                    InkWell(
                                      onTap: () {
                                        _cartRx.updateQuantity(itemId, quantity + 1);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _cartRx.removeItem(itemId);
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Bottom Bar Summary
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '€${getSubtotal(items).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF151E13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => const CustomerCheckoutScreen())?.then((_) {
                              _cartRx.fetchBasket();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
