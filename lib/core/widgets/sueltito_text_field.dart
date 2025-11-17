import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SueltitoTextField extends StatelessWidget {
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool obscureText;
  final String? prefixText;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const SueltitoTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixText,
    this.onTap,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    // Si el teclado es numérico ⇒ permitir SOLO números
    final List<TextInputFormatter>? formatters =
        keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: formatters,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: prefixText != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: Text(
                  prefixText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),

        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Color(0xFF6C63FF), // Sueltito morado suave
            width: 1.5,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}
