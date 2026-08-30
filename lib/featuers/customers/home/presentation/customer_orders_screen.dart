import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get/get.dart';
import '../../orders/data/customer_orders_rx.dart';
import '../../orders/presentation/customer_single_order_screen.dart';
import '../../orders/presentation/customer_cart_screen.dart';
import '../../orders/presentation/customer_checkout_screen.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  late CustomerOrdersRx _rx;
  late CustomerCartRx _cartRx;

  final List<String> _statusStages = [
    'Confirmed',
    'Processing',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _rx = CustomerOrdersRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _rx.fetchOrders();
    _cartRx = CustomerCartRx(empty: {}, dataFetcher: BehaviorSubject<dynamic>());
    _cartRx.fetchBasket();
  }

  @override
  void dispose() {
    _rx.dispose();
    _cartRx.dispose();
    super.dispose();
  }

  int _getStatusStageIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        return 0;
      case 'processing':
        return 1;
      case 'out for delivery':
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  void _shareReceipt(Map<String, dynamic> order) {
    final id = order['id'] ?? 'N/A';
    final date = order['created_at'] ?? '';
    final total = order['total'] ?? '0.00';
    final items = order['items'] as List? ?? [];
    
    final itemsStr = items.map((item) {
      final name = item['product_name'] ?? item['name'] ?? 'Product';
      final qty = item['quantity'] ?? 1;
      return '- $name x $qty';
    }).join('\n');
    
    final text = 'El Árbol Receipt #$id\n'
        'Date: $date\n'
        'Total: €$total\n'
        'Items:\n$itemsStr';
        
    Share.share(text);
  }

  void _reorder(Map<String, dynamic> order) {
    final id = order['id'] ?? 'N/A';
    Fluttertoast.showToast(
      msg: "Items from Order #$id added to your cart!",
      backgroundColor: const Color(0xFF00694C),
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          
          final List<dynamic> orders = snapshot.data is List ? snapshot.data as List : [];

          if (orders.isEmpty) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 48.r, color: Colors.grey.shade400),
                        SizedBox(height: 12.h),
                        Text('No active or past orders found.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
                      ],
                    ),
                  ),
                  _buildCartSummary(context, primaryColor),
                ],
              ),
            );
          }

          final activeOrders = orders.where((o) {
            final status = o['status']?.toString() ?? 'Pending';
            return status != 'Delivered' && status != 'Cancelled' && status != 'Returned';
          }).toList();

          final pastOrders = orders.where((o) {
            final status = o['status']?.toString() ?? 'Pending';
            return status == 'Delivered' || status == 'Cancelled' || status == 'Returned';
          }).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Order Live Tracker
                if (activeOrders.isNotEmpty) ...[
                  Text(
                    'Live Order Tracking',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...activeOrders.map((activeOrder) {
                    final orderId = activeOrder['id']?.toString() ?? '';
                    final status = activeOrder['status']?.toString() ?? 'Pending';
                    final dateStr = activeOrder['created_at'] ?? activeOrder['date'] ?? activeOrder['ordered_at'] ?? 'Just now';
                    final itemsList = activeOrder['items'] as List? ?? [];
                    final currentStatusIndex = _getStatusStageIndex(status);

                    return InkWell(
                      onTap: () {
                        Get.to(() => CustomerSingleOrderScreen(orderId: orderId, orderData: activeOrder));
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active Order #$orderId',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Text(
                                      'Placed: $dateStr',
                                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                              ],
                            ),
                            if (itemsList.isNotEmpty) ...[
                              const Divider(height: 20),
                              ...itemsList.map((item) {
                                final name = item['product_name'] ?? item['name'] ?? 'Product';
                                final qty = item['quantity'] ?? 1;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: Text(
                                    '$name x $qty',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
                                  ),
                                );
                              }).toList(),
                            ],
                            const Divider(height: 20),
                            // Progress indicator steps
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(_statusStages.length, (index) {
                                final bool done = index <= currentStatusIndex;
                                final bool current = index == currentStatusIndex;

                                return Expanded(
                                  child: Row(
                                    children: [
                                      // Node
                                      Column(
                                        children: [
                                          Container(
                                            width: 24.w,
                                            height: 24.w,
                                            decoration: BoxDecoration(
                                              color: done ? primaryColor : Colors.grey.shade300,
                                              shape: BoxShape.circle,
                                              border: current
                                                  ? Border.all(color: Colors.amber.shade700, width: 2)
                                                  : null,
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14.r,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            _statusStages[index],
                                            style: TextStyle(
                                              fontSize: 8.sp,
                                              fontWeight: done ? FontWeight.bold : FontWeight.normal,
                                              color: done ? const Color(0xFF151E13) : Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      // Line
                                      if (index < _statusStages.length - 1)
                                        Expanded(
                                          child: Container(
                                            height: 3.h,
                                            color: index < currentStatusIndex ? primaryColor : Colors.grey.shade300,
                                            margin: EdgeInsets.only(bottom: 16.h),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20.h),
                ],
                _buildCartSummary(context, primaryColor),

                // Order History List
                if (pastOrders.isNotEmpty) ...[
                  Text(
                    'Order History',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pastOrders.length,
                    itemBuilder: (context, index) {
                      final order = pastOrders[index];
                      final orderId = order['id']?.toString() ?? '';
                      final dateStr = order['created_at'] ?? '';
                      final total = order['total']?.toString() ?? '0.00';
                      final type = order['payment_method'] ?? 'Delivery';
                      final itemsList = order['items'] as List? ?? [];

                      return InkWell(
                        onTap: () {
                          Get.to(() => CustomerSingleOrderScreen(orderId: orderId, orderData: order));
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#$orderId',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    '€$total',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateStr,
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              ...itemsList.map((item) {
                                final name = item['product_name'] ?? item['name'] ?? 'Product';
                                final qty = item['quantity'] ?? 1;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: Text(
                                    '$name x $qty',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
                                  ),
                                );
                              }).toList(),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _shareReceipt(order),
                                    icon: const Icon(Icons.share, size: 16),
                                    label: const Text('Share Receipt'),
                                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _reorder(order),
                                    icon: const Icon(Icons.replay, size: 16),
                                    label: const Text('Reorder'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, Color primaryColor) {
    return StreamBuilder(
      stream: _cartRx.valueStreamData,
      builder: (context, cartSnapshot) {
        final basketData = cartSnapshot.data;
        final List<dynamic> cartItems = (basketData != null && basketData is Map) ? (basketData['items'] as List? ?? []) : [];
        if (cartItems.isEmpty) return const SizedBox.shrink();

        double sub = 0.0;
        for (var item in cartItems) {
          final details = item['product_details'] ?? {};
          final price = double.tryParse(details['price']?.toString() ?? '0.0') ?? 0.0;
          final quantity = item['quantity'] as int? ?? 1;
          sub += price * quantity;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Cart Summary',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => CustomerCartScreen(cartItems: RxList<Map<String, dynamic>>([])));
                  },
                  child: Text('View Full Cart', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...cartItems.map((item) {
                    final details = item['product_details'] ?? {};
                    final name = details['name'] ?? 'Product';
                    final price = double.tryParse(details['price']?.toString() ?? '0.0') ?? 0.0;
                    final qty = item['quantity'] ?? 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$name x $qty',
                              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800),
                            ),
                          ),
                          Text(
                            '€${(price * qty).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                      ),
                      Text(
                        '€${sub.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.amber.shade800),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const CustomerCheckoutScreen())?.then((_) {
                          _cartRx.fetchBasket();
                          _rx.fetchOrders();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        );
      },
    );
  }
}
