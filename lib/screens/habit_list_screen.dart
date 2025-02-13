import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import 'habit_detail_screen.dart'; // Import the detail screen
import '../models/habit.dart';
import 'package:intl/intl.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  @override
  void initState() {
    super.initState();
    // Load habits when the widget is initialized
    Provider.of<HabitProvider>(context, listen: false).loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Tracker',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          if (habitProvider.habits.isEmpty) {
            return const Center(
              child: Text('No habits yet!'),
            );
          }

          return ListView.builder(
            itemCount: habitProvider.habits.length,
            itemBuilder: (context, index) {
              final habit = habitProvider.habits[index];
              return Card(
                color: Colors.teal[50],
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      Text(habit.description),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Frequency: ${habit.frequency} times per week'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HabitDetailScreen(habit: habit),
                                ),
                              );
                            },
                            child: const Text('Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          final day = DateTime.now().subtract(Duration(
                              days: DateTime.now().weekday - 1 - index));
                          final formattedDay = DateFormat('E').format(day);

                          return FutureBuilder<bool>(
                            future: habitProvider.isHabitCompletedToday(
                                habit.id!, day),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final isCompleted = snapshot.data ?? false;
                                return Column(
                                  children: [
                                    Text(formattedDay),
                                    Checkbox(
                                      value: isCompleted,
                                      onChanged: habit.daysOfWeek[index]
                                          ? (bool? value) {
                                              habitProvider.toggleCompletion(
                                                  habit, day);
                                            }
                                          : null, // Disable the button
                                      visualDensity: VisualDensity.compact,
                                      activeColor: Colors.teal,
                                    ),
                                  ],
                                );
                              }
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(
                  habit: Habit(
                      id: null,
                      name: '',
                      description: '',
                      frequency: 1,
                      daysOfWeek: [
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false
                      ],
                      startDate: DateTime.now())),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
