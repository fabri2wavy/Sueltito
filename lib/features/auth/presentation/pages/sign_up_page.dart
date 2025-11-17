import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/core/widgets/sueltito_text_field.dart';
import 'package:sueltito/features/auth/domain/entities/auth_response.dart';
import '../providers/auth_provider.dart';
import 'package:sueltito/core/services/notification_service.dart';
import '../providers/register_provider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _fechaNacimientoController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('es'),
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(registerFormProvider.notifier).updateFechaNacimiento(picked);
      _fechaNacimientoController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> _handleRegister() async {
    try {
      await ref.read(registerFormProvider.notifier).submitRegister(context);
    } catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showWarning(
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  void dispose() {
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);

    // Escuchar cambios en el estado de auth
    final notificationService = ref.read(notificationServiceProvider);
    ref.listen<AsyncValue<AuthResponse?>>(authProvider, (previous, next) {
      next.when(
        data: (response) {
          if (response != null) {
            notificationService.showSuccess('Registro exitoso');
                context.go(AppPaths.passengerHome);
          }
        },
        error: (error, stack) {
          notificationService.showError(error.toString().replaceAll('Exception: ', ''));
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
                          'Hola! Ingresa tus datos para poder comenzar',
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 32),
                        SueltitoTextField(
                          hintText: 'Nombre',
                          enabled: !authState.isLoading,
                          onChanged: (value) => ref.read(registerFormProvider.notifier).updateNombre(value),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SueltitoTextField(
                                hintText: 'Primer Apellido',
                                enabled: !authState.isLoading,
                                onChanged: (value) => ref.read(registerFormProvider.notifier).updatePrimerApellido(value),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SueltitoTextField(
                                hintText: 'Segundo Apellido',
                                enabled: !authState.isLoading,
                                onChanged: (value) => ref.read(registerFormProvider.notifier).updateSegundoApellido(value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SueltitoTextField(
                                hintText: 'C.I.',
                                keyboardType: TextInputType.number,
                                enabled: !authState.isLoading,
                                onChanged: (value) => ref.read(registerFormProvider.notifier).updateCI(value),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SueltitoTextField(
                                hintText: 'Fecha de Nacimiento',
                                controller: _fechaNacimientoController,
                                readOnly: true,
                                onTap: authState.isLoading ? null : () => _selectDate(context),
                                suffixIcon: const Icon(Icons.calendar_today),
                                enabled: !authState.isLoading,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SueltitoTextField(
                          hintText: 'Numero Celular:',
                          keyboardType: TextInputType.phone,
                          enabled: !authState.isLoading,
                          onChanged: (value) => ref.read(registerFormProvider.notifier).updateCelular(value),
                        ),
                        const SizedBox(height: 16),
                        SueltitoTextField(
                          hintText: 'Correo',
                          keyboardType: TextInputType.emailAddress,
                          enabled: !authState.isLoading,
                          onChanged: (value) => ref.read(registerFormProvider.notifier).updateCorreo(value),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleRegister,
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
                    : const Text('Continuar'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya formas parte de Sueltito? ',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                              context.push(AppPaths.login);
                          },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Inicia sesion',
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
