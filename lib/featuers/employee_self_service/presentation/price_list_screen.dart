import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../customers/home/presentation/data/rx.dart';
import '../../customers/home/presentation/model/get_product_model.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
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
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Failed to load product price list'),
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
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final displayPrice = product.price != null 
                          ? '€${product.price} / ${product.unit ?? 'unit'}' 
                          : 'N/A';

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${product.category?.name ?? ''}  •  Origin: ${product.origin ?? 'N/A'}',
                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                                  )
                                ],
                              ),
                            ),
                            Text(
                              displayPrice,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            )
                          ],
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
