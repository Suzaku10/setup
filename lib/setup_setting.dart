import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/*class SetupSetting {
  static _ThemeData themeData = _ThemeData();
}

class _ThemeData {
  Color primaryTextColor = Colors.black;
  Brightness primaryBrightness = Brightness.light;
  Color primarySwatch = Colors.green;
  Color primaryColor = Colors.blue;
  Brightness primaryColorBrightness = Brightness.light;
  Color accentColor = Colors.amberAccent;
  Color scaffoldBackgroundColor = Colors.white;
  String fontFamily = "Roboto";
  Brightness accentColorBrightness = Brightness.light;
}*/

class SetupSetting{
  static _SetupApp setupApp = _SetupApp();
}

class _SetupApp{
  String appNameKey = "Setup_";
  List<String> supportedLanguages = ['id', 'en'];
  Iterable<LocalizationsDelegate<dynamic>> kLocalizationDelegate = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
  String assetsLocalizationJson;
}