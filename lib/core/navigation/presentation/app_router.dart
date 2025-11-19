import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/core/navigation/constants/route_permissions.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRefreshNotifier(ref);
  
  return GoRouter(
    initialLocation: AppPaths.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    // ✅ Generar rutas automáticamente desde RoutePermissions
    routes: RoutePermissions.routes.map((config) {
      return GoRoute(
        path: config.path,
        builder: config.builder,
        redirect: config.isPublic 
            ? null 
            : (c, s) => _permissionGuard(ref: ref, path: config.path),
      );
    }).toList(),
    
    // ===== REDIRECT GLOBAL =====
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isPublicRoute = RoutePermissions.isPublic(state.fullPath ?? '');

      return auth.when(
        loading: () => null,
        error: (_, __) {
          return state.fullPath == AppPaths.login ? null : AppPaths.login;
        },
        data: (resp) {
          final loggedIn = resp != null;

          if (!loggedIn && !isPublicRoute) {
            return AppPaths.login;
          }

          if (loggedIn && (state.fullPath == AppPaths.login || state.fullPath == AppPaths.signUp)) {
            return resp.usuario.getDefaultRoute();
          }

          return null; 
        },
      );
    },
  );
});

// ===== AUTH REFRESH NOTIFIER =====
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }
}

// ===== PERMISSION GUARD =====
String? _permissionGuard({
  required Ref ref,
  required String path,
}) {
  final authState = ref.read(authProvider);
  final permission = RoutePermissions.getPermission(path);
  
  if (permission == null) return null;

  return authState.when(
    loading: () => null,
    error: (_, __) => AppPaths.login,
    data: (resp) {
      if (resp == null) return AppPaths.login;
      
      final user = resp.usuario;
      final hasPermission = permission.hasPermission(
        userPerfiles: user.perfiles,
      );
      
      return hasPermission ? null : AppPaths.welcome;
    },
  );
}