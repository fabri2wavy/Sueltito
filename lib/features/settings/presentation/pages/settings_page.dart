import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/features/auth/domain/entities/auth_response.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Escuchar cuando el logout sea exitoso
    ref.listen<AsyncValue<AuthResponse?>>(authProvider, (previous, next) {
      next.whenData((response) {
        if (response == null) {
          // Logout exitoso
            context.go(AppPaths.welcome);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            // Icono de QR
            icon: Icon(Icons.qr_code, color: AppColors.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'General',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSettingsRow(
                      context,
                      title: 'Idioma',
                      trailing: 'Español',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16),
                    _buildSettingsRow(
                      context,
                      title: 'Mi Perfil',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16),
                    _buildSettingsRow(
                      context,
                      title: 'Contactanos',
                      onTap: () {},
                      hideArrow: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildSettingsRow(
                  context,
                  title: 'Cambiar a Conductor',
                  onTap: () => _showSwitchRoleDialog(context),
                  icon: Icons.swap_horiz_rounded,
                ),
              ),
              const SizedBox(height: 30),
              // Botón Cerrar Sesión
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildSettingsRow(
                  context,
                  title: 'Cerrar Sesión',
                  onTap: authState.isLoading
                      ? () {} // Deshabilitar si está cargando
                      : () => _showLogoutDialog(context, ref),
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  titleColor: Colors.red,
                  hideArrow: true,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text(
            '¿Estás seguro que deseas cerrar sesión?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                  context.pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
              onPressed: () {
             context.pop();
                // Llamar al logout del provider
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSwitchRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text(
            '¿Seguro que quieres cambiar al perfil de Conductor?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                  context.pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.textWhite,
              ),
              child: const Text('Confirmar'),
              onPressed: () {
            //  context.pop();
            //  context.go(AppPaths.driverHome);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required String title,
    String trailing = '',
    required VoidCallback onTap,
    bool hideArrow = false,
    IconData? icon,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: (icon != null)
          ? Icon(icon, color: iconColor ?? AppColors.primaryGreen)
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty)
            Text(trailing, style: TextStyle(color: Colors.grey[600])),
          if (!hideArrow) const SizedBox(width: 8),
          if (!hideArrow)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
      onTap: onTap,
    );
  }
}
