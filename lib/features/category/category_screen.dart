import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../models/category.dart';
import '../../../providers/category_provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final _nameCtrl = TextEditingController();
  Color _picked = const Color(0xFF7C4DFF);

  final _colorOptions = [
    const Color(0xFF7C4DFF),
    const Color(0xFF40C4FF),
    const Color(0xFF69F0AE),
    const Color(0xFFFFD740),
    const Color(0xFFFF5252),
    const Color(0xFFFF6D00),
    const Color(0xFFE040FB),
    const Color(0xFF00BCD4),
    const Color(0xFFF06292),
    const Color(0xFF4DB6AC),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _add() {
    if (_nameCtrl.text.trim().isEmpty) return;
    ref.read(categoryProvider.notifier).addCategory(
          Category(
            id: const Uuid().v4(),
            name: _nameCtrl.text.trim(),
            colorValue: _picked.toARGB32(),
          ),
        );
    _nameCtrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoryProvider);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(10),
                        borderRadius: GlassTheme.radiusMedium,
                        child: Icon(Icons.arrow_back_rounded,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A0A2E),
                            size: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ─── Add form ──────────────────────────────────────────────
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: GlassTheme.radiusLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A0A2E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassTextField(
                        label: 'Category Name',
                        prefixIcon: Icons.label_rounded,
                        controller: _nameCtrl,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Color',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: _colorOptions
                            .map((c) => GestureDetector(
                                  onTap: () => setState(() => _picked = c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: _picked == c
                                          ? Border.all(
                                              color: Colors.white, width: 2.5)
                                          : null,
                                      boxShadow: _picked == c
                                          ? [
                                              BoxShadow(
                                                color: c.withValues(alpha: 0.5),
                                                blurRadius: 10,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: _picked == c
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 16)
                                        : null,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      GlassButton(
                        label: 'Add Category',
                        icon: Icons.add_rounded,
                        onPressed: _add,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Your Categories',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                  ),
                ),
                const SizedBox(height: 12),

                // ─── Category List ─────────────────────────────────────────────
                Expanded(
                  child: categories.isEmpty
                      ? Center(
                          child: Text(
                            'No categories yet',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.35),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final cat = categories[i];
                            final color = Color(cat.colorValue);
                            return GlassContainer(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              borderRadius: GlassTheme.radiusMedium,
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.5),
                                          blurRadius: 8,
                                          spreadRadius: -2,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A0A2E),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => ref
                                        .read(categoryProvider.notifier)
                                        .deleteCategory(cat.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: GlassTheme.accentDanger
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: GlassTheme.accentDanger,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
