import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:el_arbol/helpers/notification_unread_manager.dart';
import 'package:el_arbol/helpers/di.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '.';
      },
    );
    await GetStorage.init();
    if (!locator.isRegistered<GetStorage>()) {
      diSetup();
    }
  });

  group('NotificationUnreadManager Tests', () {
    final manager = NotificationUnreadManager.instance;

    setUp(() {
      manager.clearAll();
    });

    test('Customer notification unread calculation and mark as read', () {
      final notifications = [
        {'id': 'notif-1', 'title': 'Welcome discount', 'is_read': false},
        {'id': 'notif-2', 'title': 'Order shipped', 'is_read': false},
        {'id': 'notif-3', 'title': 'Review requested', 'is_read': true},
      ];

      // Initially 2 unread
      expect(manager.calculateCustomerUnread(notifications), equals(2));
      expect(manager.isCustomerNotificationRead(notifications[0]), isFalse);
      expect(manager.isCustomerNotificationRead(notifications[1]), isFalse);
      expect(manager.isCustomerNotificationRead(notifications[2]), isTrue);

      // Mark notif-1 as read
      manager.markCustomerNotificationAsRead('notif-1');
      expect(manager.isCustomerNotificationRead(notifications[0]), isTrue);
      expect(manager.calculateCustomerUnread(notifications), equals(1));

      // Mark all as read
      manager.markAllCustomerNotificationsAsRead(notifications);
      expect(manager.calculateCustomerUnread(notifications), equals(0));
      expect(manager.customerUnreadCountRx.value, equals(0));
    });

    test('Wholesale notification unread calculation and mark as read', () {
      final wholesaleData = {
        'results': [
          {'id': 'w-1', 'title': 'B2B Invoice ready', 'is_read': false},
          {'id': 'w-2', 'title': 'Bulk shipment dispatched', 'is_read': false},
        ]
      };

      // Initially 2 unread
      expect(manager.calculateWholesaleUnread(wholesaleData), equals(2));
      expect(manager.isWholesaleNotificationRead({'id': 'w-1', 'is_read': false}), isFalse);

      // Mark w-1 as read
      manager.markWholesaleNotificationAsRead('w-1', callApi: false);
      expect(manager.isWholesaleNotificationRead({'id': 'w-1', 'is_read': false}), isTrue);
      expect(manager.calculateWholesaleUnread(wholesaleData), equals(1));

      // Mark all wholesale notifications as read
      manager.markAllWholesaleNotificationsAsRead(wholesaleData['results'] as List, callApi: false);
      expect(manager.calculateWholesaleUnread(wholesaleData), equals(0));
      expect(manager.wholesaleUnreadCountRx.value, equals(0));
    });

    test('Staff notification unread calculation and mark as read', () {
      final staffNotifications = [
        {'id': 's-1', 'title': 'Shift assigned', 'is_read': false},
        {'id': 's-2', 'title': 'Price updated', 'is_read': false},
      ];

      expect(manager.calculateStaffUnread(staffNotifications), equals(2));
      expect(manager.isStaffNotificationRead(staffNotifications[0]), isFalse);

      manager.markStaffNotificationAsRead('s-1');
      expect(manager.isStaffNotificationRead(staffNotifications[0]), isTrue);
      expect(manager.calculateStaffUnread(staffNotifications), equals(1));

      manager.markAllStaffNotificationsAsRead(staffNotifications);
      expect(manager.calculateStaffUnread(staffNotifications), equals(0));
      expect(manager.staffUnreadCountRx.value, equals(0));
    });
  });
}
