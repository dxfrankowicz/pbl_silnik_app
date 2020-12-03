import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:silnik_app/pages/lab_choser.dart';
import 'package:silnik_app/pages/main_lab_view.dart';

class CustomRouter extends FluroRouter {
  void defineMultiplePaths(List<String> routePath, {@required Handler handler}) {
    routePath.forEach((path) => define(path, handler: handler));
  }
}

class Routes {
  static final router = new CustomRouter();

  static void defineRoutes() {
    router.define("/", handler: new Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) => LabChooser())
    );

    router.define("/lab/:id", handler: new Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) => MainLabPage(int.parse(params["id"][0]))));

  }

  static MaterialPageRoute createPageRoute(
      Widget page, RouteSettings settings) {
    return new MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}