import 'package:get/get.dart';

class WholesaleCartItem {
  final String name;
  final double wholesalePrice;
  final String unit;
  RxDouble quantity;

  WholesaleCartItem({
    required this.name,
    required this.wholesalePrice,
    required this.unit,
    double qty = 1.0,
  }) : quantity = qty.obs;
}

class WholesaleCartState {
  static final RxList<WholesaleCartItem> cartItems = <WholesaleCartItem>[].obs;

  static double get totalAmount {
    return cartItems.fold(0.0, (sum, item) => sum + (item.wholesalePrice * item.quantity.value));
  }

  static void addToCart(String name, double price, String unit, double qty) {
    final existingIndex = cartItems.indexWhere((item) => item.name == name);
    if (existingIndex != -1) {
      cartItems[existingIndex].quantity.value += qty;
    } else {
      cartItems.add(WholesaleCartItem(name: name, wholesalePrice: price, unit: unit, qty: qty));
    }
  }

  static void updateQuantity(String name, double qty) {
    final index = cartItems.indexWhere((item) => item.name == name);
    if (index != -1) {
      if (qty <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index].quantity.value = qty;
      }
    }
  }

  static void clear() {
    cartItems.clear();
  }
}
