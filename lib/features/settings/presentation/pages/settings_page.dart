import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/features/auth/domain/entities/auth_response.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';
import 'package:sueltito/core/constants/roles.dart';
import 'package:sueltito/core/navigation/presentation/providers/navigation_provider.dart';
import 'package:sueltito/core/services/notification_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value?.usuario;
    final currentProfile = currentUser?.perfilActual;
    final targetProfile = (currentProfile == null)
        ? Roles.chofer
        : Roles.oppositeOf(currentProfile);

    // Escuchar cuando el logout sea exitoso
    ref.listen<AsyncValue<AuthResponse?>>(authProvider, (previous, next) {
      next.whenData((response) {
        if (response == null) {
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
              // Cambiar de perfil (dinámico según el actual)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  title: Text(
                    'Cambiar a ${targetProfile == Roles.chofer ? 'Conductor' : 'Pasajero'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () =>
                      _showSwitchRoleDialog(context, ref, targetProfile),
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
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
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
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSwitchRoleDialog(
    BuildContext context,
    WidgetRef ref,
    String targetProfile,
  ) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value?.usuario;

    if (currentUser == null) {
      ref.read(notificationServiceProvider).showError(
        'Error: Usuario no encontrado',
      );
      return;
    }

    final humanTarget = targetProfile == Roles.chofer
        ? 'Conductor'
        : 'Pasajero';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context2, dialogRef, _) {
            final isLoading = dialogRef.watch(authProvider).isLoading;

            return AlertDialog(
              title: const Text('Confirmación'),
              content: isLoading
                  ? Row(
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: Text('Cambiando perfil...')),
                      ],
                    )
                  : Text('¿Seguro que quieres cambiar al perfil de $humanTarget?'),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: isLoading ? null : () => dialogContext.pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.textWhite,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          // We read the notifier through dialogRef. This avoids using
                          // the outer `ref` in an async callback after widget disposal.
                          final notificationService =
                              dialogRef.read(notificationServiceProvider);

                          try {
                            await dialogRef
                                .read(authProvider.notifier)
                                .changeProfile(currentUser.id, targetProfile);

                            // Close the dialog when finished successfully
                            dialogContext.pop();

                            if (context.mounted) {
                              dialogRef.read(navigationIndexProvider.notifier).state = 1;

                              final updatedAuth = dialogRef.read(authProvider).value;
                              if (updatedAuth != null) {
                                final defaultRoute =
                                    updatedAuth.usuario.getDefaultRoute();
                                context.go(defaultRoute);

                                notificationService.showSuccess(
                                  'Perfil cambiado a $humanTarget',
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            }
                          } catch (e) {
                            // The provider will be in error state; show the
                            // notification and keep the dialog closed.
                            notificationService.showError(
                              'Error al cambiar perfil: ${e.toString()}',
                            );
                            // Close the dialog even on error so user can retry
                            dialogContext.pop();
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : const Text('Confirmar'),
                ),
              ],
            );
          },
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
        style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
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
