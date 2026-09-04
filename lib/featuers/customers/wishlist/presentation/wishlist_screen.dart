import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../home/presentation/product_details_screen.dart';
import '../../home/presentation/model/post_wishlist_model.dart';
import 'data/rx.dart';

/// Premium screen displaying user wishlisted items.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late final WishlistRx _wishlistRx;

  @override
  void initState() {
    super.initState();
    _wishlistRx = Get.find<WishlistRx>();
    _wishlistRx.fetchWishlist();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF151E13)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<PostCreateWishlistModel>>(
          stream: _wishlistRx.valueStreamData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && (!snapshot.hasData || snapshot.data!.isEmpty)) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: primaryColor,
                          size: 72.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Your Wishlist is Empty',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF151E13),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Explore our store and tap the heart icon on your favorite organic items to save them here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6D7A73),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Explore Shop',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final product = item.product;
                if (product == null) return const SizedBox.shrink();

                return _buildWishlistCard(context, item, product, primaryColor);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWishlistCard(
    BuildContext context,
    PostCreateWishlistModel item,
    Product product,
    Color primaryColor,
  ) {
    final double originalPrice = double.tryParse(product.price ?? '') ?? 0.0;
    final double discountPrice = double.tryParse(product.discountPrice ?? '') ?? 0.0;
    final double finalPrice = (discountPrice > 0) ? discountPrice : originalPrice;
    final bool onSale = discountPrice > 0;
    
    final List<String> extractedImages = [];
    if (product.thumbnailUrl != null) extractedImages.add(product.thumbnailUrl!);
    if (product.additionalImages != null) {
      extractedImages.addAll(
          product.additionalImages!.map((i) => i.image).whereType<String>());
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailsScreen(
              id: product.id?.toString(),
              name: product.name ?? '',
              origin: product.origin ?? 'Unknown',
              price: '€${finalPrice.toStringAsFixed(2)}',
              imageUrl: product.thumbnailUrl ?? 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
              images: extractedImages,
              description: product.description ?? '',
              category: product.category?.name ?? 'All',
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with remove button
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnailUrl ?? 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(color: Colors.grey[100]),
                      errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  // Badges
                  if (product.badge != null && product.badge!.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00694C),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          product.badge!,
                          style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Remove button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        if (product.id != null) {
                          _wishlistRx.removeItem(product.id!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Product Name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    product.origin ?? 'Origin',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '€${finalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: primaryColor,
                            ),
                          ),
                          if (onSale) ...[
                            SizedBox(width: 4.w),
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
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
