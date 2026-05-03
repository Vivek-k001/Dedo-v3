import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// Animated gradient background used on every screen.
class GlassBackground extends StatefulWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = GlassTheme.backgroundGradient(isDark);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.lerp(
                    Alignment.topLeft, Alignment.topRight, _anim.value) ??
                Alignment.topLeft,
              end: Alignment.lerp(
                    Alignment.bottomRight, Alignment.bottomLeft, _anim.value) ??
                Alignment.bottomRight,
              colors: colors,
              stops: [
                0.0,
                0.3 + 0.1 * _anim.value,
                0.65 - 0.1 * _anim.value,
                1.0
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
