import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/navigation/navigation_manager.gr.dart';

import 'utilities/navigation/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.dbBaslat();
  // await dbHive.initDbHive(Sabitler.dbHiveBoxName);
  runApp(const MyApp());
}

final _appRouter = AppRouter(authGuard: AuthGuard());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blueGrey.shade900),
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.all(5),
          ),
          inputDecorationTheme: const InputDecorationTheme(
              fillColor: Color.fromARGB(255, 38, 50, 56),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 182, 30, 19)))),
          appBarTheme: AppBarTheme(
              color: Colors.blueGrey.shade900,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  fontSize: 24)),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey.shade900,
                  minimumSize: Size(300, 50),
                  textStyle: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Colors.white))),
          textTheme: const TextTheme(
            headline3: TextStyle(color: Colors.black),
            headline4:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          primaryColor: Colors.blue,
          dividerColor: Colors.transparent),
      routerDelegate:
          AutoRouterDelegate(_appRouter, initialRoutes: [RouteProductAdd()]),
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