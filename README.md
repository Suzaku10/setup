# Setup

this plugin used to add multilangual, and some feature soon

*Note*: This plugin is still under development, and some Components might not be available yet or still has so many bugs.

## Installation

First, add `setup` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```
  setup:
    git:
      url: git://github.com/Suzaku10/setup.git
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

6. this full example
```
import 'package:flutter/material.dart';
import 'package:flutter_app/constanta.dart';
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
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    await allTranslation.setNewLanguage(
        (allTranslation.currentLanguage ?? 'en') == 'en' ? 'id' : 'en', true);
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslation.text(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(child: Text("Button Cuk"))),
              onTap: () => print('di tap'),
              onDoubleTap: () => print('di dobel tap'),
              onLongPress: () => print('on long press'),
            ),
            Text(allTranslation.text('ini_isi')),
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

```


