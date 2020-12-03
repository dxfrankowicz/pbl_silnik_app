import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class NavigationUtils {
  final Logger logger = new Logger("NavigationUtils");
  static final NavigationUtils _singleton = new NavigationUtils._internal();
  bool isInitialized = false;

  Type currentPage;

  factory NavigationUtils() {
    return _singleton;
  }

  NavigationUtils._internal() {
    isInitialized = false;
  }

  void init(BuildContext context) {
    if (isInitialized) {
      isInitialized = true;
    }
  }

  void goToPage(BuildContext context, Widget page) {
    Navigator.push(context,
        new MaterialPageRoute(builder: (BuildContext context) {
          return page;
        }));
  }

  void goToPageNamed(BuildContext context, String routeName) {
    logger.info("Navigating to $routeName");
    Navigator.pushNamed(context, routeName);
  }

  void goToPageNamedReplace(BuildContext context, String routeName) {
    if (routeName == null) return;

    logger.info("Navigating to $routeName with replace");

    Navigator.pushReplacementNamed(context, routeName);
  }

  void goToPageNamedRemovingAll(BuildContext context, String routeName) {
    if (routeName == null) return;

    logger.info("Navigating to $routeName. Removing all route");

    Navigator.of(context)
        .pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  }

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  Future<T> openDialog<T>(BuildContext context, Widget dialog) async {
    if (dialog == null) return null;

    logger.info("Opening dialog ${dialog.runtimeType}");

    return Navigator.push(
        context,
        new MaterialPageRoute<T>(
          builder: (BuildContext context) => dialog,
          fullscreenDialog: true,
        ));
  }
}
