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

    ref.listen<AsyncValue<AuthResponse?>>(authProvider, (previous, next) {
      next.whenData((response) {
        if (response == null) {
          context.go(AppPaths.welcome);
        }
      });
    });

    final hasBothProfiles =
        (currentUser?.esPasajero ?? false) &&
        (currentUser?.esConductor ?? false);

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
              // Agregar perfil (solo cuando no tiene conductor)
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.person_add_alt_1,
                    color: AppColors.primaryGreen,
                  ),
                  title: const Text(
                    'Agregar perfil',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: (currentUser == null || hasBothProfiles)
                      ? null
                      : () => _showAddProfileDialog(context, ref, currentUser),
                  enabled: !(currentUser == null || hasBothProfiles),
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
                  onTap: (targetProfile == Roles.chofer && !hasBothProfiles)
                      ? null
                      : () =>
                            _showSwitchRoleDialog(context, ref, targetProfile),
                  enabled: !(targetProfile == Roles.chofer && !hasBothProfiles),
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
      ref
          .read(notificationServiceProvider)
          .showError('Error: Usuario no encontrado');
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
                  : Text(
                      '¿Seguro que quieres cambiar al perfil de $humanTarget?',
                    ),
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
                          final notificationService = dialogRef.read(
                            notificationServiceProvider,
                          );

                          try {
              await dialogRef
                .read(authProvider.notifier)
                .switchProfileLocally(currentUser.id, targetProfile);

                            dialogContext.pop();

                            if (context.mounted) {
                              dialogRef
                                      .read(navigationIndexProvider.notifier)
                                      .state =
                                  1;

                              final updatedAuth = dialogRef
                                  .read(authProvider)
                                  .value;
                              if (updatedAuth != null) {
                                final defaultRoute = updatedAuth.usuario
                                    .getDefaultRoute();
                                context.go(defaultRoute);

                                notificationService.showSuccess(
                                  'Perfil cambiado a $humanTarget',
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            }
                          } catch (e) {
                            notificationService.showError(
                              'Error al cambiar perfil: ${e.toString()}',
                            );
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
                              Colors.white,
                            ),
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

  void _showAddProfileDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic currentUser,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context2, dialogRef, _) {
            final isLoading = dialogRef.watch(authProvider).isLoading;

            return AlertDialog(
              title: const Text('Agregar perfil'),
              content: isLoading
                  ? Row(
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: Text('Agregando perfil...')),
                      ],
                    )
                  : const Text('¿Deseas agregar el perfil de Conductor?'),
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
                          final notificationService = dialogRef.read(
                            notificationServiceProvider,
                          );

                          try {
                            final cuenta = currentUser.nroCuenta;
                            final tipoCuenta =
                                'BUSINESS CODE'; // TODO: use real type
                            await dialogRef
                                .read(authProvider.notifier)
                                .addProfile(currentUser.id, cuenta, tipoCuenta);

                            dialogContext.pop();

                            if (context.mounted) {
                              // Reset navigation index to home and navigate to user's default route
                              dialogRef
                                  .read(navigationIndexProvider.notifier)
                                  .state = 1;

                              final updatedAuth = dialogRef.read(authProvider).value;
                              if (updatedAuth != null) {
                                final defaultRoute = updatedAuth.usuario.getDefaultRoute();
                                context.go(defaultRoute);
                              }

                              notificationService.showSuccess(
                                'Perfil agregado correctamente',
                                duration: const Duration(seconds: 2),
                              );
                            }
                          } catch (e) {
                            notificationService.showError(
                              'Error al agregar perfil: ${e.toString()}',
                            );
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
                              Colors.white,
                            ),
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
