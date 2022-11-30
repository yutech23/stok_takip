import 'package:flutter/material.dart';
import 'package:stok_takip/screen/login.dart';
import 'package:stok_takip/screen/stock_edit.dart';
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

  Future _navigator() async {
    await Future.delayed(const Duration(milliseconds: 1500), () {});
    if (db.supabase.auth.session() != null) {
      print('splash - a');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenStockEdit(),
          ));
    } else {
      print('b');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenLogin(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
