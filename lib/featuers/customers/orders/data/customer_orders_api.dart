import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/endpoints.dart';
import '../../../../../networks/exception_handler/data_source.dart';

class CustomerOrdersApi {
  static final CustomerOrdersApi _singleton = CustomerOrdersApi._internal();
  CustomerOrdersApi._internal();
  static CustomerOrdersApi get instance => _singleton;

  Future<dynamic> getOrders() async {
    try {
      final response = await getHttp(Endpoints.customerOrders());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getOrderDetails(String id) async {
    try {
      final response = await postHttp(Endpoints.customerOrderDetails(id));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }
}
