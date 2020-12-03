import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:responsive_framework/utils/scroll_behavior.dart';
import 'package:silnik_app/pages/lab_choser.dart';
import 'package:silnik_app/pages/routes.dart';

void main() {
  Routes.defineRoutes();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Badanie silnika pierścieniowego',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('pl'),
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget),
          maxWidth: 1400,
          minWidth: 450,
          defaultScale: true,
          background: Container(color: Color(0xFFF5F5F5)),
          breakpoints: [
            ResponsiveBreakpoint.resize(650, name: MOBILE),
            ResponsiveBreakpoint.autoScale(100, name: TABLET),
            ResponsiveBreakpoint.autoScale(1200, name: TABLET),
            ResponsiveBreakpoint.resize(1400, name: DESKTOP),
            ResponsiveBreakpoint.autoScale(2460, name: "4K"),
          ],
        ),
        initialRoute: '/',
        home: LabChooser(),
        onGenerateRoute: Routes.router.generator
    );
  }
}
