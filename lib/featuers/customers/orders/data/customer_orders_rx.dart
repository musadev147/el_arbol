import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import '../../../../../networks/exception_handler/data_source.dart';
import '../../../../helpers/di.dart';
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
    final clean = orderId.trim();
    if (clean.isEmpty ||
        clean.toLowerCase() == 'placed' ||
        clean.toLowerCase() == 'null' ||
        clean.toLowerCase() == 'undefined' ||
        clean.toLowerCase() == 'pending') {
      return;
    }
    try {
      final data = await api.getOrderDetails(clean);
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

      // Merge with local order if present to preserve item sale prices
      try {
        final searchKeys = [
          clean,
          clean.replaceAll('#', ''),
          map['id']?.toString(),
          map['order_id']?.toString(),
          map['order_number']?.toString(),
        ].where((k) => k != null && k.isNotEmpty).map((k) => k!.replaceAll('#', '').trim().toLowerCase()).toSet();

        Map<String, dynamic>? localMatch;
        for (final storeKey in ['customer_placed_orders', 'wholesale_placed_orders']) {
          final list = appData.read(storeKey);
          if (list is List) {
            for (final ord in list) {
              if (ord is Map) {
                final k1 = (ord['order_number'] ?? '').toString().replaceAll('#', '').trim().toLowerCase();
                final k2 = (ord['id'] ?? '').toString().replaceAll('#', '').trim().toLowerCase();
                final k3 = (ord['order_id'] ?? '').toString().replaceAll('#', '').trim().toLowerCase();
                if (searchKeys.contains(k1) || searchKeys.contains(k2) || searchKeys.contains(k3)) {
                  localMatch = Map<String, dynamic>.from(ord);
                  break;
                }
              }
            }
          }
          if (localMatch != null) break;
        }

        if (localMatch != null) {
          final serverItems = map['items'] ?? map['order_items'] ?? map['products'] ?? map['lines'];
          final localItems = localMatch['items'] ?? localMatch['order_items'] ?? localMatch['products'] ?? localMatch['lines'];
          if ((serverItems == null || (serverItems is List && serverItems.isEmpty)) && localItems is List && localItems.isNotEmpty) {
            map['items'] = localItems;
          } else if (serverItems is List && localItems is List && serverItems.length == localItems.length) {
            final mergedItems = [];
            for (int i = 0; i < serverItems.length; i++) {
              final sIt = serverItems[i] is Map ? Map<String, dynamic>.from(serverItems[i]) : {};
              final lIt = localItems[i] is Map ? Map<String, dynamic>.from(localItems[i]) : {};
              final mIt = {...lIt, ...sIt};
              if ((sIt['product_details'] == null || (sIt['product_details'] is Map && (sIt['product_details'] as Map).isEmpty)) && lIt['product_details'] != null) {
                mIt['product_details'] = lIt['product_details'];
              }
              if (sIt['discount_price'] == null && lIt['discount_price'] != null) {
                mIt['discount_price'] = lIt['discount_price'];
              }
              if (sIt['sale_price'] == null && lIt['sale_price'] != null) {
                mIt['sale_price'] = lIt['sale_price'];
              }
              mergedItems.add(mIt);
            }
            map['items'] = mergedItems;
          }
          for (final f in ['shipping_address', 'delivery_address', 'fulfillment_type', 'delivery_type', 'delivery_date', 'delivery_slot', 'payment_method', 'customer_name', 'customer_phone', 'customer_email', 'order_notes', 'subtotal']) {
            if ((map[f] == null || map[f].toString().trim().isEmpty) && localMatch[f] != null) {
              map[f] = localMatch[f];
            }
          }
        }
      } catch (_) {}

      await handleSuccessWithReturn(map);
    } catch (e) {
      log('CustomerSingleOrderRx fetchSingleOrder note: $e');
      if (!dataFetcher.isClosed) {
        final current = dataFetcher.valueOrNull;
        if (current == null || current.isEmpty) {
          dataFetcher.sink.add(empty);
        }
      }
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

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    EasyLoading.dismiss();
    String errorMessage = "Failed to place order";
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response!.data as Map;
        if (data.containsKey("detail") && data["detail"] != null) {
          final d = data["detail"].toString();
          if (d.contains("NoneType") || d.contains("category")) {
            errorMessage = "Order failed on server: User profile category configuration error.";
          } else {
            errorMessage = d;
          }
        } else if (data.containsKey("message")) {
          errorMessage = data["message"].toString();
        } else if (data.containsKey("error")) {
          errorMessage = data["error"].toString();
        } else {
          final failure = ErrorHandler.handle(error).failure;
          errorMessage = failure.responseMessage;
        }
      } else {
        final failure = ErrorHandler.handle(error).failure;
        errorMessage = failure.responseMessage;
      }
    } else if (error is Exception) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    }
    AppToast.error(errorMessage);
    if (!dataFetcher.isClosed) {
      dataFetcher.sink.addError(error);
    }
  }

  Future<bool> createOrder(Map<String, dynamic> data) async {
    try {
      log('CustomerCreateOrderRx payload: $data');
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
      if (!dataFetcher.isClosed) {
        dataFetcher.sink.add(empty);
      }
      return null;
    }
  }
}

