import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/endpoints.dart';
import '../../../../../networks/exception_handler/data_source.dart';

class CustomerWishlistApi {
  static final CustomerWishlistApi _singleton = CustomerWishlistApi._internal();
  CustomerWishlistApi._internal();
  static CustomerWishlistApi get instance => _singleton;

  Future<dynamic> getWishlist() async {
    try {
      final response = await getHttp(Endpoints.wishlist());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addToWishlist(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.wishlist(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> removeFromWishlist(String id) async {
    try {
      final response = await deleteHttp(Endpoints.wishlistRemove(id));
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> clearWishlist() async {
    try {
      final response = await deleteHttp(Endpoints.wishlistClear());
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }
}
