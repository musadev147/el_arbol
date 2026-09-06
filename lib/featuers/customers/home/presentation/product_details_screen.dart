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
import '../../../../constants/app_assets/assets_icons.dart';
import '../../../../constants/app_colors.dart';
import 'model/post_wishlist_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? id;
  final String name;
  final String origin;
  final String price;
  final String imageUrl;
  final List<String>? images;
  final String description;
  final String category;
  final bool isWholesale;
  final String? wholesaleUnit;
  final int? minPurchase;
  final bool isStaff;
  final bool showBasket;

  const ProductDetailsScreen({
    super.key,
    this.id,
    required this.name,
    required this.origin,
    required this.price,
    required this.imageUrl,
    this.images,
    this.description = 'This artisan product is sourced directly from local farms. Produced with organic and sustainable methods, ensuring the highest quality, flavor, and freshness.',
    this.category = 'Fresh Produce',
    this.isWholesale = false,
    this.wholesaleUnit,
    this.minPurchase,
    this.stock,
    this.isStaff = false,
    this.showBasket = true,
  });

  final int? stock;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _isAddingToBasket = false;
  late final WishlistRx? _wishlistRx;
  
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  List<String> _allImages = [];

  @override
  void initState() {
    super.initState();
    final minQty = widget.minPurchase ?? 1;
    if (widget.stock != null && widget.stock! > 0 && minQty > widget.stock!) {
      _quantity = widget.stock!;
    } else {
      _quantity = minQty;
    }
    try {
      _wishlistRx = Get.find<WishlistRx>();
    } catch (_) {
      _wishlistRx = null;
    }
    
    _buildImagesList();
  }
  
  void _buildImagesList() {
    final list = <String>[];
    if (widget.images != null && widget.images!.isNotEmpty) {
      for (var img in widget.images!) {
        if (img.trim().isNotEmpty && !list.contains(img.trim())) {
          list.add(img.trim());
        }
      }
    }
    if (widget.imageUrl.trim().isNotEmpty && !list.contains(widget.imageUrl.trim())) {
      list.insert(0, widget.imageUrl.trim());
    }
    if (list.isEmpty) {
      list.add(widget.imageUrl);
    }
    _allImages = list;
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            expandedHeight: _allImages.length > 1 ? 400.h : 350.h,
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
              Builder(
                builder: (context) {
                  final rx = _wishlistRx;
                  if (widget.isStaff || widget.id == null || rx == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 16.w, top: 8.h),
                    child: StreamBuilder<List<PostCreateWishlistModel>>(
                      stream: rx.valueStreamData,
                      builder: (context, snapshot) {
                        final isWish = rx.isWishlisted(widget.id);

                        return CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(
                              isWish ? Icons.favorite : Icons.favorite_border_rounded,
                              color: isWish ? Colors.red : const Color(0xFF151E13),
                            ),
                            onPressed: () {
                              if (isWish) {
                                rx.removeItem(widget.id!);
                              } else {
                                rx.addItem(widget.id!);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _allImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: _allImages[index],
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        memCacheHeight: 800,
                        maxWidthDiskCache: 1200,
                        maxHeightDiskCache: 1200,
                        fadeInDuration: const Duration(milliseconds: 100),
                        fadeOutDuration: const Duration(milliseconds: 100),
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator(color: primaryBrandColor)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Image.asset(
                              AssetsIcons.logoIcons,
                              width: 60.r,
                              height: 60.r,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 50, color: primaryBrandColor),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_allImages.length > 1)
                    Positioned(
                      bottom: 80.h, // Space for thumbnail strip
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1} / ${_allImages.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_allImages.length > 1)
                    Positioned(
                      bottom: 16.h,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 50.h,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: _allImages.length,
                          separatorBuilder: (context, _) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            final isSelected = index == _currentImageIndex;
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 50.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected ? primaryBrandColor : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: CachedNetworkImage(
                                    imageUrl: _allImages[index],
                                    fit: BoxFit.cover,
                                    memCacheWidth: 150,
                                    memCacheHeight: 150,
                                    fadeInDuration: const Duration(milliseconds: 100),
                                    fadeOutDuration: const Duration(milliseconds: 100),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
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
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentOrange,
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
                  if (widget.showBasket) ...[
                    SizedBox(height: 24.h),

                    // Quantity Selector Section
                    Builder(
                      builder: (context) {
                        final int minAllowed = widget.minPurchase ?? 1;
                        final bool isOutOfStock = widget.stock != null && widget.stock! <= 0;
                        final bool canDecrement = !isOutOfStock && _quantity > minAllowed;
                        final bool canIncrement = !isOutOfStock && (widget.stock == null || _quantity < widget.stock!);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    if (widget.minPurchase != null && widget.minPurchase! > 1)
                                      Text(
                                        'Min order: ${widget.minPurchase}',
                                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                                      ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: canDecrement
                                            ? () {
                                                setState(() {
                                                  _quantity--;
                                                });
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.remove,
                                          color: canDecrement ? const Color(0xFF151E13) : Colors.grey.shade400,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                                        child: Text(
                                          '$_quantity',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isOutOfStock ? Colors.grey : const Color(0xFF151E13),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: canIncrement
                                            ? () {
                                                setState(() {
                                                  _quantity++;
                                                });
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.add,
                                          color: canIncrement ? const Color(0xFF151E13) : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (widget.stock != null) ...[
                              SizedBox(height: 6.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  widget.stock! <= 0
                                      ? 'Stock Out (0 available)'
                                      : (_quantity >= widget.stock!
                                          ? 'Maximum stock reached (${widget.stock} in stock)'
                                          : 'Available in stock: ${widget.stock}'),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: widget.stock! <= 0
                                        ? Colors.red
                                        : (_quantity >= widget.stock! ? Colors.orange.shade800 : Colors.grey.shade600),
                                    fontWeight: _quantity >= widget.stock! ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 28.h),

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

                                // 1. If Wholesale product / mode -> Use WholesaleCartState
                                if (widget.isWholesale) {
                                  final double? priceVal = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), ''));
                                  WholesaleCartState.addToCart(
                                    id: widget.id ?? '',
                                    name: widget.name,
                                    price: priceVal ?? 0.0,
                                    unit: widget.wholesaleUnit ?? 'unit',
                                    imageUrl: widget.imageUrl,
                                    minPurchase: widget.minPurchase ?? 1,
                                    stock: widget.stock,
                                    qty: _quantity.toDouble(),
                                  );
                                  success = true;
                                } else if (widget.id != null && widget.id!.isNotEmpty) {
                                  // 2. Normal customer / staff -> backend Basket API
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
                                        style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                } else {
                                  AppToast.error(errorMsg.isNotEmpty ? errorMsg : "Failed to add to basket. Please try again.");
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (widget.stock != null && widget.stock! <= 0) ? Colors.grey : primaryBrandColor,
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
                                  Icon((widget.stock != null && widget.stock! <= 0) ? Icons.block : Icons.shopping_basket, color: Colors.white),
                                  SizedBox(width: 12.w),
                                  Text(
                                    (widget.stock != null && widget.stock! <= 0) ? 'Out of Stock' : 'Add to Basket',
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
                  ],
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
