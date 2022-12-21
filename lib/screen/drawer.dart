import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/auth/auth_controller.dart';
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
  //Menü Sırasını belirliyorum.
  final List<String> _orderMenu = <String>[
    'RouteCustomerRegister',
    'RouteSignUp',
    'RouteCategoryEdit',
    'RouteProductAdd',
    'RouteStockEdit',
    'Test'
  ];

  final List<Widget> listWidgetMenuByRole = [];

  @override
  void initState() {
    super.initState();
    getNameAndSurenameFromStorage();
    //Kullanı rolüne göre izinli olduğu sayfaların listesi geliyor.
    db.fetchPageInfoByRole(authController.role).then((value) {
      setState(() {
        listFuncForRole(value);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    listWidgetMenuByRole.clear();
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
              for (Widget itemWidget in listWidgetMenuByRole) itemWidget,
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

  //Menu Widgetların yapısı.
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
        child: Wrap(spacing: context.extensionWrapSpacing20(), children: [
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
          context.router.pushNamed(ConstRoute.init);
          //Chrome Store tutulan verileri siliyor.
          SecurityStorageUser.deleteStorege();
        },
        child: Text(_exit,
            style: context.theme.headline6!
                .copyWith(color: Colors.white, letterSpacing: 1)),
      ),
    );
  }

//Veri tabanındaki Role göre Menü Listesini otomatik oluşturuyor.
  listFuncForRole(List<dynamic> listPathMenuByRole) {
    //Buradaki for döngüleri menü sıralaması belirlenen sırada olması sağlıyor.
    for (var orderMenuItem in _orderMenu) {
      for (var element in listPathMenuByRole) {
        if (orderMenuItem == element['class_name']) {
          switch (element['class_name']) {
            case "RouteCustomerRegister":
              listWidgetMenuByRole.add(widgetMenuItem(
                  context,
                  const RouteCustomerRegister(),
                  Icons.people_alt,
                  _customerSave));
              break;
            case "RouteSignUp":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteSignUp(), Icons.add_reaction, _newUserAdd));
              break;
            case "RouteProductAdd":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteProductAdd(), Icons.add_box, _newProductAdd));
              break;
            case "RouteStockEdit":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteStockEdit(), Icons.edit_note, _stockEdit));
              break;
            case "RouteCategoryEdit":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteCategoryEdit(), Icons.category, _categoryAdd));
              break;
            case "Test":
              listWidgetMenuByRole.add(widgetMenuItem(
                  context, const Test(), Icons.try_sms_star, _test));
              break;
            default:
          }
        }
      }
    }
  }
}
