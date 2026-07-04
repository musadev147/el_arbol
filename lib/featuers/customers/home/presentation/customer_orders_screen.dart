import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  int _currentStatusIndex = 1; // 0: Confirmed, 1: Processing, 2: Out for Delivery, 3: Delivered

  final List<String> _statusStages = [
    'Confirmed',
    'Processing',
    'Out for Delivery',
    'Delivered',
  ];

  final List<Map<String, dynamic>> _pastOrders = [
    {
      'id': '#OR-78902',
      'date': 'June 28, 2026',
      'total': '€14.20',
      'type': 'Home Delivery',
      'items': [
        'Organic Heirloom Tomatoes x 2',
        'Sweet Organic Strawberries x 1',
      ],
    },
    {
      'id': '#OR-76110',
      'date': 'June 22, 2026',
      'total': '€22.50',
      'type': 'Click & Collect',
      'items': [
        'Fresh Haas Avocados x 3',
        'Artisan Raw Honey x 1',
        'Fresh Goat Cheese x 1',
      ],
    },
  ];

  void _advanceOrderState() {
    if (_currentStatusIndex < _statusStages.length - 1) {
      setState(() {
        _currentStatusIndex++;
      });
      // Simulate push notification trigger
      Fluttertoast.showToast(
        msg: "🔔 Push Alert: Order Status updated to ${_statusStages[_currentStatusIndex]}!",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: const Color(0xFF00694C),
        textColor: Colors.white,
      );
    } else {
      setState(() {
        _currentStatusIndex = 0; // Loop back for testing
      });
      Fluttertoast.showToast(
        msg: "🔔 Push Alert: New order placed & Confirmed!",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: const Color(0xFF00694C),
        textColor: Colors.white,
      );
    }
  }

  void _shareReceipt(Map<String, dynamic> order) {
    final text = 'El Árbol Receipt ${order['id']}\n'
        'Date: ${order['date']}\n'
        'Total: ${order['total']}\n'
        'Type: ${order['type']}\n'
        'Items:\n'
        '${(order['items'] as List).join('\n')}';
    Share.share(text);
  }

  void _reorder(Map<String, dynamic> order) {
    Fluttertoast.showToast(
      msg: "Items from ${order['id']} added to your cart!",
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Order Live Tracker
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Order #OR-8902',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            'Estimated delivery: today at 18:30',
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _advanceOrderState,
                        tooltip: 'Simulate status change / push notice',
                        icon: const Icon(Icons.refresh, color: primaryColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Progress indicator steps
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_statusStages.length, (index) {
                      final bool done = index <= _currentStatusIndex;
                      final bool current = index == _currentStatusIndex;

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
                                  color: index < _currentStatusIndex ? primaryColor : Colors.grey.shade300,
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
            SizedBox(height: 24.h),

            // Order History List
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
              itemCount: _pastOrders.length,
              itemBuilder: (context, index) {
                final order = _pastOrders[index];

                return Container(
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
                            order['id'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            order['total'],
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
                            order['date'],
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              order['type'],
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
                      ...((order['items'] as List).map((item) => Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Text(
                              item,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
                            ),
                          ))),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
