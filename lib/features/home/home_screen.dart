import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../providers/theme_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/profile_provider.dart';
import '../task/create_task_screen.dart';
import '../category/category_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/date_strip.dart';
import 'widgets/category_chips.dart';
import 'widgets/task_card.dart';
import 'widgets/task_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: GlassBackground(
        child: IndexedStack(
          index: _navIndex,
          children: [
            _HomeBody(
              selectedDate: _selectedDate,
              selectedCategory: _selectedCategory,
              showSearch: _showSearch,
              searchCtrl: _searchCtrl,
              tabCtrl: _tabCtrl,
              isDark: isDark,
              onDateSelected: (d) => setState(() => _selectedDate = d),
              onCategorySelected: (c) => setState(() => _selectedCategory = c),
              onSearchToggle: () => setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchCtrl.clear();
              }),
              onThemeToggle: () => ref.read(themeProvider.notifier).toggle(),
              onOpenCategory: () => Navigator.push(
                context,
                _glassRoute(const CategoryScreen()),
              ),
              onAddTask: (task) {
                Navigator.push(
                  context,
                  _glassRoute(CreateTaskScreen(initialTask: task)),
                );
              },
            ),
            const ProfileScreen(),
          ],
        ),
      ),
      floatingActionButton: _navIndex == 0 ? _GlassFab(isDark: isDark, onTap: () {
        Navigator.push(context, _glassRoute(const CreateTaskScreen()));
      }) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _GlassNavBar(
        isDark: isDark,
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  PageRouteBuilder _glassRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// ─── Home Body ─────────────────────────────────────────────────────────────────

class _HomeBody extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final String? selectedCategory;
  final bool showSearch;
  final TextEditingController searchCtrl;
  final TabController tabCtrl;
  final bool isDark;
  final void Function(DateTime) onDateSelected;
  final void Function(String?) onCategorySelected;
  final VoidCallback onSearchToggle;
  final VoidCallback onThemeToggle;
  final VoidCallback onOpenCategory;
  final void Function(dynamic task) onAddTask;

  const _HomeBody({
    required this.selectedDate,
    required this.selectedCategory,
    required this.showSearch,
    required this.searchCtrl,
    required this.tabCtrl,
    required this.isDark,
    required this.onDateSelected,
    required this.onCategorySelected,
    required this.onSearchToggle,
    required this.onThemeToggle,
    required this.onOpenCategory,
    required this.onAddTask,
  });

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody> {
  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final categories = ref.watch(categoryProvider);
    final profile = ref.watch(profileProvider);
    final searchQ = widget.searchCtrl.text;

    List tasksFiltered = searchQ.isNotEmpty
        ? ref.read(taskProvider.notifier).search(searchQ)
        : tasks.where((t) {
            final dateMatch = t.date.year == widget.selectedDate.year &&
                t.date.month == widget.selectedDate.month &&
                t.date.day == widget.selectedDate.day;
            final catMatch = widget.selectedCategory == null ||
                t.categoryId == widget.selectedCategory;
            return dateMatch && catMatch;
          }).toList();

    final pending = tasksFiltered.where((t) => !t.isCompleted).toList();
    final completed = tasksFiltered.where((t) => t.isCompleted).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ─── Top Bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEDO',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1A0A2E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Hi, ${profile?.username ?? 'there'} 👋',
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.55)
                              : Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                // Theme toggle
                _TopBarButton(
                  icon: widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  onTap: widget.onThemeToggle,
                  isDark: widget.isDark,
                ),
                const SizedBox(width: 10),
                // Search toggle
                _TopBarButton(
                  icon: widget.showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                  onTap: widget.onSearchToggle,
                  isDark: widget.isDark,
                ),
                const SizedBox(width: 10),
                // Category
                _TopBarButton(
                  icon: Icons.category_rounded,
                  onTap: widget.onOpenCategory,
                  isDark: widget.isDark,
                ),
              ],
            ),
          ),

          // ─── Search Bar ──────────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: widget.showSearch
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GlassTextField(
                      label: 'Search tasks...',
                      prefixIcon: Icons.search_rounded,
                      controller: widget.searchCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),

          // ─── Date Strip ──────────────────────────────────────────────────
          DateStrip(
            selectedDate: widget.selectedDate,
            onDateSelected: widget.onDateSelected,
          ),

          const SizedBox(height: 16),

          // ─── Category Chips ───────────────────────────────────────────────
          CategoryChips(
            selected: widget.selectedCategory,
            onSelected: widget.onCategorySelected,
            categories: categories,
          ),

          const SizedBox(height: 16),

          // ─── Tab Bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassContainer(
              borderRadius: GlassTheme.radiusLarge,
              padding: const EdgeInsets.all(4),
              fillOpacity: widget.isDark ? 0.06 : 0.12,
              child: TabBar(
                controller: widget.tabCtrl,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassTheme.accentPrimary.withValues(alpha: 0.7),
                      GlassTheme.accentSecondary.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(GlassTheme.radiusLarge - 4),
                  boxShadow: [
                    BoxShadow(
                      color: GlassTheme.accentPrimary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: -4,
                    )
                  ],
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.45),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'Pending (${pending.length})'),
                  Tab(text: 'Completed (${completed.length})'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─── Task Lists ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: widget.tabCtrl,
              children: [
                _TaskList(tasks: pending, onTap: (task) {
                  showTaskModal(context, ref, task,
                      onEdit: () => widget.onAddTask(task));
                }),
                _TaskList(tasks: completed, onTap: (task) {
                  showTaskModal(context, ref, task,
                      onEdit: () => widget.onAddTask(task));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List tasks;
  final void Function(dynamic) onTap;

  const _TaskList({required this.tasks, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 56,
              color: GlassTheme.accentPrimary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks here',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: tasks.length,
      itemBuilder: (_, i) => TaskCard(
        task: tasks[i],
        onTap: () => onTap(tasks[i]),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _TopBarButton(
      {required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(10),
        borderRadius: GlassTheme.radiusMedium,
        fillOpacity: isDark ? 0.08 : 0.14,
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF1A0A2E),
        ),
      ),
    );
  }
}

class _GlassFab extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _GlassFab({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: 60,
        height: 60,
        borderRadius: GlassTheme.radiusLarge,
        tintColor: GlassTheme.accentPrimary,
        fillOpacity: 0.6,
        shadows: [
          BoxShadow(
            color: GlassTheme.accentPrimary.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
        child: const Center(
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final void Function(int) onTap;

  const _GlassNavBar(
      {required this.isDark,
      required this.currentIndex,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: GlassContainer(
        borderRadius: GlassTheme.radiusXL,
        padding: const EdgeInsets.symmetric(vertical: 12),
        fillOpacity: isDark ? 0.12 : 0.18,
        blur: GlassTheme.blurHeavy,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: currentIndex == 0,
              isDark: isDark,
              onTap: () => onTap(0),
            ),
            const SizedBox(width: 64), // FAB space
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: currentIndex == 1,
              isDark: isDark,
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: selected
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlassTheme.accentPrimary.withValues(alpha: 0.3),
                    GlassTheme.accentSecondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(GlassTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: GlassTheme.accentPrimary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: -4,
                  )
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected
                  ? GlassTheme.accentPrimary
                  : isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? GlassTheme.accentPrimary
                    : isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
