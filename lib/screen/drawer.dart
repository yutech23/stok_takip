import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/navigation/navigation_manager.gr.dart';
import '../utilities/constants.dart';

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
  final String _customerSave = 'Müşteri Kayıt';
  final String _newUserAdd = 'Yeni Kullanıcı Ekle';
  final String _categoryAdd = 'Kategori Düzenleme';
  final String _newProductAdd = 'Yeni Ürün Ekle';
  final String _stockEdit = 'Stok Düzenleme';
  final String _test = 'Test';
  final String _exit = 'Güvenli Çıkış';

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
      child: Column(
        children: [
          Expanded(
            child: ListView(children: [
              widgetAvatarAndNameTage(context),
              widgetMenuItem(context, const RouteCustomerRegister(),
                  Icons.people_alt, _customerSave),
              widgetMenuItem(context, const RouteSignUp(), Icons.add_reaction,
                  _newUserAdd),
              widgetMenuItem(context, const RouteCategoryEdit(), Icons.category,
                  _categoryAdd),
              widgetMenuItem(context, const RouteProductAdd(), Icons.add_box,
                  _newProductAdd),
              widgetMenuItem(
                  context, const RouteStockEdit(), Icons.edit_note, _stockEdit),
              widgetMenuItem(context, const Test(), Icons.try_sms_star, _test),
              ElevatedButton(
                  onPressed: () async => db.fetchPageInfoByRole(
                      await SecurityStorageUser.getUserRole() ?? '2'),
                  child: Text("role Bağlı"))
              /*   ElevatedButton(
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
                  child: Text("stack ver")) */
            ]),
          ),
          widgetContainerExit(context),
        ],
      ),
    );
  }

//Avatar ve İsim Bölümü
  DrawerHeader widgetAvatarAndNameTage(BuildContext context) {
    return DrawerHeader(
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
        const Divider(),
        Text(nameAndLastNameCapitalFirst,
            style: context.theme.headline5!.copyWith(color: Colors.white)),
      ]),
    );
  }

  InkWell widgetMenuItem(BuildContext context, PageRouteInfo<dynamic> route,
      IconData? icon, String listItemName) {
    Color backGround = Colors.transparent;
    return InkWell(
      onTap: () {
        context.router.push(route);
      },
      onHover: (value) {
        backGround = Colors.grey.shade200;
      },
      child: Container(
        decoration: BoxDecoration(
            color: backGround,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
        padding: context.extensionPadding10(),
        child: Wrap(spacing: context.extensionSpacingDrawer20(), children: [
          Icon(
            icon,
            size: 30,
          ),
          Text(
            listItemName,
            style:
                context.theme.headline6!.copyWith(fontWeight: FontWeight.bold),
          )
        ]),
      ),
    );
  }

//Çıkış Bölmünün widgetı.
  Widget widgetContainerExit(BuildContext context) {
    return Container(
      color: context.extensionBlueGreyColor(),
      height: context.extensionButtonHeight,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () async {
          await db.signOut();
          context.router.pushNamed(RouteConsts.init);
          //Chrome Store tutulan verileri siliyor.
          SecurityStorageUser.deleteStorege();
        },
        child: Text(_exit,
            style: context.theme.headline6!
                .copyWith(color: Colors.white, letterSpacing: 1)),
      ),
    );
  }

  listFuncForRole(String role) {
    List<Widget> listWidget = <Widget>[];

    if (role == '1') {
    } else {}
  }
}
