import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/screen/category_edit.dart';
import 'package:stok_takip/screen/customer_register.dart';
import 'package:stok_takip/screen/login.dart';
import 'package:stok_takip/screen/product_add.dart';
import 'package:stok_takip/screen/sign_up.dart';
import 'package:stok_takip/screen/splash.dart';
import 'package:stok_takip/screen/stock_edit.dart';
import 'package:stok_takip/screen/test.dart';
import 'package:stok_takip/screen/user_setting.dart';

Future<void> main() async {
  DbHelper.dbBaslat();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => ScreenSplash(),
        '/login': (context) => ScreenLogin(),
        '/signUp': (context) => const ScreenSignUp(),
        '/customerRegister': (context) => const ScreenCustomerRegister(),
        '/productAdd': (context) => const ScreenProductAdd(),
        '/categoryEdit': (context) => const ScreenCategoryEdit(),
        '/stockEdit': (context) => const ScreenStockEdit(),
        '/test': (context) => const Test(),
        '/userSetting': (context) => ScreenUserSetting(),
      },
    );
  }
}
