import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      AppButtonSize.sm => 40.0,
      AppButtonSize.md => 52.0,
      AppButtonSize.lg => 56.0,
    };
    final fontSize = switch (size) {
      AppButtonSize.sm => 13.0,
      AppButtonSize.md => 15.0,
      AppButtonSize.lg => 16.0,
    };
    final hPad = switch (size) {
      AppButtonSize.sm => 12.0,
      AppButtonSize.md => 20.0,
      AppButtonSize.lg => 24.0,
    };

    final (bgColor, fgColor, borderColor) = switch (variant) {
      AppButtonVariant.primary  => (AppColors.primary, AppColors.textOnPrimary, Colors.transparent),
      AppButtonVariant.secondary => (AppColors.primarySurface, AppColors.primary, Colors.transparent),
      AppButtonVariant.outline  => (Colors.transparent, AppColors.primary, AppColors.primary),
      AppButtonVariant.ghost    => (Colors.transparent, AppColors.textSecondary, Colors.transparent),
      AppButtonVariant.danger   => (AppColors.error, AppColors.textOnPrimary, Colors.transparent),
    };

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: fgColor,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.labelLg.copyWith(color: fgColor, fontSize: fontSize),
                ),
              ),
              if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
            ],
          );

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.roundedMd,
            side: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
        child: child,
      ),
    );
  }
}
