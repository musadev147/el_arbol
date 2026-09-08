import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/app_shimmer.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../customers/home/presentation/data/rx.dart';
import '../../customers/home/presentation/model/get_product_model.dart';
import '../../customers/home/presentation/product_details_screen.dart';
import '../../customers/orders/data/customer_orders_rx.dart';
import '../../customers/orders/data/customer_orders_api.dart';
import '../../customers/orders/presentation/customer_cart_screen.dart';
import '../../wholesale_b2b/presentation/wholesale_add_product_screen.dart';
import 'staff_order_history_screen.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortOrder = 'name_asc'; // 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'category'

  final GetProductRx _productRx = GetProductRx(
    empty: GetProductModel(),
    dataFetcher: BehaviorSubject<GetProductModel>(),
  );

  @override
  void initState() {
    super.initState();
    _productRx.fetchProducts();
    CustomerCartRx.instance.fetchBasket();
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

  double _parseProductPrice(Results p) {
    if (p.price != null) {
      return double.tryParse(p.price.toString()) ?? 0.0;
    }
    if (p.wholesalePrice != null) {
      return double.tryParse(p.wholesalePrice.toString()) ?? 0.0;
    }
    return 0.0;
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
          // Add Product button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF151E13)),
            tooltip: 'Add Product',
            onPressed: () => Get.to(() => const WholesaleAddProductScreen())?.then((_) => _productRx.fetchProducts()),
          ),
          // Cart / Basket icon with live item count
          StreamBuilder(
            stream: CustomerCartRx.instance.valueStreamData,
            builder: (context, snapshot) {
              final cartCount = CustomerCartRx.instance.itemCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF151E13)),
                    tooltip: 'Cart',
                    onPressed: () => Get.to(() => CustomerCartScreen(cartItems: RxList<Map<String, dynamic>>([]))),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6.w,
                      top: 6.h,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Order History
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF151E13)),
            tooltip: 'Order History',
            onPressed: () => Get.to(() => const StaffOrderHistoryScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF151E13)),
            tooltip: 'Refresh',
            onPressed: () {
              _productRx.fetchProducts();
              CustomerCartRx.instance.fetchBasket();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Sort Menu Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
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
                  SizedBox(width: 8.w),
                  PopupMenuButton<String>(
                    tooltip: 'Sort Products',
                    icon: Container(
                      padding: EdgeInsets.all(11.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(Icons.sort_rounded, color: primaryColor, size: 20.r),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _sortOrder = val;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'name_asc', child: Text('Name (A-Z)')),
                      const PopupMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
                      const PopupMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                      const PopupMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                      const PopupMenuItem(value: 'category', child: Text('Category')),
                    ],
                  ),
                ],
              ),
            ),

            // Product List and Category Chips
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

                  // Extract unique category names
                  final uniqueCategories = products
                      .map((p) => p.category?.name)
                      .where((name) => name != null && name.isNotEmpty)
                      .cast<String>()
                      .toSet()
                      .toList()
                    ..sort();

                  // Sort
                  final sortedProducts = List<Results>.from(products);
                  if (_sortOrder == 'name_asc') {
                    sortedProducts.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
                  } else if (_sortOrder == 'name_desc') {
                    sortedProducts.sort((a, b) => (b.name ?? '').toLowerCase().compareTo((a.name ?? '').toLowerCase()));
                  } else if (_sortOrder == 'price_asc') {
                    sortedProducts.sort((a, b) => _parseProductPrice(a).compareTo(_parseProductPrice(b)));
                  } else if (_sortOrder == 'price_desc') {
                    sortedProducts.sort((a, b) => _parseProductPrice(b).compareTo(_parseProductPrice(a)));
                  } else if (_sortOrder == 'category') {
                    sortedProducts.sort((a, b) => (a.category?.name ?? '').toLowerCase().compareTo((b.category?.name ?? '').toLowerCase()));
                  }

                  // Filter by query and category
                  final filteredProducts = sortedProducts.where((p) {
                    final name = (p.name ?? '').toLowerCase();
                    final catName = (p.category?.name ?? '').toLowerCase();
                    final origin = (p.origin ?? '').toLowerCase();
                    final matchesQuery = _searchQuery.isEmpty ||
                        name.contains(_searchQuery) ||
                        catName.contains(_searchQuery) ||
                        origin.contains(_searchQuery);
                    final matchesCategory = _selectedCategory == null ||
                        p.category?.name?.toLowerCase() == _selectedCategory?.toLowerCase();
                    return matchesQuery && matchesCategory;
                  }).toList();

                  return Column(
                    children: [
                      // Category Filter Chips
                      if (uniqueCategories.isNotEmpty)
                        Container(
                          height: 38.h,
                          margin: EdgeInsets.only(bottom: 8.h),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            children: [
                              ChoiceChip(
                                label: const Text('All Categories'),
                                selected: _selectedCategory == null,
                                selectedColor: primaryColor.withOpacity(0.15),
                                labelStyle: TextStyle(
                                  color: _selectedCategory == null ? primaryColor : Colors.grey.shade700,
                                  fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12.sp,
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedCategory = null;
                                    });
                                  }
                                },
                              ),
                              SizedBox(width: 8.w),
                              ...uniqueCategories.map((cat) => Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: _selectedCategory == cat,
                                  selectedColor: primaryColor.withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: _selectedCategory == cat ? primaryColor : Colors.grey.shade700,
                                    fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12.sp,
                                  ),
                                  onSelected: (sel) {
                                    setState(() {
                                      _selectedCategory = sel ? cat : null;
                                    });
                                  },
                                ),
                              )),
                            ],
                          ),
                        ),

                      // Product List
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? Center(
                                child: Text(
                                  'No products found matching your filter.',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                                ),
                              )
                            : RefreshIndicator(
                                color: primaryColor,
                                onRefresh: () async {
                                  await _productRx.fetchProducts();
                                  await CustomerCartRx.instance.fetchBasket();
                                },
                                child: ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
                                              showBasket: true,
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
                                                            placeholder: (context, url) => AppShimmer.box(
                                                              width: 58.r,
                                                              height: 58.r,
                                                              borderRadius: BorderRadius.circular(8.r),
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
                                                      SizedBox(height: 4.h),
                                                      Text(
                                                        displayPrice,
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 13.sp,
                                                          fontWeight: FontWeight.bold,
                                                          color: primaryColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 6.w),

                                                // Quick Add to Basket Button
                                                IconButton(
                                                  icon: Container(
                                                    padding: EdgeInsets.all(6.r),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.add_shopping_cart_rounded, color: primaryColor, size: 20),
                                                  ),
                                                  tooltip: 'Add to Basket',
                                                  onPressed: () async {
                                                    if (product.id != null) {
                                                      EasyLoading.show(status: 'Adding...');
                                                      try {
                                                        await CustomerOrdersApi.instance.addBasketItem(product.id!, 1);
                                                        await CustomerCartRx.instance.fetchBasket();
                                                        AppToast.success('${product.name ?? "Product"} added to basket!');
                                                      } catch (_) {
                                                        AppToast.error('Could not add to basket');
                                                      } finally {
                                                        EasyLoading.dismiss();
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
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
