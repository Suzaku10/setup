import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef Future<void> OnSelectNotification(String payload);
typedef Future<void> OnDidReceiveLocalNotification(
    int id, String title, String body, String payload);

class Application {
  static final Application _application = Application._internal();
  Completer<BuildContext> completer = Completer();
  OnSelectNotification selectNotification;
  OnDidReceiveLocalNotification receiveLocalNotificationIOS;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory Application() {
    return _application;
  }

  Application._internal();
}

Application application = Application();


