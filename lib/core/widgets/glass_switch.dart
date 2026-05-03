import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

class GlassSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<GlassSwitch> createState() => _GlassSwitchState();
}

class _GlassSwitchState extends State<GlassSwitch> {
  bool _isPressed = false;
  bool _isDragging = false;
  double? _dragOffset;
  
  // Optimistic UI state to prevent rubber-banding glitch waiting for Riverpod to update!
  bool? _optimisticValue;

  @override
  void didUpdateWidget(GlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _optimisticValue = null;
    }
  }

  bool get _effectiveValue => _optimisticValue ?? widget.value;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    final newValue = !_effectiveValue;
    setState(() {
      _isPressed = false;
      _optimisticValue = newValue;
    });
    widget.onChanged(newValue);
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _isDragging = false;
      _dragOffset = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dimensions
    const double trackWidth = 64.0;
    const double trackHeight = 26.0;
    const double baseKnobWidth = 42.0;
    const double knobHeight = 32.0;

    final double maxLeft = trackWidth - baseKnobWidth + 4; // Right limit
    final double minLeft = -4.0; // Left limit

    final Color activeColor = GlassTheme.accentSuccess;
    final Color inactiveColor = isDark 
        ? Colors.grey.shade800.withValues(alpha: 0.6) 
        : Colors.grey.shade400.withValues(alpha: 0.8);

    // Calculate our target logical percentage for the tween (0.0 = left, 1.0 = right)
    double targetProgress = _effectiveValue ? 1.0 : 0.0;
    if (_isDragging && _dragOffset != null) {
      targetProgress = ((_dragOffset! - minLeft) / (maxLeft - minLeft)).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onHorizontalDragStart: (details) {
        setState(() {
          _isDragging = true;
          _isPressed = true;
          _dragOffset = _effectiveValue ? maxLeft : minLeft;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset ?? 0) + details.delta.dx;
          _dragOffset = _dragOffset!.clamp(minLeft, maxLeft);
        });
      },
      onHorizontalDragEnd: (details) {
        // Did we cross the midpoint horizontally?
        final bool newValue = (_dragOffset ?? minLeft) > (minLeft + (maxLeft - minLeft) / 2);
        
        setState(() {
          _isDragging = false;
          _isPressed = false;
          _dragOffset = null;
          _optimisticValue = newValue;
        });
        
        if (newValue != widget.value) {
          widget.onChanged(newValue);
        }
      },
      child: SizedBox(
        width: trackWidth + 8,
        height: 38,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track Layer
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: trackWidth,
                height: trackHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(trackHeight / 2),
                  color: _effectiveValue ? activeColor : inactiveColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
              ),
            ),
            // Sub-frame Tweener for Flawless Liquid Physics
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: targetProgress, end: targetProgress),
              duration: Duration(milliseconds: _isDragging ? 0 : 500),
              curve: _isDragging ? Curves.linear : Curves.elasticOut,
              builder: (context, progress, child) {
                
                // Map progress to absolute left offset
                final double currentLeftLoc = minLeft + (progress * (maxLeft - minLeft));
                
                // LIQUID STRETCH PHYSICS
                // The squircle blob elongates as it reaches the center (progress = 0.5)
                // Squished perfectly back into stable size (squishes) when reaching ends (progress 0.0 or 1.0)
                final double distanceToCenter = (progress - 0.5).abs();
                final double stretchIntensity = 1.0 - (distanceToCenter / 0.5); // 1.0 at center, 0.0 at edges
                
                double dynamicWidth = baseKnobWidth + (stretchIntensity * 16.0); // Expands up to +16px in middle
                
                if (_isPressed && !_isDragging && stretchIntensity < 0.1) {
                  dynamicWidth += 4.0; // slight pressure squish from finger press at rest edges
                }

                return Positioned(
                  left: currentLeftLoc + 4, // factoring in tracking padding
                  child: SizedBox(
                    width: dynamicWidth,
                    height: knobHeight,
                    child: child,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(knobHeight / 2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(knobHeight / 2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.8), // Inner glare
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.4), // Bottom reflection
                        ],
                        stops: const [0.0, 0.4, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
