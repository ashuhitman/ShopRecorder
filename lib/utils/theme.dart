import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTheme extends ChangeNotifier {
  static bool _isDarkMode = true;
  static Color scaffoldBG = const Color(0xff2b2c31);
  static Color bgColor = const Color(0xff33333b);

  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ThemeData get lightTheme => ThemeData(
  //     scaffoldBackgroundColor: Colors.white,
  //     backgroundColor: Colors.white,
  //     primaryColor: Colors.lightBlue);
  // ThemeData get darkTheme => ThemeData(
  //       scaffoldBackgroundColor: scaffoldBG,
  //       backgroundColor: bgColor,
  //       primaryColor: bgColor,
  //       accentColor: Colors.white,
  //     );
}

CustomTheme currentTheme = CustomTheme();
