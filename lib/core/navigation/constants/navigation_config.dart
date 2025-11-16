import 'package:flutter/material.dart';
import 'package:sueltito/features/driver/presentation/pages/driver_home_page.dart';
import 'package:sueltito/features/history/presentation/pages/history_page.dart';
import 'package:sueltito/features/passenger/presentation/pages/passenger_home_page.dart';
import 'package:sueltito/features/settings/presentation/pages/settings_page.dart';
import 'package:sueltito/core/widgets/app_bottom_navigation.dart';

class NavigationConfig {
  static List<BottomNavigationItem> getPassengerItems() {
    return [
      const BottomNavigationItem(
        icon: Icons.history,
        label: 'Historial',
        page: HistoryPage(),
      ),
      const BottomNavigationItem(
        icon: Icons.home,
        label: 'Home',
        page: PassengerHomePage(),
      ),
      const BottomNavigationItem(
        icon: Icons.settings,
        label: 'Configuración',
        page: SettingsPage(),
      ),
    ];
  }

  static List<BottomNavigationItem> getDriverItems() {
    return [
      const BottomNavigationItem(
        icon: Icons.history,
        label: 'Historial',
        page: HistoryPage(),
      ),
      const BottomNavigationItem(
        icon: Icons.home,
        label: 'Home',
        page: DriverHomeContent(), // El contenido sin scaffold
      ),
      const BottomNavigationItem(
        icon: Icons.menu,
        label: 'Más',
        page: SettingsPage(),
      ),
    ];
  }
}