import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    _load();
  }

  void _load() {
    _ensureWeeklySampleData();
    state = HiveService.tasks.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _ensureWeeklySampleData() {
    final alreadySeeded =
        HiveService.settings.get('hasSeededWeeklyRainbow', defaultValue: false);
    if (alreadySeeded) return;

    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final sampleTitles = [
      'Morning Reflection & Planning',
      'Team Design Sync',
      'Code Architecture Review',
      'Workout & Cardio Session',
      'Feature Sprint Wrap-up',
      'Reading & Knowledge Catch-up',
      'Weekly Goal Setting',
    ];

    final sampleColors = [
      0xFFFF5A52, // Mon
      0xFFFF9500, // Tue
      0xFFFFCC00, // Wed
      0xFF34C759, // Thu
      0xFF30B0C7, // Fri
      0xFF007AFF, // Sat
      0xFFAF52DE, // Sun
    ];

    for (int i = 0; i < 7; i++) {
      final taskDate = monday.add(Duration(days: i, hours: 10));
      final taskId = 'sample_week_day_$i';
      if (!HiveService.tasks.containsKey(taskId)) {
        final task = Task(
          id: taskId,
          title: sampleTitles[i],
          note: 'Completed weekly milestone',
          date: taskDate,
          startTime: taskDate,
          endTime: taskDate.add(const Duration(hours: 1)),
          colorValue: sampleColors[i],
          isCompleted: true,
          createdAt: taskDate,
        );
        HiveService.tasks.put(taskId, task);
      }
    }
    HiveService.settings.put('hasSeededWeeklyRainbow', true);
  }

  Future<void> addTask(Task task) async {
    await HiveService.tasks.put(task.id, task);
    await NotificationService.scheduleTaskNotifications(task);
    _load();
  }

  Future<void> updateTask(Task task) async {
    await HiveService.tasks.put(task.id, task);
    await NotificationService.scheduleTaskNotifications(task);
    _load();
  }

  Future<void> deleteTask(String id) async {
    await HiveService.tasks.delete(id);
    await NotificationService.cancelTaskNotifications(id);
    _load();
  }

  Future<void> toggleComplete(String id) async {
    final task = HiveService.tasks.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await task.save();
      _load();
    }
  }

  List<Task> get pending => state.where((t) => !t.isCompleted).toList();
  List<Task> get completed => state.where((t) => t.isCompleted).toList();

  List<Task> forDate(DateTime date) {
    return state.where((t) =>
        t.date.year == date.year &&
        t.date.month == date.month &&
        t.date.day == date.day).toList();
  }

  List<Task> forCategory(String categoryId) =>
      state.where((t) => t.categoryId == categoryId).toList();

  List<Task> search(String query) {
    final q = query.toLowerCase();
    return state
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            (t.note?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ─── Analytics ────────────────────────────────────────────────────────────
  int completedThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return state
        .where((t) =>
            t.isCompleted &&
            t.date.isAfter(weekStart.subtract(const Duration(days: 1))))
        .length;
  }

  /// Returns completed count for the current calendar week (Monday to Sunday)
  List<int> weeklyCompletions() {
    final now = DateTime.now();
    // Monday of current week (DateTime.monday == 1)
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final result = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      result[i] = state
          .where((t) =>
              t.isCompleted &&
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .length;
    }
    return result;
  }

  int get streak {
    int s = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final dayTasks = forDate(day);
      if (dayTasks.isEmpty) break;
      if (dayTasks.any((t) => t.isCompleted)) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }
}
