import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../helpers/notification_unread_manager.dart';
import '../../../../helpers/di.dart';
import '../data/customer_notifications_rx.dart';
import '../../tickets/data/customer_tickets_api.dart';
import '../../tickets/presentation/customer_ticket_chat_screen.dart';
import '../../tickets/presentation/customer_tickets_screen.dart';
import '../../orders/presentation/customer_single_order_screen.dart';
import '../../orders/data/customer_orders_api.dart';

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

  String _formatNotificationDate(dynamic rawDate) {
    if (rawDate == null || rawDate.toString().trim().isEmpty) return 'Recently';
    final str = rawDate.toString().trim();
    try {
      final parsed = DateTime.tryParse(str);
      if (parsed != null) {
        return DateFormat('dd MMM, HH:mm').format(parsed.toLocal());
      }
    } catch (_) {}
    return str;
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getMergedNotifications(dynamic serverData) {
    final List<Map<String, dynamic>> merged = [];
    final List<String> deletedKeys = (appData.read('customer_deleted_notifications') is List)
        ? List<String>.from(appData.read('customer_deleted_notifications'))
        : [];

    // 1. Local customer notifications (e.g. from checkout or placed orders)
    try {
      final local = appData.read('customer_local_notifications');
      if (local is List) {
        for (final item in local) {
          if (item is Map) {
            final id = item['id']?.toString() ?? '';
            if (id.isNotEmpty && !deletedKeys.contains(id)) {
              merged.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }
    } catch (_) {}

    // 2. Server notifications
    List<dynamic> serverList = [];
    if (serverData is List) {
      serverList = serverData;
    } else if (serverData is Map && serverData['results'] is List) {
      serverList = serverData['results'] as List;
    } else if (serverData is Map && serverData['data'] is List) {
      serverList = serverData['data'] as List;
    }

    for (final item in serverList) {
      if (item is Map) {
        final id = item['id']?.toString() ?? '';
        if (id.isNotEmpty && !deletedKeys.contains(id)) {
          if (!merged.any((m) => m['id']?.toString() == id)) {
            merged.add(Map<String, dynamic>.from(item));
          }
        }
      }
    }

    // 3. Fallback: Generate notifications for locally placed customer orders if missing
    try {
      final placedOrders = appData.read('customer_placed_orders');
      if (placedOrders is List && placedOrders.isNotEmpty) {
        for (final ord in placedOrders) {
          if (ord is Map) {
            final orderNum = ord['order_number'] ?? ord['id'] ?? ord['order_id'] ?? '';
            final notifId = 'order_notif_$orderNum';
            if (orderNum.toString().isNotEmpty &&
                !deletedKeys.contains(notifId) &&
                !merged.any((m) => m['order_id']?.toString() == orderNum.toString() ||
                    m['order_number']?.toString() == orderNum.toString() ||
                    m['id']?.toString() == notifId)) {
              final total = ord['total'] ?? ord['total_amount'] ?? '0.00';
              merged.add({
                'id': notifId,
                'title': 'Order #$orderNum Placed',
                'message': 'Your order for €$total has been received and is being processed.',
                'created_at': ord['created_at'] ?? 'Recent',
                'type': 'order',
                'order_id': orderNum.toString(),
                'order_number': orderNum.toString(),
                'order': ord,
                'is_read': false,
              });
            }
          }
        }
      }
    } catch (_) {}

    return merged;
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
                final ids = notifications.map((e) => (e is Map ? e['id']?.toString() : e.toString()) ?? '').where((id) => id.isNotEmpty).toList();

                // Save to deleted blacklist
                try {
                  final deletedKeys = (appData.read('customer_deleted_notifications') is List)
                      ? List<String>.from(appData.read('customer_deleted_notifications'))
                      : <String>[];
                  for (final id in ids) {
                    if (!deletedKeys.contains(id)) deletedKeys.add(id);
                  }
                  appData.write('customer_deleted_notifications', deletedKeys);
                  appData.remove('customer_local_notifications');
                } catch (_) {}

                await _rx.bulkDeleteNotifications(ids);
                _rx.fetchNotifications();
                setState(() {});
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSingleNotification(String id) async {
    if (id.isEmpty) return;
    try {
      final deletedKeys = (appData.read('customer_deleted_notifications') is List)
          ? List<String>.from(appData.read('customer_deleted_notifications'))
          : <String>[];
      if (!deletedKeys.contains(id)) {
        deletedKeys.add(id);
        appData.write('customer_deleted_notifications', deletedKeys);
      }

      final local = appData.read('customer_local_notifications');
      if (local is List) {
        final updated = List<dynamic>.from(local);
        updated.removeWhere((item) => item is Map && item['id']?.toString() == id);
        appData.write('customer_local_notifications', updated);
      }
    } catch (_) {}

    await _rx.bulkDeleteNotifications([id]);
    _rx.fetchNotifications();
    setState(() {});
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

    final rawTitle = (notif['title'] ?? notif['subject'] ?? '').toString();
    final rawBody = (notif['body'] ?? notif['message'] ?? notif['description'] ?? '').toString();
    final rawType = (notif['type'] ?? notif['action'] ?? notif['category'] ?? '').toString();

    final title = rawTitle.toLowerCase();
    final body = rawBody.toLowerCase();
    final type = rawType.toLowerCase();

    // 1. Check if notification is related to an Order
    final bool isOrderRelated = type.contains('order') ||
        type.contains('purchase') ||
        type.contains('delivery') ||
        type.contains('shipping') ||
        title.contains('order') ||
        title.contains('pedido') ||
        title.contains('compra') ||
        body.contains('order') ||
        body.contains('delivery') ||
        body.contains('shipped') ||
        body.contains('dispatched') ||
        notif['order_id'] != null ||
        notif['order_number'] != null ||
        notif['orderId'] != null ||
        notif['orderNumber'] != null ||
        notif['order'] != null;

    if (isOrderRelated) {
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
        notif['orderId'],
        notif['orderNumber'],
        notif['target_id'],
        notif['data']?['order_id'],
        notif['data']?['order_number'],
        notif['data']?['orderId'],
        notif['data']?['id'],
        notif['order'] is Map ? notif['order']['order_number'] : null,
        notif['order'] is Map ? notif['order']['order_id'] : null,
        notif['order'] is Map ? notif['order']['id'] : null,
        notif['id']?.toString().startsWith('order_notif_') == true
            ? notif['id']?.toString().replaceFirst('order_notif_', '')
            : null,
      ];

      for (final c in candidates) {
        if (c != null && isValidOrderId(c.toString())) {
          orderId = c.toString().trim();
          break;
        }
      }

      final combinedText = '$rawTitle $rawBody';
      if (orderId == null || orderId.isEmpty) {
        final hashRegex = RegExp(r'#(ORD-[A-Za-z0-9_\-]+|[A-Za-z0-9_\-]+)', caseSensitive: false);
        final match = hashRegex.firstMatch(combinedText);
        if (match != null && isValidOrderId(match.group(1))) {
          orderId = match.group(1)!.trim();
        }
      }

      if (orderId == null || orderId.isEmpty) {
        final ordCodeRegex = RegExp(r'\b(ORD-[0-9a-zA-Z_\-]+)\b', caseSensitive: false);
        final match = ordCodeRegex.firstMatch(combinedText);
        if (match != null && isValidOrderId(match.group(1))) {
          orderId = match.group(1)!.trim();
        }
      }

      if (orderId == null || orderId.isEmpty) {
        final generalOrderRegex = RegExp(r'(?:order|pedido|orden)\s*(?:#|no\.?|number)?\s*([A-Za-z0-9_\-]+)', caseSensitive: false);
        final match = generalOrderRegex.firstMatch(combinedText);
        if (match != null && isValidOrderId(match.group(1))) {
          orderId = match.group(1)!.trim();
        }
      }

      Map<String, dynamic>? orderData = notif['order'] is Map ? Map<String, dynamic>.from(notif['order']) : null;

      // Try matching from locally placed orders
      if (orderId != null && orderId.isNotEmpty) {
        final cleanSearch = orderId.replaceAll('#', '').trim().toLowerCase();
        try {
          final localCust = appData.read('customer_placed_orders');
          if (localCust is List) {
            for (final ord in localCust) {
              if (ord is Map) {
                final k = (ord['order_number'] ?? ord['id'] ?? ord['order_id'] ?? '').toString().replaceAll('#', '').trim().toLowerCase();
                if (k == cleanSearch) {
                  orderData ??= Map<String, dynamic>.from(ord);
                  break;
                }
              }
            }
          }
        } catch (_) {}
      }

      // If still no orderId found, look for the most recent local placed order
      if (orderId == null || orderId.isEmpty) {
        try {
          final localCust = appData.read('customer_placed_orders');
          if (localCust is List && localCust.isNotEmpty) {
            final firstOrd = localCust.first;
            if (firstOrd is Map) {
              orderData = Map<String, dynamic>.from(firstOrd);
              orderId = (firstOrd['order_number'] ?? firstOrd['id'] ?? firstOrd['order_id'] ?? '').toString();
            }
          }
        } catch (_) {}
      }

      final finalOrderId = (orderId != null && orderId.isNotEmpty && isValidOrderId(orderId))
          ? orderId
          : 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Attempt to fetch latest details from API, fallback gracefully to orderData
      try {
        EasyLoading.show(status: 'Opening order...');
        final fetched = await CustomerOrdersApi.instance.getOrderDetails(finalOrderId);
        EasyLoading.dismiss();
        if (fetched is Map && fetched.isNotEmpty) {
          Map<String, dynamic> resolved = Map<String, dynamic>.from(fetched);
          if (resolved.containsKey('data') && resolved['data'] is Map) {
            resolved = Map<String, dynamic>.from(resolved['data']);
          } else if (resolved.containsKey('order') && resolved['order'] is Map) {
            resolved = Map<String, dynamic>.from(resolved['order']);
          }
          Get.to(() => CustomerSingleOrderScreen(orderId: finalOrderId, orderData: resolved));
          return;
        }
      } catch (_) {
        EasyLoading.dismiss();
      }

      Get.to(() => CustomerSingleOrderScreen(orderId: finalOrderId, orderData: orderData));
      return;
    }

    // 2. Check if notification is related to a Support Ticket
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

    // 3. Fallback: Show Notification Details Modal
    _showNotificationDetailsModal(notif);
  }

  void _showNotificationDetailsModal(Map<String, dynamic> notif) {
    final title = notif['title'] ?? notif['subject'] ?? 'Notification Details';
    final body = notif['body'] ?? notif['message'] ?? notif['description'] ?? 'No additional details provided.';
    final date = notif['created_at'] ?? notif['date'] ?? notif['timestamp'] ?? '';

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
                        color: const Color(0xFF00694C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active, color: Color(0xFF00694C), size: 24),
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
                          if (date.toString().isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              date.toString(),
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: StreamBuilder<List<dynamic>>(
          stream: _rx.valueStreamData,
          builder: (context, snapshot) {
            final merged = _getMergedNotifications(snapshot.data);
            final unreadCount = NotificationUnreadManager.instance.calculateCustomerUnread(merged);
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
              final notifications = _getMergedNotifications(snapshot.data);
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
          if (snapshot.connectionState == ConnectionState.waiting && (!snapshot.hasData || (snapshot.data as List).isEmpty)) {
            return const CustomAppLoading(message: 'Loading notifications...');
          }

          final notifications = _getMergedNotifications(snapshot.data);

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

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              await _rx.fetchNotifications();
            },
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final id = notif['id']?.toString() ?? '';
                final bool isRead = NotificationUnreadManager.instance.isCustomerNotificationRead(notif);
                final type = (notif['type'] ?? notif['category'] ?? '').toString().toLowerCase();
                final title = (notif['title'] ?? notif['subject'] ?? '').toString();
                final body = (notif['body'] ?? notif['message'] ?? notif['description'] ?? '').toString();

                IconData iconData = isRead ? Icons.notifications_none : Icons.notifications_active;
                Color iconColor = primaryColor;
                String tag = 'Notification';

                if (type.contains('order') || title.toLowerCase().contains('order') || body.toLowerCase().contains('order')) {
                  iconData = Icons.receipt_long_rounded;
                  iconColor = const Color(0xFF00694C);
                  tag = 'Order';
                } else if (type.contains('ticket') || type.contains('support') || title.toLowerCase().contains('ticket') || body.toLowerCase().contains('ticket')) {
                  iconData = Icons.support_agent_rounded;
                  iconColor = Colors.blue.shade700;
                  tag = 'Support';
                }

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
                                  ? iconColor.withValues(alpha: 0.08)
                                  : iconColor.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              color: iconColor,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: iconColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                          color: iconColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        title.isNotEmpty ? title : 'Notification',
                                        style: TextStyle(
                                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                          fontSize: 13.5.sp,
                                          color: const Color(0xFF151E13),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                SizedBox(height: 6.h),
                                Text(
                                  body,
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5.sp, height: 1.3),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatNotificationDate(notif['created_at'] ?? notif['date'] ?? notif['timestamp']),
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Tap to view',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: iconColor,
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Icon(Icons.arrow_forward_ios_rounded, size: 9.r, color: iconColor),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                            onPressed: () {
                              if (id.isNotEmpty) {
                                _deleteSingleNotification(id);
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
            ),
          );
        },
      ),
    );
  }
}
