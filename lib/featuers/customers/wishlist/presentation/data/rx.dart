import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import '../../../home/presentation/model/post_wishlist_model.dart';
import 'api.dart';

/// Reactive state handler for customer wishlist operations.
class WishlistRx extends RxResponseInt<List<PostCreateWishlistModel>> {
  final api = WishlistApi.instance;

  WishlistRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<List<PostCreateWishlistModel>> get valueStreamData => dataFetcher.stream;

  /// Checks if a given product ID is in the current wishlist.
  bool isWishlisted(String? productId) {
    if (productId == null) return false;
    final currentList = dataFetcher.value;
    return currentList.any((item) => item.product?.id == productId);
  }

  /// Gets the wishlist item ID for a given product ID.
  int? getWishlistId(String? productId) {
    if (productId == null) return null;
    final currentList = dataFetcher.value;
    try {
      return currentList.firstWhere((item) => item.product?.id == productId).id;
    } catch (_) {
      return null;
    }
  }

  /// Fetches all wishlist items from the server.
  Future<void> fetchWishlist() async {
    try {
      final data = await api.getWishlistData();
      await handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch wishlist error: $error");
      await handleErrorWithReturn(error);
    }
  }

  /// Adds a product to the wishlist.
  Future<void> addItem(String productId) async {
    try {
      await EasyLoading.show(status: "Adding to wishlist...");
      final addedItem = await api.addToWishlist(productId);

      final currentList = dataFetcher.value;
      final updatedList = List<PostCreateWishlistModel>.from(currentList)..add(addedItem);
      dataFetcher.sink.add(updatedList);

      AppToast.success("Added to wishlist!");
    } catch (error) {
      log("Add to wishlist error: $error");
      AppToast.error("Failed to add to wishlist");
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Removes a product from the wishlist by product ID.
  Future<void> removeItem(String productId) async {
    try {
      await EasyLoading.show(status: "Removing...");
      await api.removeFromWishlist(productId);

      final currentList = dataFetcher.value;
      final updatedList = List<PostCreateWishlistModel>.from(currentList)
        ..removeWhere((item) => item.product?.id == productId);
      dataFetcher.sink.add(updatedList);

      AppToast.success("Removed from wishlist!");
    } catch (error) {
      log("Remove from wishlist error: $error");
      AppToast.error("Failed to remove from wishlist");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  handleSuccessWithReturn(List<PostCreateWishlistModel> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  handleErrorWithReturn(error) {
    String message = "Failed to load wishlist";

    if (error is DioException) {
      message = error.response?.data["message"] ?? message;
    }

    AppToast.error(message);
    dataFetcher.sink.addError(error);
  }
}
