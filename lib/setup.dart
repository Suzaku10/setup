library setup;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:setup/adv_state.dart';
import 'package:setup/application.dart';
import 'package:setup/setup_setting.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

enum Status {
  failed,
  success,
  processing,
  canUpdate,
  mustUpdate,
  failedGetMinVersion,
  failedGetLatestVersion
}

typedef Widget UiBuilder(
    BuildContext context, double processing, String description, Status type);

class Setup extends StatefulWidget {
  final List<NavigatorObserver> observer;
  final ThemeData theme;
  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;
  final NotifOnMessage notifOnMessage;
  final NotifOnResume notifOnResume;
  final NotifOnLaunch notifOnLaunch;
  final OnBackgroundHandler notifBackground;
  final Fetcher fetcher;
  final MinVer minVer;
  final LatestVer latestVer;
  final SetupController controller;
  final UiBuilder uiBuilder;
  final OnInit onInit;
  final int totalApiRequest;
  final Iterable<Locale> supportLocales;

  const Setup(
      {this.observer = const [],
        @required this.theme,
        @required this.localizationsDelegates,
        this.notifOnLaunch,
        this.notifOnMessage,
        this.notifOnResume,
        this.fetcher,
        this.minVer,
        this.latestVer,
        @required this.uiBuilder,
        @required this.onInit,
        this.supportLocales = const [
          const Locale('en', 'US'), // English
          const Locale('id', 'ID'),
        ],
        @required this.totalApiRequest,
        @required SetupController controller,
        this.notifBackground})
      : assert(controller != null),
        this.controller = controller;

  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends AdvState<Setup> with WidgetsBindingObserver {
  Status statusNow;
  String minVer;
  bool isDataFetched = false;

  @override
  Widget advBuild(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: widget.observer,
      localizationsDelegates: widget.localizationsDelegates,
      supportedLocales: widget.supportLocales,
      theme: widget.theme,
      home: Builder(builder: (context) {
        Widget uiBuilder;
        uiBuilder = widget.uiBuilder(context, widget.controller.progress,
            widget.controller.description, statusNow);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _getData();
        });
        return NHome(uiBuilder);
      }),
    );
  }

  @override
  void initStateWithContext(BuildContext context) async {
    SetupSetting.refreshToken = _firebaseMessaging.getToken;
    SetupSetting.FCMToken = await _firebaseMessaging.getToken();

    if (widget.onInit != null) widget.onInit(context);

    _initNotif(context);

    widget.controller.addListener(_update);
    widget.controller.setupState = this;
    widget.controller._totalApiRequest = widget.totalApiRequest;
  }

  void _initNotif(BuildContext context) {
    _firebaseMessaging.configure(
        onMessage: widget.notifOnMessage,
        onBackgroundMessage: widget.notifBackground,
        onLaunch: widget.notifOnLaunch,
        onResume: widget.notifOnResume);
  }

  void _getData() {
    if (!isDataFetched) {
      isDataFetched = true;
      statusNow = Status.processing;
      widget.fetcher();
    }
  }

  void _retry() {
    setState(() {
      if (statusNow == Status.failed) {
        isDataFetched = false;
      } else if (statusNow == Status.failedGetMinVersion) {
        _fetchMinVersion();
      } else if (statusNow == Status.failedGetLatestVersion) {
        _fetchLatestVersion();
      }
      statusNow = Status.processing;
    });
  }

  void _updateApps() {
  }

  void _fetchMinVersion() {
    widget.minVer().then((result) {
      if (result == null) {
        setState(() {
          statusNow = Status.failedGetMinVersion;
        });
      } else {
        minVer = result;
        _fetchLatestVersion();
      }
    });
  }

  void _fetchLatestVersion() {
    widget.latestVer().then((latestVerResult) {
      if (latestVerResult == null) {
        setState(() {
          statusNow = Status.failedGetLatestVersion;
        });
      } else {
        _checkVersion(minVer, latestVerResult).then((result) {
          setState(() {
            statusNow = result;
          });
        });
      }
    });
  }

  void _update() {
    if (widget.controller.progress == 1.0) {
      if (widget.controller.checkDataIsNotValid()) {
        setState(() {
          statusNow = Status.failed;
        });
      } else {
        if (widget.minVer != null && widget.latestVer != null) {
          _fetchMinVersion();
        } else {
          setState(() {
            statusNow = Status.success;
          });
        }
      }
    } else {
      setState(() {
        statusNow = Status.processing;
      });
    }
  }

  Future<Status> _checkVersion(String minVersion, String latestVersion) async {
  }
}

class NHome extends StatefulWidget {
  final Widget child;

  NHome(this.child);

  @override
  _NHomeState createState() => _NHomeState();
}

class _NHomeState extends AdvState<NHome> {
  BuildContext buildContext;

  @override
  Widget advBuild(BuildContext context) {
    if (!application.completer.isCompleted)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!application.completer.isCompleted)
          application.completer.complete(Future.value(context));
      });

    return widget.child;
  }

  void _settingDynamicOnLink() async {
  }

  @override
  void initStateWithContext(BuildContext context) {
    _settingDynamicOnLink();
  }
}

class SetupController extends ValueNotifier<SetupEditingValue> {
  double get progress => value.progress;

  String get description => value.description;

  bool get isError => value.isError;

  List<bool> get apiResultList => _apiResult;

  _SetupState setupState;

  int _totalApiRequest;

  List<bool> _apiResult = [];

  void retry() {
    _apiResult.clear();
    setupState._retry();
  }

  void updateApps() {
    setupState._updateApps();
  }

  void updateProgress(String description, bool isGetDataSuccess) {
    _apiResult.add(isGetDataSuccess);
    double progress = _apiResult.length / _totalApiRequest;
    value = value.copyWith(
        description: description,
        progress: progress,
        isError: !isGetDataSuccess);
  }

  bool checkDataIsNotValid() {
    return _apiResult.contains(false);
  }

  SetupController({double progress, String description, bool isError})
      : super(progress == null && description == null && isError == null
      ? SetupEditingValue.empty
      : new SetupEditingValue(
      progress: progress,
      description: description,
      isError: isError));

  SetupController.fromValue(SetupEditingValue value)
      : super(value ?? SetupEditingValue.empty);

  void clear() {
    value = SetupEditingValue.empty;
  }
}

@immutable
class SetupEditingValue {
  const SetupEditingValue(
      {this.progress = 0.0,
        this.description = "",
        this.isError = false,
        this.setupState});

  final double progress;
  final String description;
  final bool isError;
  final _SetupState setupState;

  static const SetupEditingValue empty = const SetupEditingValue();

  SetupEditingValue copyWith(
      {double progress,
        String description,
        bool isError,
        _SetupState setupState,
        List<bool> apiResultList}) {
    return new SetupEditingValue(
        progress: progress,
        description: description,
        isError: isError,
        setupState: setupState);
  }

  SetupEditingValue.fromValue(SetupEditingValue copy)
      : this.progress = copy.progress,
        this.description = copy.description,
        this.isError = copy.isError,
        this.setupState = copy.setupState;

  @override
  String toString() =>
      '$runtimeType(progress: \u2524$progress\u251C, description: \u2524$description\u251C, isError: \u2524$isError\u251C)';

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! SetupEditingValue) return false;
    final SetupEditingValue typedOther = other;
    return typedOther.progress == progress &&
        typedOther.description == description &&
        typedOther.isError == isError;
  }

  @override
  int get hashCode =>
      hashValues(progress.hashCode, description.hashCode, isError.hashCode);
}

