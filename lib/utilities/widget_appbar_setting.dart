import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import '../data/database_helper.dart';
import '../screen/login.dart';
import '../screen/user_setting.dart';

class ShareWidgetAppbarSetting extends StatelessWidget {
  const ShareWidgetAppbarSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.settings),
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

  settingOnSelected(BuildContext context, item) {
    switch (item) {
      case 0:
        Navigator.of(context).pushNamed('/userSetting');
        break;
      case 1:
        db.signOut().then((value) {
          Navigator.of(context).pushNamed('/');
          //Chrome Store tutulan verileri siliyor.
          Sabitler.sessionStorageSecurty.deleteAll();
        });
    }
  }
}
