import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../../customers/home/presentation/data/rx.dart';
import '../../customers/home/presentation/model/get_product_model.dart';
import '../../customers/home/presentation/product_details_screen.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final GetProductRx _productRx = GetProductRx(
    empty: GetProductModel(),
    dataFetcher: BehaviorSubject<GetProductModel>(),
  );

  @override
  void initState() {
    super.initState();
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
        title: Text(
          'Product Price List',
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF151E13)),
            onPressed: () => _productRx.fetchProducts(),
          ),
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
                  hintText: 'Search products, origin, or category...',
                  hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
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

            // Product List
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: _productRx.valueStreamData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomAppLoading(message: 'Loading product price list...');
                  }

                  if (snapshot.hasError) {
                    return NoInternetOrDataWidget(
                      title: 'Failed to Load Products',
                      message: 'Could not fetch the product price list. Please check your internet connection.',
                      onRetry: () => _productRx.fetchProducts(),
                    );
                  }

                  final GetProductModel? model = snapshot.data;
                  final List<Results> products = model?.results ?? [];

                  if (products.isEmpty) {
                    return NoInternetOrDataWidget(
                      title: 'No Products Available',
                      message: 'There are currently no products in the price list catalog.',
                      onRetry: () => _productRx.fetchProducts(),
                    );
                  }

                  // Sort A-Z by name
                  final sortedProducts = List<Results>.from(products)
                    ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

                  // Filter by query
                  final filteredProducts = sortedProducts.where((p) {
                    final name = (p.name ?? '').toLowerCase();
                    final catName = (p.category?.name ?? '').toLowerCase();
                    final origin = (p.origin ?? '').toLowerCase();
                    return name.contains(_searchQuery) ||
                        catName.contains(_searchQuery) ||
                        origin.contains(_searchQuery);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found matching your search.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () async {
                      await _productRx.fetchProducts();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final displayPrice = product.price != null 
                            ? '€${product.price} / ${product.unit ?? 'unit'}' 
                            : (product.wholesalePrice != null ? '€${product.wholesalePrice} / ${product.wholesaleUnit ?? 'unit'}' : 'N/A');

                        final imageUrl = product.thumbnailUrl ?? '';
                        final List<String> extractedImages = [];
                        if (product.thumbnailUrl != null) extractedImages.add(product.thumbnailUrl!);
                        if (product.additionalImages != null) {
                          extractedImages.addAll(
                            product.additionalImages!.map((i) => i.image).whereType<String>(),
                          );
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14.r),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14.r),
                              onTap: () {
                                Get.to(() => ProductDetailsScreen(
                                  id: product.id,
                                  name: product.name ?? '',
                                  origin: product.origin ?? 'Spain Sourced',
                                  price: displayPrice,
                                  imageUrl: imageUrl,
                                  images: extractedImages,
                                  category: product.category?.name ?? 'Fresh Produce',
                                  description: product.description ??
                                      'Premium fresh produce. Sourced directly from certified sustainable farms.',
                                  isStaff: true,
                                  showBasket: false,
                                ));
                              },
                              child: Padding(
                                padding: EdgeInsets.all(12.r),
                                child: Row(
                                  children: [
                                    // Product Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Container(
                                        width: 58.r,
                                        height: 58.r,
                                        color: Colors.grey.shade50,
                                        child: imageUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.cover,
                                                memCacheWidth: 150,
                                                memCacheHeight: 150,
                                                fadeInDuration: const Duration(milliseconds: 100),
                                                placeholder: (context, url) => Center(
                                                  child: SizedBox(
                                                    width: 18.r,
                                                    height: 18.r,
                                                    child: const CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) => const Icon(
                                                  Icons.grass,
                                                  color: primaryColor,
                                                  size: 26,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.grass,
                                                color: primaryColor,
                                                size: 26,
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),

                                    // Product Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF151E13),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              if (product.category?.name != null) ...[
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(4.r),
                                                  ),
                                                  child: Text(
                                                    product.category!.name!,
                                                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(width: 6.w),
                                              ],
                                              Expanded(
                                                child: Text(
                                                  'Origin: ${product.origin ?? 'N/A'}',
                                                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),

                                    // Price & Arrow
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          displayPrice,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey.shade400,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}
