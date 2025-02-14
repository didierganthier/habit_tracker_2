import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'screens/habit_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final initialThemeColor = prefs.getInt('themeColor') ?? Colors.blue.value;
  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: MyApp(initialThemeColor: Color(initialThemeColor)),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Color initialThemeColor;
  const MyApp({super.key, required this.initialThemeColor});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color? _themeColor;
  @override
  void initState() {
    super.initState();
    _themeColor = widget.initialThemeColor;
  }

  // Method to update the theme color
  void setThemeColor(Color color) async {
    setState(() {
      _themeColor = color;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeColor', color.value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: MaterialColor(_themeColor!.value, {
          50: tintColor(_themeColor!, 0.9),
          100: tintColor(_themeColor!, 0.7),
          200: tintColor(_themeColor!, 0.5),
          300: tintColor(_themeColor!, 0.3),
          400: tintColor(_themeColor!, 0.1),
          500: _themeColor!,
          600: Color(shadeColor(_themeColor!, 0.1)),
          700: Color(shadeColor(_themeColor!, 0.3)),
          800: Color(shadeColor(_themeColor!, 0.5)),
          900: Color(shadeColor(_themeColor!, 0.7)),
        }),
      ),
      home: HabitListScreen(
        setThemeColor: setThemeColor,
      ),
    );
  }

  int shadeColor(Color color, double factor) =>
      (color.value - ((color.value & 0xFFFFFF) * factor)).toInt();

  Color tintColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (1 - factor) + hsl.lightness;
    return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }
}
