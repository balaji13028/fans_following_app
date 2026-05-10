import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// Custom Date Picker Field Widget
class DatePickerField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onDateSelected;
  final String? Function(DateTime?)? validator;
  final bool isRequired;

  const DatePickerField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.validator,
    this.isRequired = false,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && onDateSelected != null) {
      onDateSelected!(picked);
    }
  }

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
        // Date picker field
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hintText ?? 'Select date',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: AppColors.textSecondary,
              ),
              // Uses theme's inputDecorationTheme for consistent styling
            ),
            child: Text(
              initialDate != null
                  ? DateFormat('dd/MM/yyyy').format(initialDate!)
                  : hintText ?? 'Select date',
              style: TextStyle(
                color: initialDate != null
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

