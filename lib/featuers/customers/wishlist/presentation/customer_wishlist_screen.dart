import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import '../data/customer_wishlist_rx.dart';

class CustomerWishlistScreen extends StatefulWidget {
  const CustomerWishlistScreen({super.key});

  @override
  State<CustomerWishlistScreen> createState() => _CustomerWishlistScreenState();
}

class _CustomerWishlistScreenState extends State<CustomerWishlistScreen> {
  late CustomerWishlistRx _rx;

  @override
  void initState() {
    super.initState();
    _rx = CustomerWishlistRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _rx.fetchWishlist();
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  void _clearWishlist() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Wishlist?'),
          content: const Text('Are you sure you want to remove all items from your wishlist?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _rx.clearWishlist();
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: _clearWishlist,
            tooltip: 'Clear Wishlist',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text("Failed to load wishlist"));
          }

          final List<dynamic> items = data as List<dynamic>;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80.r, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text('Your wishlist is empty', style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: items.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item['id']?.toString() ?? '';
              final productId = item['product_id']?.toString() ?? '';
              final name = item['name'] ?? item['product_name'] ?? 'Product';
              final image = item['image'] ?? item['product_image'];
              final price = item['price']?.toString() ?? '0.0';
              
              return Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(image, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          SizedBox(height: 8.h),
                          Text('\$$price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: primaryColor)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        _rx.removeFromWishlist(id.isNotEmpty ? id : productId);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
