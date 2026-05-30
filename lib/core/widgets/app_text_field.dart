import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.labelMd),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: AppTheme.bodyMd.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.textTertiary)
                : null,
            suffix: suffix,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
          ),
        ),
      ],
    );
  }
}
