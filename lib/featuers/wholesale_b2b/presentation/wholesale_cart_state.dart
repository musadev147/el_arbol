import 'package:get/get.dart';

class WholesaleCartItem {
  final String id;
  final String name;
  final double wholesalePrice;
  final String unit;
  final String? imageUrl;
  final int minPurchase;
  final int? stock;
  RxDouble quantity;

  WholesaleCartItem({
    required this.id,
    required this.name,
    required this.wholesalePrice,
    required this.unit,
    this.imageUrl,
    this.minPurchase = 1,
    this.stock,
    double qty = 1.0,
  }) : quantity = qty.obs;

  double get subtotal => wholesalePrice * quantity.value;
}

class WholesaleCartState {
  static final RxList<WholesaleCartItem> cartItems = <WholesaleCartItem>[].obs;

  static double get totalAmount {
    return cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  static int get totalItemCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity.value.toInt());
  }

  static bool addToCart({
    required String id,
    required String name,
    required double price,
    required String unit,
    String? imageUrl,
    int minPurchase = 1,
    int? stock,
    double qty = 1.0,
  }) {
    if (stock != null && stock <= 0) {
      Get.snackbar('Out of Stock', '$name is currently out of stock.');
      return false;
    }

    final existingIndex = cartItems.indexWhere((item) => (id.isNotEmpty && item.id == id) || item.name == name);
    if (existingIndex != -1) {
      final item = cartItems[existingIndex];
      final newQty = item.quantity.value + qty;
      if (item.stock != null && newQty > item.stock!) {
        item.quantity.value = item.stock!.toDouble();
        Get.snackbar('Stock Limit', 'Maximum available stock of ${item.stock} reached.');
        return false;
      } else {
        item.quantity.value = newQty;
      }
    } else {
      double initialQty = qty < minPurchase ? minPurchase.toDouble() : qty;
      if (stock != null && initialQty > stock) {
        initialQty = stock.toDouble();
        Get.snackbar('Stock Limit', 'Only $stock items available in stock.');
      }
      cartItems.add(WholesaleCartItem(
        id: id,
        name: name,
        wholesalePrice: price,
        unit: unit,
        imageUrl: imageUrl,
        minPurchase: minPurchase,
        stock: stock,
        qty: initialQty,
      ));
    }
    return true;
  }

  static void updateQuantity(String idOrName, double qty) {
    final index = cartItems.indexWhere((item) => item.id == idOrName || item.name == idOrName);
    if (index != -1) {
      final item = cartItems[index];
      if (qty <= 0) {
        cartItems.removeAt(index);
      } else if (item.stock != null && qty > item.stock!) {
        item.quantity.value = item.stock!.toDouble();
        Get.snackbar('Stock Limit', 'Maximum available stock is ${item.stock}.');
      } else {
        item.quantity.value = qty;
      }
    }
  }

  static void removeFromCart(String idOrName) {
    cartItems.removeWhere((item) => item.id == idOrName || item.name == idOrName);
  }

  static void clear() {
    cartItems.clear();
  }
}
