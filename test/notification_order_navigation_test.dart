import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification Order ID Parser & Detection Tests', () {
    String? extractOrderId(Map<String, dynamic> notif) {
      final rawTitle = (notif['title'] ?? notif['subject'] ?? '').toString();
      final rawBody = (notif['body'] ?? notif['message'] ?? notif['description'] ?? '').toString();
      final rawType = (notif['type'] ?? notif['action'] ?? notif['category'] ?? '').toString();

      final title = rawTitle.toLowerCase();
      final body = rawBody.toLowerCase();
      final type = rawType.toLowerCase();

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
          body.contains('placed') ||
          notif['order_id'] != null ||
          notif['order_number'] != null ||
          notif['orderId'] != null ||
          notif['orderNumber'] != null;

      if (!isOrderRelated) return null;

      String? orderId = notif['order_id']?.toString() ??
          notif['order_number']?.toString() ??
          notif['orderId']?.toString() ??
          notif['orderNumber']?.toString() ??
          notif['target_id']?.toString() ??
          notif['data']?['order_id']?.toString() ??
          notif['data']?['order_number']?.toString() ??
          notif['data']?['orderId']?.toString() ??
          (notif['order'] is Map ? (notif['order']['order_number'] ?? notif['order']['id'] ?? notif['order']['order_id'])?.toString() : null);

      if (orderId == null || orderId.isEmpty) {
        final regex = RegExp(r'(?:order|pedido)\s*#?([A-Za-z0-9_\-]+)', caseSensitive: false);
        final match = regex.firstMatch('$rawTitle $rawBody');
        if (match != null) {
          orderId = match.group(1);
        }
      }

      if (orderId == null || orderId.isEmpty) {
        final hashRegex = RegExp(r'#([A-Za-z0-9_\-]+)');
        final match = hashRegex.firstMatch('$rawTitle $rawBody');
        if (match != null) {
          orderId = match.group(1);
        }
      }

      return orderId;
    }

    test('extracts order ID from explicit order_id field', () {
      final notif = {
        'id': '101',
        'title': 'Order Dispatched',
        'message': 'Your package is on the way',
        'type': 'order',
        'order_id': 'ORD-998822',
      };
      expect(extractOrderId(notif), equals('ORD-998822'));
    });

    test('extracts order ID from title text with # prefix', () {
      final notif = {
        'id': '102',
        'title': 'Order #ORD-776655 Confirmed',
        'body': 'We have received your payment',
      };
      expect(extractOrderId(notif), equals('ORD-776655'));
    });

    test('extracts order ID from nested order map', () {
      final notif = {
        'id': '103',
        'title': 'Order Delivered',
        'type': 'order',
        'order': {
          'order_number': 'ORD-12345',
          'total': '45.00',
        }
      };
      expect(extractOrderId(notif), equals('ORD-12345'));
    });

    test('extracts order ID from target_id in wholesale notifications', () {
      final notif = {
        'id': '104',
        'title': 'Wholesale Order Placed',
        'message': 'Order ORD-WHS-5544 for €1,250 placed',
        'type': 'order',
        'target_id': 'ORD-WHS-5544',
      };
      expect(extractOrderId(notif), equals('ORD-WHS-5544'));
    });

    test('returns null for non-order notifications like general alerts', () {
      final notif = {
        'id': '105',
        'title': 'New discount voucher available',
        'message': 'Use code ORGANIC10 for 10% off',
        'type': 'general',
      };
      expect(extractOrderId(notif), isNull);
    });
  });
}
