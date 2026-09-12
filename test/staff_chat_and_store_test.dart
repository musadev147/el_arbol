import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:el_arbol/featuers/employee_self_service/data/rx.dart';
import 'package:el_arbol/featuers/employee_self_service/model/staff_chat_model.dart';
import 'package:el_arbol/featuers/employee_self_service/model/staff_dashboard_model.dart';
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

  group('Staff Chat Unread Count & State Tests', () {
    test('StaffChatRx singleton instance is accessible', () {
      expect(StaffChatRx.instance, isNotNull);
    });

    test('Unread count calculation and markAllAsRead', () {
      final rx = StaffChatRx.instance;
      // Reset local read state
      appData.write('last_read_admin_chat_id', 10);

      // Provide test messages:
      // msg 11: ADMIN, is_read: true -> unread because id 11 > 10
      // msg 12: ADMIN, is_read: false -> unread
      // msg 13: STAFF -> not counted as unread
      final testMessages = [
        StaffChatMessage(id: 9, sender: 'ADMIN', message: 'Old read message', isRead: true),
        StaffChatMessage(id: 11, sender: 'ADMIN', message: 'New admin message 1', isRead: true),
        StaffChatMessage(id: 12, sender: 'ADMIN', message: 'New admin message 2', isRead: false),
        StaffChatMessage(id: 13, sender: 'STAFF', message: 'Staff reply', isRead: false),
      ];

      rx.computeUnreadCount(testMessages);
      rx.dataFetcher.sink.add(testMessages);

      expect(rx.unreadCount, equals(2));

      // Now mark all as read
      rx.markAllAsRead();

      // Highest admin message ID is 12
      expect(appData.read('last_read_admin_chat_id'), equals(12));
      // Unread count should now be 0
      expect(rx.unreadCount, equals(0));
    });
  });

  group('Store Image Parsing Tests', () {
    test('ActiveStore parses image from image key', () {
      final json = {
        'id': 2,
        'name': 'Shopno',
        'image': 'http://apielarbol.icommerce.com.bd/media/stores/banners/shopno.png',
        'hours': '8:00 AM — 9:00 PM',
      };

      final store = ActiveStore.fromJson(json);
      expect(store.name, equals('Shopno'));
      expect(store.image, equals('http://apielarbol.icommerce.com.bd/media/stores/banners/shopno.png'));
    });

    test('ActiveStore parses banner as image fallback', () {
      final json = {
        'id': 1,
        'name': 'United Group',
        'banner': 'http://apielarbol.icommerce.com.bd/media/stores/banners/Dhanmondi.jpg',
      };

      final store = ActiveStore.fromJson(json);
      expect(store.name, equals('United Group'));
      expect(store.image, equals('http://apielarbol.icommerce.com.bd/media/stores/banners/Dhanmondi.jpg'));
    });
  });
}
