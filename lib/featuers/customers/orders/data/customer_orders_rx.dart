import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
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
      } else if (data is Map && data.containsKey('results')) {
        list = data['results'];
      }
      await handleSuccessWithReturn(list);
    } catch (e) {
      log('CustomerOrdersRx fetchOrders error: $e');
      await handleErrorWithReturn(e);
    }
  }

  @override
  Future<void> handleSuccessWithReturn(dynamic data) async {
    dataFetcher.sink.add(data is List ? data : []);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
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
