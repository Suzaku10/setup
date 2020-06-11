import 'dart:async';
import 'package:flutter/material.dart';

typedef Future<void> OnSelectNotification(String payload);
typedef Future<void> OnDidReceiveLocalNotification(
    int id, String title, String body, String payload);
typedef Future<void> Fetcher();
typedef Future<void> OnInit(BuildContext context);
typedef Future<String> MinVer();
typedef Future<String> LatestVer();
typedef Future<void> NotifOnMessage(Map<String, dynamic> message);
typedef Future<void> NotifOnResume(Map<String, dynamic> message);
typedef Future<void> NotifOnLaunch(Map<String, dynamic> message);
typedef Future<dynamic> OnBackgroundHandler(Map<String, dynamic> message);
typedef Future<void> OnRetrieveDynamicLink(BuildContext context);
typedef void NotifInit(BuildContext context);
typedef void OnLink(BuildContext context, Uri deepLink);
typedef Future<String> GetFCMToken();

class Application {
  static final Application _application = Application._internal();
  Completer<BuildContext> completer = Completer();
  OnSelectNotification selectNotification;
  OnDidReceiveLocalNotification receiveLocalNotificationIOS;

  factory Application() {
    return _application;
  }

  Application._internal();
}

Application application = Application();


