import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import 'package:el_arbol/constants/app_assets/assets_icons.dart';
import 'wholesale_cart_state.dart';
import 'wholesale_checkout_screen.dart';

class WholesaleCartScreen extends StatelessWidget {
  const WholesaleCartScreen({super.key});

  void _showRemoveConfirmDialog(BuildContext context, WholesaleCartItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Remove Product'),
        content: Text('Remove "${item.name}" from your wholesale cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              WholesaleCartState.removeFromCart(item.id.isNotEmpty ? item.id : item.name);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Clear Wholesale Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              WholesaleCartState.clear();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
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
          'Wholesale Bulk Cart',
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
          Obx(() {
            if (WholesaleCartState.cartItems.isEmpty) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: 'Clear Cart',
              onPressed: () => _showClearConfirmDialog(context),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (WholesaleCartState.cartItems.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90.r,
                      height: 90.r,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_cart_outlined, size: 48.r, color: primaryColor),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Wholesale cart is empty',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF151E13),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Explore our B2B catalog and add sustainable organic crops and products in bulk.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp, height: 1.3),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.storefront_outlined, color: Colors.white, size: 18),
                      label: const Text('Browse Wholesale Catalog', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Items count header banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                color: primaryColor.withValues(alpha: 0.06),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: primaryColor, size: 16),
                    SizedBox(width: 8.w),
                    Text(
                      '${WholesaleCartState.cartItems.length} product lines (${WholesaleCartState.totalItemCount} total units)',
                      style: TextStyle(fontSize: 12.sp, color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: WholesaleCartState.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = WholesaleCartState.cartItems[index];
                    final imageUrl = item.imageUrl ?? '';

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 60.w,
                                    height: 60.w,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey.shade100,
                                      width: 60.w,
                                      height: 60.w,
                                      padding: EdgeInsets.all(8.r),
                                      child: Image.asset(
                                        AssetsIcons.logoIcons,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: primaryColor, size: 28),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey.shade100,
                                    width: 60.w,
                                    height: 60.w,
                                    padding: EdgeInsets.all(8.r),
                                    child: Image.asset(
                                      AssetsIcons.logoIcons,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: primaryColor, size: 28),
                                    ),
                                  ),
                          ),
                          SizedBox(width: 12.w),

                          // Info & Stepper
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF151E13),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                                      onPressed: () => _showRemoveConfirmDialog(context, item),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '€ ${item.wholesalePrice.toStringAsFixed(2)} / ${item.unit}',
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                ),
                                if (item.stock != null && item.stock! <= 0) ...[
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'Out of stock (Available: 0)',
                                      style: TextStyle(fontSize: 10.sp, color: Colors.red.shade800, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ] else if (item.minPurchase > 1) ...[
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'Min order: ${item.minPurchase} ${item.unit}',
                                      style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade800, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                                SizedBox(height: 10.h),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Stepper
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.all(4.r),
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.remove, size: 16, color: Colors.black87),
                                            onPressed: () {
                                              if (item.quantity.value <= 1) {
                                                _showRemoveConfirmDialog(context, item);
                                              } else {
                                                WholesaleCartState.updateQuantity(
                                                  item.id.isNotEmpty ? item.id : item.name,
                                                  item.quantity.value - 1,
                                                );
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                                            child: Obx(() => Text(
                                              '${item.quantity.value.toInt()}',
                                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                                            )),
                                          ),
                                          Obx(() {
                                            final bool canAddMore = item.stock == null || item.quantity.value < item.stock!;
                                            return IconButton(
                                              padding: EdgeInsets.all(4.r),
                                              constraints: const BoxConstraints(),
                                              icon: Icon(
                                                Icons.add,
                                                size: 16,
                                                color: canAddMore ? primaryColor : Colors.grey.shade400,
                                              ),
                                              onPressed: canAddMore
                                                  ? () {
                                                      WholesaleCartState.updateQuantity(
                                                        item.id.isNotEmpty ? item.id : item.name,
                                                        item.quantity.value + 1,
                                                      );
                                                    }
                                                  : null,
                                            );
                                          }),
                                        ],
                                      ),
                                    ),

                                    // Line total
                                    Obx(() => Text(
                                      '€ ${item.subtotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Summary & Checkout Button
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Bulk Amount',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                            Text(
                              'Excl. VAT / Freight',
                              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                        Text(
                          '€ ${WholesaleCartState.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20.sp,
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
                      child: ElevatedButton.icon(
                        onPressed: () {
                          for (final it in WholesaleCartState.cartItems) {
                            if (it.stock != null && it.stock! <= 0) {
                              AppToast.error("'${it.name}' is out of stock (Available: 0). Please remove it to proceed.");
                              return;
                            }
                            if (it.stock != null && it.quantity.value > it.stock!) {
                              AppToast.error("Requested quantity for '${it.name}' exceeds available stock (${it.stock}).");
                              return;
                            }
                          }
                          Get.to(() => const WholesaleCheckoutScreen());
                        },
                        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        label: Text(
                          'Proceed to B2B Checkout',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          elevation: 0,
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
