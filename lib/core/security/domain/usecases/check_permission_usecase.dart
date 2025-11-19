import 'package:sueltito/features/auth/domain/entities/user.dart';

import '../entities/permission.dart';

class CheckPermissionUseCase {
  bool call({
    required User user,
    required Permission permission,
  }) {
    return permission.hasPermission(
      // userRoles: user.roles,
      userPerfiles: user.perfiles,
    );
  }
}