import 'package:sueltito/core/constants/app_paths.dart';

class Roles {
  static const pasajero = 'PASAJERO';
  static const chofer = 'CONDUCTOR';
  static const admin = 'ADMIN';

  static String oppositeOf(String current) {
    final up = current.toUpperCase();
    if (up == chofer) return pasajero;
    if (up == pasajero) return chofer;
    return pasajero; 
  }

  static bool isChofer(String profile) => profile.toUpperCase() == chofer;
  static bool isPasajero(String profile) => profile.toUpperCase() == pasajero;

  static const Map<String, String> profileRoutes = {
    chofer: AppPaths.driverHome,
    pasajero: AppPaths.passengerHome,
  };
}