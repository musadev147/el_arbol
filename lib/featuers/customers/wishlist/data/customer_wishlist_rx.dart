import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import 'customer_wishlist_api.dart';
import 'dart:developer';

class CustomerWishlistRx extends RxResponseInt<List<dynamic>> {
  final api = CustomerWishlistApi.instance;

  CustomerWishlistRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchWishlist() async {
    try {
      final data = await api.getWishlist();
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('results')) {
        list = data['results'];
      }
      await handleSuccessWithReturn(list);
    } catch (e) {
      log('CustomerWishlistRx fetchWishlist error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> addToWishlist(Map<String, dynamic> data) async {
    try {
      await EasyLoading.show(status: 'Adding...');
      await api.addToWishlist(data);
      AppToast.success("Added to wishlist");
      fetchWishlist();
      return true;
    } catch (e) {
      log('CustomerWishlistRx addToWishlist error: $e');
      AppToast.error("Failed to add to wishlist");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> removeFromWishlist(String id) async {
    try {
      await EasyLoading.show(status: 'Removing...');
      await api.removeFromWishlist(id);
      AppToast.success("Removed from wishlist");
      fetchWishlist();
      return true;
    } catch (e) {
      log('CustomerWishlistRx removeFromWishlist error: $e');
      AppToast.error("Failed to remove from wishlist");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> clearWishlist() async {
    try {
      await EasyLoading.show(status: 'Clearing...');
      await api.clearWishlist();
      AppToast.success("Wishlist cleared");
      fetchWishlist();
      return true;
    } catch (e) {
      log('CustomerWishlistRx clearWishlist error: $e');
      AppToast.error("Failed to clear wishlist");
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
