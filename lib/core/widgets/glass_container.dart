import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// The foundational glass widget — wraps any child in a frosted-glass surface.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? blur;
  final double? fillOpacity;
  final double? borderOpacity;
  final Color? tintColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final bool showBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = GlassTheme.radiusMedium,
    this.blur,
    this.fillOpacity,
    this.borderOpacity,
    this.tintColor,
    this.shadows,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sigmaBlur = blur ?? GlassTheme.blurSigma(isDark);

    final effectiveFillOpacity =
        fillOpacity ?? (isDark ? GlassTheme.fillDarkMode : GlassTheme.fillLightMode);

    final Color fill = tintColor != null
        ? tintColor!.withValues(alpha: effectiveFillOpacity)
        : Colors.white.withValues(alpha: effectiveFillOpacity);

    final effectiveBorderOpacity =
        borderOpacity ?? (isDark ? GlassTheme.borderDark : GlassTheme.borderLight);

    final Color border = showBorder
        ? Colors.white.withValues(alpha: effectiveBorderOpacity)
        : Colors.transparent;

    final radius = BorderRadius.circular(borderRadius);

    Widget container = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaBlur, sigmaY: sigmaBlur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                fill.withValues(alpha: effectiveFillOpacity + 0.15), // Specular Top
                fill, // Core
                fill.withValues(alpha: effectiveFillOpacity * 0.4), // Dark refractor volume
              ],
              stops: const [0.0, 0.2, 1.0],
            ),
            borderRadius: radius,
            border: showBorder 
                ? Border.all(
                    color: Colors.white.withValues(alpha: effectiveBorderOpacity * 0.9), 
                    width: 1.2)
                : null,
          ),
          child: child,
        ),
      ),
    );

    container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows ?? GlassTheme.glassShadow(isDark),
      ),
      child: container,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}
