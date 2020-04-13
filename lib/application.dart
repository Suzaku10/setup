import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class Application {
  static final Application _application = Application._internal();
  Completer<BuildContext> completer = Completer();

  factory Application() {
    return _application;
  }

  Application._internal();
}

Application application = Application();


