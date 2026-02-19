enum UserRole {
  admin,
  oner,
  assistant;

  static UserRole getUserRoleFromString(String userRole) {
    for (final role in UserRole.values) {
      if (role.name == userRole) return role;
    }
    throw Exception('$userRole is not found');
  }
}

const UserRole currentUserRole = UserRole.admin;
const String currentUser = 'e05f3ee8-2c6f-4ac8-bb2a-f744fdb8886c';
const String deviceId = 'device1';
