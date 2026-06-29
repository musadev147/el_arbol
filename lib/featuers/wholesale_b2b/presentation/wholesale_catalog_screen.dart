import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'wholesale_cart_state.dart';
import 'wholesale_cart_screen.dart';
import '../../customers/home/presentation/product_details_screen.dart';

class WholesaleProduct {
  final String name;
  final String category;
  final double? wholesalePrice; // Null means no wholesale price is set
  final String unit;
  final String imageUrl;

  WholesaleProduct({
    required this.name,
    required this.category,
    this.wholesalePrice,
    required this.unit,
    required this.imageUrl,
  });

  bool get isRunout => wholesalePrice == null;
}

class WholesaleCatalogScreen extends StatefulWidget {
  const WholesaleCatalogScreen({super.key});

  @override
  State<WholesaleCatalogScreen> createState() => _WholesaleCatalogScreenState();
}

class _WholesaleCatalogScreenState extends State<WholesaleCatalogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<WholesaleProduct> _products = [
    WholesaleProduct(
      name: 'Organic Heirloom Tomatoes',
      category: 'Vegetables',
      wholesalePrice: 2.80,
      unit: 'kg',
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
    ),
    WholesaleProduct(
      name: 'Fresh Haas Avocados',
      category: 'Fruits',
      wholesalePrice: 2.10,
      unit: 'kg',
      imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500&auto=format&fit=crop',
    ),
    WholesaleProduct(
      name: 'Sweet Organic Strawberries',
      category: 'Fruits',
      wholesalePrice: 3.90,
      unit: 'kg',
      imageUrl: 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&auto=format&fit=crop',
    ),
    WholesaleProduct(
      name: 'Artisan Raw Honey',
      category: 'Honey',
      wholesalePrice: 6.20,
      unit: 'pcs',
      imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&auto=format&fit=crop',
    ),
    WholesaleProduct(
      name: 'Fresh Goat Cheese',
      category: 'Dairy',
      wholesalePrice: 4.80,
      unit: 'pcs',
      imageUrl: 'https://images.unsplash.com/photo-1524351199679-46cddf530c04?w=500&auto=format&fit=crop',
    ),
    WholesaleProduct(
      name: 'Sourdough Country Bread',
      category: 'Bakery',
      wholesalePrice: null, // No price set -> Runout
      unit: 'pcs',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop',
    ),
    WholesaleProduct(
      name: 'Conference Pears',
      category: 'Apples & Pears',
      wholesalePrice: 1.40,
      unit: 'kg',
      imageUrl: 'https://images.unsplash.com/photo-1514986888952-8cd320577b68?w=500&auto=format&fit=crop',
    ),
    WholesaleProduct(
      name: 'Cantaloupe Melons',
      category: 'Melons',
      wholesalePrice: null, // No price set -> Runout
      unit: 'pcs',
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    final filteredProducts = _products.where((p) {
      return p.name.toLowerCase().contains(_searchQuery) ||
          p.category.toLowerCase().contains(_searchQuery);
    }).toList();

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
          )
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
              child: GridView.builder(
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
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => ProductDetailsScreen(
                            name: product.name,
                            origin: 'Spain Sourced',
                            price: product.isRunout
                                ? 'Runout'
                                : '€ ${(product.wholesalePrice!).toStringAsFixed(2)} / ${product.unit}',
                            imageUrl: product.imageUrl,
                            category: product.category,
                            description: 'Premium organic B2B crop supply. Sourced directly from certified sustainable farms.',
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
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl,
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
                                  ),
                                ),
                                if (product.isRunout)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
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
                                  product.name,
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
                                  product.category,
                                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.isRunout
                                          ? 'Unavailable'
                                          : '€ ${product.wholesalePrice!.toStringAsFixed(2)} / ${product.unit}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: product.isRunout ? Colors.grey : primaryColor,
                                      ),
                                    ),
                                    if (!product.isRunout)
                                      GestureDetector(
                                        onTap: () {
                                          WholesaleCartState.addToCart(
                                            product.name,
                                            product.wholesalePrice!,
                                            product.unit,
                                            1.0,
                                          );
                                          Get.snackbar(
                                            'Added to Cart',
                                            '${product.name} added to wholesale cart.',
                                            backgroundColor: primaryColor,
                                            colorText: Colors.white,
                                            duration: const Duration(seconds: 1),
                                            snackPosition: SnackPosition.BOTTOM,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
