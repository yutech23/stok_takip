import 'package:flutter/material.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

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
            onPressed: () => Navigator.of(context).pushNamed('/'),
            child: Text("Giriş Ekranı")),
        TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/signUp'),
            child: Text("Kayıt Ekranı")),
        TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed('/customerRegister'),
            child: Text("Müşteri Kayıt")),
        TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/categoryEdit'),
            child: Text("Categori Düzenleme")),
        TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/productAdd'),
            child: Text("Yeni Ürün Ekleme")),
        TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/stockEdit'),
            child: Text("Stok Güncelleme Ekranı")),
        TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/test'),
            child: Text("Test")),
      ]),
    );
  }
}
