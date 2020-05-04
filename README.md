# Setup

this plugin used to add multilangual, notification and some feature soon

*Note*: This plugin is still under development, and some Components might not be available yet or still has so many bugs.

## Installation

First, add `setup` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```
  setup:
    git:
      url: git://github.com/Suzaku10/setup.git
      ref: notification
```

## Important And How To Use
1. add assets/localization directory in app, and add assets/localization in pubspec.yaml.
2. must initialize SetupSetting.setupApp.assetsLocalizationJson to your json asset directory.
3. replace void main with this code.

```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SetupSetting.setupApp.assetsLocalizationJson = "assets/localization/language_en.json";
  await allTranslation.init();

  runApp(MyApp());
}
```

4. change MyApp to extends StatefulWidget
*Note*: we need to access initState to configure callback and anything
we can set onlocalchangedcallback, and initialize a SetupController;
```
 @override
  void initState() {
    super.initState();
    allTranslation.onLocalChangedCallback = _onLocaleChanged;
    SetupSetting.setupApp.supportedLanguages = kSupportedLanguage;
    SetupSetting.setupApp.appNameKey = "FlutterApp_";
    controller = SetupController();
  }
}
```

5. this code must in onlocalechanged,
*Note*: SetupSetting.setupApp.assetsLocalizationJson = "assets/localization/language_${allTranslation.currentLanguage ?? 'en'}.json";
```
  _onLocaleChanged() async {
    // do anything you need to do if the language changes
    SetupSetting.setupApp.assetsLocalizationJson = "assets/localization/language_${allTranslation.currentLanguage ?? 'en'}.json";
    print('Language has been changed to: ${allTranslation.currentLanguage}');
  }
```

6. add some code below
*Note*: add this classpath to [project]/android/build.gradle file;
```
dependencies {
  // Example existing classpath
  classpath 'com.android.tools.build:gradle:3.5.3'
  // Add the google services classpath
  classpath 'com.google.gms:google-services:4.3.2'
}
```
*Note*: Add the apply plugin to the [project]/android/app/build.gradle file.
```
// ADD THIS AT THE BOTTOM
apply plugin: 'com.google.gms.google-services'
}
```
*Note*: (optional, but recommended) If want to be notified in your app (via onResume and onLaunch, see below) when the user clicks on a notification in the system tray include the following intent-filter within the <activity> tag of your android/app/src/main/AndroidManifest.xml:
```
 <intent-filter>
      <action android:name="FLUTTER_NOTIFICATION_CLICK" />
      <category android:name="android.intent.category.DEFAULT" />
  </intent-filter>
```
*Note*: Add the com.google.firebase:firebase-messaging dependency in your app-level build.gradle file that is typically located at <app-name>/android/app/build.gradle.
```
dependencies {
  // ...

    implementation 'com.google.firebase:firebase-messaging:19.0.0'
}
```
*Note*: Add an Application.java class to your app in the same directory as your MainActivity.java
```
package your.packagename;


import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class Application extends FlutterApplication implements PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}
```
*Note*: Add FirebaseCloudMessagingPluginRegistrant.java
```
package your.packagename;


import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;

public final class FirebaseCloudMessagingPluginRegistrant{
    public static void registerWith(PluginRegistry registry) {
        if (alreadyRegisteredWith(registry)) {
            return;
        }
        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
    }

    private static boolean alreadyRegisteredWith(PluginRegistry registry) {
        final String key = FirebaseCloudMessagingPluginRegistrant.class.getCanonicalName();
        if (registry.hasPlugin(key)) {
            return true;
        }
        registry.registrarFor(key);
        return false;
    }
}
```
*Note*: Set name property of application in AndroidManifest.xml. This is typically found in <app-name>/android/app/src/main/.
```
<application android:name=".Application" ...>
```
*Note*: Add this in top level to handle background message, and add FlutterLocalNotificationsPlugin in pubscpec.yaml
```
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid =
  new AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = new IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, data['msg'], data['status'], platformChannelSpecifics,
        payload: 'item x');
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
```

