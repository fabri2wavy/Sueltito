import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/core/widgets/sueltito_text_field.dart';
import 'package:sueltito/features/auth/domain/entities/auth_response.dart';
import '../providers/auth_provider.dart';
import 'package:sueltito/core/services/notification_service.dart';
import 'package:sueltito/core/network/api_client.dart';
import '../providers/register_provider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController fechaCtrl = TextEditingController();
  final pinCtrl = List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    fechaCtrl.dispose();
    for (final ctrl in pinCtrl) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('es'),
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(registerFormProvider.notifier).updateFechaNacimiento(picked);
      fechaCtrl.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _handleRegister() async {
    try {
      await ref.read(registerFormProvider.notifier).submitRegister(context);
    } catch (e) {
      if (mounted) {
        final err = e is ApiException ? e.message : e.toString().replaceAll('Exception: ', '');
        ref.read(notificationServiceProvider).showWarning(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);
    final formState = ref.watch(registerFormProvider);

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
          final err = error is ApiException ? error.message : error.toString().replaceAll('Exception: ', '');
          notificationService.showError(err);
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
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hola! Ingresa tus datos para poder comenzar',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nombre
                      SueltitoTextField(
                        hintText: 'Nombre',
                        enabled: !authState.isLoading,
                        onChanged: (value) =>
                            ref.read(registerFormProvider.notifier).updateNombre(value),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Apellidos
                      Row(
                        children: [
                          Expanded(
                            child: SueltitoTextField(
                              hintText: 'Primer Apellido',
                              enabled: !authState.isLoading,
                              onChanged: (value) => ref
                                  .read(registerFormProvider.notifier)
                                  .updatePrimerApellido(value),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SueltitoTextField(
                              hintText: 'Segundo Apellido',
                              enabled: !authState.isLoading,
                              onChanged: (value) => ref
                                  .read(registerFormProvider.notifier)
                                  .updateSegundoApellido(value),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // CI + Complemento
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SueltitoTextField(
                              hintText: 'C.I.',
                              enabled: !authState.isLoading,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => ref
                                  .read(registerFormProvider.notifier)
                                  .updateCI(value),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: SueltitoTextField(
                              hintText: 'Comple. (Opcional)',
                              enabled: !authState.isLoading,
                              onChanged: (value) => ref
                                  .read(registerFormProvider.notifier)
                                  .updateComplemento(value),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Expedido
                      DropdownButtonFormField<String>(
                        value: formState.expedido.isEmpty ? null : formState.expedido,
                        hint: const Text('Expedido en...'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          'LP', 'SC', 'CB', 'CH', 'OR', 'PT', 'TJ', 'BN', 'PA', 'SIN EXTENSION'
                        ].map((String depto) {
                          return DropdownMenuItem<String>(
                            value: depto,
                            child: Text(depto),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          ref.read(registerFormProvider.notifier).updateExpedido(newValue ?? '');
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fecha de nacimiento
                      SueltitoTextField(
                        hintText: "Fecha de Nacimiento (YYYY-MM-DD)",
                        controller: fechaCtrl,
                        enabled: !authState.isLoading,
                        keyboardType: TextInputType.none,
                        onTap: authState.isLoading ? null : () => _selectDate(context),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Celular
                      SueltitoTextField(
                        hintText: 'Celular',
                        enabled: !authState.isLoading,
                        keyboardType: TextInputType.phone,
                        prefixText: "+591 ",
                        onChanged: (value) => ref
                            .read(registerFormProvider.notifier)
                            .updateCelular(value),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email
                      SueltitoTextField(
                        hintText: 'Correo',
                        enabled: !authState.isLoading,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => ref
                            .read(registerFormProvider.notifier)
                            .updateCorreo(value),
                      ),
                      const SizedBox(height: 32),

                      // PIN
                      Text(
                        "Crea tu PIN de seguridad",
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (i) {
                          return SizedBox(
                            width: 55,
                            child: TextField(
                              controller: pinCtrl[i],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              enabled: !authState.isLoading,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                ref
                                    .read(registerFormProvider.notifier)
                                    .updatePin(i, value);
                                if (value.isNotEmpty && i < 3) {
                                  FocusScope.of(context).nextFocus();
                                }
                                if (value.isEmpty && i > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Botón continuar
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    : const Text(
                        'Continuar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya formas parte de Sueltito? '),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            context.go(AppPaths.login);
                          },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Inicia sesión',
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