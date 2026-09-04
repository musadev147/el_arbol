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
      }
    } catch (_) {
      try {
        final fallback = await getHttp("auth/orders/");
        if (fallback.statusCode == 200 || fallback.statusCode == 201) {
          return fallback.data;
        }
      } catch (e2) {
        rethrow;
      }
    }
    throw DataSource.DEFAULT.getFailure();
  }

  Future<dynamic> getOrderDetails(String id) async {
    try {
      final response = await getHttp(Endpoints.customerOrderDetails(id));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } catch (_) {
      try {
        final fallback = await getHttp("auth/orders/$id/");
        if (fallback.statusCode == 200 || fallback.statusCode == 201) {
          return fallback.data;
        }
      } catch (e2) {
        rethrow;
      }
    }
    throw DataSource.DEFAULT.getFailure();
  }

  Future<dynamic> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.createOrder(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> submitOrder(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.submitOrder(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> calculateShipping(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.calculateShipping(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> validateCoupon(String code) async {
    try {
      final response = await postHttp(Endpoints.validateCoupon(), {"code": code});
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> confirmPayment(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.confirmPayment(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getShippingMethods() async {
    try {
      final response = await getHttp(Endpoints.shippingMethods());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getOrderInvoice(String orderNumber) async {
    try {
      final response = await getHttp(Endpoints.orderInvoice(orderNumber));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getBasket() async {
    try {
      final response = await getHttp(Endpoints.getBasket());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addBasketItem(String productId, int quantity) async {
    try {
      final response = await postHttp(Endpoints.addBasketItem(), {
        "product_id": productId,
        "quantity": quantity,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateBasketItem(String itemId, int quantity) async {
    try {
      final response = await putHttp(Endpoints.updateBasketItem(itemId), {
        "quantity": quantity,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteBasketItem(String itemId) async {
    try {
      final response = await deleteHttp(Endpoints.deleteBasketItem(itemId));
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> cancelCheckout() async {
    try {
      final response = await postHttp(Endpoints.cancelCheckout(), {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getStores() async {
    try {
      final response = await getHttp(Endpoints.getStores());
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
