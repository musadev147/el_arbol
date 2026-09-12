import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../data/rx.dart';

class NotificationsInboxScreen extends StatefulWidget {
  const NotificationsInboxScreen({super.key});

  @override
  State<NotificationsInboxScreen> createState() => _NotificationsInboxScreenState();
}

class _NotificationsInboxScreenState extends State<NotificationsInboxScreen> {
  late final StaffNotificationsRx _rx;

  @override
  void initState() {
    super.initState();
    _rx = StaffNotificationsRx(
      empty: [],
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _rx.fetchNotifications();
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  void _deleteNotificationItem(String id) async {
    final success = await _rx.deleteNotification(id);
    if (success) {
      Get.snackbar(
        'Deleted',
        'Notification deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00694C),
        colorText: Colors.white,
      );
      _rx.fetchNotifications();
    } else {
      Get.snackbar(
        'Error',
        'Failed to delete notification',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAF8),
        appBar: AppBar(
          title: Text(
            'Notifications Inbox',
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
          bottom: const TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
            tabs: [
              Tab(text: 'Price Alerts'),
              Tab(text: 'Management'),
              Tab(text: 'Direct Messages'),
            ],
          ),
        ),
        body: StreamBuilder<dynamic>(
          stream: _rx.valueStreamData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomAppLoading(message: 'Loading notifications...');
            }

            final rawData = snapshot.data;
            List<dynamic> allNotifications = [];
            if (rawData is List) {
              allNotifications = rawData;
            } else if (rawData is Map && rawData['results'] is List) {
              allNotifications = rawData['results'] as List;
            }

            // Filter notifications into categories
            final priceAlerts = allNotifications.where((notif) {
              final title = (notif['title'] ?? '').toString().toLowerCase();
              return title.contains('price') || title.contains('rate');
            }).toList();

            final groupMessages = allNotifications.where((notif) {
              final title = (notif['title'] ?? '').toString().toLowerCase();
              final isPrice = title.contains('price') || title.contains('rate');
              final isMgmt = title.contains('store') || title.contains('mgmt') || title.contains('management') || title.contains('operation') || title.contains('shift');
              return !isPrice && isMgmt;
            }).toList();

            final directMessages = allNotifications.where((notif) {
              final title = (notif['title'] ?? '').toString().toLowerCase();
              final isPrice = title.contains('price') || title.contains('rate');
              final isMgmt = title.contains('store') || title.contains('mgmt') || title.contains('management') || title.contains('operation') || title.contains('shift');
              return !isPrice && !isMgmt;
            }).toList();

            return TabBarView(
              children: [
                _buildNotificationTab(priceAlerts, Icons.sell_outlined, Colors.green),
                _buildNotificationTab(groupMessages, Icons.groups_outlined, Colors.blue),
                _buildNotificationTab(directMessages, Icons.chat_bubble_outline_rounded, Colors.purple),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationTab(List<dynamic> alerts, IconData icon, Color badgeColor) {
    if (alerts.isEmpty) {
      return const NoInternetOrDataWidget(
        title: 'No Notifications',
        message: 'No new notifications in this category.',
        isFullPage: false,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index] as Map<String, dynamic>;
        final id = alert['id'].toString();
        final title = alert['title'] ?? '';
        final body = alert['body'] ?? alert['message'] ?? '';
        final date = alert['created_at'] ?? alert['date'] ?? '';

        return Dismissible(
          key: Key(id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            _deleteNotificationItem(id);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: badgeColor, size: 20.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: const Color(0xFF151E13),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                          )
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        body,
                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6D7A73), height: 1.35),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
