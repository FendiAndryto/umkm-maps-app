import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool hasShadow;
  final bool hasBorder;
  final double? borderRadius;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.hasShadow = true,
    this.hasBorder = true,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
        border: hasBorder ? Border.all(color: AppColors.border, width: 1) : null,
        boxShadow: hasShadow ? AppColors.shadowSm : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
          onTap: onTap,
          splashColor: AppColors.primarySurface,
          highlightColor: AppColors.primarySurface.withValues(alpha: 0.5),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spaceMd),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Section header with optional trailing action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTheme.headingMd),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTheme.labelMd.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

/// Status / promo badge
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color surfaceColor;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.surfaceColor = AppColors.primarySurface,
    this.icon,
  });

  factory AppBadge.promo() => const AppBadge(
    label: 'PROMO',
    color: AppColors.secondary,
    surfaceColor: AppColors.secondarySurface,
    icon: Icons.local_fire_department_rounded,
  );

  factory AppBadge.approved() => const AppBadge(
    label: 'Aktif',
    color: AppColors.success,
    surfaceColor: AppColors.successSurface,
    icon: Icons.check_circle_outline_rounded,
  );

  factory AppBadge.pending() => const AppBadge(
    label: 'Menunggu',
    color: AppColors.warning,
    surfaceColor: AppColors.warningSurface,
    icon: Icons.hourglass_top_rounded,
  );

  factory AppBadge.rejected() => const AppBadge(
    label: 'Ditolak',
    color: AppColors.error,
    surfaceColor: AppColors.errorSurface,
    icon: Icons.cancel_outlined,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTheme.labelMd.copyWith(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Skeleton shimmer loading placeholder
class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppTheme.radiusSm,
            ),
          ),
        ),
      ),
    );
  }
}
