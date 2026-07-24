import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/customer_notifications_rx.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() => _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState extends State<CustomerNotificationsScreen> {
  final CustomerNotificationsRx _rx = CustomerNotificationsRx();
  List<Map<String, dynamic>> _mockNotifications = [
    {
      "id": "1",
      "title": "Order Shipped",
      "body": "Your order #12345 has been shipped.",
      "date": "2 hours ago",
      "isRead": false,
    },
    {
      "id": "2",
      "title": "Welcome",
      "body": "Welcome to El Arbol! We're glad to have you.",
      "date": "1 day ago",
      "isRead": true,
    }
  ];

  void _bulkDelete() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Notifications?'),
          content: const Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                final ids = _mockNotifications.map((e) => e['id'].toString()).toList();
                final success = await _rx.bulkDeleteNotifications(ids);
                if (success) {
                  setState(() {
                    _mockNotifications.clear();
                  });
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
        title: const Text('Notifications', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_mockNotifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: _bulkDelete,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _mockNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80.r, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text('No notifications', style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: _mockNotifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final notif = _mockNotifications[index];
                final isRead = notif['isRead'] == true;

                return Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: isRead ? Colors.grey.shade100 : Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications, color: primaryColor),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                            SizedBox(height: 4.h),
                            Text(notif['body'] ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp)),
                            SizedBox(height: 8.h),
                            Text(notif['date'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
