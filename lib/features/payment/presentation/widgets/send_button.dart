import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';

class SendButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;
  final String? tooltip;

  const SendButton({
    Key? key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
    this.label = 'ENVIAR',
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading;

    final roundedBtn = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(18),
        backgroundColor: enabled ? const Color.fromARGB(255, 84, 209, 190) : Colors.grey[400],
        disabledBackgroundColor: Colors.grey[300],
        disabledForegroundColor: Colors.grey[500],
        elevation: 0,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: isLoading
            ? const SizedBox(
                key: ValueKey('spinner'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
              )
            : const Icon(
                Icons.attach_money,
                key: ValueKey('icon'),
                size: 30,
                color: Colors.white,
              ),
      ),
    );

    final Widget button = (tooltip != null && tooltip!.isNotEmpty) ? Tooltip(message: tooltip!, child: roundedBtn) : roundedBtn;

    return Column(
      children: [
        button,
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: enabled ? AppColors.primaryGreen : Colors.grey,
          ),
        ),
      ],
    );
  }
}
