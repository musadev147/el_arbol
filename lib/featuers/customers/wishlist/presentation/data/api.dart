import 'package:el_arbol/networks/dio/dio.dart';
import 'package:el_arbol/networks/exception_handler/data_source.dart';
import 'package:el_arbol/networks/endpoints.dart';
import '../../../home/presentation/model/post_wishlist_model.dart';

/// API remote data source for Wishlist operations.
class WishlistApi {
  static final WishlistApi _singleton = WishlistApi._internal();
  WishlistApi._internal();
  static WishlistApi get instance => _singleton;

  /// Fetches all wishlist items from the backend.
  Future<List<PostCreateWishlistModel>> getWishlistData() async {
    try {
      final response = await getHttp(Endpoints.wishlist());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List) {
          return data.map((v) => PostCreateWishlistModel.fromJson(v)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          final results = data['results'] as List;
          return results.map((v) => PostCreateWishlistModel.fromJson(v)).toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Adds a product to the wishlist.
  Future<PostCreateWishlistModel> addToWishlist(String productId) async {
    try {
      final response = await postHttp(
        Endpoints.wishlist(),
        {
          "product_id": productId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostCreateWishlistModel.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Removes an item from the wishlist by product ID.
  Future<void> removeFromWishlist(String productId) async {
    try {
      final response = await deleteHttp(Endpoints.wishlistDelete(productId));
      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 201) {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
