import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_container.dart';

class DateStrip extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late final ScrollController _scroll;
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    final now = DateTime.now();
    _dates = List.generate(30, (i) => now.subtract(Duration(days: 7 - i)));
    // Scroll to today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          7 * 66.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 88,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final date = _dates[i];
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isToday(date);

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: 56,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 10),
                borderRadius: GlassTheme.radiusMedium,
                fillOpacity: isSelected ? 0.35 : (isDark ? 0.06 : 0.12),
                tintColor: isSelected ? GlassTheme.accentPrimary : null,
                shadows: isSelected
                    ? [
                        BoxShadow(
                          color: GlassTheme.accentPrimary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: -4,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                    if (isToday && !isSelected)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: const BoxDecoration(
                          color: GlassTheme.accentPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
