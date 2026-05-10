import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom Text Field Widget - Consistent design throughout the app
class CustomTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final int? maxLength;
  final bool enabled;
  final String? initialValue;
  final bool isRequired;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.maxLength,
    this.enabled = true,
    this.initialValue,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the field
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  labelText!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isRequired)
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Text field without label
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          enabled: enabled,
          initialValue: initialValue,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            floatingLabelBehavior: FloatingLabelBehavior.never, // Never show floating label
            // Uses theme's inputDecorationTheme for consistent styling
            // Background: #212121, Border: #2c2929, Border radius: 8px, Border width: 1px
          ),
        ),
      ],
    );
  }
}

