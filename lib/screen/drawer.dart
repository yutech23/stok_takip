import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/screen/login.dart';
import 'package:stok_takip/screen/product_add.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/navigation/navigation_manager.gr.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() {
    return _MyDrawerState();
  }
}

class _MyDrawerState extends State<MyDrawer> {
  String nameAndLastnameFirstLatter = '';

  @override
  void initState() {
    super.initState();
    storageData();
  }

  Future storageData() async {
    String name = await SecurityStorageUser.getUserName() ?? 'N';
    String lastName = await SecurityStorageUser.getUserLastName() ?? 'O';

    setState(() {
      print(" deger : $name");
      nameAndLastnameFirstLatter =
          name[0].toUpperCase() + lastName[0].toUpperCase();
    });
  }

  @override
  void didUpdateWidget(covariant MyDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blueGrey.shade900),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              // ignore: sort_child_properties_last
              child: Text(nameAndLastnameFirstLatter,
                  style: context.theme.headline4!
                      .copyWith(letterSpacing: 1, fontWeight: FontWeight.bold)),
              radius: 40,
            ),
            Divider(),
            Text("Firma ismi",
                style: context.theme.headline5!.copyWith(color: Colors.white)),
          ]),
        ),
        TextButton(
            onPressed: () => context.router.push<bool>(const RouteSignUp()),
            child: Text("Kayıt Ekranı")),
        TextButton(
            onPressed: () =>
                context.router.push<bool>(const RouteCustomerRegister()),
            child: Text("Müşteri Kayıt")),
        TextButton(
            onPressed: () => context.router.push(const RouteCategoryEdit()),
            child: Text("Categori Düzenleme")),
        TextButton(
            onPressed: () => context.router.push<bool>(const RouteProductAdd()),
            child: Text("Yeni Ürün Ekleme")),
        TextButton(
            onPressed: () => context.router.push<bool>(const RouteStockEdit()),
            child: Text("Stok Güncelleme Ekranı")),
        TextButton(
            onPressed: () => context.router.push(const Test()),
            child: Text("Test")),
        ElevatedButton(
            onPressed: () async {
              String? refleshToken =
                  await SecurityStorageUser.getUserRefleshToken();
              print("ilke geken deger : $refleshToken");
              db.refleshToken(refleshToken!);
            },
            child: Text("Session")),
        ElevatedButton(
            onPressed: () {
              context.router.pop();
            },
            child: Text("pop")),
        ElevatedButton(
            onPressed: () {
              print(context.router.stack);
            },
            child: Text("stack ver"))
      ]),
    );
  }
}
