import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:el_arbol/common_wigdets/custom_navigation.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import 'package:el_arbol/common_wigdets/user_role.dart';
import '../../../../constants/app_assets/assets_icons.dart';
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
      Get.offAll(() => const CustomNavigation(role: UserRole.customer, initialIndex: 0));
    }
  }

  double _extractFinalPrice(dynamic item) {
    if (item == null) return 0.0;
    final details = (item is Map && item['product_details'] is Map)
        ? Map<String, dynamic>.from(item['product_details'])
        : (item is Map && item['product'] is Map)
            ? Map<String, dynamic>.from(item['product'])
            : (item is Map) ? Map<String, dynamic>.from(item) : <String, dynamic>{};

    final double discountPrice = double.tryParse(
      details['discount_price']?.toString() ??
      details['discountPrice']?.toString() ??
      details['sale_price']?.toString() ??
      details['sell_price']?.toString() ??
      (item is Map ? (item['discount_price']?.toString() ?? item['discountPrice']?.toString()) : null) ??
      ''
    ) ?? 0.0;

    if (discountPrice > 0) return discountPrice;

    final double regularPrice = double.tryParse(
      details['price']?.toString() ??
      details['regular_price']?.toString() ??
      (item is Map ? (item['price']?.toString() ?? item['unit_price']?.toString() ?? item['product_price']?.toString()) : null) ??
      '0.0'
    ) ?? 0.0;

    return regularPrice;
  }

  double _extractOriginalPrice(dynamic item) {
    if (item == null) return 0.0;
    final details = (item is Map && item['product_details'] is Map)
        ? Map<String, dynamic>.from(item['product_details'])
        : (item is Map && item['product'] is Map)
            ? Map<String, dynamic>.from(item['product'])
            : (item is Map) ? Map<String, dynamic>.from(item) : <String, dynamic>{};

    return double.tryParse(
      details['price']?.toString() ??
      details['regular_price']?.toString() ??
      details['original_price']?.toString() ??
      details['originalPrice']?.toString() ??
      (item is Map ? (item['original_price']?.toString() ?? item['price']?.toString()) : null) ??
      '0.0'
    ) ?? 0.0;
  }

  double getSubtotal(List<dynamic> items) {
    double sum = 0.0;
    for (var item in items) {
      final price = _extractFinalPrice(item);
      final quantity = (item is Map && item['quantity'] is int)
          ? (item['quantity'] as int)
          : (int.tryParse(item is Map ? (item['quantity']?.toString() ?? '1') : '1') ?? 1);
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
                    final name = details['name'] ?? 'Product';
                    final price = _extractFinalPrice(item);
                    final originalPrice = _extractOriginalPrice(item);
                    final bool onSale = originalPrice > price && price > 0;
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
                            color: Colors.black.withValues(alpha: 0.01),
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
                                      padding: EdgeInsets.all(12.r),
                                      child: Image.asset(AssetsIcons.logoIcons, fit: BoxFit.contain),
                                    ),
                                  )
                                : Container(
                                    width: 70.w,
                                    height: 70.w,
                                    color: Colors.green.shade50,
                                    padding: EdgeInsets.all(12.r),
                                    child: Image.asset(AssetsIcons.logoIcons, fit: BoxFit.contain),
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '€${price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                    if (onSale) ...[
                                      SizedBox(width: 6.w),
                                      Text(
                                        '€${originalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
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
