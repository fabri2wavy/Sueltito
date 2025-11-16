import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/widgets/app_bottom_navigation.dart';
import 'package:sueltito/core/navigation/constants/navigation_config.dart';
import 'package:sueltito/core/navigation/presentation/providers/navigation_provider.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final navigationItems = NavigationConfig.getPassengerItems();

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
