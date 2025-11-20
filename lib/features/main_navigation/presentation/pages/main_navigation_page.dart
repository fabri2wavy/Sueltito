import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/widgets/app_bottom_navigation.dart';
import 'package:sueltito/core/navigation/constants/navigation_config.dart';
import 'package:sueltito/core/navigation/presentation/providers/navigation_provider.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';
import 'package:sueltito/features/auth/domain/entities/user.dart';
import 'package:sueltito/core/constants/roles.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final currentUser = ref.watch(currentUserProvider);
    final profileActual = currentUser?.perfilActual;

    // Reset navigation index to default when profile changes so the home page is shown.
    ref.listen<User?>(currentUserProvider, (previous, next) {
      final prevPerfil = previous?.perfilActual;
      final nextPerfil = next?.perfilActual;
      if (prevPerfil != nextPerfil) {
        ref.read(navigationIndexProvider.notifier).state = 1; // default 'home' index
      }
    });

    final navigationItems = (profileActual == Roles.chofer)
        ? NavigationConfig.getDriverItems()
        : NavigationConfig.getPassengerItems();

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
        items: navigationItems,
      ),
    );
  }
}