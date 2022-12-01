import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/screen/login.dart';
import 'package:stok_takip/screen/stock_edit.dart';
import 'package:stok_takip/utilities/navigation/navigation_manager.gr.dart';
import '../data/database_helper.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  @override
  void initState() {
    super.initState();
    _navigator();
  }

  Future _navigator() {
    // await Future.delayed(const Duration(milliseconds: 1500), () {});
    if (db.supabase.auth.session() != null) {
      print('splash - a');
      return context.router.push(const RouteStockEdit());
      /*  Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenStockEdit(),
          )); */
    } else {
      print('b');
      return context.router.push(const RouteLogin());
      /*  Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenLogin(),
          )); */
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
