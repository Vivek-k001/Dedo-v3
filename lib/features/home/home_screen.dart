import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
import '../../core/widgets/liquid_glass_nav_bar.dart';

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
              onOpenCategory: () => setState(() => _navIndex = 1),
              onAddTask: (task) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => CreateTaskScreen(initialTask: task)),
                );
              },
            ),
            const CategoryScreen(isRootTab: true),
            const ProfileScreen(),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _navIndex == 0 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _navIndex == 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 180),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: (MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 14) +
                  62 +
                  16,
              right: 6,
            ),
            child: _GlassFab(
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => const CreateTaskScreen()),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: LiquidGlassNavBar(
        isDark: isDark,
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          LiquidNavItem(
            icon: CupertinoIcons.home,
            label: 'Home',
          ),
          LiquidNavItem(
            icon: CupertinoIcons.square_grid_2x2,
            label: 'Categories',
          ),
          LiquidNavItem(
            icon: CupertinoIcons.person,
            label: 'Profile',
          ),
        ],
      ),
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
                // + Create Task
                _TopBarButton(
                  icon: CupertinoIcons.plus,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => const CreateTaskScreen()),
                    );
                  },
                  isDark: widget.isDark,
                  isAccent: true,
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

          // ─── Liquid Glass Segmented Control ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF1C1C1E)
                    : const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: widget.tabCtrl,
                onTap: (_) => HapticFeedback.selectionClick(),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 4,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                labelColor: widget.isDark ? Colors.white : Colors.black,
                unselectedLabelColor: const Color(0xFF8E8E93),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  letterSpacing: -0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                  letterSpacing: -0.2,
                ),
                tabs: [
                  Tab(text: 'Pending (${pending.length})'),
                  Tab(text: 'Done (${completed.length})'),
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
                  widget.onAddTask(task);
                }),
                _TaskList(tasks: completed, onTap: (task) {
                  widget.onAddTask(task);
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
  final bool isAccent;

  const _TopBarButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(10),
        borderRadius: GlassTheme.radiusMedium,
        fillOpacity: isAccent
            ? (isDark ? 0.24 : 0.28)
            : (isDark ? 0.08 : 0.14),
        tintColor: isAccent ? GlassTheme.accentPrimary : null,
        child: Icon(
          icon,
          size: 20,
          color: isAccent
              ? (isDark ? const Color(0xFF64B5F6) : GlassTheme.accentPrimary)
              : (isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF1A0A2E)),
        ),
      ),
    );
  }
}

class _GlassFab extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _GlassFab({required this.isDark, required this.onTap});

  @override
  State<_GlassFab> createState() => _GlassFabState();
}

class _GlassFabState extends State<_GlassFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: GlassTheme.accentPrimary.withValues(alpha: isDark ? 0.40 : 0.32),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.40)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Translucent Liquid Glass Body with Accent Gradient
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                GlassTheme.accentPrimary.withValues(alpha: 0.70),
                                GlassTheme.accentSecondary.withValues(alpha: 0.45),
                                Colors.black.withValues(alpha: 0.35),
                              ]
                            : [
                                GlassTheme.accentPrimary.withValues(alpha: 0.85),
                                GlassTheme.accentSecondary.withValues(alpha: 0.70),
                                Colors.white.withValues(alpha: 0.40),
                              ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // 2. Pure Monochromatic Specular Top Sheen
                  Positioned(
                    top: 2,
                    left: 10,
                    right: 10,
                    height: 2.5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: isDark ? 0.85 : 0.95),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 3. Pure Monochromatic Specular Bottom Floor Reflection
                  Positioned(
                    bottom: 2,
                    left: 12,
                    right: 12,
                    height: 1.8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: isDark ? 0.35 : 0.50),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 4. Perimeter Glass Border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
                        width: 1.0,
                      ),
                    ),
                  ),

                  // 5. Centered Plus Icon
                  const Center(
                    child: Icon(
                      CupertinoIcons.plus,
                      color: Colors.white,
                      size: 28,
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
