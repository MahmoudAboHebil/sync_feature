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
const String currentUser = 'mahmoud';
const String deviceId = 'device1';
