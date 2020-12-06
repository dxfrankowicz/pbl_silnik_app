import 'package:flutter/material.dart';

class SilnikScaffold {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  // ignore: unnecessary_getters_setters
  static set scaffoldKey(GlobalKey<ScaffoldState> value) {
    _scaffoldKey = value;
  }

  ScrollController _controller = ScrollController();
  void scrollCallBack(DragUpdateDetails dragUpdate) {
      _controller.position.moveTo(dragUpdate.globalPosition.dy * 3.5);
  }

  static GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  static Widget get(BuildContext context,
      {appBar,
        body,
        floatingActionButton,
        floatingActionButtonLocation,
        floatingActionButtonAnimator,
        persistentFooterButtons,
        drawer,
        endDrawer,
        botNavBar,
        bottomSheet,
        backgroundColor,
        scaffoldKey}) {

    return new Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        endDrawer: endDrawer,
        appBar: appBar ?? SilnikScaffold.appBar(context),
        drawer: drawer,
        bottomSheet: bottomSheet,
        bottomNavigationBar: botNavBar,
        body: body);
  }

  static AppBar appBar(BuildContext context, {actions}) => new AppBar(
    centerTitle: true,
    title: new Text(
      'Badanie silnika pierścieniowego',
    ),
    actions: actions,
  );
}