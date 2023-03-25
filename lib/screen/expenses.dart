import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ScreenExpenses extends StatefulWidget {
  const ScreenExpenses({super.key});

  @override
  State<ScreenExpenses> createState() => _ScreenExpensesState();
}

class _ScreenExpensesState extends State<ScreenExpenses> {
  final GlobalKey<FormState> _formKeySale = GlobalKey();
  final String _labelHeading = "Gider Ekranı";
  final double _firstContainerMaxWidth = 1000;
  final double _firstContainerMinWidth = 340;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_labelHeading),

        actionsIconTheme: IconThemeData(color: Colors.blueGrey.shade100),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildSale(),
      drawer: const MyDrawer(),
    );
  }

  buildSale() {
    return Form(
        key: _formKeySale,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
            constraints: BoxConstraints(
                minWidth: _firstContainerMinWidth,
                maxWidth: _firstContainerMaxWidth),
            padding: context.extensionPadding20(),
            decoration: context.extensionThemaWhiteContainer(),
            child: Wrap(
                alignment: WrapAlignment.center,
                spacing: context.extensionWrapSpacing20(),
                runSpacing: context.extensionWrapSpacing10(),
                children: [
                  Container(),
                ]),
          )),
        ));
  }
}
