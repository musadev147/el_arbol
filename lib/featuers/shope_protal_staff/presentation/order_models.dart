class FVProductInput {
  final String name;
  double classAQty;
  String classAUnit;
  double classBQty;
  String classBUnit;

  FVProductInput({
    required this.name,
    this.classAQty = 0.0,
    this.classAUnit = 'kg',
    this.classBQty = 0.0,
    this.classBUnit = 'kg',
  });
}

class GroceryProductInput {
  String category;
  String name;
  double quantity;
  String unit;
  String details;

  GroceryProductInput({
    required this.category,
    this.name = '',
    this.quantity = 0.0,
    this.unit = 'pcs',
    this.details = '',
  });
}

class StaffOrder {
  final String id;
  final DateTime date;
  final String type; // Retail or Wholesale
  final List<FVProductInput> fvItems;
  final List<GroceryProductInput> groceryItems;
  String status; // e.g., 'Pending Warehouse Approval', 'Approved', 'Shipped'

  StaffOrder({
    required this.id,
    required this.date,
    required this.type,
    required this.fvItems,
    required this.groceryItems,
    required this.status,
  });
}
