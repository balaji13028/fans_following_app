import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom Dropdown Widget - Consistent design throughout the app
class CustomDropdown<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isRequired;

  const CustomDropdown({
    super.key,
    this.labelText,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
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
        // Dropdown field
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            // Uses theme's inputDecorationTheme for consistent styling
            // Background: #212121, Border: #2c2929, Border radius: 8px, Border width: 1px
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          dropdownColor: AppColors.surfaceVariant,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          isExpanded: true,
        ),
      ],
    );
  }
}

