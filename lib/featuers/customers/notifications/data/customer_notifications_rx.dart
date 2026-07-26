import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import 'customer_notifications_api.dart';
import 'dart:developer';

class CustomerNotificationsRx {
  final api = CustomerNotificationsApi.instance;

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
}
