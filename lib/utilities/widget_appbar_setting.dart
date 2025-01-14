import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

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
            child: Text("Şifre Değiştirme", style: context.theme.titleLarge)),
      ],
    );
  }

  settingOnSelected(BuildContext context, item) async {
    switch (item) {
      case 0:
        context.router.pushNamed(ConstRoute.userSetting);
        break;
    }
  }
}
