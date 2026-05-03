import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_text_field.dart';
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
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GlassTheme.accentPrimary,
                          GlassTheme.accentSecondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GlassTheme.accentPrimary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: -4,
                          offset: const Offset(0, 6),
                        )
                      ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_editingName) ...[
                          GlassTextField(
                            label: 'Your name',
                            controller: _nameCtrl
                              ..text = profile?.username ?? '',
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              GlassButton(
                                label: 'Save',
                                onPressed: () async {
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
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _editingName = false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : Colors.black.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ],
                          )
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                StatCard(
                  label: 'Pending',
                  value: '$pending',
                  icon: Icons.pending_actions_rounded,
                  color: GlassTheme.accentWarning,
                ),
                StatCard(
                  label: 'Completed',
                  value: '$completed',
                  icon: Icons.check_circle_rounded,
                  color: GlassTheme.accentSuccess,
                ),
                StatCard(
                  label: 'Total Tasks',
                  value: '${allTasks.length}',
                  icon: Icons.task_alt_rounded,
                  color: GlassTheme.accentPrimary,
                ),
                StatCard(
                  label: 'Day Streak 🔥',
                  value: '$streak',
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF6D00),
                ),
              ],
            ),

            const SizedBox(height: 24),

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              borderRadius: GlassTheme.radiusLarge,
              child: SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                  ),
                ),
                subtitle: Text(
                  isDark ? 'On' : 'Off',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: GlassTheme.accentPrimary,
                ),
                value: isDark,
                activeThumbColor: GlassTheme.accentPrimary,
                onChanged: (_) =>
                    ref.read(themeProvider.notifier).toggle(),
                contentPadding: EdgeInsets.zero,
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
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: GlassTheme.radiusLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF7C4DFF),
                              Color(0xFF40C4FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: GlassTheme.accentPrimary.withValues(alpha: 0.4),
                              blurRadius: 14,
                              spreadRadius: -4,
                            )
                          ],
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
                      value: 'sdedodedo80@gmail.com',
                      isDark: isDark),
                ],
              ),
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

  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: GlassTheme.accentPrimary.withValues(alpha: 0.7),
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
      ],
    );
  }
}
