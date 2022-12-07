import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import '../data/database_helper.dart';

class ShareWidgetAppbarSetting extends StatelessWidget {
  const ShareWidgetAppbarSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.settings),
      onSelected: (item) => settingOnSelected(context, item),
      itemBuilder: (context) => [
        PopupMenuItem(
            value: 0,
            child: Text("Şifre Değiştirme", style: context.theme.headline6)),
        PopupMenuItem(
            value: 1, child: Text("Çıkış", style: context.theme.headline6))
      ],
    );
  }

  settingOnSelected(BuildContext context, item) async {
    switch (item) {
      case 0:
        context.router.pushNamed(RouteConsts.userSetting);
        break;
      case 1:
        await db.signOut();
        context.router.pushNamed(RouteConsts.init);

        //Chrome Store tutulan verileri siliyor.
        SecurityStorageUser.deleteStorege();
    }
  }
}
