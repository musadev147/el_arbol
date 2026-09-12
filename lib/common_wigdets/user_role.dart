enum UserRole {
  customer,
  wholesale,
  employeeSelfService,
  staff;

  String get value => name;

  static UserRole fromString(String? role) {
    if (role == null || role.trim().isEmpty) {
      return UserRole.customer;
    }
    final normalized = role.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    switch (normalized) {
      case 'customer':
      case 'user':
      case 'client':
        return UserRole.customer;
      case 'wholesale':
      case 'wholesales':
      case 'wholesaler':
      case 'wholesalers':
      case 'b2b':
        return UserRole.wholesale;
      case 'employeeselfservice':
      case 'employee_self_service':
      case 'employee':
        return UserRole.employeeSelfService;
      case 'staff':
      case 'store_manager':
      case 'cashier':
      case 'stock_clerk':
      case 'delivery_driver':
      case 'order_picker':
        return UserRole.staff;
      default:
        return UserRole.customer;
    }
  }
}
