import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import '../model/get_product_model.dart';
import '../model/get_category_model.dart';
import '../model/leftover_store_model.dart';
import 'api.dart';

/// Reactive response handler for fetching customer products.
class GetProductRx extends RxResponseInt<GetProductModel> {
  final api = GetProductApi.instance;

  GetProductRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream get valueStreamData => dataFetcher.stream;

  /// Fetches products from the remote server.
  Future<void> fetchProducts() async {
    try {
      await EasyLoading.show(status: "Loading products...");
      final data = await api.getProductsData();
      await handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch products error: $error");
      await handleErrorWithReturn(error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  handleSuccessWithReturn(GetProductModel data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  handleErrorWithReturn(error) {
    String message = "Failed to load products";

    if (error is DioException) {
      message = error.response?.data["message"] ?? message;

      if (error.type == DioExceptionType.connectionError) {
        message = "Check Your Network Connection";
      }
    }

    AppToast.error(message);
    dataFetcher.sink.addError(error);
  }
}

/// Reactive response handler for fetching customer categories.
class GetCategoryRx extends RxResponseInt<GetCategoryModel> {
  final api = GetCategoryApi.instance;

  GetCategoryRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream get valueStreamData => dataFetcher.stream;

  /// Fetches categories from the remote server.
  Future<void> fetchCategories() async {
    try {
      final data = await api.getCategoriesData();
      await handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch categories error: $error");
      await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(GetCategoryModel data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  handleErrorWithReturn(error) {
    String message = "Failed to load categories";

    if (error is DioException) {
      message = error.response?.data["message"] ?? message;
    }

    AppToast.error(message);
    dataFetcher.sink.addError(error);
  }
}

class GetLeftoverStoreRx extends RxResponseInt<List<LeftoverStoreModel>> {
  final api = GetLeftoverStoreApi.instance;

  GetLeftoverStoreRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<List<LeftoverStoreModel>> get valueStreamData => dataFetcher.stream;

  Future<void> fetchLeftoverStores() async {
    try {
      await EasyLoading.show(status: "Loading surplus packs...");
      final data = await api.getLeftoverStores();
      await handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch leftover stores error: $error");
      await handleErrorWithReturn(error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  handleSuccessWithReturn(List<LeftoverStoreModel> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  handleErrorWithReturn(error) {
    String message = "Failed to load leftover stores";

    if (error is DioException) {
      message = error.response?.data["message"] ?? message;
      if (error.type == DioExceptionType.connectionError) {
        message = "Check Your Network Connection";
      }
    }

    AppToast.error(message);
    dataFetcher.sink.addError(error);
  }
}
