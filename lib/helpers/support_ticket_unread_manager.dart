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

  /// Checks if a message/reply map was sent by Admin or Support staff
  bool isMessageFromAdmin(Map<String, dynamic> r) {
    final currentUserId = appData.read(kKeyUserID)?.toString().trim() ?? '';
    final currentUserEmail = appData.read(kKeyEmail)?.toString().trim().toLowerCase() ?? '';

    final role = (r['sender_role'] ?? r['user_role'] ?? r['role'] ?? r['user_type'] ?? r['sender_type'] ?? '')
        .toString()
        .toLowerCase();
    final senderStr = (r['sender'] ?? r['user_name'] ?? r['author'] ?? r['name'] ?? '')
        .toString()
        .toLowerCase();

    final bool isExplicitAdminOrStaff = role.contains('admin') ||
        role.contains('support') ||
        role.contains('staff') ||
        role.contains('agent') ||
        role.contains('helpdesk') ||
        senderStr.contains('admin') ||
        senderStr.contains('support') ||
        senderStr.contains('staff') ||
        senderStr.contains('agent') ||
        senderStr.contains('helpdesk') ||
        r['is_admin'] == true ||
        r['is_support'] == true;

    final senderId = (r['user_id'] ?? r['user'] ?? r['sender_id'] ?? r['author_id'])?.toString().trim() ?? '';
    final senderEmail = (r['email'] ?? r['user_email'] ?? r['sender_email'])?.toString().trim().toLowerCase() ?? '';

    final bool isMe = r['isMe'] == true ||
        r['is_me'] == true ||
        r['sender'] == 'You' ||
        (currentUserId.isNotEmpty && senderId.isNotEmpty && senderId == currentUserId) ||
        (currentUserEmail.isNotEmpty && senderEmail.isNotEmpty && senderEmail == currentUserEmail);

    if (isMe) return false;
    if (isExplicitAdminOrStaff) return true;

    // If not authored by me and sender is not customer/wholesale user, treat as admin reply
    if (role != 'customer' && role != 'wholesale') return true;

    return false;
  }

  /// Calculates the number of unread Admin replies for a ticket
  int getUnreadCountForTicket(Map<String, dynamic> ticket) {
    final ticketId = ticket['id']?.toString() ?? '';
    if (ticketId.isEmpty) return 0;

    // Direct backend unread count if provided
    if (ticket['unread_count'] is int) {
      final unread = ticket['unread_count'] as int;
      ticketUnreadMap[ticketId] = unread;
      return unread;
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
          ticketUnreadMap[ticketId] = 1;
          return 1;
        }
      }
      ticketUnreadMap[ticketId] = 0;
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

    ticketUnreadMap[ticketId] = unread;
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

    ticketUnreadMap[ticketId] = 0;

    // Recalculate totals
    _recalculateCustomerTotal();
    _recalculateWholesaleTotal();
  }

  /// Updates Customer tickets list and calculates unread count
  void updateCustomerTickets(List<dynamic> tickets) {
    _lastCustomerTickets = tickets;
    _recalculateCustomerTotal();
  }

  /// Updates Wholesale tickets list and calculates unread count
  void updateWholesaleTickets(List<dynamic> tickets) {
    _lastWholesaleTickets = tickets;
    _recalculateWholesaleTotal();
  }

  void _recalculateCustomerTotal() {
    int total = 0;
    for (var t in _lastCustomerTickets) {
      if (t is Map) {
        final count = getUnreadCountForTicket(Map<String, dynamic>.from(t));
        if (count > 0) {
          total += count;
        }
      }
    }
    customerUnreadCountRx.value = total;
  }

  void _recalculateWholesaleTotal() {
    int total = 0;
    for (var t in _lastWholesaleTickets) {
      if (t is Map) {
        final count = getUnreadCountForTicket(Map<String, dynamic>.from(t));
        if (count > 0) {
          total += count;
        }
      }
    }
    wholesaleUnreadCountRx.value = total;
  }
}
