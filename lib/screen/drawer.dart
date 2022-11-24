import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

import '../utilities/constants.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String nameAndLastnameFirstLatter = '';

  @override
  void initState() {
    getFirstLetters().then((value) => nameAndLastnameFirstLatter = value!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blueGrey.shade900),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    // ignore: sort_child_properties_last
                    child: Text(snapshot.data!,
                        style: context.theme.headline4!.copyWith(
                            letterSpacing: 1, fontWeight: FontWeight.bold)),
                    radius: 40,
                  );
                } else {
                  return const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(""),
                    radius: 40,
                  );
                }
              },
              future: getFirstLetters(),
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

  Future<String?> getFirstLetters() async {
    String? name;
    String? lastName;

    await Sabitler.sessionStorageSecurty
        .read(key: 'name')
        .then((value) => name = value);

    await Sabitler.sessionStorageSecurty
        .read(key: 'lastName')
        .then((value) => lastName = value);

    if (name != null && lastName != null) {
      nameAndLastnameFirstLatter =
          name![0].toUpperCase() + lastName![0].toUpperCase();
    } else {
      nameAndLastnameFirstLatter = "N.N";
    }

    return nameAndLastnameFirstLatter;
  }
}
