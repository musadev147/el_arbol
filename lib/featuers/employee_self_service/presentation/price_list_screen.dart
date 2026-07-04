import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProductPrice {
  final String name;
  final String category;
  final String origin;
  final String price;

  ProductPrice({required this.name, required this.category, required this.origin, required this.price});
}

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ProductPrice> _allProducts = [
    ProductPrice(name: 'Artisan Raw Honey', category: 'Honey', origin: 'Black Forest, DE', price: '€8.90 / jar'),
    ProductPrice(name: 'Basil Fresh Herbs', category: 'Herbs', origin: 'Local Farm', price: '€1.50 / bunch'),
    ProductPrice(name: 'Blueberries Organic', category: 'Forest Fruits', origin: 'Huelva, ES', price: '€3.80 / pack'),
    ProductPrice(name: 'Cherry Tomatoes', category: 'Tomatoes', origin: 'Almeria, ES', price: '€2.50 / pack'),
    ProductPrice(name: 'Conference Pears', category: 'Apples & Pears', origin: 'Lleida, ES', price: '€2.10 / kg'),
    ProductPrice(name: 'Fresh Goat Cheese', category: 'Dairy', origin: 'Loire Valley, FR', price: '€6.80 / pc'),
    ProductPrice(name: 'Fresh Haas Avocados', category: 'Fruits', origin: 'Michoacán, MX', price: '€3.20 / kg'),
    ProductPrice(name: 'Gala Apples', category: 'Apples & Pears', origin: 'South Tyrol, IT', price: '€2.40 / kg'),
    ProductPrice(name: 'Organic Heirloom Tomatoes', category: 'Vegetables', origin: 'Andalusia, ES', price: '€4.20 / kg'),
    ProductPrice(name: 'Red Bell Peppers', category: 'Peppers', origin: 'Murcia, ES', price: '€2.80 / kg'),
    ProductPrice(name: 'Romaine Lettuce', category: 'Lettuce', origin: 'Local Farm', price: '€1.20 / head'),
    ProductPrice(name: 'Sourdough Country Bread', category: 'Bakery', origin: 'Local Bakery', price: '€3.90 / loaf'),
    ProductPrice(name: 'Strawberries Sweet', category: 'Forest Fruits', origin: 'Huelva, ES', price: '€5.50 / kg'),
    ProductPrice(name: 'Watermelon Seedless', category: 'Melons', origin: 'Valencia, ES', price: '€1.80 / kg'),
  ];

  @override
  void initState() {
    super.initState();
    // Sort all products alphabetically (A-Z)
    _allProducts.sort((a, b) => a.name.compareTo(b.name));
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

    final filteredProducts = _allProducts.where((p) {
      return p.name.toLowerCase().contains(_searchQuery) ||
          p.category.toLowerCase().contains(_searchQuery) ||
          p.origin.toLowerCase().contains(_searchQuery);
    }).toList();

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

            // Alphabetical Price Sheet List
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No products found matching your search.',
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF151E13),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${product.category}  •  Origin: ${product.origin}',
                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                                  )
                                ],
                              ),
                              Text(
                                product.price,
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
