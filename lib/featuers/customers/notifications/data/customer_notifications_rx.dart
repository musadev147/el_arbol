import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import '../../../../../helpers/notification_unread_manager.dart';
import 'customer_notifications_api.dart';
import 'dart:developer';

class CustomerNotificationsRx extends RxResponseInt<List<dynamic>> {
  final api = CustomerNotificationsApi.instance;

  CustomerNotificationsRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<List<dynamic>> get valueStreamData => dataFetcher.stream;

  Future<void> fetchNotifications() async {
    try {
      final data = await api.fetchNotifications();
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data.containsKey('results')) {
          list = data['results'] as List? ?? [];
        } else if (data.containsKey('data')) {
          list = data['data'] as List? ?? [];
        }
      }
      NotificationUnreadManager.instance.updateCustomerNotifications(list);
      await handleSuccessWithReturn(list);
    } catch (e) {
      log('CustomerNotificationsRx fetch error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> bulkDeleteNotifications(List<String> ids) async {
    try {
      await EasyLoading.show(status: 'Deleting...');
      await api.bulkDeleteNotifications(ids);
      AppToast.success("Notifications deleted");
      return true;
    } catch (e) {
      log('CustomerNotificationsRx bulkDelete error: $e');
      AppToast.error("Failed to delete notifications");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(dynamic data) async {
    if (!dataFetcher.isClosed) {
      dataFetcher.sink.add(data is List ? data : []);
    }
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    if (!dataFetcher.isClosed) {
      dataFetcher.sink.addError(error);
    }
  }
}
