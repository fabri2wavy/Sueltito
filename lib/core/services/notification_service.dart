import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/config/global_keys.dart';

/// Provides an application-wide notification API.
///
/// The implementation uses the global [kScaffoldMessengerKey] to show snackbars
/// so they persist across navigation. This wrapper centralizes styling and
/// behavior for all toast/snackbar usage.
class NotificationService {
  void _showSnackBar(
    String message, {required Color backgroundColor, Duration? duration}) {
    final scaffold = kScaffoldMessengerKey.currentState;
    if (scaffold == null) return;

    // hide any current snackbars so messages don't pile
    scaffold.hideCurrentSnackBar();

    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void showSuccess(String message, {Duration? duration}) {
    _showSnackBar(message,
        backgroundColor: AppColors.primaryGreen, duration: duration);
  }

  void showError(String message, {Duration? duration}) {
    _showSnackBar(message, backgroundColor: Colors.red, duration: duration);
  }

  void showWarning(String message, {Duration? duration}) {
    _showSnackBar(message, backgroundColor: Colors.orange, duration: duration);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});