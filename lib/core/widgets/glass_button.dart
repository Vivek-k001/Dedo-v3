import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final double borderRadius;
  final double? width;
  final bool isLoading;
  final TextStyle? textStyle;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.borderRadius = GlassTheme.radiusMedium,
    this.width,
    this.isLoading = false,
    this.textStyle,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.color ?? GlassTheme.accentPrimary;
    final radius = BorderRadius.circular(widget.borderRadius);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Stack(
                children: [
                  // Base color layer (Saturating the refraction)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: isDark ? 0.65 : 0.85),
                          accent.withValues(alpha: isDark ? 0.35 : 0.55),
                        ],
                      ),
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(widget.icon, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.label,
                                  style: widget.textStyle ??
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  // Specular Reflection & Refraction Rim Layer
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border(
                            top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                            left: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3), width: 1.0),
                            right: BorderSide(
                                color: Colors.black.withValues(alpha: 0.1), width: 1.0),
                            bottom: BorderSide(
                                color: Colors.black.withValues(alpha: 0.2), width: 1.5),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.4), // Glare
                              Colors.white.withValues(alpha: 0.0), // Clear center
                              Colors.black.withValues(alpha: 0.0), // Clear center
                              accent.withValues(alpha: 0.4),       // Internal refraction volume bounce
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
