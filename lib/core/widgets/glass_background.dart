import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// Static gradient background used on every screen.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = GlassTheme.scaffoldBg(isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      color: bg,
      child: child,
    );
  }
}
