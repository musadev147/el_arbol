import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rxdart/rxdart.dart';
import 'wholesale_cart_state.dart';
import 'wholesale_cart_screen.dart';
import '../../customers/home/presentation/product_details_screen.dart';
import '../../customers/home/presentation/data/rx.dart';
import '../../customers/home/presentation/model/get_product_model.dart';
import '../../../route/app_pages.dart';

class WholesaleCatalogScreen extends StatefulWidget {
  const WholesaleCatalogScreen({super.key});

  @override
  State<WholesaleCatalogScreen> createState() => _WholesaleCatalogScreenState();
}

class _WholesaleCatalogScreenState extends State<WholesaleCatalogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late final GetProductRx _productRx;

  @override
  void initState() {
    super.initState();
    _productRx = GetProductRx(
      empty: GetProductModel(),
      dataFetcher: BehaviorSubject<GetProductModel>(),
    );
    _productRx.fetchProducts();
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF151E13)),
            onPressed: () => Get.toNamed(Routes.WHOLESALE_NOTIFICATIONS_SCREEN),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF151E13)),
                onPressed: () => Get.to(() => const WholesaleCartScreen()),
              ),
              Obx(() {
                if (WholesaleCartState.cartItems.isEmpty) return const SizedBox();
                return Positioned(
                  right: 6.w,
                  top: 6.h,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                    child: Text(
                      '${WholesaleCartState.cartItems.length}',
                      style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              })
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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

            // Products Grid
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: _productRx.valueStreamData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryColor));
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load products list'));
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

                  // Filter by query
                  final filteredProducts = products.where((p) {
                    final name = (p.name ?? '').toLowerCase();
                    final catName = (p.category?.name ?? '').toLowerCase();
                    return name.contains(_searchQuery) || catName.contains(_searchQuery);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found matching your search.',
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
                      final isRunout = wholesalePriceVal == null;

                      final displayPrice = isRunout 
                          ? 'Runout' 
                          : '€ ${wholesalePriceVal.toStringAsFixed(2)} / ${product.wholesaleUnit ?? product.unit ?? 'unit'}';

                      final imageUrl = product.thumbnailUrl ?? '';

                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ProductDetailsScreen(
                                id: product.id,
                                name: product.name ?? '',
                                origin: product.origin ?? 'Spain Sourced',
                                price: displayPrice,
                                imageUrl: imageUrl,
                                category: product.category?.name ?? '',
                                description: product.description ?? 'Premium organic B2B crop supply. Sourced directly from certified sustainable farms.',
                                isWholesale: true,
                                wholesaleUnit: product.wholesaleUnit ?? product.unit ?? 'unit',
                                minPurchase: product.minimumPurchase ?? 1,
                              ));
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
                              // Image Container with Runout overlay
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                                      child: imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                color: Colors.grey.shade100,
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00694C)),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                color: Colors.grey.shade100,
                                                child: const Icon(Icons.grass, color: Color(0xFF00694C), size: 30),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey.shade100,
                                              child: const Icon(Icons.grass, color: Color(0xFF00694C), size: 30),
                                            ),
                                    ),
                                    if (isRunout)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.55),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                                        ),
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                          child: Text(
                                            'Runout',
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
                                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
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
                                              final minQty = product.minimumPurchase ?? 1;
                                              WholesaleCartState.addToCart(
                                                id: product.id ?? '',
                                                name: product.name ?? '',
                                                price: wholesalePriceVal,
                                                unit: product.wholesaleUnit ?? product.unit ?? 'unit',
                                                imageUrl: imageUrl,
                                                minPurchase: minQty,
                                                stock: product.stock,
                                                qty: minQty.toDouble(),
                                              );
                                              Get.snackbar(
                                                'Added to Cart',
                                                '${product.name} added to wholesale cart.',
                                                backgroundColor: primaryColor,
                                                colorText: Colors.white,
                                                duration: const Duration(seconds: 2),
                                                snackPosition: SnackPosition.BOTTOM,
                                                mainButton: TextButton(
                                                  onPressed: () => Get.to(() => const WholesaleCartScreen()),
                                                  child: const Text(
                                                    'VIEW CART',
                                                    style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(6.r),
                                              decoration: const BoxDecoration(
                                                color: primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.add, color: Colors.white, size: 14),
                                            ),
                                          )
                                      ],
                                    )
                                  ],
                                ),
                              )
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(Routes.WHOLESALE_ADD_PRODUCT);
          if (result == true) {
            _productRx.fetchProducts();
          }
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