class CustomerCouponRx extends RxResponseInt<dynamic> {
  final api = CustomerOrdersApi.instance;
  CustomerCouponRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<dynamic> validateCoupon(
    String code, {
    double? cartTotal,
    List<String>? productIds,
    Map<String, int>? quantities,
  }) async {
    try {
      final response = await api.validateCoupon(
        code,
        cartTotal: cartTotal,
        productIds: productIds,
        quantities: quantities,
      );
      await handleSuccessWithReturn(response);
      return response;
    } catch (e) {
      log('CustomerCouponRx error: $e');
      try {
        await handleErrorWithReturn(e);
      } catch (_) {}
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
      final response = await api.confirmPayment(data);
      await handleSuccessWithReturn(response);
      return true;
    } catch (e) {
      log('CustomerPaymentConfirmationRx error: $e');
      if (!dataFetcher.isClosed) {
        dataFetcher.sink.add(empty);
      }
      return false;
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
  static final CustomerCartRx instance = CustomerCartRx(
    empty: {},
    dataFetcher: BehaviorSubject<dynamic>.seeded({}),
  );

  static final List<Map<String, dynamic>> _localPackItems = [];

  final api = CustomerOrdersApi.instance;
  CustomerCartRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  int get itemCount {
    final data = valueStreamData.valueOrNull;
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).length;
    }
    return _localPackItems.length;
  }

  Future<void> fetchBasket() async {
    try {
      final data = await api.getBasket();
      Map<String, dynamic> combined = {};
      if (data is Map) {
        combined = Map<String, dynamic>.from(data);
        final backendItems = List<dynamic>.from(combined['items'] as List? ?? []);
        combined['items'] = [...backendItems, ..._localPackItems];
      } else {
        combined = {'items': [..._localPackItems]};
      }
      await handleSuccessWithReturn(combined);
    } catch (e) {
      log('CustomerCartRx fetchBasket error: $e');
      if (!dataFetcher.isClosed) {
        dataFetcher.sink.add({'items': [..._localPackItems]});
      }
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

  Future<bool> addLeftoverPackToBasket({
    required int packId,
    required String name,
    required double price,
    String? imageUrl,
    String? storeName,
    int quantity = 1,
  }) async {
    final existingIndex = _localPackItems.indexWhere((it) => it['leftover_pack_id'] == packId);
    if (existingIndex >= 0) {
      _localPackItems[existingIndex]['quantity'] = (_localPackItems[existingIndex]['quantity'] as int) + quantity;
    } else {
      _localPackItems.add({
        'id': 'pack_$packId',
        'is_leftover_pack': true,
        'leftover_pack_id': packId,
        'quantity': quantity,
        'product_details': {
          'id': 'pack_$packId',
          'name': '[Leftover Pack] $name',
          'price': price.toStringAsFixed(2),
          'image_url': imageUrl ?? '',
          'thumbnail_url': imageUrl ?? '',
          'store_name': storeName ?? '',
          'is_leftover': true,
        },
      });
    }

    await _emitCombined();
    return true;
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (itemId.startsWith('pack_')) {
      final index = _localPackItems.indexWhere((it) => it['id'] == itemId);
      if (index >= 0) {
        if (quantity <= 0) {
          _localPackItems.removeAt(index);
        } else {
          _localPackItems[index]['quantity'] = quantity;
        }
        await _emitCombined();
      }
      return;
    }
    try {
      await api.updateBasketItem(itemId, quantity);
      await fetchBasket();
    } catch (e) {
      log('CustomerCartRx updateQuantity error: $e');
    }
  }

  Future<void> removeItem(String itemId) async {
    if (itemId.startsWith('pack_')) {
      _localPackItems.removeWhere((it) => it['id'] == itemId);
      await _emitCombined();
      return;
    }
    try {
      await api.deleteBasketItem(itemId);
      await fetchBasket();
    } catch (e) {
      log('CustomerCartRx removeItem error: $e');
    }
  }

  Future<void> _emitCombined() async {
    final currentData = valueStreamData.valueOrNull;
    Map<String, dynamic> updatedData = {};
    if (currentData is Map) {
      updatedData = Map<String, dynamic>.from(currentData);
      final backendItems = (updatedData['items'] as List? ?? []).where((it) => it['is_leftover_pack'] != true).toList();
      updatedData['items'] = [...backendItems, ..._localPackItems];
    } else {
      updatedData = {'items': [..._localPackItems]};
    }
    await handleSuccessWithReturn(updatedData);
  }

  @override
  void clean() {
    _localPackItems.clear();
    super.clean();
  }

  @override
  void dispose() {
    if (this == instance) return;
    super.dispose();
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
