import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final bool isRootTab;

  const CategoryScreen({super.key, this.isRootTab = false});

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

  void _confirmDeleteCategory(Category category) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = GlassTheme.cardBg(isDark);
    final borderColor = GlassTheme.borderColor(isDark);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete Category',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x38000000),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Do you want to delete this Category?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You cannot undo this action',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF636366),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            color: GlassTheme.accentPrimary,
                            borderRadius: BorderRadius.circular(16),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Delete button
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(16),
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              ref
                                  .read(categoryProvider.notifier)
                                  .deleteCategory(category.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: GlassTheme.accentDanger,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoryProvider);

    final content = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (!widget.isRootTab && Navigator.canPop(context)) ...[
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      borderRadius: GlassTheme.radiusMedium,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A0A2E),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                      padding: const EdgeInsets.only(bottom: 120),
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
                                onTap: () => _confirmDeleteCategory(cat),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: GlassTheme.accentDanger
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.trash,
                                    color: GlassTheme.accentDanger,
                                    size: 17,
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
    );

    if (widget.isRootTab) {
      return content;
    }

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
      ),
    );
  }
}
