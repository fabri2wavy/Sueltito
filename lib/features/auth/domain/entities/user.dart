import 'package:sueltito/core/constants/roles.dart';

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
    if (perfiles.contains(Roles.chofer)) return '/driver_home';
    if (perfiles.contains(Roles.pasajero)) return '/passenger_home';

    return '/welcome'; 
  }
}
