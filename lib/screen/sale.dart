import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ScreenSale extends StatefulWidget {
  const ScreenSale({super.key});

  @override
  State<ScreenSale> createState() => _ScreenSallingState();
}

class _ScreenSallingState extends State<ScreenSale> {
  final double _saleMinWidth = 360, _saleMaxWidth = 760;
  final GlobalKey<FormState> _formKeySale = GlobalKey();

  final String _labelHeading = "Satış Ekranı";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                minWidth: _saleMinWidth, maxWidth: _saleMaxWidth),
            padding: context.extensionPadding20(),
            decoration: context.extensionThemaWhiteContainer(),
            child: Column(
              children: [
                Text(
                  "KATEGORİ FİLTRE",
                  style: context.theme.headlineMedium,
                ),
                const Divider(),
                const Divider(
                    color: Colors.blueGrey, thickness: 2.5, height: 40),
              ],
            ),
          )),
        ));
  }
}
