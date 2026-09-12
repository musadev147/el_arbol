import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_details_screen.dart';
import 'store_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rxdart/rxdart.dart';
import '../../orders/data/customer_orders_rx.dart';
import '../../../../common_wigdets/custom_app_loading.dart';

class ShopMapScreen extends StatefulWidget {
  const ShopMapScreen({super.key});

  @override
  State<ShopMapScreen> createState() => _ShopMapScreenState();
}

class _ShopMapScreenState extends State<ShopMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDistance = 'All';
  String _viewMode = 'list'; // 'list' or 'map'
  Map<String, dynamic>? _selectedShop;

  List<Map<String, dynamic>> _allShops = [];
  bool _isLoading = true;
  late final CustomerStoresRx _storesRx;

  double normalizeLat(dynamic raw) {
    final val = double.tryParse(raw?.toString() ?? '') ?? 0.0;
    if (val >= 0.0 && val <= 1.0) return val;
    return (val.abs() % 1.0) * 0.7 + 0.15;
  }

  double normalizeLng(dynamic raw) {
    final val = double.tryParse(raw?.toString() ?? '') ?? 0.0;
    if (val >= 0.0 && val <= 1.0) return val;
    return (val.abs() % 1.0) * 0.7 + 0.15;
  }

  List<Map<String, dynamic>> get _filteredShops {
    var list = _allShops;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((shop) {
        final name = (shop['name'] ?? '').toString().toLowerCase();
        final addr = (shop['address'] ?? '').toString().toLowerCase();
        return name.contains(q) || addr.contains(q);
      }).toList();
    }
    if (_selectedDistance == '5 km') {
      return list.where((shop) => ((shop['distance'] as num?)?.toDouble() ?? 0.0) <= 5.0).toList();
    } else if (_selectedDistance == '10 km') {
      return list.where((shop) => ((shop['distance'] as num?)?.toDouble() ?? 0.0) <= 10.0).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _storesRx = CustomerStoresRx(empty: [], dataFetcher: BehaviorSubject<dynamic>());
    _storesRx.fetchStores();

    _storesRx.valueStreamData.listen((data) {
      if (data != null) {
        List<dynamic> results = [];
        if (data is List) {
          results = data;
        } else if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            results = data['data'];
          } else if (data.containsKey('results') && data['results'] is List) {
            results = data['results'];
          } else if (data.containsKey('stores') && data['stores'] is List) {
            results = data['stores'];
          } else {
            for (var val in data.values) {
              if (val is List) {
                results = val;
                break;
              }
            }
          }
        }

        final List<Map<String, dynamic>> loaded = [];
        if (results.isEmpty) {
          // Fallback to local default stores
          loaded.addAll([
            {
              'id': 'fallback-centro',
              'name': 'El Árbol Centro',
              'address': 'Calle Sierpes 14, Sevilla',
              'distance': 1.2,
              'phone': '+34 954 123 456',
              'status': 'Open • Closes 21:00',
              'lat': 0.3,
              'lng': 0.4,
              'mapLink': 'https://maps.google.com/?q=Calle+Sierpes+14,+Sevilla',
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
              'id': 'fallback-nervion',
              'name': 'El Árbol Nervión',
              'address': 'Avenida de la Buhaira 27, Sevilla',
              'distance': 4.5,
              'phone': '+34 954 987 654',
              'status': 'Open • Closes 21:30',
              'lat': 0.6,
              'lng': 0.5,
              'mapLink': 'https://maps.google.com/?q=Avenida+de+la+Buhaira+27,+Sevilla',
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
              'id': 'fallback-triana',
              'name': 'El Árbol Triana',
              'address': 'Calle San Jacinto 82, Sevilla',
              'distance': 8.7,
              'phone': '+34 954 555 111',
              'status': 'Open • Closes 21:00',
              'lat': 0.2,
              'lng': 0.8,
              'mapLink': 'https://maps.google.com/?q=Calle+San+Jacinto+82,+Sevilla',
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
            {
              'id': 'fallback-macarena',
              'name': 'El Árbol Macarena',
              'address': 'Calle Resolana 34, Sevilla',
              'distance': 3.1,
              'phone': '+34 954 332 211',
              'status': 'Open • Closes 21:00',
              'lat': 0.8,
              'lng': 0.3,
              'mapLink': 'https://maps.google.com/?q=Calle+Resolana+34,+Sevilla',
              'products': [
                {
                  'name': 'Sweet Organic Strawberries',
                  'price': '€5.50',
                  'origin': 'Huelva, ES',
                  'imageUrl': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&auto=format&fit=crop',
                  'category': 'Fruits',
                  'description': 'Juicy, hand-picked organic strawberries from Huelva.',
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
              'id': 'fallback-remedios',
              'name': 'El Árbol Los Remedios',
              'address': 'Calle Asunción 45, Sevilla',
              'distance': 6.2,
              'phone': '+34 954 667 889',
              'status': 'Open • Closes 21:30',
              'lat': 0.4,
              'lng': 0.7,
              'mapLink': 'https://maps.google.com/?q=Calle+Asuncion+45,+Sevilla',
              'products': [
                {
                  'name': 'Fresh Goat Cheese',
                  'price': '€6.80',
                  'origin': 'Loire Valley, FR',
                  'imageUrl': 'https://images.unsplash.com/photo-1524351199679-46cddf530c04?w=500&auto=format&fit=crop',
                  'category': 'Fresh Cheese',
                  'description': 'A creamy, traditional French chèvre made using raw goat milk.',
                },
                {
                  'name': 'Organic Heirloom Tomatoes',
                  'price': '€4.20',
                  'origin': 'Andalusia, ES',
                  'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
                  'category': 'Vegetables',
                  'description': 'These heirloom tomatoes are grown using biodynamic methods in Andalusia, Spain.',
                },
              ]
            },
          ]);
        } else {
          for (var i = 0; i < results.length; i++) {
            final item = results[i];
            loaded.add({
              'id': item['id'],
              'name': item['name'] ?? 'Store ${i + 1}',
              'image': item['image'] ?? item['banner'] ?? item['store_image'] ?? item['photo'] ?? '',
              'address': item['address'] ?? item['street'] ?? 'Calle Sierpes 14, Sevilla',
              'distance': double.tryParse(item['distance']?.toString() ?? '') ?? (1.2 * (i + 1)),
              'phone': item['phone'] ?? '+34 954 123 456',
              'status': item['status'] ?? 'Open • Closes 21:00',
              'lat': double.tryParse(item['lat']?.toString() ?? '') ?? (0.3 + (i * 0.1)),
              'lng': double.tryParse(item['lng']?.toString() ?? '') ?? (0.4 + (i * 0.1)),
              'mapLink': item['mapLink'] ?? item['map_url'] ?? '',
              'products': [
                {
                  'name': 'Organic Heirloom Tomatoes',
                  'price': '€4.20',
                  'origin': 'Andalusia, ES',
                  'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
                  'category': 'Vegetables',
                  'description': 'These heirloom tomatoes are grown using biodynamic methods in Andalusia, Spain.',
                },
              ]
            });
          }
        }

        if (mounted) {
          setState(() {
            _allShops = loaded;
            _isLoading = false;
            if (_allShops.isNotEmpty) {
              _selectedShop = _allShops.first;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _storesRx.dispose();
    super.dispose();
  }

  Widget _buildStoreThumbnail(String? url, {double size = 44}) {
    String cleanUrl = url?.trim() ?? '';
    if (cleanUrl.startsWith('http://')) {
      cleanUrl = cleanUrl.replaceFirst('http://', 'https://');
    } else if (cleanUrl.startsWith('/')) {
      cleanUrl = 'https://apielarbol.icommerce.com.bd$cleanUrl';
    }

    if (cleanUrl.isEmpty) {
      return Container(
        width: size.w,
        height: size.w,
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFF00694C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.storefront_rounded, color: const Color(0xFF00694C), size: (size * 0.55).sp),
      );
    }

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.r),
        child: CachedNetworkImage(
          imageUrl: cleanUrl,
          width: size.w,
          height: size.w,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00694C)),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: const Color(0xFF00694C).withValues(alpha: 0.1),
            child: Icon(Icons.storefront_rounded, color: const Color(0xFF00694C), size: (size * 0.55).sp),
          ),
        ),
      ),
    );
  }

  Future<void> _launchDirections(Map<String, dynamic> shop) async {
    final mapLink = shop['mapLink'] ?? '';
    final lat = shop['lat'];
    final lng = shop['lng'];
    String url = '';
    if (lat != null && lng != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    } else if (mapLink.toString().isNotEmpty) {
      url = mapLink.toString();
    } else {
      url = 'https://maps.google.com/?q=${Uri.encodeComponent(shop['address'] ?? shop['name'])}';
    }
    if (url.isNotEmpty) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    final shops = _filteredShops;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'Our Stores',
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
            icon: const Icon(Icons.refresh, color: Color(0xFF151E13)),
            onPressed: () {
              setState(() => _isLoading = true);
              _storesRx.fetchStores();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Store Search Bar
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search stores by name or location...',
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: primaryColor, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
          ),

          // View Mode Switcher + Distance Filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Row(
              children: [
                // View Mode Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _viewMode = 'list'),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _viewMode == 'list' ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.list, size: 16.sp, color: _viewMode == 'list' ? Colors.white : Colors.black87),
                              SizedBox(width: 4.w),
                              Text(
                                'List (${shops.length})',
                                style: TextStyle(
                                  color: _viewMode == 'list' ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _viewMode = 'map'),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _viewMode == 'map' ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.map_outlined, size: 16.sp, color: _viewMode == 'map' ? Colors.white : Colors.black87),
                              SizedBox(width: 4.w),
                              Text(
                                'Map',
                                style: TextStyle(
                                  color: _viewMode == 'map' ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Distance chips
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', '5 km', '10 km'].map((dist) {
                        final isSelected = _selectedDistance == dist;
                        return Container(
                          margin: EdgeInsets.only(right: 6.w),
                          child: ChoiceChip(
                            label: Text(
                              dist,
                              style: TextStyle(
                                color: isSelected ? Colors.white : primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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
                ),
              ],
            ),
          ),

          // Body depending on ViewMode
          Expanded(
            child: _isLoading && _allShops.isEmpty
                ? const CustomAppLoading(message: 'Loading store locations...')
                : _viewMode == 'list'
                    ? _buildStoresListView(shops, primaryColor)
                    : _buildMapView(shops, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStoresListView(List<Map<String, dynamic>> shops, Color primaryColor) {
    if (shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64.r, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              _searchQuery.isNotEmpty ? 'No stores matching "$_searchQuery"' : 'No stores found in this area',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Text('Clear Search', style: TextStyle(color: primaryColor)),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: shops.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final shop = shops[index];
        final products = (shop['products'] as List? ?? []);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () {
                Get.to(() => StoreDetailsScreen(store: shop));
              },
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStoreThumbnail(shop['image'], size: 52),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop['name'] ?? 'Store',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                  color: const Color(0xFF151E13),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey.shade600),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      shop['address'] ?? '',
                                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${shop['distance']} km',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            shop['status'] ?? 'Open Now • Closes 21:00',
                            style: TextStyle(fontSize: 11.sp, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              '${products.length} Products',
                              style: TextStyle(fontSize: 11.sp, color: primaryColor, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_forward_ios_rounded, size: 11, color: primaryColor),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedShop = shop;
                                _viewMode = 'map';
                              });
                            },
                            icon: const Icon(Icons.map_outlined, size: 16),
                            label: const Text('View on Map', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                            onPressed: () {
                              Get.to(() => StoreDetailsScreen(store: shop));
                            },
                            icon: const Icon(Icons.storefront_rounded, size: 16),
                            label: const Text('Store Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
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
    );
  }

  Widget _buildMapView(List<Map<String, dynamic>> shops, Color primaryColor) {
    return Column(
      children: [
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
                    left: normalizeLng(shop['lng']) * 300.w + 20.w,
                    top: normalizeLat(shop['lat']) * 200.h + 20.h,
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
                                boxShadow: const [
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
                    onPressed: () {
                      if (_selectedShop != null) {
                        _launchDirections(_selectedShop!);
                      }
                    },
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
                      _buildStoreThumbnail(_selectedShop!['image'], size: 44),
                      SizedBox(width: 10.w),
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
                      SizedBox(width: 4.w),
                      IconButton(
                        onPressed: () => _launchDirections(_selectedShop!),
                        icon: Icon(Icons.directions, color: primaryColor),
                        tooltip: 'Open in Google Maps',
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
                                  id: product['id']?.toString(),
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
                                    errorWidget: (context, url, error) => const Icon(Icons.grass, color: Color(0xFF00694C)),
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                          color: const Color(0xFF151E13),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        product['origin'] ?? product['category'] ?? '',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF6D7A73),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  product['price'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: primaryColor,
                                  ),
                                ),
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
          ),
      ],
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
