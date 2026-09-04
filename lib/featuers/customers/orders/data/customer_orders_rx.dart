import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../../networks/rx_base.dart';
import 'customer_orders_api.dart';
import 'dart:developer';

class CustomerOrdersRx extends RxResponseInt<List<dynamic>> {
  final api = CustomerOrdersApi.instance;

  CustomerOrdersRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchOrders() async {
    try {
      final data = await api.getOrders();
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data.containsKey('results') && data['results'] is List) {
          list = data['results'];
        } else if (data.containsKey('data') && data['data'] is List) {
          list = data['data'];
        } else if (data.containsKey('orders') && data['orders'] is List) {
          list = data['orders'];
        }
      }
      await handleSuccessWithReturn(list);
    } catch (e) {
      log('CustomerOrdersRx fetchOrders error: $e');
      await handleErrorWithReturn(e);
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

class CustomerSingleOrderRx extends RxResponseInt<Map<String, dynamic>> {
  final api = CustomerOrdersApi.instance;

  CustomerSingleOrderRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchSingleOrder(String orderId) async {
    try {
      final data = await api.getOrderDetails(orderId);
      Map<String, dynamic> map = {};
      if (data is Map<String, dynamic>) {
        map = data;
      } else if (data is Map) {
        map = Map<String, dynamic>.from(data);
      }
      if (map.containsKey('data') && map['data'] is Map) {
        map = Map<String, dynamic>.from(map['data']);
      } else if (map.containsKey('order') && map['order'] is Map) {
        map = Map<String, dynamic>.from(map['order']);
      }
      await handleSuccessWithReturn(map);
    } catch (e) {
      log('CustomerSingleOrderRx fetchSingleOrder error: $e');
      await handleErrorWithReturn(e);
    }
  }

  @override
  Future<void> handleSuccessWithReturn(dynamic data) async {
    dataFetcher.sink.add(data is Map<String, dynamic> ? data : {});
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}

class CustomerCreateOrderRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerCreateOrderRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<bool> createOrder(Map<String, dynamic> data) async {
    try {
      await EasyLoading.show(status: 'Placing order...');
      final response = await api.createOrder(data);
      await handleSuccessWithReturn(response);
      return true;
    } catch (e) {
      log('CustomerCreateOrderRx error: $e');
      await handleErrorWithReturn(e);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> submitOrder(Map<String, dynamic> data) async {
    try {
      await EasyLoading.show(status: 'Submitting order...');
      final response = await api.submitOrder(data);
      await handleSuccessWithReturn(response);
      return true;
    } catch (e) {
      log('CustomerSubmitOrderRx error: $e');
      await handleErrorWithReturn(e);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}

class CustomerShippingCalculatorRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerShippingCalculatorRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<dynamic> calculateShipping(Map<String, dynamic> data) async {
    try {
      final response = await api.calculateShipping(data);
      await handleSuccessWithReturn(response);
      return response;
    } catch (e) {
      log('CustomerShippingCalculatorRx error: $e');
      await handleErrorWithReturn(e);
      return null;
    }
  }
}

class CustomerCouponRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerCouponRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<dynamic> validateCoupon(String code) async {
    try {
      final response = await api.validateCoupon(code);
      await handleSuccessWithReturn(response);
      return response;
    } catch (e) {
      log('CustomerCouponRx error: $e');
      await handleErrorWithReturn(e);
      return null;
    }
  }
}

class CustomerPaymentConfirmationRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerPaymentConfirmationRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<bool> confirmPayment(Map<String, dynamic> data) async {
    try {
      await EasyLoading.show(status: 'Confirming payment...');
      final response = await api.confirmPayment(data);
      await handleSuccessWithReturn(response);
      return true;
    } catch (e) {
      log('CustomerPaymentConfirmationRx error: $e');
      await handleErrorWithReturn(e);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}

class CustomerShippingMethodsRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerShippingMethodsRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchShippingMethods() async {
    try {
      final data = await api.getShippingMethods();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('CustomerShippingMethodsRx error: $e');
      await handleErrorWithReturn(e);
    }
  }
}

class CustomerInvoiceRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerInvoiceRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<dynamic> fetchOrderInvoice(String orderNumber) async {
    try {
      final data = await api.getOrderInvoice(orderNumber);
      await handleSuccessWithReturn(data);
      return data;
    } catch (e) {
      log('CustomerInvoiceRx error: $e');
      await handleErrorWithReturn(e);
      return null;
    }
  }
}

class CustomerCartRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerCartRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchBasket() async {
    try {
      final data = await api.getBasket();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('CustomerCartRx fetchBasket error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> addToBasket(String productId, int quantity) async {
    try {
      await EasyLoading.show(status: 'Adding to basket...');
      await api.addBasketItem(productId, quantity);
      await fetchBasket();
      EasyLoading.showSuccess('Added to basket!');
      return true;
    } catch (e) {
      log('CustomerCartRx addToBasket error: $e');
      String message = "Failed to add to basket";
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        message = data["message"]?.toString() ?? data["detail"]?.toString() ?? message;
      }
      EasyLoading.showError(message);
      return false;
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await api.updateBasketItem(itemId, quantity);
      await fetchBasket();
    } catch (e) {
      log('CustomerCartRx updateQuantity error: $e');
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await api.deleteBasketItem(itemId);
      await fetchBasket();
    } catch (e) {
      log('CustomerCartRx removeItem error: $e');
    }
  }
}

class CustomerStoresRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerStoresRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchStores() async {
    try {
      final data = await api.getStores();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('CustomerStoresRx error: $e');
      await handleErrorWithReturn(e);
    }
  }
}
