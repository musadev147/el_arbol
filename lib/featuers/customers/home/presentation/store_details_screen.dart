import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_details_screen.dart';

class StoreDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> store;

  const StoreDetailsScreen({
    super.key,
    required this.store,
  });

  Future<void> _launchDirections() async {
    final lat = store['lat'];
    final lng = store['lng'];
    final mapLink = store['mapLink'] ?? store['map_url'] ?? '';
    String url = '';
    if (lat != null && lng != null && lat.toString().isNotEmpty && lng.toString().isNotEmpty) {
      url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    } else if (mapLink.toString().isNotEmpty) {
      url = mapLink.toString();
    } else {
      url = 'https://maps.google.com/?q=${Uri.encodeComponent(store['address'] ?? store['name'] ?? 'El Arbol')}';
    }
    if (url.isNotEmpty) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    final String storeName = store['name'] ?? 'Store Details';
    final String address = store['address'] ?? store['street'] ?? 'Store Location';
    final dynamic distance = store['distance'];
    final String status = store['status'] ?? 'Open Now • Closes 21:00';
    final String? storeImage = store['image'] ?? store['imageUrl'] ?? store['photo'];
    final List<dynamic> products = store['products'] is List ? store['products'] : [];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          storeName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Hero Header
            Stack(
              children: [
                Container(
                  height: 180.h,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: storeImage != null && storeImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: storeImage,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _buildPlaceholderHeader(primaryColor),
                        )
                      : _buildPlaceholderHeader(primaryColor),
                ),
                Container(
                  height: 180.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00694C),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4.w),
                                Text(
                                  'El Árbol Store',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (distance != null) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '$distance km away',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        storeName,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Store Info Card
            Container(
              margin: EdgeInsets.all(16.r),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: const Icon(Icons.location_on_outlined, color: primaryColor, size: 20),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address',
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              address,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF151E13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(height: 1, color: Colors.grey.shade100),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.access_time_rounded, color: Colors.green.shade700, size: 20),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Operating Hours',
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton.icon(
                      onPressed: _launchDirections,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text(
                        'Get Directions on Map',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Available Products Header
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco_outlined, color: primaryColor, size: 20),
                      SizedBox(width: 6.w),
                      Text(
                        'Available Products (${products.length})',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: const Color(0xFF151E13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Products Grid
            if (products.isEmpty)
              Padding(
                padding: EdgeInsets.all(32.r),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48.r, color: Colors.grey.shade400),
                      SizedBox(height: 8.h),
                      Text(
                        'No products currently listed for this store',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index] is Map
                        ? Map<String, dynamic>.from(products[index] as Map)
                        : <String, dynamic>{};
                    final name = p['name'] ?? 'Organic Product';
                    final price = p['price'] ?? '€0.00';
                    final origin = p['origin'] ?? 'Spain';
                    final category = p['category'] ?? 'Fresh Produce';
                    final imageUrl = p['imageUrl'] ?? p['image'] ?? p['thumbnail'] ?? '';
                    final description = p['description'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => ProductDetailsScreen(
                              id: p['id']?.toString(),
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
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                                      child: imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorWidget: (_, __, ___) => const Center(
                                                child: Icon(Icons.grass, color: primaryColor, size: 36),
                                              ),
                                            )
                                          : const Center(
                                              child: Icon(Icons.grass, color: primaryColor, size: 36),
                                            ),
                                    ),
                                    Positioned(
                                      top: 6.h,
                                      left: 6.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'In Stock',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Details
                            Padding(
                              padding: EdgeInsets.all(10.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5.sp,
                                      color: const Color(0xFF151E13),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    origin,
                                    style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade500),
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        price.toString().startsWith('€') || price.toString().startsWith('\$') ? price.toString() : '€$price',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5.sp,
                                          color: primaryColor,
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: 12.r,
                                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                                        child: const Icon(Icons.add, color: primaryColor, size: 14),
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
                ),
              ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderHeader(Color primaryColor) {
    return Container(
      color: primaryColor.withValues(alpha: 0.15),
      child: Center(
        child: Icon(Icons.store_mall_directory_rounded, color: primaryColor, size: 64.r),
      ),
    );
  }
}
