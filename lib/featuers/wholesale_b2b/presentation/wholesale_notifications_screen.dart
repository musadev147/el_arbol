import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WholesaleNotificationsScreen extends StatefulWidget {
  const WholesaleNotificationsScreen({super.key});

  @override
  State<WholesaleNotificationsScreen> createState() => _WholesaleNotificationsScreenState();
}

class _WholesaleNotificationsScreenState extends State<WholesaleNotificationsScreen> {
  late WholesaleNotificationsRx _rx;

  @override
  void initState() {
    super.initState();
    _rx = WholesaleNotificationsRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
    _rx.fetchNotifications();
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
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
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final data = snapshot.data;
          
          List<dynamic> notifications = [];
          if (data is Map && data['results'] is List) {
            notifications = data['results'] as List;
          } else if (data is List) {
            notifications = data;
          }
          
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64.r, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text('No notifications', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.r),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.notifications, color: primaryColor),
                  ),
                  title: Text(notif['title'] ?? 'Notification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(notif['message'] ?? '', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(height: 8.h),
                      Text(notif['created_at'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      try {
                        await _rx.api.deleteNotification(notif['id']);
                        Fluttertoast.showToast(msg: "Notification deleted");
                        _rx.fetchNotifications();
                      } catch (e) {
                        Fluttertoast.showToast(msg: "Error deleting notification");
                      }
                    },
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
