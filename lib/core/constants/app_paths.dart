class AppPaths {
  AppPaths._(); // Constructor privado

  // ===== PUBLIC ROUTES =====
  
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signUp = '/sign_up';
  static const profile = '/profile';
  static const settings = '/settings';

  // ===== PASSENGER ROUTES =====
  static const passengerHome = '/passenger_home';
  static const minibusPayment = '/minibus_payment';
  static const trufisPayment = '/trufis_payment';
  static const taxiPayment = '/taxi_payment';
  static const paymentStatus = '/payment_status';
  
  // ===== DRIVER ROUTES =====
  static const driverHome = '/driver_home';
  
  static List<String> get publicRoutes => [welcome, login, signUp];
  
  static bool isPublicRoute(String? path) =>
      publicRoutes.contains(path);
}