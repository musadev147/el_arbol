import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../helpers/notification_unread_manager.dart';
import '../data/customer_notifications_rx.dart';
import '../../tickets/data/customer_tickets_api.dart';
import '../../tickets/presentation/customer_ticket_chat_screen.dart';
import '../../tickets/presentation/customer_tickets_screen.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() => _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState extends State<CustomerNotificationsScreen> {
  final CustomerNotificationsRx _rx = CustomerNotificationsRx(
    empty: [],
    dataFetcher: BehaviorSubject<List<dynamic>>(),
  );

  @override
  void initState() {
    super.initState();
    _rx.fetchNotifications();
  }

  void _bulkDelete(List<dynamic> notifications) async {
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
                final ids = notifications.map((e) => e['id'].toString()).toList();
                final success = await _rx.bulkDeleteNotifications(ids);
                if (success) {
                  _rx.fetchNotifications();
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _markAllAsRead(List<dynamic> notifications) {
    if (notifications.isEmpty) return;
    NotificationUnreadManager.instance.markAllCustomerNotificationsAsRead(notifications);
    AppToast.success('All notifications marked as read');
    setState(() {});
  }

  void _handleNotificationTap(Map<String, dynamic> notif) async {
    final id = notif['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      NotificationUnreadManager.instance.markCustomerNotificationAsRead(id);
      setState(() {});
    }

    final title = (notif['title'] ?? notif['subject'] ?? '').toString().toLowerCase();
    final body = (notif['body'] ?? notif['message'] ?? notif['description'] ?? '').toString().toLowerCase();
    final type = (notif['type'] ?? notif['action'] ?? notif['category'] ?? '').toString().toLowerCase();

    // Check if notification is related to a support ticket
    final bool isTicketRelated = type.contains('ticket') ||
        type.contains('support') ||
        title.contains('ticket') ||
        title.contains('support') ||
        body.contains('ticket') ||
        body.contains('support');

    if (isTicketRelated) {
      String? ticketId = notif['ticket_id']?.toString() ??
          notif['ticketId']?.toString() ??
          notif['data']?['ticket_id']?.toString() ??
          notif['data']?['ticketId']?.toString();

      if (ticketId == null || ticketId.isEmpty) {
        final regex = RegExp(r'ticket\s*#?(\d+)', caseSensitive: false);
        final match = regex.firstMatch('$title $body');
        if (match != null) {
          ticketId = match.group(1);
        }
      }

      if (ticketId != null && ticketId.isNotEmpty) {
        try {
          EasyLoading.show(status: 'Opening ticket...');
          final ticketsData = await CustomerTicketsApi.instance.getTickets();
          EasyLoading.dismiss();
          List<dynamic> ticketList = [];
          if (ticketsData is Map && ticketsData['results'] is List) {
            ticketList = ticketsData['results'] as List;
          } else if (ticketsData is List) {
            ticketList = ticketsData;
          }
          final matchingTicket = ticketList.firstWhere(
            (t) => t['id']?.toString() == ticketId,
            orElse: () => null,
          );

          if (matchingTicket != null) {
            Get.to(() => CustomerTicketChatScreen(ticket: matchingTicket));
            return;
          } else {
            Get.to(() => CustomerTicketChatScreen(ticket: {
              'id': ticketId,
              'subject': notif['title'] ?? notif['subject'] ?? 'Support Ticket #$ticketId',
              'status': 'Open',
              'created_at': notif['created_at'] ?? '',
            }));
            return;
          }
        } catch (_) {
          EasyLoading.dismiss();
          Get.to(() => CustomerTicketChatScreen(ticket: {
            'id': ticketId,
            'subject': notif['title'] ?? notif['subject'] ?? 'Support Ticket #$ticketId',
            'status': 'Open',
            'created_at': notif['created_at'] ?? '',
          }));
          return;
        }
      } else {
        Get.to(() => const CustomerSupportTicketsScreen());
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: StreamBuilder<List<dynamic>>(
          stream: _rx.valueStreamData,
          builder: (context, snapshot) {
            final notifs = snapshot.data ?? [];
            final unreadCount = NotificationUnreadManager.instance.calculateCustomerUnread(notifs);
            return Text(
              unreadCount > 0 ? 'Notifications ($unreadCount)' : 'Notifications',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            );
          },
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          StreamBuilder<List<dynamic>>(
            stream: _rx.valueStreamData,
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];
              if (notifications.isEmpty) return const SizedBox.shrink();
              final hasUnread = NotificationUnreadManager.instance.calculateCustomerUnread(notifications) > 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasUnread)
                    IconButton(
                      icon: const Icon(Icons.done_all, color: Colors.white),
                      onPressed: () => _markAllAsRead(notifications),
                      tooltip: 'Mark All as Read',
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.white),
                    onPressed: () => _bulkDelete(notifications),
                    tooltip: 'Clear All',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomAppLoading(message: 'Loading notifications...');
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80.r, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text('No notifications', style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final notif = notifications[index] as Map<String, dynamic>;
              final bool isRead = NotificationUnreadManager.instance.isCustomerNotificationRead(notif);
              return Material(
                color: isRead ? Colors.white : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  onTap: () => _handleNotificationTap(notif),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isRead ? Colors.grey.shade200 : primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: isRead
                                ? primaryColor.withValues(alpha: 0.08)
                                : primaryColor.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRead ? Icons.notifications_none : Icons.notifications_active,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif['title'] ?? notif['subject'] ?? 'Notification',
                                      style: TextStyle(
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                        fontSize: 14.sp,
                                        color: const Color(0xFF151E13),
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8.r,
                                      height: 8.r,
                                      margin: EdgeInsets.only(left: 6.w),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                notif['body'] ?? notif['message'] ?? notif['description'] ?? '',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                notif['created_at'] ?? notif['date'] ?? notif['timestamp'] ?? '',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                          onPressed: () async {
                            final id = notif['id']?.toString();
                            if (id != null) {
                              await _rx.bulkDeleteNotifications([id]);
                              _rx.fetchNotifications();
                            }
                          },
                          tooltip: 'Delete notification',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
