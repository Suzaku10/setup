import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:setup/application.dart';

class SetupSetting{
  static String appNameKey = "Setup_";
  static List<String> supportedLanguages = ['id', 'en'];
  static Iterable<LocalizationsDelegate<dynamic>> LocalizationDelegate = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
  static String assetsLocalizationJson;
  static String FCMToken;
  static GetFCMToken refreshToken;
}
