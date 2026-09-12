import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:el_arbol/helpers/support_ticket_unread_manager.dart';
import 'package:el_arbol/helpers/di.dart';
import 'package:el_arbol/constants/app_constants.dart';

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

  group('Support Ticket Unread Manager Tests', () {
    final manager = SupportTicketUnreadManager.instance;

    setUp(() {
      // Simulate current user ID = "42", email = "test@elarbol.com"
      appData.write(kKeyUserID, '42');
      appData.write(kKeyEmail, 'test@elarbol.com');
      // Reset ticket read state for test ticket 101
      appData.remove('ticket_last_read_reply_id_101');
      appData.remove('ticket_last_read_time_101');
    });

    test('Identifies admin replies correctly vs user replies', () {
      final userReply = {
        'id': 1,
        'user_id': '42',
        'message': 'Hello support',
        'sender': 'You',
        'role': 'customer',
      };
      expect(manager.isMessageFromAdmin(userReply), isFalse);

      final adminReply = {
        'id': 2,
        'user_id': '1',
        'message': 'Hello, we are looking into your issue.',
        'sender': 'Admin Support',
        'role': 'admin',
      };
      expect(manager.isMessageFromAdmin(adminReply), isTrue);

      final supportStaffReply = {
        'id': 3,
        'user_id': '99',
        'message': 'Your order has been dispatched.',
        'sender': 'Agent John',
        'sender_role': 'support',
      };
      expect(manager.isMessageFromAdmin(supportStaffReply), isTrue);
    });

    test('Calculates unread count and marks ticket as read', () {
      final testTicket = {
        'id': 101,
        'subject': 'Order Delayed',
        'messages': [
          {
            'id': 1,
            'user_id': '42',
            'message': 'Why is my order delayed?',
            'sender': 'You',
          },
          {
            'id': 2,
            'user_id': '1',
            'message': 'We apologize, it was delayed due to weather.',
            'role': 'admin',
          },
          {
            'id': 3,
            'user_id': '1',
            'message': 'It will arrive tomorrow.',
            'role': 'support',
          },
          {
            'id': 4,
            'user_id': '42',
            'message': 'Thank you!',
            'sender': 'You',
          },
        ],
      };

      // Ticket has 2 admin replies (ID 2 and 3)
      final unread = manager.getUnreadCountForTicket(testTicket);
      expect(unread, equals(2));

      manager.updateCustomerTickets([testTicket]);
      expect(manager.customerUnreadCountRx.value, equals(2));

      // Now mark ticket as read
      manager.markTicketAsRead(testTicket);

      // Unread count should now be 0
      expect(manager.getUnreadCountForTicket(testTicket), equals(0));
      expect(manager.customerUnreadCountRx.value, equals(0));
      expect(appData.read('ticket_last_read_reply_id_101'), equals(3));

      // Now simulate a new admin reply arriving (ID 5)
      final updatedTicket = {
        'id': 101,
        'subject': 'Order Delayed',
        'messages': [
          ...testTicket['messages'] as List,
          {
            'id': 5,
            'user_id': '1',
            'message': 'Tracking code is EL-12345.',
            'role': 'admin',
          },
        ],
      };

      // New reply (ID 5 > 3) should now count as 1 unread!
      final newUnread = manager.getUnreadCountForTicket(updatedTicket);
      expect(newUnread, equals(1));

      manager.updateCustomerTickets([updatedTicket]);
      expect(manager.customerUnreadCountRx.value, equals(1));
    });
  });
}
