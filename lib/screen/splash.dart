import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/constants.dart';
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

  //TokenCacheManager _cacheManager = TokenCacheManager();
  Future _navigator() async {
    // await Future.delayed(const Duration(milliseconds: 1500), () {});
    if (db.supabase.auth.currentSession != null) {
      print('splash - a');
      return context.router.pushNamed(ConstRoute.stockEdit);
    } else {
      print('b');
      return context.router.pushNamed(ConstRoute.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
