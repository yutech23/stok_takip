import 'package:flutter/material.dart';
import 'package:stok_takip/bloc/bloc_categorty.dart';
import 'package:stok_takip/screen/drawer.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/widget_category_add.dart';
import 'package:stok_takip/utilities/widget_category_edit.dart';
import 'package:stok_takip/validations/validation.dart';
import '../utilities/widget_appbar_setting.dart';

class ScreenCategoryEdit extends StatefulWidget {
  const ScreenCategoryEdit({Key? key}) : super(key: key);

  @override
  State<ScreenCategoryEdit> createState() => _ScreenCategoryEditState();
}

class _ScreenCategoryEditState extends State<ScreenCategoryEdit>
    with Validation, TickerProviderStateMixin {
  final GlobalKey<FormState> _globalFormKey = GlobalKey<FormState>();
  final String _labelNewCategoryAdd = "Yeni Kategori Ekle";
  final String _labelCategoryDelete = "Kategori Sil";
  final String _labelCategoryEdit = "Kategori Düzenle";
  late final TabController _controllerTab;
  final double _tabHeight = 600;

  final BlocCategory _blocCategory = BlocCategory();

  @override
  void initState() {
    _controllerTab = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controllerTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Kategori Ekranı"),
          // ignore: prefer_const_literals_to_create_immutables
          actions: [
            const ShareWidgetAppbarSetting(),
          ]),
      body: buildProductAdd(),
      drawer: const MyDrawer(),
    );
  }

  buildProductAdd() {
    return Form(
        key: _globalFormKey,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ///Kategori silme bölümü
              widgetCardCategoryDelete(),
              context.extensionHighSizedBox10(),

              ///TabBar Bölümü
              Container(
                constraints: const BoxConstraints(maxWidth: 850),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8)
                    ]),
                padding: const EdgeInsets.all(8),
                child: TabBar(
                    controller: _controllerTab,
                    unselectedLabelColor: context.extensionDefaultColor,
                    labelColor: Colors.white,
                    indicatorColor: Colors.blueGrey.shade600,
                    labelStyle: context.theme.titleMedium,
                    indicator: BoxDecoration(
                        color: context.extensionDefaultColor,
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.5),
                              blurRadius: 8)
                        ]),
                    tabs: [
                      widgetTab(_labelNewCategoryAdd),
                      widgetTab(_labelCategoryEdit),
                    ]),
              ),
              Container(
                height: _tabHeight,
                constraints: const BoxConstraints(minWidth: 360, maxWidth: 850),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8)
                    ]),
                child: TabBarView(
                  controller: _controllerTab,
                  children: [
                    SingleChildScrollView(
                      child: WidgetCategoryAdd(_blocCategory),
                    ),
                    SingleChildScrollView(
                      child: WidgetCategoryEdit(_blocCategory),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  final String _header = "Seçilen kategori siliniyor.";
  final String _yesText = "Sil";
  Card widgetCardCategoryDelete() {
    return Card(
      child: Container(
        width: 200,
        height: 40,
        alignment: Alignment.center,
        child: TextButton.icon(
          icon: Icon(Icons.delete, color: context.extensionDefaultColor),
          onPressed: () async {
            if (_blocCategory.category.category1 != null) {
              buildPopupDialog(context);
            }
            setState(() {});
          },
          label: Text(
            _labelCategoryDelete,
            style: context.theme.titleSmall,
          ),
        ),
      ),
    );
  }

  Tab widgetTab(String label) {
    return Tab(
      height: 30,
      text: label,
    );
  }

  ///Silme popup bölümü
  buildPopupDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('UYARI',
              textAlign: TextAlign.center,
              style: context.theme.titleLarge!
                  .copyWith(fontWeight: FontWeight.bold)),
          alignment: Alignment.center,
          content: Text(_header,
              style: context.theme.titleMedium!
                  .copyWith(fontWeight: FontWeight.bold)),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                  onPressed: () async {
                    await _blocCategory.deleteCategory();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: Text(_yesText,
                      style: context.theme.titleSmall!
                          .copyWith(color: Colors.white))),
            ),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                child: Text("İptal",
                    style: context.theme.titleSmall!
                        .copyWith(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
