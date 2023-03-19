import 'package:flutter/material.dart';
import 'package:stok_takip/screen/drawer.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/utilities/widget_category_add.dart';
import 'package:stok_takip/utilities/widget_category_delete.dart';
import 'package:stok_takip/validations/validation.dart';
import '../models/category.dart';
import '../utilities/widget_appbar_setting.dart';

class ScreenCategoryEdit extends StatefulWidget {
  const ScreenCategoryEdit({Key? key}) : super(key: key);

  @override
  State<ScreenCategoryEdit> createState() => _ScreenCategoryEditState();
}

class _ScreenCategoryEditState extends State<ScreenCategoryEdit>
    with Validation {
  final GlobalKey<FormState> _globalFormKey = GlobalKey<FormState>();
  late Category _categoryMap;
  bool _changeNewCategoryAndDeleteCategory = true;

  @override
  void initState() {
    super.initState();
    _categoryMap = Category();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: const Text("Yeni Kategori Ekleme veya Silme"),
          actions: [
            ShareWidgetAppbarSetting(),
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
          child: Container(
            height: context.extendFixedHeighContainer,
            width: context.extendFixedWightContainer,
            constraints: const BoxConstraints(minWidth: 360, maxWidth: 750),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: context.extensionThemaWhiteContainer(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widgetElevatedButtonOperationType(),
                  _changeNewCategoryAndDeleteCategory
                      ? WidgetCategoryAdd()
                      : const WidgetCategoryDelete(),
                ],
              ),
            ),
          ),
        ));
  }

  ///Buttonlar Kategori Ekleme ve Silme
  widgetElevatedButtonOperationType() {
    return Wrap(
        alignment: WrapAlignment.center,
        spacing: context.extensionWrapSpacing10(),
        runSpacing: context.extensionWrapSpacing10(),
        children: [
          shareWidget.widgetElevatedButton(
              onPressedDoSomething: () {
                setState(() {
                  _changeNewCategoryAndDeleteCategory = true;
                });
              },
              label: "Yeni Kategori Ekle"),
          shareWidget.widgetElevatedButton(
              onPressedDoSomething: () {
                setState(() {
                  _changeNewCategoryAndDeleteCategory = false;
                });
              },
              label: "Kategori Silme"),
          Divider()
        ]);
  }
}
