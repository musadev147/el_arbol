import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../helpers/notification_unread_manager.dart';
import '../../../../helpers/di.dart';
import '../data/rx.dart';

import 'apply_day_off_screen.dart';
import 'price_list_screen.dart';
import 'request_shift_change_screen.dart';
import 'staff_chat_screen.dart';
import 'staff_colleagues_screen.dart';
import 'staff_order_history_screen.dart';
import 'staff_tasks_screen.dart';
import 'update_staff_profile_screen.dart';
import 'weekly_shift_screen.dart';
import '../../customers/orders/presentation/customer_single_order_screen.dart';

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

  List<dynamic> _getFilteredNotifications(dynamic serverData) {
    List<dynamic> list = [];
    if (serverData is List) {
      list = serverData;
    } else if (serverData is Map && serverData['results'] is List) {
      list = serverData['results'] as List;
    }

    final deletedKeys = (appData.read('staff_deleted_notifications') is List)
        ? List<String>.from(appData.read('staff_deleted_notifications'))
        : <String>[];

    if (deletedKeys.isEmpty) return list;

    return list.where((item) {
      if (item is Map) {
        final id = item['id']?.toString() ?? '';
        return id.isEmpty || !deletedKeys.contains(id);
      }
      return true;
    }).toList();
  }

  void _markAllAsRead(List<dynamic> allNotifications) {
    if (allNotifications.isEmpty) return;
    NotificationUnreadManager.instance.markAllStaffNotificationsAsRead(allNotifications);
    AppToast.success('All notifications marked as read');
    setState(() {});
  }

  Map<String, dynamic> _getNotificationCategory(Map<String, dynamic> notif) {
    final title = (notif['title'] ?? '').toString().toLowerCase();
    final body = (notif['body'] ?? notif['message'] ?? '').toString().toLowerCase();
    final type = (notif['type'] ?? notif['category'] ?? notif['action'] ?? '').toString().toLowerCase();
    final combined = '$title $body $type';

    // 1. Task
    if (type.contains('task') || combined.contains('task') || combined.contains('todo') || combined.contains('assignment')) {
      return {
        'icon': Icons.checklist_rtl_rounded,
        'color': const Color(0xFF8B5CF6),
        'bg': const Color(0xFFF3E8FF),
        'tag': 'Task',
        'target': 'tasks',
      };
    }

    // 2. Day Off / Leave
    if (type.contains('leave') || type.contains('day_off') || combined.contains('day off') || combined.contains('leave request') || combined.contains('vacation') || combined.contains('holiday') || combined.contains('absence')) {
      return {
        'icon': Icons.event_busy_rounded,
        'color': const Color(0xFFEF4444),
        'bg': const Color(0xFFFEE2E2),
        'tag': 'Day Off',
        'target': 'day_off',
      };
    }

    // 3. Shift Change / Swap
    if (type.contains('shift_change') || type.contains('shift_swap') || combined.contains('shift change') || combined.contains('swap shift') || combined.contains('change request')) {
      return {
        'icon': Icons.edit_calendar_rounded,
        'color': const Color(0xFFF59E0B),
        'bg': const Color(0xFFFEF3C7),
        'tag': 'Shift Change',
        'target': 'shift_change',
      };
    }

    // 4. Weekly Shift / Roster / Hours
    if (type.contains('shift') || combined.contains('shift') || combined.contains('schedule') || combined.contains('roster') || combined.contains('check-in') || combined.contains('check-out') || combined.contains('store hours')) {
      return {
        'icon': Icons.calendar_view_week_rounded,
        'color': const Color(0xFF3B82F6),
        'bg': const Color(0xFFEFF6FF),
        'tag': 'Shift',
        'target': 'weekly_shift',
      };
    }

    // 5. Direct Message / Support / Admin Chat
    if (type.contains('chat') || type.contains('message') || combined.contains('message') || combined.contains('chat') || combined.contains('support') || combined.contains('admin')) {
      return {
        'icon': Icons.chat_bubble_outline_rounded,
        'color': const Color(0xFF06B6D4),
        'bg': const Color(0xFFECFEFF),
        'tag': 'Message',
        'target': 'chat',
      };
    }

    // 6. Price Alert / Produce Rates / Catalog
    if (type.contains('price') || combined.contains('price') || combined.contains('rate') || combined.contains('product') || combined.contains('produce')) {
      return {
        'icon': Icons.sell_rounded,
        'color': const Color(0xFF10B981),
        'bg': const Color(0xFFECFDF5),
        'tag': 'Price Alert',
        'target': 'price',
      };
    }

    // 7. Orders
    if (type.contains('order') || combined.contains('order') || combined.contains('purchase')) {
      return {
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
        'tag': 'Order',
        'target': 'order',
      };
    }

    // 8. Colleagues
    if (type.contains('colleague') || combined.contains('colleague') || combined.contains('team member')) {
      return {
        'icon': Icons.groups_rounded,
        'color': const Color(0xFF6366F1),
        'bg': const Color(0xFFEEF2FF),
        'tag': 'Team',
        'target': 'colleagues',
      };
    }

    // 9. Profile
    if (type.contains('profile') || combined.contains('profile') || combined.contains('password')) {
      return {
        'icon': Icons.person_outline_rounded,
        'color': const Color(0xFF64748B),
        'bg': const Color(0xFFF1F5F9),
        'tag': 'Profile',
        'target': 'profile',
      };
    }

    return {
      'icon': Icons.notifications_none_rounded,
      'color': const Color(0xFF00694C),
      'bg': const Color(0xFFE6F4EA),
      'tag': 'Notice',
      'target': 'general',
    };
  }

  void _onNotificationTap(Map<String, dynamic> notif) {
    final id = notif['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      NotificationUnreadManager.instance.markStaffNotificationAsRead(id);
      setState(() {});
    }

    final category = _getNotificationCategory(notif);
    final target = category['target'] as String;

    switch (target) {
      case 'tasks':
        Get.to(() => const StaffTasksScreen());
        break;
      case 'day_off':
        Get.to(() => const ApplyDayOffScreen());
        break;
      case 'shift_change':
        Get.to(() => const RequestShiftChangeScreen());
        break;
      case 'weekly_shift':
        Get.to(() => const WeeklyShiftScreen());
        break;
      case 'chat':
        Get.to(() => const StaffChatScreen());
        break;
      case 'price':
        Get.to(() => const PriceListScreen());
        break;
      case 'order':
        bool isValidOrderId(String? id) {
          if (id == null) return false;
          final clean = id.replaceAll('#', '').trim().toLowerCase();
          if (clean.isEmpty) return false;
          const invalidWords = {
            'placed', 'pending', 'confirmed', 'confirmation', 'shipped', 'delivered',
            'cancelled', 'canceled', 'received', 'details', 'notification', 'history',
            'status', 'success', 'failed', 'update', 'created', 'new', 'order', 'orders',
            'pedido', 'pedidos', 'null', 'undefined', 'view', 'item', 'items', 'processing'
          };
          return !invalidWords.contains(clean);
        }

        String? orderId;
        final candidates = [
          notif['order_id'],
          notif['order_number'],
          notif['target_id'],
          notif['orderId'],
          notif['data']?['order_id'],
          notif['data']?['order_number'],
          notif['order'] is Map ? notif['order']['order_number'] : null,
          notif['order'] is Map ? notif['order']['order_id'] : null,
          notif['order'] is Map ? notif['order']['id'] : null,
        ];

        for (final c in candidates) {
          if (c != null && isValidOrderId(c.toString())) {
            orderId = c.toString().trim();
            break;
          }
        }

        final titleStr = (notif['title'] ?? '').toString();
        final bodyStr = (notif['body'] ?? notif['message'] ?? '').toString();
        final combinedText = '$titleStr $bodyStr';

        if (orderId == null || orderId.isEmpty) {
          final hashRegex = RegExp(r'#(ORD-[A-Za-z0-9_\-]+|[A-Za-z0-9_\-]+)', caseSensitive: false);
          final match = hashRegex.firstMatch(combinedText);
          if (match != null && isValidOrderId(match.group(1))) {
            orderId = match.group(1)!.trim();
          }
        }

        if (orderId == null || orderId.isEmpty) {
          final ordCodeRegex = RegExp(r'\b(ORD-[0-9a-zA-Z]+)\b', caseSensitive: false);
          final match = ordCodeRegex.firstMatch(combinedText);
          if (match != null && isValidOrderId(match.group(1))) {
            orderId = match.group(1)!.trim();
          }
        }

        if (orderId != null && orderId.isNotEmpty && isValidOrderId(orderId)) {
          Get.to(() => CustomerSingleOrderScreen(
            orderId: orderId!,
            orderData: notif['order'] is Map ? Map<String, dynamic>.from(notif['order']) : null,
          ));
        } else {
          Get.to(() => const StaffOrderHistoryScreen());
        }
        break;
      case 'colleagues':
        Get.to(() => const StaffColleaguesScreen());
        break;
      case 'profile':
        Get.to(() => const UpdateStaffProfileScreen(initialName: '', initialPhone: ''));
        break;
      default:
        _showNotificationDetailsModal(notif, category);
        break;
    }
  }

  void _showNotificationDetailsModal(Map<String, dynamic> notif, Map<String, dynamic> category) {
    final title = notif['title'] ?? 'Notification Details';
    final body = notif['body'] ?? notif['message'] ?? 'No additional description provided.';
    final date = notif['created_at'] ?? notif['date'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: category['bg'],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(category['icon'], color: category['color'], size: 24.r),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: const Color(0xFF151E13),
                            ),
                          ),
                          if (date.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              date,
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    body,
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151), height: 1.45),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00694C),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                    child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteNotificationItem(String id) async {
    if (id.isEmpty) return;

    // 1. Add to local deleted blacklist for instant UI response
    try {
      final deletedKeys = (appData.read('staff_deleted_notifications') is List)
          ? List<String>.from(appData.read('staff_deleted_notifications'))
          : <String>[];
      if (!deletedKeys.contains(id)) {
        deletedKeys.add(id);
        appData.write('staff_deleted_notifications', deletedKeys);
      }
    } catch (_) {}

    setState(() {});

    // 2. Call API to delete on server
    final success = await _rx.deleteNotification(id);
    if (success) {
      AppToast.success('Notification deleted');
    }
    _rx.fetchNotifications();
  }

  Future<void> _clearAllNotifications(List<dynamic> notifications) async {
    if (notifications.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 22),
            ),
            SizedBox(width: 10.w),
            const Text('Clear All?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all notifications from your inbox?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: const Text('Delete All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      EasyLoading.show(status: 'Deleting all...');
      final ids = notifications.map((e) => e['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList();

      // Local blacklist
      try {
        final deletedKeys = (appData.read('staff_deleted_notifications') is List)
            ? List<String>.from(appData.read('staff_deleted_notifications'))
            : <String>[];
        for (final id in ids) {
          if (!deletedKeys.contains(id)) deletedKeys.add(id);
        }
        appData.write('staff_deleted_notifications', deletedKeys);
      } catch (_) {}

      final success = await _rx.bulkDeleteNotifications(ids);
      EasyLoading.dismiss();

      if (success) {
        AppToast.success('All notifications cleared');
      } else {
        AppToast.success('Notifications cleared');
      }
      _rx.fetchNotifications();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return StreamBuilder<dynamic>(
      stream: _rx.valueStreamData,
      builder: (context, snapshot) {
        final allNotifications = _getFilteredNotifications(snapshot.data);
        final unreadCount = NotificationUnreadManager.instance.calculateStaffUnread(allNotifications);

        // Filter notifications into sub categories
        final tasksAndShifts = allNotifications.where((notif) {
          if (notif is! Map<String, dynamic>) return false;
          final cat = _getNotificationCategory(notif)['target'];
          return cat == 'tasks' || cat == 'day_off' || cat == 'shift_change' || cat == 'weekly_shift';
        }).toList();

        final priceAlerts = allNotifications.where((notif) {
          if (notif is! Map<String, dynamic>) return false;
          final cat = _getNotificationCategory(notif)['target'];
          return cat == 'price';
        }).toList();

        final directMessages = allNotifications.where((notif) {
          if (notif is! Map<String, dynamic>) return false;
          final cat = _getNotificationCategory(notif)['target'];
          return cat == 'chat' || cat == 'order' || cat == 'colleagues' || cat == 'profile' || cat == 'general';
        }).toList();

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: const Color(0xFFFAFAF8),
            appBar: AppBar(
              title: Text(
                unreadCount > 0 ? 'Notifications ($unreadCount)' : 'Notifications Inbox',
                style: TextStyle(
                  color: const Color(0xFF151E13),
                  fontFamily: 'Poppins',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
                onPressed: () => Navigator.maybePop(context),
              ),
              actions: [
                if (unreadCount > 0)
                  IconButton(
                    icon: const Icon(Icons.done_all_rounded, color: Color(0xFF151E13)),
                    tooltip: 'Mark All as Read',
                    onPressed: () => _markAllAsRead(allNotifications),
                  ),
                if (allNotifications.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                    tooltip: 'Clear All Notifications',
                    onPressed: () => _clearAllNotifications(allNotifications),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF151E13)),
                  tooltip: 'Refresh',
                  onPressed: () => _rx.fetchNotifications(),
                ),
                SizedBox(width: 8.w),
              ],
              bottom: const TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                isScrollable: true,
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Tasks & Shifts'),
                  Tab(text: 'Price Alerts'),
                  Tab(text: 'Messages'),
                ],
              ),
            ),
            body: Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting && allNotifications.isEmpty) {
                  return const CustomAppLoading(message: 'Loading notifications...');
                }

                return TabBarView(
                  children: [
                    _buildNotificationList(allNotifications),
                    _buildNotificationList(tasksAndShifts),
                    _buildNotificationList(priceAlerts),
                    _buildNotificationList(directMessages),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationList(List<dynamic> alerts) {
    if (alerts.isEmpty) {
      return const NoInternetOrDataWidget(
        title: 'No Notifications',
        message: 'No notifications in this category.',
        isFullPage: false,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF00694C),
      onRefresh: () async {
        await _rx.fetchNotifications();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index] is Map ? Map<String, dynamic>.from(alerts[index]) : <String, dynamic>{};
          final id = alert['id']?.toString() ?? '';
          final title = alert['title'] ?? 'Notification';
          final body = alert['body'] ?? alert['message'] ?? '';
          final date = alert['created_at'] ?? alert['date'] ?? '';
          final isRead = NotificationUnreadManager.instance.isStaffNotificationRead(alert);
          final category = _getNotificationCategory(alert);
          final IconData icon = category['icon'];
          final Color badgeColor = category['color'];
          final Color bg = category['bg'];
          final String tag = category['tag'];

          return Dismissible(
            key: Key(id.isNotEmpty ? id : 'notif_$index'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.w),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
            ),
            onDismissed: (direction) {
              if (id.isNotEmpty) {
                _deleteNotificationItem(id);
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: isRead ? Colors.white : const Color(0xFFF6FBF8),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isRead ? Colors.grey.shade100 : badgeColor.withValues(alpha: 0.35),
                  width: isRead ? 1.0 : 1.5,
                ),
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
                borderRadius: BorderRadius.circular(14.r),
                child: InkWell(
                  onTap: () => _onNotificationTap(alert),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Padding(
                    padding: EdgeInsets.all(14.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: isRead ? bg.withValues(alpha: 0.5) : bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: badgeColor, size: 22.r),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!isRead)
                                    Container(
                                      width: 8.r,
                                      height: 8.r,
                                      margin: EdgeInsets.only(right: 6.w),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Text(
                                    date,
                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: const Color(0xFF151E13),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (body.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  body,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF6D7A73),
                                    height: 1.35,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Tap to view',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: badgeColor,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Icon(Icons.arrow_forward_ios_rounded, size: 10.r, color: badgeColor),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (id.isNotEmpty) {
                                        _deleteNotificationItem(id);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18.r,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
