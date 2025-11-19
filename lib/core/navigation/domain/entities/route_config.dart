import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/security/domain/entities/permission.dart';

class RouteConfig {
  final String path;
  final Widget Function(BuildContext context, GoRouterState state) builder;
  final Permission permission;
  final bool isPublic;

  const RouteConfig({
    required this.path,
    required this.builder,
    this.permission = const Permission(),
    this.isPublic = false,
  });
}