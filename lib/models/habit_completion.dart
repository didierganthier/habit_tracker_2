import 'package:intl/intl.dart';

class HabitCompletion {
  int? id;
  int habitId;
  DateTime completionDate;

  HabitCompletion({
    this.id,
    required this.habitId,
    required this.completionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completionDate': DateFormat('yyyy-MM-dd').format(completionDate),
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'],
      habitId: map['habitId'],
      completionDate: DateFormat('yyyy-MM-dd').parse(map['completionDate']),
    );
  }
}
