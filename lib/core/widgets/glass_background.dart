import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// Static gradient background used on every screen.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = GlassTheme.backgroundGradient(isDark);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [0.0, 0.3, 0.65, 1.0],
        ),
      ),
      child: child,
    );
  }
}
