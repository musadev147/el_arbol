enum UserRole {
  wholesale,
  shopPortal,
  employeeSelfService;

  String get value => name;

  static UserRole fromString(String? role) {
    if (role == null || role.isEmpty) {
      throw Exception("Invalid user role: (empty)");
    }
    switch (role.toLowerCase()) {
      case 'wholesale':
      case 'wholesales':
        return UserRole.wholesale;
      case 'shopportal':
      case 'shop portal':
        return UserRole.shopPortal;
      case 'employeeselfservice':
      case 'employee self-service':
      case 'employee':
        return UserRole.employeeSelfService;
      default:
        throw Exception("Invalid user role: $role");
    }
  }
}
