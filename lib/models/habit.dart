import 'package:intl/intl.dart';

class Habit {
  int? id; //Nullable as it will be assigned by database
  String name;
  String description;
  int frequency; // How many times per week (e.g., 3 for 3 times/week)
  List<bool> daysOfWeek; // Which days of the week (Sun=0, Mon=1, ...)
  DateTime startDate;
  DateTime? endDate;

  Habit({
    this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.daysOfWeek,
    required this.startDate,
    this.endDate,
  });

  // Convert a Habit into a Map. The keys must correspond to the column names in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'daysOfWeek': daysOfWeek
          .map((e) => e ? 1 : 0)
          .toList()
          .join(','), //Convert bool list to comma separated String
      'startDate':
          DateFormat('yyyy-MM-dd').format(startDate), //Store it as string on db
      'endDate':
          endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : null,
    };
  }

  // Factory method to create a Habit from a Map (from the database).
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      frequency: map['frequency'],
      daysOfWeek: (map['daysOfWeek'] as String)
          .split(',')
          .map((e) => e == '1')
          .toList(), //Convert String to bool list
      startDate: DateFormat('yyyy-MM-dd').parse(map['startDate']),
      endDate: map['endDate'] != null
          ? DateFormat('yyyy-MM-dd').parse(map['endDate'])
          : null,
    );
  }
}
