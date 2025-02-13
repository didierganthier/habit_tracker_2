import 'package:habit_tracker_2/models/habit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'HabitTracker.db';
  static const _databaseVersion = 1;

  static const tableHabits = 'habits';
  static const tableCompletions = 'habit_completions';

  // Making it a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableHabits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      frequency INTEGER NOT NULL,
      daysOfWeek TEXT NOT NULL,
      startDate TEXT NOT NULL,
      endDate TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableCompletions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      habitId INTEGER NOT NULL,
      completionDate TEXT NOT NULL,
      FOREIGN KEY (habitId) REFERENCES $tableHabits(id)
    )
    ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert(tableHabits, habit.toMap());
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableHabits);
    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }
}
