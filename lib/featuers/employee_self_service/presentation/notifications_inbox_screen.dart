import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SystemAlert {
  final String title;
  final String body;
  final String date;
  final bool isRead;

  SystemAlert({required this.title, required this.body, required this.date, this.isRead = false});
}

class NotificationsInboxScreen extends StatelessWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    final List<SystemAlert> priceAlerts = [
      SystemAlert(title: 'Price Update: Haas Avocados', body: 'Haas Avocados wholesale price increased to €3.20 per kg starting tomorrow morning.', date: '2 hours ago'),
      SystemAlert(title: 'Price Update: Organic Heirloom Tomatoes', body: 'Tomato retail price updated to €4.20 per kg due to season adjustments.', date: '1 day ago'),
    ];

    final List<SystemAlert> groupMessages = [
      SystemAlert(title: 'Store Operations: Valencia-04', body: 'All staff please remember to check and verify refrigerator temperatures during stock rotation today.', date: '3 hours ago'),
      SystemAlert(title: 'Management Notice: Shift Handover', body: 'Reminder: Floor staff handovers must include shift checklists logged in the terminal.', date: '2 days ago'),
    ];

    final List<SystemAlert> directMessages = [
      SystemAlert(title: 'From Manager (Clara)', body: 'Hi Sofia, your shift change request for next Thursday has been approved. Check your calendar.', date: '4 hours ago'),
      SystemAlert(title: 'From HR Department', body: 'Hello Sofia, please submit your pending signature on the revised store safety contract by Friday.', date: '3 days ago'),
    ];

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
        body: TabBarView(
          children: [
            _buildNotificationTab(priceAlerts, Icons.sell_outlined, Colors.green),
            _buildNotificationTab(groupMessages, Icons.groups_outlined, Colors.blue),
            _buildNotificationTab(directMessages, Icons.chat_bubble_outline_rounded, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTab(List<SystemAlert> alerts, IconData icon, Color badgeColor) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_outlined, size: 54.r, color: Colors.grey),
            SizedBox(height: 12.h),
            Text('No new notifications in this category.', style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Container(
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
                            alert.title,
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
                          alert.date,
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        )
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      alert.body,
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6D7A73), height: 1.35),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
