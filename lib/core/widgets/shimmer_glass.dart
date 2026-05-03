import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/glass_theme.dart';

class ShimmerGlass extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerGlass({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.borderRadius = GlassTheme.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Shimmer.fromColors(
          baseColor: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.3),
          highlightColor: isDark
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.7),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}

/// A column of shimmer cards for loading states
class ShimmerGlassList extends StatelessWidget {
  final int count;

  const ShimmerGlassList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerGlass(height: 90),
        ),
      ),
    );
  }
}
