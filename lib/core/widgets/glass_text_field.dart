import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/glass_theme.dart';

class GlassTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;

  const GlassTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = GlassTheme.accentPrimary;
    final radius = BorderRadius.circular(GlassTheme.radiusMedium);

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: -4,
                  )
                ]
              : GlassTheme.glassShadow(isDark),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              readOnly: widget.readOnly,
              focusNode: widget.focusNode,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              validator: widget.validator,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                hintStyle: GoogleFonts.outfit(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3),
                  fontSize: 14,
                ),
                labelStyle: GoogleFonts.outfit(
                  color: _focused
                      ? accent
                      : isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _focused
                            ? accent
                            : isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.4),
                        size: 20,
                      )
                    : null,
                suffix: widget.suffix,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.25),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                      color: GlassTheme.accentDanger.withValues(alpha: 0.8),
                      width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide:
                      BorderSide(color: GlassTheme.accentDanger, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
