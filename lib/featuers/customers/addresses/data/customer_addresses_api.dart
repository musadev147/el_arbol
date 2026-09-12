import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/endpoints.dart';
import '../../../../../networks/exception_handler/data_source.dart';

class CustomerAddressesApi {
  static final CustomerAddressesApi _singleton = CustomerAddressesApi._internal();
  CustomerAddressesApi._internal();
  static CustomerAddressesApi get instance => _singleton;

  Future<dynamic> getAddresses() async {
    try {
      final response = await getHttp(Endpoints.customerAddresses());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createAddress(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.customerAddresses(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      final response = await patchHttp(Endpoints.customerAddress(id), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteAddress(String id) async {
    try {
      final response = await deleteHttp(Endpoints.customerAddress(id));
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
