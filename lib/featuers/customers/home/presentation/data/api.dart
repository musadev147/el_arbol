import '../../../../../../networks/dio/dio.dart';
import '../../../../../../networks/exception_handler/data_source.dart';
import '../../../../../../networks/endpoints.dart';
import '../model/get_product_model.dart';
import '../model/get_category_model.dart';
import '../model/leftover_store_model.dart';

/// API remote data source for Customer Home Screen products.
class GetProductApi {
  static final GetProductApi _singleton = GetProductApi._internal();
  GetProductApi._internal();
  static GetProductApi get instance => _singleton;

  /// Fetches product list from backend endpoint.
  Future<GetProductModel> getProductsData() async {
    try {
      final response = await getHttp(Endpoints.getProducts());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetProductModel.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}

/// API remote data source for Customer Home Screen categories.
class GetCategoryApi {
  static final GetCategoryApi _singleton = GetCategoryApi._internal();
  GetCategoryApi._internal();
  static GetCategoryApi get instance => _singleton;

  /// Fetches category list from backend endpoint.
  Future<GetCategoryModel> getCategoriesData() async {
    try {
      final response = await getHttp(Endpoints.getCategories());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetCategoryModel.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}

class GetLeftoverStoreApi {
  static final GetLeftoverStoreApi _singleton = GetLeftoverStoreApi._internal();
  GetLeftoverStoreApi._internal();
  static GetLeftoverStoreApi get instance => _singleton;

  Future<List<LeftoverStoreModel>> getLeftoverStores() async {
    try {
      final response = await getHttp(Endpoints.storeLeftoverPacks());
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is List) {
          return (response.data as List)
              .map((x) => LeftoverStoreModel.fromJson(x as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}

