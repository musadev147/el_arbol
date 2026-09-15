import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'di.dart';
import '../featuers/wholesale_b2b/data/wholesale_api.dart';

/// Centralized manager tracking read/unread notification states across
/// Customer, Wholesale (B2B), and Staff roles.
class NotificationUnreadManager {
  static final NotificationUnreadManager instance = NotificationUnreadManager._();
  NotificationUnreadManager._();

  static const String _kCustomerReadNotifications = 'customer_read_notifications';
  static const String _kWholesaleReadNotifications = 'wholesale_read_notifications';
  static const String _kStaffReadNotifications = 'staff_read_notifications';

  /// Reactive unread count for Customer
  final RxInt customerUnreadCountRx = 0.obs;

  /// Reactive unread count for Wholesale
  final RxInt wholesaleUnreadCountRx = 0.obs;

  /// Reactive unread count for Staff
  final RxInt staffUnreadCountRx = 0.obs;

  void _safeUpdate(void Function() updateFn) {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      updateFn();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateFn();
      });
    }
  }

  // ==========================================
  // CUSTOMER NOTIFICATIONS
  // ==========================================

  Set<String> getCustomerReadIds() {
    try {
      final raw = appData.read(_kCustomerReadNotifications);
      if (raw is List) {
        return Set<String>.from(raw.map((e) => e.toString()));
      }
    } catch (_) {}
    return <String>{};
  }

  bool isCustomerNotificationRead(dynamic notif) {
    if (notif == null) return true;
    if (notif is Map) {
      if (notif['is_read'] == true || notif['read'] == true || notif['isRead'] == true) {
        return true;
      }
      final id = notif['id']?.toString();
      if (id != null && id.isNotEmpty) {
        return getCustomerReadIds().contains(id);
      }
    }
    return false;
  }

  void markCustomerNotificationAsRead(String id) {
    if (id.isEmpty) return;
    try {
      final set = getCustomerReadIds();
      if (!set.contains(id)) {
        set.add(id);
        appData.write(_kCustomerReadNotifications, set.toList());
      }
      if (customerUnreadCountRx.value > 0) {
        _safeUpdate(() {
          customerUnreadCountRx.value = (customerUnreadCountRx.value - 1).clamp(0, 9999);
        });
      }
    } catch (e) {
      log('Error marking customer notification as read: $e');
    }
  }

  void markAllCustomerNotificationsAsRead(List<dynamic> notifs) {
    try {
      final set = getCustomerReadIds();
      for (final n in notifs) {
        if (n is Map) {
          final id = n['id']?.toString();
          if (id != null && id.isNotEmpty) {
            set.add(id);
          }
        }
      }
      appData.write(_kCustomerReadNotifications, set.toList());
      _safeUpdate(() {
        customerUnreadCountRx.value = 0;
      });
    } catch (e) {
      log('Error marking all customer notifications as read: $e');
    }
  }

  int calculateCustomerUnread(List<dynamic> notifs) {
    int unread = 0;
    final readSet = getCustomerReadIds();
    for (final n in notifs) {
      if (n is Map) {
        final id = n['id']?.toString() ?? '';
        final isServerRead = n['is_read'] == true || n['read'] == true || n['isRead'] == true;
        if (!isServerRead && (id.isEmpty || !readSet.contains(id))) {
          unread++;
        }
      }
    }
    return unread;
  }

  void updateCustomerNotifications(List<dynamic> notifs) {
    final count = calculateCustomerUnread(notifs);
    _safeUpdate(() {
      customerUnreadCountRx.value = count;
    });
  }

  // ==========================================
  // WHOLESALE (B2B) NOTIFICATIONS
  // ==========================================

  Set<String> getWholesaleReadIds() {
    try {
      final raw = appData.read(_kWholesaleReadNotifications);
      if (raw is List) {
        return Set<String>.from(raw.map((e) => e.toString()));
      }
    } catch (_) {}
    return <String>{};
  }

  bool isWholesaleNotificationRead(dynamic notif) {
    if (notif == null) return true;
    if (notif is Map) {
      if (notif['is_read'] == true || notif['read'] == true || notif['isRead'] == true) {
        return true;
      }
      final id = notif['id']?.toString();
      if (id != null && id.isNotEmpty) {
        return getWholesaleReadIds().contains(id);
      }
    }
    return false;
  }

  void markWholesaleNotificationAsRead(String id, {bool callApi = true}) {
    if (id.isEmpty) return;
    try {
      final set = getWholesaleReadIds();
      if (!set.contains(id)) {
        set.add(id);
        appData.write(_kWholesaleReadNotifications, set.toList());
      }

      // Also update wholesale_local_notifications if present
      final local = appData.read('wholesale_local_notifications');
      if (local is List) {
        final updatedLocal = List<dynamic>.from(local);
        for (final item in updatedLocal) {
          if (item is Map && item['id']?.toString() == id) {
            item['is_read'] = true;
          }
        }
        appData.write('wholesale_local_notifications', updatedLocal);
      }

      if (callApi) {
        WholesaleApi.instance.markNotificationRead(id).catchError((_) {});
      }

      if (wholesaleUnreadCountRx.value > 0) {
        _safeUpdate(() {
          wholesaleUnreadCountRx.value = (wholesaleUnreadCountRx.value - 1).clamp(0, 9999);
        });
      }
    } catch (e) {
      log('Error marking wholesale notification as read: $e');
    }
  }

  void markAllWholesaleNotificationsAsRead(List<dynamic> notifs, {bool callApi = true}) {
    try {
      final set = getWholesaleReadIds();
      for (final n in notifs) {
        if (n is Map) {
          final id = n['id']?.toString();
          if (id != null && id.isNotEmpty) {
            set.add(id);
            if (callApi) {
              WholesaleApi.instance.markNotificationRead(id).catchError((_) {});
            }
          }
        }
      }
      appData.write(_kWholesaleReadNotifications, set.toList());

      // Mark all local notifications as read
      final local = appData.read('wholesale_local_notifications');
      if (local is List) {
        final updatedLocal = List<dynamic>.from(local);
        for (final item in updatedLocal) {
          if (item is Map) {
            item['is_read'] = true;
          }
        }
        appData.write('wholesale_local_notifications', updatedLocal);
      }

      _safeUpdate(() {
        wholesaleUnreadCountRx.value = 0;
      });
    } catch (e) {
      log('Error marking all wholesale notifications as read: $e');
    }
  }

  int calculateWholesaleUnread(dynamic data) {
    int unread = 0;
    final readSet = getWholesaleReadIds();
    final List<String> deletedKeys = (appData.read('wholesale_deleted_notifications') is List)
        ? List<String>.from(appData.read('wholesale_deleted_notifications'))
        : [];

    List<dynamic> serverList = [];
    if (data is Map && data['results'] is List) {
      serverList = data['results'] as List;
    } else if (data is List) {
      serverList = data;
    }

    for (final item in serverList) {
      if (item is Map) {
        final id = item['id']?.toString() ?? '';
        if (deletedKeys.contains(id)) continue;
        final isServerRead = item['is_read'] == true || item['read'] == true || item['isRead'] == true;
        if (!isServerRead && (id.isEmpty || !readSet.contains(id))) {
          unread++;
        }
      }
    }

    try {
      final local = appData.read('wholesale_local_notifications');
      if (local is List) {
        for (final item in local) {
          if (item is Map) {
            final id = item['id']?.toString() ?? '';
            if (deletedKeys.contains(id)) continue;
            final isServerRead = item['is_read'] == true || item['read'] == true;
            if (!isServerRead && (id.isEmpty || !readSet.contains(id))) {
              unread++;
            }
          }
        }
      }
    } catch (_) {}

    return unread;
  }

  void updateWholesaleNotifications(dynamic data) {
    final count = calculateWholesaleUnread(data);
    _safeUpdate(() {
      wholesaleUnreadCountRx.value = count;
    });
  }

  // ==========================================
  // STAFF NOTIFICATIONS
  // ==========================================

  Set<String> getStaffReadIds() {
    try {
      final raw = appData.read(_kStaffReadNotifications);
      if (raw is List) {
        return Set<String>.from(raw.map((e) => e.toString()));
      }
    } catch (_) {}
    return <String>{};
  }

  bool isStaffNotificationRead(dynamic notif) {
    if (notif == null) return true;
    if (notif is String) {
      return getStaffReadIds().contains(notif);
    }
    if (notif is Map) {
      if (notif['is_read'] == true || notif['read'] == true || notif['isRead'] == true) {
        return true;
      }
      final id = notif['id']?.toString();
      if (id != null && id.isNotEmpty) {
        return getStaffReadIds().contains(id);
      }
    } else {
      try {
        if (notif.isRead == true) return true;
        final id = notif.id?.toString();
        if (id != null && id.isNotEmpty) {
          return getStaffReadIds().contains(id);
        }
      } catch (_) {}
    }
    return false;
  }

  void markStaffNotificationAsRead(String id) {
    if (id.isEmpty) return;
    try {
      final set = getStaffReadIds();
      if (!set.contains(id)) {
        set.add(id);
        appData.write(_kStaffReadNotifications, set.toList());
      }
      if (staffUnreadCountRx.value > 0) {
        _safeUpdate(() {
          staffUnreadCountRx.value = (staffUnreadCountRx.value - 1).clamp(0, 9999);
        });
      }
    } catch (e) {
      log('Error marking staff notification as read: $e');
    }
  }

  void markAllStaffNotificationsAsRead(List<dynamic> notifs) {
    try {
      final set = getStaffReadIds();
      for (final n in notifs) {
        String? id;
        if (n is Map) {
          id = n['id']?.toString();
        } else {
          try {
            id = n.id?.toString();
          } catch (_) {}
        }
        if (id != null && id.isNotEmpty) {
          set.add(id);
        }
      }
      appData.write(_kStaffReadNotifications, set.toList());
      _safeUpdate(() {
        staffUnreadCountRx.value = 0;
      });
    } catch (e) {
      log('Error marking all staff notifications as read: $e');
    }
  }

  int calculateStaffUnread(List<dynamic> notifs) {
    int unread = 0;
    final readSet = getStaffReadIds();
    for (final n in notifs) {
      if (n is Map) {
        final id = n['id']?.toString() ?? '';
        final isServerRead = n['is_read'] == true || n['read'] == true || n['isRead'] == true;
        if (!isServerRead && (id.isEmpty || !readSet.contains(id))) {
          unread++;
        }
      } else {
        try {
          final id = n.id?.toString() ?? '';
          final isServerRead = n.isRead == true;
          if (!isServerRead && (id.isEmpty || !readSet.contains(id))) {
            unread++;
          }
        } catch (_) {}
      }
    }
    return unread;
  }

  void updateStaffNotifications(List<dynamic> notifs) {
    final count = calculateStaffUnread(notifs);
    _safeUpdate(() {
      staffUnreadCountRx.value = count;
    });
  }

  /// Clears all stored read notification IDs (e.g. on logout)
  void clearAll() {
    try {
      appData.remove(_kCustomerReadNotifications);
      appData.remove(_kWholesaleReadNotifications);
      appData.remove(_kStaffReadNotifications);
      _safeUpdate(() {
        customerUnreadCountRx.value = 0;
        wholesaleUnreadCountRx.value = 0;
        staffUnreadCountRx.value = 0;
      });
    } catch (_) {}
  }
}