6. this full example
```
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constanta.dart';
import 'package:flutter_app/custom_cupertino_activity_incidator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:setup/global_translation.dart';
import 'package:setup/setup.dart';
import 'package:setup/setup_setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SetupSetting.setupApp.assetsLocalizationJson =
      "assets/localization/language_en.json";
  await allTranslation.init();

  runApp(MyApp());
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid =
  new AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = new IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, data['msg'], data['status'], platformChannelSpecifics,
        payload: 'item x');
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SetupController controller;

  @override
  void initState() {
    super.initState();
    allTranslation.onLocalChangedCallback = _onLocaleChanged;
    SetupSetting.setupApp.supportedLanguages = kSupportedLanguage;
    SetupSetting.setupApp.appNameKey = "FlutterApp_";
    controller = SetupController();
  }

  _onLocaleChanged() async {
    // do anything you need to do if the language changes
    SetupSetting.setupApp.assetsLocalizationJson =
        "assets/localization/language_${allTranslation.currentLanguage ?? 'en'}.json";
    print('Language has been changed to: ${allTranslation.currentLanguage}');
  }

  @override
  Widget build(BuildContext context) {
    return Setup(
        theme: ThemeData(primarySwatch: Colors.blue),
        supportLocales: allTranslation.supportLocales(),
        localizationsDelegates: SetupSetting.setupApp.kLocalizationDelegate,
        uiBuilder: _uiBuilder,
        notifOnLaunch: _onLaunch,
        notifBackground: myBackgroundMessageHandler,
        notifOnResume: _onResume,
        notifOnMessage: _onMessage,
        onInit: _onInit,
        fetcher: _fetcher,
        totalApiRequest: 1,
        controller: controller);
  }

  Future<void> _fetcher() {
    controller.updateProgress("done", true);
  }

  Future<void> _onInit(BuildContext context) {}

  Widget _uiBuilder(BuildContext context, double processing, String description,
      Status type) {
    switch (type) {
      case Status.success:
        return MyHomePage(title: 'cobadulu');
        break;
      default:
        return Container();
        break;
    }
  }

  Future<void> _onLaunch(Map<String, dynamic> message) {
    myBackgroundMessageHandler(message);
    print("ini _onLaunch: $message");
  }

  Future<void> _onResume(Map<String, dynamic> message) {
    myBackgroundMessageHandler(message);
    print("ini _onResume: $message");
  }

  Future<void> _onMessage(Map<String, dynamic> message) {
    myBackgroundMessageHandler(message);
    print("ini _onMessage: $message");
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  TextEditingController _controller;

  void _incrementCounter() async {
    await allTranslation.setNewLanguage(
        (allTranslation.currentLanguage ?? 'en') == 'en' ? 'id' : 'en', true);
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'text here');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
            previousPageTitle: 'back', onPressed: () {}),
        previousPageTitle: 'before',
        trailing: Text('trail'),
        middle: Text('hello'),
      ),
      /* appBar: AppBar(
        title: Text(allTranslation.text(widget.title)),
      ),*/
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoTextField(
              enableInteractiveSelection: true,
              controller: _controller,
              enableSuggestions: false,
            ),
            Expanded(
              child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  minuteInterval: 15,
                  onTimerDurationChanged: (d) => print(d)),
            ),
            //  CupertinoFullscreenDialogTransition(animation: null, child: Text('this')),
            Container(
              height: 100,
              width: 100,
              child: CupertinoContextMenu(
                child: Container(
                  color: Colors.red,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text('Hello'),
                  ),
                ),
                actions: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoContextMenuAction(
                          child: Center(child: Icon(Icons.thumb_up)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                          child: CupertinoContextMenuAction(
                        child: Center(child: Icon(Icons.thumb_down)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )),
                    ],
                  )
                ],
              ),
            ),
            CupertinoActivityIndicator(radius: 20.0),
            CustomCupertinoActivityIndicator(radius: 20.0),
            Expanded(
                child: CupertinoDatePicker(
                    onDateTimeChanged: (date) => print(date))),
            CupertinoButton(child: Text('this'), onPressed: () => print('ss')),
            GestureDetector(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(child: Text("Button Cuk"))),
              onTap: () => print('di tap'),
              onDoubleTap: () => print('di dobel tap'),
              onLongPress: () => print('on long press'),
            ),
            Text(allTranslation.text('ini_isi'),
                style: TextStyle(color: CupertinoColors.activeBlue)),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
}

Future onSelectNotification(String payload) {
}

```


