import 'dart:async';

import 'package:flutter/material.dart';

abstract class AdvState<T extends StatefulWidget> extends State<T> {
  bool _firstRun = true;
  bool _processing = false;
  Color loadingBackgroundColor = Colors.black.withOpacity(0.3);
  bool withLoading = true;
  LoadingController controller = LoadingController();

  @override
  Widget build(BuildContext context) {
    if (_firstRun) {
      initStateWithContext(context);
      _firstRun = false;
    }

    return WillPopScope(
      child: advBuild(context),
      onWillPop: () async {
        return !isProcessing();
      },
    );
  }

  void initStateWithContext(BuildContext context);

  Widget advBuild(BuildContext context);

  bool isProcessing() => _processing;

  Future<void> process(Function f) async {
    setState(() {
      _processing = true;
    });

    OverlayEntry x = withLoading ? _showLoading() : null;
    await f();
    if (this.mounted) {
      setState(() {
        _processing = false;
      });
    }
    if (controller.refresh != null) await controller.refresh();

    x?.remove();
  }

  OverlayEntry _showLoading() {
    OverlayEntry toastOverlay = _createLoadingOverlay();

    OverlayState overlay = Overlay.of(context);

    if (overlay == null) return null;
    overlay.insert(toastOverlay);

    return toastOverlay;
  }

  OverlayEntry _createLoadingOverlay() {
    return OverlayEntry(
      builder: (context) =>
          FullLoading(true, Colors.black38, 100, 100, controller),
    );
  }
}

typedef Future<void> RefreshLoading();

class LoadingController {
  RefreshLoading refresh;
}

class FullLoading extends StatefulWidget {
  final bool visible;
  final Color barrierColor;
  final double width;
  final double height;
  final LoadingController controller;

  FullLoading(this.visible, this.barrierColor, this.width, this.height,
      this.controller);

  @override
  State<StatefulWidget> createState() => FullLoadingState();
}

class FullLoadingState extends State<FullLoading>
    with TickerProviderStateMixin {
  AnimationController opacityController;

  @override
  void initState() {
    super.initState();
    if (!this.mounted) return;

    widget.controller.refresh = () async {
      if (this.mounted) await opacityController.reverse(from: 1.0);
    };

    opacityController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);

    opacityController.addListener(() {
      if (this.mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    opacityController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!opacityController.isAnimating) {
        if (widget.visible && opacityController.value == 0.0)
          opacityController.forward(from: 0.0);
      }
    });

    return Visibility(
      visible: opacityController.value > 0.0,
      child: Positioned.fill(
          child: Opacity(
              opacity: opacityController.value,
              child: Container(
                  color: widget.barrierColor,
                  child: Center(
                    child: CircularProgressIndicator(),
                  )))),
    );
  }
}
