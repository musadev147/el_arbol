import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_wigdets/app_toast.dart';
import '../../orders/data/customer_orders_api.dart';
import '../../orders/presentation/customer_cart_screen.dart';
import '../../wishlist/presentation/data/rx.dart';
import '../../../wholesale_b2b/presentation/wholesale_cart_screen.dart';
import '../../../wholesale_b2b/presentation/wholesale_cart_state.dart';
import 'model/post_wishlist_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? id;
  final String name;
  final String origin;
  final String price;
  final String imageUrl;
  final String description;
  final String category;
  final bool isWholesale;
  final String? wholesaleUnit;
  final int? minPurchase;

  const ProductDetailsScreen({
    super.key,
    this.id,
    required this.name,
    required this.origin,
    required this.price,
    required this.imageUrl,
    this.description = 'This artisan product is sourced directly from local farms. Produced with organic and sustainable methods, ensuring the highest quality, flavor, and freshness.',
    this.category = 'Fresh Produce',
    this.isWholesale = false,
    this.wholesaleUnit,
    this.minPurchase,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _isAddingToBasket = false;
  late final WishlistRx? _wishlistRx;

  @override
  void initState() {
    super.initState();
    if (widget.minPurchase != null && widget.minPurchase! > 1) {
      _quantity = widget.minPurchase!;
    }
    try {
      _wishlistRx = Get.find<WishlistRx>();
    } catch (_) {
      _wishlistRx = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrandColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: CustomScrollView(
        slivers: [
          // Premium Sliver App Bar with Image
          SliverAppBar(
            expandedHeight: 350.h,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(left: 16.w, top: 8.h),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            actions: [
              if (widget.id != null && _wishlistRx != null)
                Padding(
                  padding: EdgeInsets.only(right: 16.w, top: 8.h),
                  child: StreamBuilder<List<PostCreateWishlistModel>>(
                    stream: _wishlistRx.valueStreamData,
                    builder: (context, snapshot) {
                      final isWish = _wishlistRx.isWishlisted(widget.id);

                      return CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isWish ? Icons.favorite : Icons.favorite_border_rounded,
                            color: isWish ? Colors.red : const Color(0xFF151E13),
                          ),
                          onPressed: () {
                            if (isWish) {
                              _wishlistRx.removeItem(widget.id!);
                            } else {
                              _wishlistRx.addItem(widget.id!);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator(color: primaryBrandColor)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.grass, size: 60, color: primaryBrandColor),
                ),
              ),
            ),
          ),

          // Content Details Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: primaryBrandColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      widget.category.toUpperCase(),
                      style: TextStyle(
                        color: primaryBrandColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Title and Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF151E13),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'from ${widget.origin}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF6D7A73),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.price,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Divider
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  SizedBox(height: 16.h),

                  // Description
                  Text(
                    'About this Product',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6D7A73),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Quantity Selector Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF151E13),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove, color: Color(0xFF151E13)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text(
                                '$_quantity',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF151E13),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              icon: const Icon(Icons.add, color: Color(0xFF151E13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Add To Basket Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _isAddingToBasket
                          ? null
                          : () async {
                              setState(() {
                                _isAddingToBasket = true;
                              });

                              bool success = false;
                              String errorMsg = '';

                              // 1. If product has ID, invoke the backend Basket API
                              if (widget.id != null && widget.id!.isNotEmpty) {
                                try {
                                  await EasyLoading.show(status: 'Adding to basket...');
                                  await CustomerOrdersApi.instance.addBasketItem(widget.id!, _quantity);
                                  success = true;
                                } catch (e) {
                                  if (e is DioException && e.response?.data is Map) {
                                    final data = e.response!.data as Map;
                                    errorMsg = data['message']?.toString() ?? data['detail']?.toString() ?? '';
                                  }
                                } finally {
                                  EasyLoading.dismiss();
                                }
                              } else {
                                // If id was not provided, still allow adding
                                success = true;
                              }

                              // 2. If Wholesale product / mode
                              if (widget.isWholesale) {
                                final double? priceVal = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), ''));
                                WholesaleCartState.addToCart(
                                  id: widget.id ?? '',
                                  name: widget.name,
                                  price: priceVal ?? 0.0,
                                  unit: widget.wholesaleUnit ?? 'unit',
                                  imageUrl: widget.imageUrl,
                                  minPurchase: widget.minPurchase ?? 1,
                                  qty: _quantity.toDouble(),
                                );
                                success = true;
                              }

                              setState(() {
                                _isAddingToBasket = false;
                              });

                              if (success) {
                                Get.back();
                                Get.snackbar(
                                  'Added to Basket',
                                  '${widget.name} ($_quantity) added to your basket.',
                                  backgroundColor: primaryBrandColor,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: EdgeInsets.all(16.w),
                                  duration: const Duration(seconds: 3),
                                  mainButton: TextButton(
                                    onPressed: () {
                                      if (widget.isWholesale) {
                                        Get.to(() => const WholesaleCartScreen());
                                      } else {
                                        Get.to(() => CustomerCartScreen(cartItems: RxList<Map<String, dynamic>>([])));
                                      }
                                    },
                                    child: const Text(
                                      'VIEW BASKET',
                                      style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              } else {
                                AppToast.error(errorMsg.isNotEmpty ? errorMsg : "Failed to add to basket. Please try again.");
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrandColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: _isAddingToBasket
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_basket, color: Colors.white),
                                SizedBox(width: 12.w),
                                Text(
                                  'Add to Basket',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
