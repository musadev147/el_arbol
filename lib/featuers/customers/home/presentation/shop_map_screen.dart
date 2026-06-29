import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_details_screen.dart';

class ShopMapScreen extends StatefulWidget {
  const ShopMapScreen({super.key});

  @override
  State<ShopMapScreen> createState() => _ShopMapScreenState();
}

class _ShopMapScreenState extends State<ShopMapScreen> {
  String _selectedDistance = 'All';
  Map<String, dynamic>? _selectedShop;

  final List<Map<String, dynamic>> _allShops = [
    {
      'name': 'El Árbol Centro',
      'address': 'Calle Sierpes 14, Sevilla',
      'distance': 1.2, // km
      'phone': '+34 954 123 456',
      'lat': 0.3,
      'lng': 0.4,
      'products': [
        {
          'name': 'Organic Heirloom Tomatoes',
          'price': '€4.20',
          'origin': 'Andalusia, ES',
          'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
          'category': 'Vegetables',
          'description': 'These heirloom tomatoes are grown using biodynamic methods in Andalusia, Spain.',
        },
        {
          'name': 'Sweet Organic Strawberries',
          'price': '€5.50',
          'origin': 'Huelva, ES',
          'imageUrl': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&auto=format&fit=crop',
          'category': 'Fruits',
          'description': 'Juicy, hand-picked organic strawberries from Huelva.',
        },
        {
          'name': 'Fresh Goat Cheese',
          'price': '€6.80',
          'origin': 'Loire Valley, FR',
          'imageUrl': 'https://images.unsplash.com/photo-1524351199679-46cddf530c04?w=500&auto=format&fit=crop',
          'category': 'Fresh Cheese',
          'description': 'A creamy, traditional French chèvre made using raw goat milk.',
        },
      ]
    },
    {
      'name': 'El Árbol Nervión',
      'address': 'Avenida de la Buhaira 27, Sevilla',
      'distance': 4.5, // km
      'phone': '+34 954 987 654',
      'lat': 0.6,
      'lng': 0.5,
      'products': [
        {
          'name': 'Fresh Haas Avocados',
          'price': '€3.20',
          'origin': 'Michoacán, MX',
          'imageUrl': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500&auto=format&fit=crop',
          'category': 'Fruits',
          'description': 'Sourced directly from the mountains of Michoacán, Haas avocados.',
        },
        {
          'name': 'Artisan Raw Honey',
          'price': '€8.90',
          'origin': 'Black Forest, DE',
          'imageUrl': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&auto=format&fit=crop',
          'category': 'Grocery',
          'description': 'Pure, unpasteurized honey harvested from organic apiaries.',
        },
      ]
    },
    {
      'name': 'El Árbol Triana',
      'address': 'Calle San Jacinto 82, Sevilla',
      'distance': 8.7, // km
      'phone': '+34 954 555 111',
      'lat': 0.2,
      'lng': 0.8,
      'products': [
        {
          'name': 'Organic Heirloom Tomatoes',
          'price': '€4.50',
          'origin': 'Andalusia, ES',
          'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
          'category': 'Vegetables',
          'description': 'These heirloom tomatoes are grown using biodynamic methods in Andalusia, Spain.',
        },
        {
          'name': 'Fresh Haas Avocados',
          'price': '€3.50',
          'origin': 'Michoacán, MX',
          'imageUrl': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500&auto=format&fit=crop',
          'category': 'Fruits',
          'description': 'Sourced directly from the mountains of Michoacán, Haas avocados.',
        },
      ]
    },
  ];

  List<Map<String, dynamic>> get _filteredShops {
    if (_selectedDistance == '5 km') {
      return _allShops.where((shop) => shop['distance'] <= 5.0).toList();
    } else if (_selectedDistance == '10 km') {
      return _allShops.where((shop) => shop['distance'] <= 10.0).toList();
    }
    return _allShops;
  }

  @override
  void initState() {
    super.initState();
    _selectedShop = _allShops.first;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    final shops = _filteredShops;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'Find Stores',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Distance Filters
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: ['5 km', '10 km', 'All'].map((dist) {
                final isSelected = _selectedDistance == dist;
                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(
                      dist,
                      style: TextStyle(
                        color: isSelected ? Colors.white : primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    backgroundColor: Colors.white,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDistance = dist;
                          if (!shops.contains(_selectedShop)) {
                            _selectedShop = shops.isNotEmpty ? shops.first : null;
                          }
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Map view mock
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE3ECD5),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: MapBackgroundPainter(),
                  ),
                  ...shops.map((shop) {
                    final isSelected = _selectedShop == shop;
                    return Positioned(
                      left: (shop['lng'] as double) * 300.w + 20.w,
                      top: (shop['lat'] as double) * 200.h + 20.h,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedShop = shop;
                          });
                        },
                        child: AnimatedScale(
                          scale: isSelected ? 1.3 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                                child: Text(
                                  shop['name'],
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                color: isSelected ? Colors.red : primaryColor,
                                size: 32.r,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  Positioned(
                    bottom: 16.h,
                    right: 16.w,
                    child: FloatingActionButton.small(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected Shop Detail & Inventory
          if (_selectedShop != null)
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.all(16.r),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedShop!['name'],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF151E13),
                                ),
                              ),
                              Text(
                                _selectedShop!['address'],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF6D7A73),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${_selectedShop!['distance']} km',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      "Available Products & Live Prices",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF151E13),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount: (_selectedShop!['products'] as List).length,
                        itemBuilder: (context, index) {
                          final product = _selectedShop!['products'][index];
                          return InkWell(
                            onTap: () {
                              Get.to(() => ProductDetailsScreen(
                                    name: product['name'],
                                    origin: product['origin'],
                                    price: product['price'],
                                    imageUrl: product['imageUrl'],
                                    description: product['description'],
                                    category: product['category'],
                                  ));
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CachedNetworkImage(
                                      imageUrl: product['imageUrl'],
                                      width: 48.w,
                                      height: 48.w,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade100,
                                        width: 48.w,
                                        height: 48.w,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00694C)),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey.shade100,
                                        width: 48.w,
                                        height: 48.w,
                                        child: const Icon(Icons.grass, color: Color(0xFF00694C), size: 24),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF151E13),
                                          ),
                                        ),
                                        Text(
                                          product['category'],
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    product['price'],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
            )
          else
            const Expanded(
              child: Center(
                child: Text('No shops found within the selected distance.'),
              ),
            ),
        ],
      ),
    );
  }
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final parkPaint = Paint()..color = const Color(0xFFD5E5BF);
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 60, parkPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 40, parkPaint);

    final road1 = Path();
    road1.moveTo(0, size.height * 0.2);
    road1.lineTo(size.width, size.height * 0.5);
    canvas.drawPath(road1, roadPaint);

    final road2 = Path();
    road2.moveTo(size.width * 0.5, 0);
    road2.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.6, size.height);
    canvas.drawPath(road2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
