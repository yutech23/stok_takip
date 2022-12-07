import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/user_security_storage.dart';
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
  String nameAndLastNameCapitalFirst = '';
  Color backGround = Colors.transparent;

  @override
  void initState() {
    super.initState();
    getNameAndSurenameFromStorage();
  }

  Future getNameAndSurenameFromStorage() async {
    String name = await SecurityStorageUser.getUserName() ?? 'N';
    String lastName = await SecurityStorageUser.getUserLastName() ?? 'O';

    setState(() {
      nameAndLastNameCapitalFirst = name.inCaps + ' ' + lastName.inCaps;
      nameAndLastnameFirstLatter =
          name[0].toUpperCase() + lastName[0].toUpperCase();
    });
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
            Text(nameAndLastNameCapitalFirst,
                style: context.theme.headline5!.copyWith(color: Colors.white)),
          ]),
        ),
        InkWell(
          onTap: () {
            context.router.push(const RouteCustomerRegister());
          },
          onHover: (value) {
            backGround = Colors.grey.shade200;
          },
          child: Container(
            decoration: BoxDecoration(
                color: backGround,
                border:
                    Border(bottom: BorderSide(color: Colors.grey.shade300))),
            padding: context.extensionPadding10(),
            child: Wrap(spacing: context.extensionSpacingDrawer20(), children: [
              const Icon(Icons.people_alt),
              Text(
                'Müşteri Kayıt',
                style: context.theme.headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              )
            ]),
          ),
        ),
        TextButton(
            onPressed: () => context.router.push(const RouteSignUp()),
            child: const Text("Kayıt Ekranı")),
        TextButton(
            onPressed: () => context.router.push(const RouteCategoryEdit()),
            child: const Text("Categori Düzenleme")),
        TextButton(
            onPressed: () => context.router.push(const RouteProductAdd()),
            child: Text("Yeni Ürün Ekleme")),
        TextButton(
            onPressed: () => context.router.push(const RouteStockEdit()),
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
