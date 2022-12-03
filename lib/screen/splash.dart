import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/utilities/constants.dart';
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

  //TokenCacheManager _cacheManager = TokenCacheManager();
  Future _navigator() async {
    // await Future.delayed(const Duration(milliseconds: 1500), () {});
    if (db.supabase.auth.session() != null) {
      print('splash - a');
      return context.router.pushNamed(RouteConsts.stockEdit);
    } else {
      print('b');
      return context.router.pushNamed(RouteConsts.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
