import 'dart:math' as math;
import 'package:flutter/material.dart';

class SquircleTickPainter extends CustomPainter {
  final double progress; // Overall focus session progress (0.0 to 1.0)
  final Color activeColor;
  final Color inactiveColor;
  final int tickCount; // 60 ticks for 60 seconds
  final int remainingSeconds;
  final int totalSeconds;
  final bool isDark;

  SquircleTickPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    this.tickCount = 60, // Exactly 60 ticks around the squircle perimeter
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;
    
    // Inset from squircle border
    final inset = 11.0;

    // Second of the current minute (0..59)
    // When remainingSeconds counts down, elapsed second within the minute runs 0..59
    final elapsedTotal = (totalSeconds - remainingSeconds).clamp(0, totalSeconds);
    final currentSecond = elapsedTotal % 60;

    // 1. Draw 60 Perimeter Dial Ticks (1 Tick per Second)
    for (int i = 0; i < tickCount; i++) {
      // Angle starting from top (-pi / 2) going clockwise
      final angle = -math.pi / 2 + (2 * math.pi * i / tickCount);
      
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);

      final rx = (w / 2) - inset;
      final ry = (h / 2) - inset;

      // Superellipse radial approximation for continuous squircle
      final cosPow = math.pow(cosA.abs(), 3.5);
      final sinPow = math.pow(sinA.abs(), 3.5);
      final dist = math.pow(cosPow / math.pow(rx, 3.5) + sinPow / math.pow(ry, 3.5), -1.0 / 3.5).toDouble();

      // Major markers every 5 seconds (0, 5, 10, 15...)
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 7.5 : 4.5;

      final outer = Offset(center.dx + cosA * dist, center.dy + sinA * dist);
      final inner = Offset(center.dx + cosA * (dist - tickLength), center.dy + sinA * (dist - tickLength));

      // Active state: lights up up to the exact current second
      final isActive = i <= currentSecond;
      final isCurrent = i == currentSecond;

      final paint = Paint()
        ..color = isCurrent
            ? activeColor
            : (isActive
                ? activeColor.withValues(alpha: 0.85)
                : (isMajor
                    ? (isDark ? Colors.white38 : Colors.black38)
                    : inactiveColor))
        ..strokeWidth = isCurrent ? 2.5 : (isMajor ? 1.8 : 1.2)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(inner, outer, paint);
    }

    // 2. HAND 1: Focus Progress Hand (Session / Minute Hand)
    // Points according to total session progress (0.0 to 1.0) or elapsed minutes
    final sessionAngle = -math.pi / 2 + (2 * math.pi * progress.clamp(0.0, 1.0));
    final sessionHandLength = (w / 2) * 0.44;

    final sessionEnd = Offset(
      center.dx + math.cos(sessionAngle) * sessionHandLength,
      center.dy + math.sin(sessionAngle) * sessionHandLength,
    );
    final sessionTail = Offset(
      center.dx - math.cos(sessionAngle) * 6.0,
      center.dy - math.sin(sessionAngle) * 6.0,
    );

    // Sturdy, elegant session hand
    final sessionPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF1C1C1E)).withValues(alpha: 0.90)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(sessionTail, sessionEnd, sessionPaint);

    // 3. HAND 2: Second Hand (1:1 Matched to the 60 ticks)
    // Points exactly at the active tick of currentSecond!
    final secondAngle = -math.pi / 2 + (2 * math.pi * currentSecond / 60);
    final secondHandLength = (w / 2) * 0.65;

    final secondEnd = Offset(
      center.dx + math.cos(secondAngle) * secondHandLength,
      center.dy + math.sin(secondAngle) * secondHandLength,
    );
    final secondTail = Offset(
      center.dx - math.cos(secondAngle) * 11.0,
      center.dy - math.sin(secondAngle) * 11.0,
    );

    // Vibrant accent colored second hand with counter-balance tail
    final secondPaint = Paint()
      ..color = activeColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(secondTail, secondEnd, secondPaint);

    // 4. Center Pivot Caps (mechanical depth with layered concentric rings)
    final outerPivot = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.5, outerPivot);

    final innerPivot = Paint()
      ..color = isDark ? const Color(0xFF121214) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.0, innerPivot);
  }

  @override
  bool shouldRepaint(covariant SquircleTickPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.remainingSeconds != remainingSeconds ||
        oldDelegate.totalSeconds != totalSeconds ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.tickCount != tickCount ||
        oldDelegate.isDark != isDark;
  }
}
