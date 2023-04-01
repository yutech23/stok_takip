import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/auth/auth_controller.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/navigation/navigation_manager.gr.dart';
import 'data/database_mango.dart';
import 'utilities/navigation/auth_guard.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.dbBaslat();
  await authController.controllerAuth();
  await dbHive.initDbHive(Sabitler.dbHiveBoxName);
  runApp(const MyApp());
}

final _appRouter = AppRouter(authGuard: AuthGuard());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "ERP Sistemi",

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior()
          .copyWith(scrollbars: true, dragDevices: {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown
      }),

      theme: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blueGrey.shade900),
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.all(5),
          ),
          inputDecorationTheme: const InputDecorationTheme(
              fillColor: Color.fromARGB(255, 38, 50, 56),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue))),
          appBarTheme: AppBarTheme(
              color: Colors.blueGrey.shade900,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  fontSize: 24)),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(300, 50)),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.white;
                    }
                    return Colors.white;
                  }),
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey.shade400;
                    }
                    return context.extensionDefaultColor;
                  }),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) {
                      if (states.contains(MaterialState.focused)) {
                        return context.extensionDisableColor;
                      } else if (states.contains(MaterialState.pressed)) {
                        return context.extensionDisableColor.withOpacity(0.48);
                      } else if (states.contains(MaterialState.hovered)) {
                        return context.extensionDisableColor.withOpacity(0.24);
                      }
                      return null;
                    },
                  ),
                  textStyle: MaterialStateProperty.all(Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Colors.white)))),
          textTheme: const TextTheme(
            headline3: TextStyle(color: Colors.black),
            headline4:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          primaryColor: Colors.blue,
          dividerColor: Colors.transparent),

      routerDelegate: AutoRouterDelegate(_appRouter, initialRoutes: [
        if (authController.role == '') const RouteLogin(),
        if (authController.role == '1') const RouteSale(),
        if (authController.role == '2') const RouteSale()
      ]),
      // AutoRouterDelegate(_appRouter,initialRoutes: [const RouteCariSupplier()]),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}

/* class MyObserve extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print('New route pushed: ${route.settings.name}');
  }

  // only override to observer tab routes
  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    print('Tab route visited: ${route.name}');
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    print('Tab route re-visited: ${route.name}');
  }
}
 */