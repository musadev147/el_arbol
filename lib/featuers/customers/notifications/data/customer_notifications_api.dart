import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/endpoints.dart';
import '../../../../../networks/exception_handler/data_source.dart';

class CustomerNotificationsApi {
  static final CustomerNotificationsApi _singleton = CustomerNotificationsApi._internal();
  CustomerNotificationsApi._internal();
  static CustomerNotificationsApi get instance => _singleton;

  Future<dynamic> fetchNotifications() async {
    try {
      final response = await getHttp(Endpoints.customerNotifications());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> bulkDeleteNotifications(List<String> ids) async {
    try {
      final response = await deleteHttp(Endpoints.customerNotificationsBulkDelete(), {"ids": ids});
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }
}
