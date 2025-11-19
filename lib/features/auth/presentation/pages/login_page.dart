import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/core/widgets/sueltito_text_field.dart';
import 'package:sueltito/core/services/notification_service.dart';
import 'package:sueltito/features/auth/domain/entities/auth_response.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _celularController = TextEditingController();

  @override
  void dispose() {
    _celularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);

    final notificationService = ref.read(notificationServiceProvider);
    ref.listen<AsyncValue<AuthResponse?>>(authProvider, (previous, next) {
      next.when(
        data: (response) {
          if (response != null) {
            notificationService.showSuccess('Login exitoso');
            context.go(response.usuario.getDefaultRoute());
          }
        },
        error: (error, stack) {
          notificationService.showError(
            error.toString().replaceAll('Exception: ', ''),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Bienvenido de nuevo!',
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ingresa tu número de celular para continuar',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 48),
                        SueltitoTextField(
                          hintText: 'Número Celular',
                          controller: _celularController,
                          keyboardType: TextInputType.phone,
                          enabled: !authState.isLoading,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        final celular = _celularController.text.trim();
                        if (celular.isNotEmpty) {
                          ref.read(authProvider.notifier).login(celular);
                        } else {
                          ref
                              .read(notificationServiceProvider)
                              .showWarning('Ingresa tu número de celular');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Ingresar'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            context.push(AppPaths.signUp);
                          },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
