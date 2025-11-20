import 'package:sueltito/core/constants/roles.dart';
import 'package:sueltito/core/constants/app_paths.dart';

class User {
  final String id;
  final String idEntPersona;
  final String nombre;
  final String celular;
  final String correo;
  final String nroCuenta;
  final String estado;
  final String primerApellido;
  final String segundoApellido;
  final String nombreCompleto;
  final List<String> perfiles;
  final List<String> roles;

  User({
    required this.id,
    required this.nombre,
    required this.idEntPersona,
    required this.celular,
    required this.correo,
    required this.nroCuenta,
    required this.estado,
    required this.primerApellido,
    required this.segundoApellido,
    required this.nombreCompleto,
    required this.perfiles,
    required this.roles,
  });

  bool get esPasajero => perfiles.contains(Roles.pasajero);
  bool get esConductor => perfiles.contains(Roles.chofer);

  String? get perfilActual => perfiles.isNotEmpty ? perfiles.first : null;

  String getDefaultRoute() {
    final active = perfilActual;
    if (active == Roles.chofer) return AppPaths.driverHome;
    if (active == Roles.pasajero) return AppPaths.passengerHome;
    // fallback: if active not defined, fallback to presence check
    if (perfiles.contains(Roles.chofer)) return AppPaths.driverHome;
    if (perfiles.contains(Roles.pasajero)) return AppPaths.passengerHome;

    return AppPaths.welcome; 
  }
}
