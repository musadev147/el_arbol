import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../constants/app_constants.dart';
import 'di.dart';

/// Centralized manager tracking unread Admin/Support replies on support tickets
/// for both Customer and Wholesale users.
class SupportTicketUnreadManager {
  static final SupportTicketUnreadManager instance = SupportTicketUnreadManager._();
  SupportTicketUnreadManager._();

  /// Total unread ticket count for Customer
  final RxInt customerUnreadCountRx = 0.obs;

  /// Total unread ticket count for Wholesale
  final RxInt wholesaleUnreadCountRx = 0.obs;

  /// Map of ticketId -> unreadCount for reactive UI per ticket card
  final RxMap<String, int> ticketUnreadMap = <String, int>{}.obs;

  /// Cached list of current customer tickets
  List<dynamic> _lastCustomerTickets = [];

  /// Cached list of current wholesale tickets
  List<dynamic> _lastWholesaleTickets = [];

  void _safeUpdate(void Function() updateFn) {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      updateFn();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateFn();
      });
    }
  }

  /// Checks if a message/reply map was sent by Admin or Support staff
  bool isMessageFromAdmin(Map<String, dynamic> r) {
    final currentUserId = appData.read(kKeyUserID)?.toString().trim() ?? '';
    final currentUserEmail = appData.read(kKeyEmail)?.toString().trim().toLowerCase() ?? '';

    String senderId = '';
    String senderEmail = '';
    String senderName = '';
    String role = '';
    bool isStaffOrAdminFlag = false;

    if (r['user'] is Map) {
      final u = r['user'] as Map;
      senderId = (u['id'] ?? u['user_id'] ?? u['pk'])?.toString().trim() ?? '';
      senderEmail = (u['email'] ?? u['user_email'])?.toString().trim().toLowerCase() ?? '';
      senderName = (u['name'] ?? u['username'] ?? u['first_name'] ?? '')?.toString().trim().toLowerCase() ?? '';
      role = (u['user_type'] ?? u['role'] ?? u['user_role'] ?? '')?.toString().trim().toLowerCase() ?? '';
      if (u['is_staff'] == true || u['is_admin'] == true || u['is_superuser'] == true) {
        isStaffOrAdminFlag = true;
      }
    } else if (r['sender'] is Map) {
      final u = r['sender'] as Map;
      senderId = (u['id'] ?? u['user_id'] ?? u['pk'])?.toString().trim() ?? '';
      senderEmail = (u['email'] ?? u['user_email'])?.toString().trim().toLowerCase() ?? '';
      senderName = (u['name'] ?? u['username'] ?? u['first_name'] ?? '')?.toString().trim().toLowerCase() ?? '';
      role = (u['user_type'] ?? u['role'] ?? u['user_role'] ?? '')?.toString().trim().toLowerCase() ?? '';
      if (u['is_staff'] == true || u['is_admin'] == true || u['is_superuser'] == true) {
        isStaffOrAdminFlag = true;
      }
    } else if (r['author'] is Map) {
      final u = r['author'] as Map;
      senderId = (u['id'] ?? u['user_id'] ?? u['pk'])?.toString().trim() ?? '';
      senderEmail = (u['email'] ?? u['user_email'])?.toString().trim().toLowerCase() ?? '';
      senderName = (u['name'] ?? u['username'] ?? u['first_name'] ?? '')?.toString().trim().toLowerCase() ?? '';
      role = (u['user_type'] ?? u['role'] ?? u['user_role'] ?? '')?.toString().trim().toLowerCase() ?? '';
      if (u['is_staff'] == true || u['is_admin'] == true || u['is_superuser'] == true) {
        isStaffOrAdminFlag = true;
      }
    }

    if (senderId.isEmpty) {
      senderId = (r['user_id'] ?? r['sender_id'] ?? r['author_id'] ?? (r['user'] is! Map ? r['user'] : null) ?? (r['sender'] is! Map ? r['sender'] : null))?.toString().trim() ?? '';
    }
    if (senderEmail.isEmpty) {
      senderEmail = (r['senderEmail'] ?? r['sender_email'] ?? r['email'] ?? r['user_email'])?.toString().trim().toLowerCase() ?? '';
    }
    if (senderName.isEmpty) {
      senderName = (r['senderName'] ?? r['sender_name'] ?? (r['sender'] is! Map ? r['sender'] : null) ?? r['user_name'] ?? (r['author'] is! Map ? r['author'] : null) ?? r['name'])?.toString().trim().toLowerCase() ?? '';
    }
    if (role.isEmpty) {
      role = (r['sender_role'] ?? r['user_role'] ?? r['role'] ?? r['user_type'] ?? r['sender_type'])?.toString().trim().toLowerCase() ?? '';
    }

    if (r['is_admin'] == true || r['isAdmin'] == true || r['is_staff'] == true || r['is_support'] == true || r['is_superuser'] == true) {
      isStaffOrAdminFlag = true;
    }

    final bool isExplicitAdminOrStaff = isStaffOrAdminFlag ||
        role.contains('admin') ||
        role.contains('support') ||
        role.contains('staff') ||
        role.contains('agent') ||
        role.contains('helpdesk') ||
        role.contains('superuser') ||
        senderName.contains('admin') ||
        senderName.contains('support') ||
        senderName.contains('staff') ||
        senderName.contains('agent') ||
        senderName.contains('helpdesk') ||
        senderName.contains('elarbol') ||
        senderName.contains('el árbol');

    final bool isMe = r['isMe'] == true ||
        r['is_me'] == true ||
        r['sender'] == 'You' ||
        (currentUserId.isNotEmpty && senderId.isNotEmpty && senderId == currentUserId) ||
        (currentUserEmail.isNotEmpty && senderEmail.isNotEmpty && senderEmail == currentUserEmail);

    if (isExplicitAdminOrStaff) return true;
    if (isMe) return false;
    if (currentUserId.isNotEmpty && senderId.isNotEmpty && senderId != currentUserId) return true;

    return false;
  }

  /// Calculates the number of unread Admin replies for a ticket (pure calculation, no side-effects)
  int getUnreadCountForTicket(Map<String, dynamic> ticket) {
    final ticketId = ticket['id']?.toString() ?? '';
    if (ticketId.isEmpty) return 0;

    // Direct backend unread count if provided
    if (ticket['unread_count'] is int) {
      return ticket['unread_count'] as int;
    }

    final dynamic storedLastReadId = appData.read('ticket_last_read_reply_id_$ticketId');
    final int lastReadId = storedLastReadId is int
        ? storedLastReadId
        : (int.tryParse(storedLastReadId?.toString() ?? '0') ?? 0);

    final String? lastReadTimeStr = appData.read('ticket_last_read_time_$ticketId');
    final DateTime? lastReadTime = lastReadTimeStr != null ? DateTime.tryParse(lastReadTimeStr) : null;

    final replies = ticket['messages'] ?? ticket['replies'] ?? ticket['data']?['messages'] ?? [];
    if (replies is! List || replies.isEmpty) {
      // Check if ticket metadata indicates an unread admin reply
      final lastSenderRole = (ticket['last_reply_by'] ?? ticket['last_sender_role'] ?? ticket['last_sender'] ?? '')
          .toString()
          .toLowerCase();
      if (lastSenderRole.contains('admin') || lastSenderRole.contains('support')) {
        final updatedAtStr = ticket['updated_at']?.toString() ?? '';
        final updatedAt = DateTime.tryParse(updatedAtStr);
        if (updatedAt != null && (lastReadTime == null || updatedAt.isAfter(lastReadTime))) {
          return 1;
        }
      }
      return 0;
    }

    int unread = 0;
    for (var r in replies) {
      if (r is! Map) continue;
      final map = Map<String, dynamic>.from(r);
      if (!isMessageFromAdmin(map)) continue;

      final msgId = int.tryParse(map['id']?.toString() ?? '0') ?? 0;
      if (msgId > 0 && lastReadId > 0) {
        if (msgId > lastReadId) {
          unread++;
        }
      } else if (lastReadTime != null) {
        final createdAtStr = map['created_at'] ?? map['date'] ?? map['timestamp'] ?? '';
        final createdAt = DateTime.tryParse(createdAtStr.toString());
        if (createdAt != null && createdAt.isAfter(lastReadTime)) {
          unread++;
        } else if (map['is_read'] == false || map['read'] == false) {
          unread++;
        }
      } else {
        // Never read before: count as unread if marked unread or if no flag present
        if (map['is_read'] == false || map['read'] == false) {
          unread++;
        } else if (!map.containsKey('is_read') && !map.containsKey('read')) {
          unread++;
        }
      }
    }

    return unread;
  }

  /// Marks a ticket's current replies as read
  void markTicketAsRead(Map<String, dynamic> ticket) {
    final ticketId = ticket['id']?.toString() ?? '';
    if (ticketId.isEmpty) return;

    final replies = ticket['messages'] ?? ticket['replies'] ?? ticket['data']?['messages'] ?? [];
    int maxAdminMsgId = 0;
    if (replies is List) {
      for (var r in replies) {
        if (r is! Map) continue;
        final map = Map<String, dynamic>.from(r);
        if (isMessageFromAdmin(map)) {
          final msgId = int.tryParse(map['id']?.toString() ?? '0') ?? 0;
          if (msgId > maxAdminMsgId) {
            maxAdminMsgId = msgId;
          }
        }
      }
    }

    if (maxAdminMsgId > 0) {
      appData.write('ticket_last_read_reply_id_$ticketId', maxAdminMsgId);
    }
    appData.write('ticket_last_read_time_$ticketId', DateTime.now().toIso8601String());

    _safeUpdate(() {
      ticketUnreadMap[ticketId] = 0;
      _recalculateCustomerTotalInternal();
      _recalculateWholesaleTotalInternal();
    });
  }

  /// Updates Customer tickets list and calculates unread count
  void updateCustomerTickets(List<dynamic> tickets) {
    _lastCustomerTickets = tickets;
    _safeUpdate(() {
      final Map<String, int> newMap = {};
      int total = 0;
      for (var t in _lastCustomerTickets) {
        if (t is Map) {
          final tMap = Map<String, dynamic>.from(t);
          final id = tMap['id']?.toString() ?? '';
          final count = getUnreadCountForTicket(tMap);
          if (id.isNotEmpty) {
            newMap[id] = count;
          }
          if (count > 0) {
            total += count;
          }
        }
      }
      ticketUnreadMap.addAll(newMap);
      customerUnreadCountRx.value = total;
    });
  }

  /// Updates Wholesale tickets list and calculates unread count
  void updateWholesaleTickets(List<dynamic> tickets) {
    _lastWholesaleTickets = tickets;
    _safeUpdate(() {
      final Map<String, int> newMap = {};
      int total = 0;
      for (var t in _lastWholesaleTickets) {
        if (t is Map) {
          final tMap = Map<String, dynamic>.from(t);
          final id = tMap['id']?.toString() ?? '';
          final count = getUnreadCountForTicket(tMap);
          if (id.isNotEmpty) {
            newMap[id] = count;
          }
          if (count > 0) {
            total += count;
          }
        }
      }
      ticketUnreadMap.addAll(newMap);
      wholesaleUnreadCountRx.value = total;
    });
  }

  void _recalculateCustomerTotalInternal() {
    int total = 0;
    for (var t in _lastCustomerTickets) {
      if (t is Map) {
        final tMap = Map<String, dynamic>.from(t);
        final id = tMap['id']?.toString() ?? '';
        final count = ticketUnreadMap[id] ?? getUnreadCountForTicket(tMap);
        if (count > 0) {
          total += count;
        }
      }
    }
    customerUnreadCountRx.value = total;
  }

  void _recalculateWholesaleTotalInternal() {
    int total = 0;
    for (var t in _lastWholesaleTickets) {
      if (t is Map) {
        final tMap = Map<String, dynamic>.from(t);
        final id = tMap['id']?.toString() ?? '';
        final count = ticketUnreadMap[id] ?? getUnreadCountForTicket(tMap);
        if (count > 0) {
          total += count;
        }
      }
    }
    wholesaleUnreadCountRx.value = total;
  }
}
