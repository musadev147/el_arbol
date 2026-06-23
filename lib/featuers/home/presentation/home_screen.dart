import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBrandColor = Color(0xFF00694C);
    final categories = [
      'All',
      'Fruits',
      'Vegetables',
      'Herbs',
      'Dairy',
      'Bakery',
      'Honey',
    ];

    // List of premium products with Unsplash network images
    final List<Map<String, String>> products = [
      {
        'name': 'Organic Heirloom Tomatoes',
        'origin': 'Andalusia, ES',
        'price': '€4.20',
        'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
        'description': 'These heirloom tomatoes are grown using biodynamic methods in Andalusia, Spain. They offer rich, sweet flavor and excellent texture, perfect for salads and gourmet dishes.',
        'category': 'Vegetables',
      },
      {
        'name': 'Fresh Haas Avocados',
        'origin': 'Michoacán, MX',
        'price': '€3.20',
        'imageUrl': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500&auto=format&fit=crop',
        'description': 'Sourced directly from the mountains of Michoacán, these Haas avocados have a rich, buttery texture and delicious taste. High in heart-healthy monounsaturated fats.',
        'category': 'Fruits',
      },
      {
        'name': 'Sweet Organic Strawberries',
        'origin': 'Huelva, ES',
        'price': '€5.50',
        'imageUrl': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&auto=format&fit=crop',
        'description': 'Juicy, hand-picked organic strawberries from Huelva. Known for their intense aroma and natural sweetness. Freshly packed to preserve taste.',
        'category': 'Fruits',
      },
      {
        'name': 'Artisan Raw Honey',
        'origin': 'Black Forest, DE',
        'price': '€8.90',
        'imageUrl': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&auto=format&fit=crop',
        'description': 'Pure, unpasteurized honey harvested from organic apiaries in the deep valleys of the Black Forest. Rich in antioxidants and active enzymes.',
        'category': 'Honey',
      },
      {
        'name': 'Fresh Goat Cheese',
        'origin': 'Loire Valley, FR',
        'price': '€6.80',
        'imageUrl': 'https://images.unsplash.com/photo-1486887396153-fa416525c108?w=500&auto=format&fit=crop',
        'description': 'A creamy, traditional French chèvre made using raw goat milk from sustainable herds. It has a mild tang and velvety mouthfeel.',
        'category': 'Dairy',
      },
      {
        'name': 'Sourdough Country Bread',
        'origin': 'Local Bakery',
        'price': '€3.90',
        'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop',
        'description': 'Slow-fermented for 24 hours using stoneground organic flour. Crispy, dark crust on the outside and airy, sour crumb on the inside.',
        'category': 'Bakery',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'El Árbol',
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
            icon: const Icon(Icons.shopping_basket, color: Color(0xFF151E13)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promos Banner Slider
            const PromoSlider(),
            SizedBox(height: 20.h),

            // Category List matching web layout
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF151E13),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    child: Chip(
                      label: Text(
                        categories[index],
                        style: TextStyle(
                          color: isAll ? Colors.white : primaryBrandColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      backgroundColor: isAll ? primaryBrandColor : Colors.white,
                      side: BorderSide(
                        color: primaryBrandColor.withOpacity(0.3),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),

            // Fresh produce lists title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Seasonal Favorites',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF151E13),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Grid of products
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final prod = products[index];
                  return _buildProductCard(
                    context,
                    prod['name']!,
                    prod['origin']!,
                    prod['price']!,
                    prod['imageUrl']!,
                    prod['description']!,
                    prod['category']!,
                    primaryBrandColor,
                    onSale: index == 1,
                  );
                },
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String name,
    String origin,
    String price,
    String imageUrl,
    String description,
    String category,
    Color primaryColor, {
    bool onSale = false,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailsScreen(
              name: name,
              origin: origin,
              price: price,
              imageUrl: imageUrl,
              description: description,
              category: category,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00694C)),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(Icons.grass, color: primaryColor, size: 36.r),
                      ),
                    ),
                  ),
                  if (onSale)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE25B3D),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Text(
                          'SALE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Description info
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: const Color(0xFF151E13),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'from $origin',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF6D7A73),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: primaryColor,
                          size: 16.r,
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

// Promo Slider Widget using standard PageView for smooth animation
class PromoSlider extends StatefulWidget {
  const PromoSlider({super.key});

  @override
  State<PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<PromoSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> promoBanners = [
    {
      'title': 'Fresh Fruits & Veggies',
      'discount': '20% OFF',
      'sub': '100% Organic, direct from Huelva farms.',
      'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&auto=format&fit=crop',
    },
    {
      'title': 'Artisan Cheese Festival',
      'discount': 'Special Offer',
      'sub': 'Premium Loire Valley goat cheese selection.',
      'imageUrl': 'https://images.unsplash.com/photo-1552767059-ce182ead6c1b?w=800&auto=format&fit=crop',
    },
    {
      'title': 'Sweet Citrus Harvest',
      'discount': 'Fresh Deal',
      'sub': 'Natural, handpicked Valencia Oranges.',
      'imageUrl': 'https://images.unsplash.com/photo-1610832958506-ee563361f155?w=800&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < promoBanners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemCount: promoBanners.length,
            itemBuilder: (context, index) {
              final banner = promoBanners[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(banner['imageUrl']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00694C),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          banner['discount']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        banner['title']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        banner['sub']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            promoBanners.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentPage == index ? 16.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFF00694C) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
