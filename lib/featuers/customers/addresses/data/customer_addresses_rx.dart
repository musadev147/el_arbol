import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import 'customer_addresses_api.dart';
import 'dart:developer';

class CustomerAddressesRx extends RxResponseInt<List<dynamic>> {
  final api = CustomerAddressesApi.instance;

  CustomerAddressesRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchAddresses() async {
    try {
      final data = await api.getAddresses();
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('results')) {
        list = data['results'];
      }
      await handleSuccessWithReturn(list);
    } catch (e) {
      log('CustomerAddressesRx fetchAddresses error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> createAddress(Map<String, dynamic> addressData) async {
    try {
      await EasyLoading.show(status: 'Saving address...');
      await api.createAddress(addressData);
      AppToast.success("Address saved successfully!");
      fetchAddresses();
      return true;
    } catch (e) {
      log('CustomerAddressesRx createAddress error: $e');
      String message = "Failed to save address";
      if (e is DioException && e.response?.data is Map) {
        message = e.response?.data["message"] ?? message;
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> addressData) async {
    try {
      await EasyLoading.show(status: 'Updating address...');
      await api.updateAddress(id, addressData);
      AppToast.success("Address updated successfully!");
      fetchAddresses();
      return true;
    } catch (e) {
      log('CustomerAddressesRx updateAddress error: $e');
      AppToast.error("Failed to update address");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> deleteAddress(String id) async {
    try {
      await EasyLoading.show(status: 'Deleting...');
      await api.deleteAddress(id);
      AppToast.success("Address deleted");
      fetchAddresses();
      return true;
    } catch (e) {
      log('CustomerAddressesRx deleteAddress error: $e');
      AppToast.error("Failed to delete address");
      return false;
    } finally {
      EasyLoading.dismiss();
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
