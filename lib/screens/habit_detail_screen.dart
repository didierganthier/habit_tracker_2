import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import 'package:intl/intl.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _HabitDetailScreenState createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _frequencyController;
  late List<bool> _daysOfWeek;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _descriptionController =
        TextEditingController(text: widget.habit.description);
    _frequencyController =
        TextEditingController(text: widget.habit.frequency.toString());
    _daysOfWeek = List.from(widget.habit.daysOfWeek);
    _startDate = widget.habit.startDate;
    _endDate = widget.habit.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.habit.id == null ? 'Create Habit' : 'Edit Habit',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency (times per week)',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a frequency';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Days of the Week:'),
              Wrap(
                children: List<Widget>.generate(7, (int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        DateFormat('E').format(DateTime(0, 1, index + 1)),
                        style: TextStyle(
                          color:
                              _daysOfWeek[index] ? Colors.white : Colors.teal,
                        ),
                      ),
                      selected: _daysOfWeek[index],
                      selectedColor: Colors.teal,
                      onSelected: (bool selected) {
                        setState(() {
                          _daysOfWeek[index] = selected;
                        });
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text(
                    'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}',
                    style: const TextStyle(color: Colors.teal),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'End Date: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'None'}',
                    style: const TextStyle(color: Colors.teal),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final habit = Habit(
                        id: widget.habit.id,
                        name: _nameController.text,
                        description: _descriptionController.text,
                        frequency: int.parse(_frequencyController.text),
                        daysOfWeek: _daysOfWeek,
                        startDate: _startDate,
                        endDate: _endDate,
                      );
                      if (widget.habit.id == null) {
                        Provider.of<HabitProvider>(context, listen: false)
                            .addHabit(habit);
                      } else {
                        Provider.of<HabitProvider>(context, listen: false)
                            .updateHabit(habit);
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              if (widget.habit.id != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<HabitProvider>(context, listen: false)
                          .deleteHabit(widget.habit.id!);
                      Navigator.pop(context);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
