import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Habit> get habits => _habits;

  Future<void> loadHabits() async {
    _habits = await _dbHelper.getAllHabits();
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    final id = await _dbHelper.insertHabit(habit);
    habit.id = id; // update ID with the created id
    _habits.add(habit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _dbHelper.updateHabit(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
    }
  }

  Future<void> deleteHabit(int id) async {
    await _dbHelper.deleteHabit(id);
    _habits.removeWhere((habit) => habit.id == id);
    notifyListeners();
  }

  Future<void> toggleCompletion(Habit habit, DateTime date) async {
    final isCompleted = await _dbHelper.isHabitCompletedToday(habit.id!, date);
    if (isCompleted) {
      // Delete the completion record
      final completions = await _dbHelper.getCompletionsForHabit(habit.id!);
      final completionToDelete = completions.firstWhere((completion) {
        return DateFormat('yyyy-MM-dd').format(completion.completionDate) ==
            DateFormat('yyyy-MM-dd').format(date);
      });
      await _dbHelper.deleteCompletion(completionToDelete.id!);
    } else {
      // Insert a new completion record
      final completion =
          HabitCompletion(habitId: habit.id!, completionDate: date);
      await _dbHelper.insertCompletion(completion);
    }
    notifyListeners(); // Notify listeners to refresh UI. Can't use listen to database changes.
  }

  Future<bool> isHabitCompletedToday(int habitId, DateTime date) async {
    return await _dbHelper.isHabitCompletedToday(habitId, date);
  }

  Future<int> calculateCurrentStreak(int habitId) async {
    int streak = 0;
    DateTime currentDate = DateTime.now();

    while (true) {
      final isCompleted =
          await _dbHelper.isHabitCompletedToday(habitId, currentDate);
      if (isCompleted) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
