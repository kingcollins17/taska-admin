abstract class AdminRoles {
  static const String rootAdmin = 'ROOT_ADMIN';
  static const String superAdmin = 'SUPER_ADMIN';
  static const String operations = 'OPERATIONS';
  static const String support = 'SUPPORT';
  static const String finance = 'FINANCE';

  static const List<String> values = [
    rootAdmin,
    superAdmin,
    operations,
    support,
    finance,
  ];

  static const List<String> invitableRoles = [
    operations,
    support,
    finance,
  ];

  static const List<String> assignableRoles = [
    superAdmin,
    operations,
    support,
    finance,
  ];

  static String labelOf(String? role) {
    if (role == null || role.isEmpty) return 'Unknown';
    switch (role) {
      case rootAdmin:
        return 'Root Admin';
      case superAdmin:
        return 'Super Admin';
      case operations:
        return 'Operations';
      case support:
        return 'Support';
      case finance:
        return 'Finance';
      default:
        return role;
    }
  }
}
