import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/endpoints.dart';
import '../../../../../networks/exception_handler/data_source.dart';

class CustomerOrderApi {
  static final CustomerOrderApi _singleton = CustomerOrderApi._internal();
  CustomerOrderApi._internal();
  static CustomerOrderApi get instance => _singleton;

  Future<dynamic> getOrderHistory() async {
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
      final response = await getHttp(Endpoints.customerOrderDetails(id));
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
