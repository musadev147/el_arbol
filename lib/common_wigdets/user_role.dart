enum UserRole {
  tenant,
  landlord,
  agent,
  workman;

  String get value => name;

  static UserRole fromString(String? role) {
    if (role == null || role.isEmpty) {
      throw Exception("Invalid user role: (empty)");
    }
    switch (role.toLowerCase()) {
      case 'tenant':
        return UserRole.tenant;
      case 'landlord':
        return UserRole.landlord;
      case 'agent':
        return UserRole.agent;
      case 'workman':
        return UserRole.workman;
      default:
        throw Exception("Invalid user role: $role");
    }
  }
}
