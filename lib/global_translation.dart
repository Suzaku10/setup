import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:setup/setup_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _storageKey = SetupSetting.setupApp.appNameKey;
List<String> _supportLanguages = SetupSetting.setupApp.supportedLanguages;
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class GlobalTranslation {
  Locale _locale;
  Map<dynamic, dynamic> _localizedValues;
  VoidCallback _onLocaleChangedCallback;

  Iterable<Locale> supportLocales() =>
      _supportLanguages.map<Locale>((lang) => Locale(lang, ''));

  String text(String key) =>
      (_localizedValues == null || _localizedValues[key] == null)
          ? '** $key not found'
          : _localizedValues[key];

  get currentLanguage => _locale == null ? '' : _locale.languageCode;

  get locale => _locale;

  // one time initialize;
  Future<void> init([String language]) async {
    if (_locale == null) {
      await setNewLanguage(language);
    }
  }

  getPreferredLanguage() async => _getApplicationSavedInformation('language');

  setPreferredLanguage(String lang) async =>
      _setApplicationSavedInformation('language', lang);

  Future<void> setNewLanguage(
      [String newLanguage, bool saveInPrefs = false]) async {
    String language = newLanguage;
    if (language == null) {
      language = await getPreferredLanguage();
    }

    if (language == "") {
      //set initial language
      language = 'en';
    }

    _locale = Locale(language, "");

    //Load string from json assets

    print("ini setup :${SetupSetting.setupApp.assetsLocalizationJson}");
    if (_onLocaleChangedCallback != null) _onLocaleChangedCallback();
    print("ini sesudah localChanged");
    String _jsonContent = await rootBundle
        .loadString(SetupSetting.setupApp.assetsLocalizationJson);

    _localizedValues = jsonDecode(_jsonContent);

    if (saveInPrefs) await setPreferredLanguage(language);
  }

  set onLocalChangedCallback(VoidCallback callback) =>
      _onLocaleChangedCallback = callback;

  Future<String> _getApplicationSavedInformation(String name) async {
    final SharedPreferences preferences = await _prefs;

    return preferences.getString(_storageKey + name) ?? "";
  }

  Future<bool> _setApplicationSavedInformation(
      String name, String value) async {
    final SharedPreferences preferences = await _prefs;

    return preferences.setString(_storageKey + name, value);
  }

  // singleton factory
  static final GlobalTranslation _translations = GlobalTranslation._internal();

  factory GlobalTranslation() => _translations;

  GlobalTranslation._internal();
}

GlobalTranslation allTranslation = new GlobalTranslation();
