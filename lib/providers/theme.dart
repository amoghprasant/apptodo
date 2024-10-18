import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode? _themeMode;

  ThemeMode? get themeMode => _themeMode;

  static const kSelectedThemeMode = 'selected_theme_mode';

  final _log = Logger('ThemeProvider');

  // Initialize method to load the saved theme
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(kSelectedThemeMode);
      if (value != null) {
        _themeMode =
            ThemeMode.values.firstWhereOrNull((e) => e.name == value) ??
                ThemeMode.system;
        notifyListeners();
      } else {
        _themeMode =
            ThemeMode.system; // Default to system if no preference is found
      }
    } catch (e) {
      _log.shout('Unable to get the app theme. $e');
    }
  }

  // Method to toggle the theme and save preference
  Future<void> toggleTheme(ThemeMode? mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mode != null) {
        await prefs.setString(kSelectedThemeMode, mode.name);
      } else {
        await prefs.remove(kSelectedThemeMode);
      }

      _themeMode = mode;
      notifyListeners();
    } catch (e) {
      _log.shout('Unable to save the app theme. $e');
    }
  }

  // Custom theme data with the specified typography
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    ),
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    ),
  );
}
