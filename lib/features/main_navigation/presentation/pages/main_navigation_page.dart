import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- 1. AÑADE ESTE IMPORT (para Salir de la App)
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/history/presentation/pages/history_page.dart';
import 'package:sueltito/features/payment/presentation/pages/nfc_scan_page.dart'; // <-- El Scan es el Home
import 'package:sueltito/features/settings/presentation/pages/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 1; // El índice 1 (NFC Scan) es el default
  
  static const List<Widget> _widgetOptions = <Widget>[
    HistoryPage(),   // Índice 0
    NfcScanPage(),   // Índice 1
    SettingsPage(),  // Índice 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- 2. ENVUELVE TU SCAFFOLD EN ESTE WIDGET ---
    return PopScope(
      canPop: false, // Evita que el botón de "atrás" funcione automáticamente
      onPopInvoked: (bool didPop) {
        // Esta función se llama CADA VEZ que el usuario presiona "atrás"
        
        if (didPop) {
          // (Esto no debería pasar porque canPop es false, pero es un seguro)
          return; 
        }

        // Si el usuario NO está en la pantalla Home (Scan), simplemente regresa
        if (_selectedIndex != 1) {
          setState(() {
            _selectedIndex = 1; // Vuelve a la pestaña Home (NFC Scan)
          });
        } 
        // Si YA ESTÁ en la pantalla Home, muestra el diálogo de "Salir"
        else {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('¿Salir de Sueltito?'),
                content: const Text('¿Estás seguro de que quieres cerrar la aplicación?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra solo el diálogo
                    },
                  ),
                  TextButton(
                    child: const Text('Salir'),
                    onPressed: () {
                      // Cierra la aplicación por completo
                      SystemNavigator.pop(); 
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.textWhite,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          selectedLabelStyle: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.nfc), // <-- Ícono de NFC
              label: 'Pagar',         // <-- Etiqueta "Pagar"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configuración',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}