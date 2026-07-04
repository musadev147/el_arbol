import 'package:get/get.dart';
import 'order_models.dart';

class OrderState {
  static final RxList<StaffOrder> orders = <StaffOrder>[
    // Seed some initial demo orders
    StaffOrder(
      id: 'ORD-90812',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'Wholesale',
      fvItems: [
        FVProductInput(name: 'Gala Apples', classAQty: 120, classAUnit: 'kg', classBQty: 40, classBUnit: 'kg'),
        FVProductInput(name: 'Red Bell Peppers', classAQty: 60, classAUnit: 'kg'),
      ],
      groceryItems: [
        GroceryProductInput(category: 'Spices', name: 'Black Pepper Ground', quantity: 15, unit: 'pack', details: 'Aromatic fine powder'),
      ],
      status: 'Pending Warehouse Approval',
    ),
    StaffOrder(
      id: 'ORD-90145',
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: 'Retail',
      fvItems: [
        FVProductInput(name: 'Watermelon', classAQty: 30, classAUnit: 'pcs'),
        FVProductInput(name: 'Cherry Tomatoes', classAQty: 15, classAUnit: 'box', classBQty: 5, classBUnit: 'box'),
      ],
      groceryItems: [
        GroceryProductInput(category: 'Nuts', name: 'Raw Almonds', quantity: 24, unit: 'pcs'),
        GroceryProductInput(category: 'Frozen', name: 'Frozen Peas', quantity: 10, unit: 'pcs'),
      ],
      status: 'Approved',
    ),
  ].obs;

  static void addOrder(StaffOrder order) {
    orders.insert(0, order);
  }

  static void updateOrder(StaffOrder updatedOrder) {
    final index = orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      orders[index] = updatedOrder;
    }
  }

  static void deleteOrder(String id) {
    orders.removeWhere((o) => o.id == id);
  }
}
