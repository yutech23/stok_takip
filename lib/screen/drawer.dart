import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
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
  final String _labelCustomerSave = 'Müşteri ve Tedarikçi İşlemleri';
  final String _labelNewUserAdd = 'Yeni Kullanıcı Ekle';
  final String _labelCategoryAdd = 'Kategori Düzenleme';
  final String _labelNewProductAdd = 'Yeni Ürün Ekle';
  final String _labelStockEdit = 'Stok Düzenleme';
  final String _labelTest = 'Test';
  final String _labelExit = 'Güvenli Çıkış';
  final String _labelSale = "Satış Ekranı";
  final String _labelCaseSnapshot = "Kasa Durum";
  final String _labelCapital = "Sermaye İşlemleri";
  final String _labelExpenses = "Giderler";
  final String _labelUsers = "Kullanıcılar";

  //Menü Sırasını belirliyorum.
  final List<String> _orderMenu = <String>[
    'RouteSale',
    'RouteCari',
    'RouteStockEdit',
    'RouteProductAdd',
    'RouteCustomerRegister',
    'RouteCategoryEdit',
    'RouteSignUp',
    'RouteCaseSnapshot',
    'RouteCapital',
    'RouteExpenses',
    'RouteUsers',
    'Test',
  ];

  late List<Widget> listWidgetMenuByRole = [];

  @override
  void initState() {
    super.initState();
    getNameAndSurenameFromStorage();
    getPagesListByRole();
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

  getPagesListByRole() async {
    String? pagesList = await SecurityStorageUser.getPageList();
    List<String> pages = pagesList!.split('-');
    listFuncForRole(pages);
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
              style: context.theme.headlineMedium!
                  .copyWith(letterSpacing: 1, fontWeight: FontWeight.bold)),
          radius: 40,
        ),
        const Divider(),
        Text(nameAndLastNameCapitalFirst,
            style: context.theme.headlineSmall!.copyWith(color: Colors.white)),
      ]),
    );
  }

  //Menu Widgetların yapısı.
  InkWell widgetMenuItem(BuildContext context, PageRouteInfo<dynamic> route,
      IconData? icon, String listItemName) {
    Color backGround = Colors.transparent;
    return InkWell(
      onTap: () {
        /*   if (listItemName == _labelCaseSnapshot) {
          blocCaseSnapshot.start();
        } */
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
            style: context.theme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          )
        ]),
      ),
    );
  }

  //Menu Widgetların yapısı. Icon image koymak için
  InkWell widgetMenuItemWithIconImage(BuildContext context,
      PageRouteInfo<dynamic> route, String iconPath, String listItemName) {
    Color backGround = Colors.transparent;
    return InkWell(
      onTap: () {
        /*   if (listItemName == _labelCaseSnapshot) {
          blocCaseSnapshot.start();
        } */
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
          ImageIcon(
            AssetImage(iconPath),
            size: 30,
          ),
          Text(
            listItemName,
            style: context.theme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          )
        ]),
      ),
    );
  }

  //Bağımlı menüler için widget
  widgetMenuItemSubcategory(
      BuildContext context,
      String mainHeading,
      List<String> subtitles,
      IconData? icon,
      List<PageRouteInfo<dynamic>> route) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      child: ExpansionTile(
        iconColor: Colors.amber.shade700,
        tilePadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          size: 30,
          color: context.extensionDefaultColor,
        ),
        title: Text(
          mainHeading,
          style:
              context.theme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        children: [
          for (int i = 0; i < subtitles.length; i++)
            Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: ListTile(
                hoverColor: Colors.grey.shade300,
                contentPadding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                onTap: () {
                  context.router.push(route[i]);
                },
                title: Text(
                  subtitles[i],
                  style: context.theme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            )
        ],
      ),
    );
  }

//Çıkış Bölmünün widgetı.
  Widget widgetContainerExit(BuildContext context) {
    return Container(
      color: context.extensionDefaultColor,
      height: context.extensionButtonHeight,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () async {
          await db.signOut();
          context.router.pushNamed(ConstRoute.login);
          //Chrome Store tutulan verileri siliyor.
          SecurityStorageUser.deleteStorege();
          //tuttuğum hive içindeki veriyi siliyor.
          dbHive.delete('uuid');
        },
        child: Text(_labelExit,
            style: context.theme.titleLarge!.copyWith(
              color: Colors.white,
            )),
      ),
    );
  }

//Veri tabanındaki Role göre Menü Listesini otomatik oluşturuyor.
  listFuncForRole(List<dynamic> listPathMenuByRole) {
    //Buradaki for döngüleri menü sıralaması belirlenen sırada olması sağlıyor.
    for (var orderMenuItem in _orderMenu) {
      for (var element in listPathMenuByRole) {
        if (orderMenuItem == element) {
          switch (element) {
            case "RouteCustomerRegister":
              listWidgetMenuByRole.add(widgetMenuItem(
                  context,
                  const RouteCustomerRegister(),
                  Icons.people_alt,
                  _labelCustomerSave));
              break;
            case "RouteSignUp":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteSignUp(), Icons.add_reaction, _labelNewUserAdd));
              break;
            case "RouteProductAdd":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteProductAdd(), Icons.add_box, _labelNewProductAdd));
              break;
            case "RouteStockEdit":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteStockEdit(), Icons.edit_note, _labelStockEdit));
              break;
            case "RouteCategoryEdit":
              listWidgetMenuByRole.add(widgetMenuItem(
                  context,
                  const RouteCategoryEdit(),
                  Icons.category,
                  _labelCategoryAdd));
              break;
            case "RouteSale":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteSale(), Icons.point_of_sale_rounded, _labelSale));
              break;
            case "RouteCari":
              listWidgetMenuByRole.add(widgetMenuItemSubcategory(
                  context,
                  "Cari İşlemler",
                  ["Müşteri", "Tedarikçi"],
                  Icons.person_search,
                  [const RouteCariCustomer(), const RouteCariSupplier()]));
              break;

            case "RouteCaseSnapshot":
              listWidgetMenuByRole.add(widgetMenuItem(
                  context,
                  const RouteCaseSnapshot(),
                  Icons.monitor,
                  _labelCaseSnapshot));
              break;
            case "RouteCapital":
              listWidgetMenuByRole.add(widgetMenuItem(
                  context, const RouteCapital(), Icons.money, _labelCapital));
              break;
            case "RouteExpenses":
              listWidgetMenuByRole.add(widgetMenuItemWithIconImage(context,
                  const RouteExpenses(), 'assets/gider.png', _labelExpenses));
              break;
            case "RouteUsers":
              listWidgetMenuByRole.add(widgetMenuItem(context,
                  const RouteUsers(), Icons.manage_accounts, _labelUsers));
              break;
            case "Test":
              listWidgetMenuByRole.add(widgetMenuItem(
                  context, const Test(), Icons.try_sms_star, _labelTest));
              break;
            default:
          }
        }
      }
    }
  }
}
