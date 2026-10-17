import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/widgets/glass_switch.dart';
import '../../core/widgets/glass_toast.dart';
import '../../core/widgets/shimmer_glass.dart';
import '../../providers/task_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_profile.dart';
import 'widgets/stat_card.dart';
import 'widgets/weekly_chart.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loading = true;
  bool _editingName = false;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Simulate load for shimmer effect
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(profileProvider);
    final taskNotifier = ref.read(taskProvider.notifier);
    final allTasks = ref.watch(taskProvider);
    final pending = allTasks.where((t) => !t.isCompleted).length;
    final completed = allTasks.where((t) => t.isCompleted).length;
    final streak = taskNotifier.streak;
    final weekly = taskNotifier.weeklyCompletions();

    if (_loading) {
      return SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ShimmerGlassList(count: 5),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────────
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Avatar + Username ────────────────────────────────────────
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: GlassTheme.radiusLarge,
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: GlassTheme.accentPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (profile?.username.isNotEmpty == true)
                            ? profile!.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_editingName) ...[
                            GlassTextField(
                              label: 'Your name',
                              controller: _nameCtrl
                                ..text = profile?.username ?? '',
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                // Compact fluid Save button
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.mediumImpact();
                                    final name = _nameCtrl.text.trim();
                                    if (name.isNotEmpty) {
                                      await ref
                                          .read(profileProvider.notifier)
                                          .saveProfile(UserProfile(
                                            username: name,
                                            joinedAt: profile?.joinedAt,
                                          ));
                                      setState(() => _editingName = false);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: GlassTheme.accentPrimary,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: GlassTheme.accentPrimary
                                              .withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Compact fluid Cancel button
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _editingName = false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: (isDark ? Colors.white : Colors.black)
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.12),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.6)
                                            : Colors.black.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              profile?.username ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                              ),
                            ),
                          const SizedBox(height: 4),
                            Text(
                              'DEDO User',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!_editingName)
                    GestureDetector(
                      onTap: () => setState(() => _editingName = true),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(8),
                        borderRadius: GlassTheme.radiusMedium,
                        child: Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Stats Grid ───────────────────────────────────────────────
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Pending',
                    value: '$pending',
                    icon: Icons.pending_actions_rounded,
                    color: GlassTheme.accentWarning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Completed',
                    value: '$completed',
                    icon: Icons.check_circle_rounded,
                    color: GlassTheme.accentSuccess,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Tasks',
                    value: '${allTasks.length}',
                    icon: Icons.task_alt_rounded,
                    color: GlassTheme.accentPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Day Streak 🔥',
                    value: '$streak',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF6D00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Analytics ────────────────────────────────────────────────
            Text(
              'Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
              ),
            ),
            const SizedBox(height: 12),
            WeeklyChart(data: weekly),
            const SizedBox(height: 12),

            // Completion Rate
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: GlassTheme.radiusLarge,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completion Rate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A0A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          allTasks.isEmpty
                              ? '0%'
                              : '${(completed / allTasks.length * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: GlassTheme.accentSuccess,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.pie_chart_rounded,
                    size: 48,
                    color: GlassTheme.accentSuccess.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Settings ─────────────────────────────────────────────────
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              borderRadius: GlassTheme.radiusLarge,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 26,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                              ),
                            ),
                            Text(
                              isDark ? 'On' : 'Off',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlassSwitch(
                        value: isDark,
                        onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── About ────────────────────────────────────────────────────
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
              ),
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: GlassTheme.radiusLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: GlassTheme.accentPrimary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'D',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DEDO',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A0A2E),
                                ),
                              ),
                              Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.45)
                                      : Colors.black.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A simple and powerful task management app designed for productivity.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.55)
                              : Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AboutRow(
                          icon: Icons.code_rounded,
                          label: 'Developer',
                          value: 'VNJ Softworks',
                          isDark: isDark),
                      const SizedBox(height: 10),
                      _AboutRow(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: 'vnjsoftworks@gmail.com',
                          isDark: isDark,
                          onTap: () {
                            Clipboard.setData(
                                const ClipboardData(text: 'vnjsoftworks@gmail.com'));
                            HapticFeedback.lightImpact();
                            GlassToast.show(
                              context,
                              message: 'Copied vnjsoftworks@gmail.com',
                              icon: CupertinoIcons.doc_on_doc_fill,
                              iconColor: const Color(0xFF007AFF),
                            );
                          }),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(GlassTheme.radiusLarge),
                      child: Shimmer.fromColors(
                        baseColor: Colors.transparent,
                        highlightColor: isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.95),
                        period: const Duration(milliseconds: 2200),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.transparent,
                                isDark
                                    ? Colors.white.withValues(alpha: 0.75)
                                    : Colors.white.withValues(alpha: 0.95),
                                Colors.transparent,
                              ],
                              stops: const [0.15, 0.5, 0.85],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback? onTap;

  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF1A0A2E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null)
            Icon(
              CupertinoIcons.doc_on_doc,
              size: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }
}
