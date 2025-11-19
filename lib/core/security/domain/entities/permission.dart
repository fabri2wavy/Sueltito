class Permission {
  final List<String> requiredRoles;
  final List<String> requiredPerfiles;

  const Permission({
    this.requiredRoles = const [],
    this.requiredPerfiles = const [],
  });

  bool hasPermission({
    // required List<String> userRoles,
    required List<String> userPerfiles,
  }) {
    if (requiredRoles.isEmpty && requiredPerfiles.isEmpty) {
      return true;
    }

    // final hasRole = requiredRoles.isEmpty ||
    //     requiredRoles.any((role) => userRoles.contains(role));
    
    final hasPerfil = requiredPerfiles.isEmpty ||
        requiredPerfiles.any((perfil) => userPerfiles.contains(perfil));

    // return hasRole && hasPerfil;
    return hasPerfil;
  }
}