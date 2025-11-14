import 'package:sueltito/core/constants/roles.dart';
import 'package:sueltito/core/constants/app_paths.dart';

class User {
  final String id;
  final String nombre;
  final List<String> perfiles;
  final List<String> roles;

  User({
    required this.id,
    required this.nombre,
    required this.perfiles,
    required this.roles,
  });

  bool get esPasajero => perfiles.contains(Roles.pasajero);
  bool get esConductor => perfiles.contains(Roles.chofer);

  String? get perfilActual => perfiles.isNotEmpty ? perfiles.first : null;

  String getDefaultRoute() {
    if (perfiles.contains(Roles.chofer)) return AppPaths.driverHome;
    if (perfiles.contains(Roles.pasajero)) return AppPaths.passengerHome;

    return AppPaths.welcome; 
  }
}
