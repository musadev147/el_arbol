enum UserRole {
  customer,
  wholesale,
  employeeSelfService,
  staff;

  String get value => name;

  static UserRole fromString(String? role) {
    if (role == null || role.isEmpty) {
      throw Exception("Invalid user role: (empty)");
    }
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'wholesale':
      case 'wholesales':
        return UserRole.wholesale;
      case 'employeeselfservice':
      case 'employee self-service':
      case 'employee':
        return UserRole.employeeSelfService;
      case 'staff':
        return UserRole.staff;
      default:
        throw Exception("Invalid user role: $role");
    }
  }
}
