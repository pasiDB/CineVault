import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme;
  SharedPreferences? _prefs;

  ThemeProvider(this._currentTheme) {
    loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  void setTheme(ThemeData theme) async {
    _currentTheme = theme;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    String? themeName = _prefs?.getString('theme');
    if (themeName != null) {
      switch (themeName) {
        case 'orange':
          _currentTheme = AppThemes.orangeTheme;
          break;
        case 'blue':
          _currentTheme = AppThemes.blueTheme;
          break;
        case 'red':
          _currentTheme = AppThemes.redTheme;
          break;
        case 'brown':
          _currentTheme = AppThemes.brownTheme;
          break;
        case 'grey':
          _currentTheme = AppThemes.greyTheme;
          break;
        case 'yellow':
          _currentTheme = AppThemes.yellowTheme;
          break;
        case 'green':
          _currentTheme = AppThemes.greenTheme;
          break;
        case 'mono':
          _currentTheme = AppThemes.monoFontTheme;
          break;
        case 'nothing':
          _currentTheme = AppThemes.nothingFontTheme;
          break;
        // Add more cases for additional themes
      }
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    String themeName = 'orange'; // Default
    if (_currentTheme == AppThemes.blueTheme) {
      themeName = 'blue';
    } else if (_currentTheme == AppThemes.redTheme) {
      themeName = 'red';
    } else if (_currentTheme == AppThemes.brownTheme) {
      themeName = 'brown';
    } else if (_currentTheme == AppThemes.greyTheme) {
      themeName = 'grey';
    } else if (_currentTheme == AppThemes.yellowTheme) {
      themeName = 'yellow';
    } else if (_currentTheme == AppThemes.greenTheme) {
      themeName = 'green';
    } else if (_currentTheme == AppThemes.monoFontTheme) {
      themeName = 'mono';
    } else if (_currentTheme == AppThemes.nothingFontTheme) {
      themeName = 'nothing';
    }
    await _prefs?.setString('theme', themeName);
  }
}

class AppThemes {
  static final ThemeData orangeTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 255, 34, 34),
      onPrimary: Colors.red,
      secondary: Colors.redAccent,
      onSecondary: Color.fromARGB(255, 163, 12, 12),
      error: Colors.red,
      onError: Color.fromARGB(255, 255, 42, 0),
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: const Color.fromARGB(255, 255, 34, 34),
    secondaryHeaderColor: const Color.fromARGB(255, 255, 35, 34),
    hintColor: Colors.redAccent[200],
    cardColor: Colors.red,
    scaffoldBackgroundColor: Colors.black,
  );

  static final ThemeData blueTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blue,
      onPrimary: Colors.lightBlue,
      secondary: Colors.lightBlueAccent,
      onSecondary: Colors.blueAccent,
      error: Colors.red,
      onError: Colors.blue,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: Colors.blueAccent,
    secondaryHeaderColor: Colors.blueAccent,
    hintColor: Colors.lightBlue[200],
    cardColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
  );

  static final ThemeData redTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.red,
      onPrimary: Colors.redAccent,
      secondary: Colors.pink,
      onSecondary: Colors.pinkAccent,
      error: Color.fromARGB(255, 163, 12, 12),
      onError: Colors.red,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: Colors.redAccent,
    secondaryHeaderColor: Colors.redAccent,
    hintColor: Colors.red[200],
    cardColor: Colors.red,
    scaffoldBackgroundColor: Colors.black,
  );

  static final ThemeData greyTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.grey,
      onPrimary: Colors.blueGrey,
      secondary: Colors.blueGrey,
      onSecondary: Colors.grey,
      error: Colors.red,
      onError: Colors.grey,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: Colors.blueGrey,
    secondaryHeaderColor: Colors.blueGrey,
    hintColor: Colors.grey[400],
    cardColor: Colors.grey,
    scaffoldBackgroundColor: Colors.black,
  );

  static final ThemeData yellowTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.yellow,
      onPrimary: Colors.amber,
      secondary: Colors.amber,
      onSecondary: Colors.yellowAccent,
      error: Colors.red,
      onError: Colors.yellow,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: Colors.amber,
    secondaryHeaderColor: Colors.amber,
    hintColor: Colors.yellow[200],
    cardColor: Colors.yellow,
    scaffoldBackgroundColor: Colors.black,
  );

  static final ThemeData brownTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.brown,
      onPrimary: Colors.amber,
      secondary: Colors.amber,
      onSecondary: Colors.brown,
      error: Colors.red,
      onError: Colors.brown,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: Colors.amber,
    secondaryHeaderColor: Colors.amber,
    hintColor: Colors.brown[200],
    cardColor: Colors.brown,
    scaffoldBackgroundColor: Colors.black,
  );
  static final ThemeData greenTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.green,
      onPrimary: Colors.lightGreen,
      secondary: Colors.lightGreenAccent,
      onSecondary: Colors.greenAccent,
      error: Colors.red,
      onError: Colors.green,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: Colors.greenAccent,
    secondaryHeaderColor: Colors.greenAccent,
    hintColor: Colors.lightGreen[200],
    cardColor: Colors.green,
    scaffoldBackgroundColor: Colors.black,
  );
  static final ThemeData monoFontTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'RobotoMono',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.grey,
      onPrimary: Colors.blueGrey,
      secondary: Colors.blueGrey,
      onSecondary: Colors.grey,
      error: Colors.red,
      onError: Colors.grey,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: Colors.blueGrey,
    secondaryHeaderColor: Colors.blueGrey,
    hintColor: Colors.grey[400],
    cardColor: Colors.grey,
    scaffoldBackgroundColor: Colors.black,
  );

  static final ThemeData nothingFontTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
        TargetPlatform.values,
        value: (_) => const FadeForwardsPageTransitionsBuilder(),
      ),
    ),
    fontFamily: 'Nothing',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.grey,
      onPrimary: Colors.blueGrey,
      secondary: Colors.blueGrey,
      onSecondary: Colors.grey,
      error: Colors.red,
      onError: Colors.grey,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    highlightColor: Colors.blueGrey,
    secondaryHeaderColor: Colors.blueGrey,
    hintColor: Colors.grey[400],
    cardColor: Colors.grey,
    scaffoldBackgroundColor: Colors.black,
  );
}
