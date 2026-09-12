import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/app_shimmer.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../constants/app_assets/assets_icons.dart';
import '../../../../constants/app_colors.dart';
import 'wholesale_cart_state.dart';
import 'wholesale_cart_screen.dart';
import '../data/wholesale_rx.dart';
import '../../customers/home/presentation/product_details_screen.dart';
import '../../customers/home/presentation/data/rx.dart';
import '../../customers/home/presentation/model/get_product_model.dart';
import '../../customers/home/presentation/model/get_category_model.dart';
import '../../../route/app_pages.dart';
import 'package:el_arbol/helpers/di.dart';

class WholesaleCatalogScreen extends StatefulWidget {
  const WholesaleCatalogScreen({super.key});

  @override
  State<WholesaleCatalogScreen> createState() => _WholesaleCatalogScreenState();
}

class _WholesaleCatalogScreenState extends State<WholesaleCatalogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  late final GetProductRx _productRx;
  late final GetCategoryRx _categoryRx;
  late final WholesaleNotificationsRx _notificationsRx;

  @override
  void initState() {
    super.initState();
    _productRx = GetProductRx(
      empty: GetProductModel(),
      dataFetcher: BehaviorSubject<GetProductModel>(),
    );
    _productRx.fetchProducts();

    _categoryRx = GetCategoryRx(
      empty: GetCategoryModel(),
      dataFetcher: BehaviorSubject<GetCategoryModel>(),
    );
    _categoryRx.fetchCategories();

    _notificationsRx = WholesaleNotificationsRx(
      empty: {},
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _notificationsRx.fetchNotifications();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _productRx.dispose();
    _categoryRx.dispose();
    _notificationsRx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'B2B Wholesale Catalog',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Notification Icon with Unread Badge
          StreamBuilder<dynamic>(
            stream: _notificationsRx.valueStreamData,
            builder: (context, notifSnapshot) {
              int unreadCount = 0;
              final data = notifSnapshot.data;
              if (data is Map && data['unread_count'] is int) {
                unreadCount = data['unread_count'];
              } else if (data is Map && data['results'] is List) {
                unreadCount = (data['results'] as List).where((n) => n['is_read'] != true && n['read'] != true).length;
              } else if (data is List) {
                unreadCount = data.where((n) => n['is_read'] != true && n['read'] != true).length;
              }
              try {
                final localNotifs = appData.read('wholesale_local_notifications');
                if (localNotifs is List) {
                  unreadCount += localNotifs.where((n) => n['is_read'] != true).length;
                }
              } catch (_) {}

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF151E13),
                    ),
                    onPressed: () async {
                      await Get.toNamed(Routes.WHOLESALE_NOTIFICATIONS_SCREEN);
                      _notificationsRx.fetchNotifications();
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8.w,
                      top: 8.h,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.h,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF151E13),
                ),
                onPressed: () => Get.to(() => const WholesaleCartScreen()),
              ),
              Obx(() {
                if (WholesaleCartState.cartItems.isEmpty) return const SizedBox();
                return Positioned(
                  right: 6.w,
                  top: 6.h,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.h,
                    ),
                    child: Text(
                      '${WholesaleCartState.cartItems.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search wholesale products...',
                  hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ),

            // Category Section (Task 10)
            StreamBuilder<dynamic>(
              stream: _categoryRx.valueStreamData,
              builder: (context, catSnapshot) {
                final GetCategoryModel? catModel = catSnapshot.data;
                final List<String> categories = ['All'];
                if (catModel?.results != null) {
                  for (final c in catModel!.results!) {
                    final name = c.name?.trim();
                    if (name != null && name.isNotEmpty && !categories.contains(name)) {
                      categories.add(name);
                    }
                  }
                }

                return Container(
                  height: 38.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, idx) {
                      final cat = categories[idx];
                      final isSelected = _selectedCategory == cat;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade200,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF151E13),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Products Grid
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: _productRx.valueStreamData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomAppLoading.grid(message: 'Loading catalog products...');
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Failed to load products list'),
                    );
                  }

                  final GetProductModel? model = snapshot.data;
                  final List<Results> products = model?.results ?? [];

                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found.',
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    );
                  }

                  // Filter by search query and category
                  final filteredProducts = products.where((p) {
                    final name = (p.name ?? '').toLowerCase();
                    final catName = (p.category?.name ?? '').toLowerCase();
                    final matchesSearch = _searchQuery.isEmpty ||
                        name.contains(_searchQuery) ||
                        catName.contains(_searchQuery);

                    final matchesCat = _selectedCategory == 'All' ||
                        catName.toLowerCase() == _selectedCategory.toLowerCase();

                    return matchesSearch && matchesCat;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found in this category.',
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 6.h,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final wholesalePriceVal = product.wholesalePrice != null
                          ? double.tryParse(product.wholesalePrice!)
                          : null;
                      final isRunout = wholesalePriceVal == null || (product.stock != null && product.stock! <= 0);

                      final displayPrice = isRunout
                          ? 'Stock Out'
                          : '€ ${wholesalePriceVal.toStringAsFixed(2)} / ${product.wholesaleUnit ?? product.unit ?? 'unit'}';

                      final imageUrl = product.thumbnailUrl ?? '';
                      final List<String> extractedImages = [];
                      if (product.thumbnailUrl != null) {
                        extractedImages.add(product.thumbnailUrl!);
                      }
                      if (product.additionalImages != null) {
                        extractedImages.addAll(
                          product.additionalImages!
                              .map((i) => i.image)
                              .whereType<String>(),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => ProductDetailsScreen(
                              id: product.id,
                              name: product.name ?? '',
                              origin: product.origin ?? 'Spain Sourced',
                              price: displayPrice,
                              imageUrl: imageUrl,
                              images: extractedImages,
                              category: product.category?.name ?? '',
                              description: product.description ??
                                  'Premium organic B2B crop supply. Sourced directly from certified sustainable farms.',
                              isWholesale: true,
                              wholesaleUnit: product.wholesaleUnit ?? product.unit ?? 'unit',
                              minPurchase: product.minimumPurchase ?? 1,
                              stock: product.stock,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Container with Stock Out overlay
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(14.r),
                                      ),
                                      child: imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.cover,
                                              memCacheWidth: 300,
                                              memCacheHeight: 300,
                                              maxWidthDiskCache: 600,
                                              maxHeightDiskCache: 600,
                                              fadeInDuration: const Duration(milliseconds: 100),
                                              fadeOutDuration: const Duration(milliseconds: 100),
                                              placeholder: (context, url) => AppShimmer.box(
                                                width: double.infinity,
                                                height: double.infinity,
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                color: Colors.grey.shade100,
                                                padding: EdgeInsets.all(12.r),
                                                child: Center(
                                                  child: Image.asset(
                                                    AssetsIcons.logoIcons,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: primaryColor, size: 28),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey.shade100,
                                              padding: EdgeInsets.all(12.r),
                                              child: Center(
                                                child: Image.asset(
                                                  AssetsIcons.logoIcons,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: primaryColor, size: 28),
                                                ),
                                              ),
                                            ),
                                    ),
                                    if (isRunout)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(14.r),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                          child: Text(
                                            'Stock Out',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Details
                              Padding(
                                padding: EdgeInsets.all(12.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF151E13),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      product.category?.name ?? '',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            displayPrice,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isRunout ? Colors.grey : primaryColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (!isRunout)
                                          GestureDetector(
                                            onTap: () {
                                              if (product.stock != null && product.stock! <= 0) {
                                                AppToast.error("${product.name} is currently out of stock.");
                                                return;
                                              }
                                              final minQty = product.minimumPurchase ?? 1;
                                              final added = WholesaleCartState.addToCart(
                                                id: product.id ?? '',
                                                name: product.name ?? '',
                                                price: wholesalePriceVal,
                                                unit: (product.wholesaleUnit ?? product.unit) ?? 'unit',
                                                imageUrl: imageUrl,
                                                minPurchase: minQty,
                                                stock: product.stock,
                                                qty: minQty.toDouble(),
                                              );
                                              if (added) {
                                                Get.snackbar(
                                                  'Added to Cart',
                                                  '${product.name} ($minQty) added to wholesale cart.',
                                                  backgroundColor: primaryColor,
                                                  colorText: Colors.white,
                                                  duration: const Duration(seconds: 2),
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  mainButton: TextButton(
                                                    onPressed: () => Get.to(() => const WholesaleCartScreen()),
                                                    child: const Text(
                                                      'VIEW CART',
                                                      style: TextStyle(
                                                        color: AppColors.accentOrange,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(6.r),
                                              decoration: BoxDecoration(
                                                color: AppColors.accentOrange.withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.add_shopping_cart,
                                                color: AppColors.accentOrange,
                                                size: 18,
                                              ),
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
