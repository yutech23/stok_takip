import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ScreenCaseSnapshot extends StatefulWidget {
  const ScreenCaseSnapshot({super.key});

  @override
  State<ScreenCaseSnapshot> createState() => _ScreenCaseSnapshotState();
}

class _ScreenCaseSnapshotState extends State<ScreenCaseSnapshot> {
  final _formKeyCaseSnapshot = GlobalKey<FormState>();
  final String _labelHeading = "Güncel Durum";
  final double _shareMinWidth = 360;
  final double _shareMaxWidth = 1200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_labelHeading),

        iconTheme: IconThemeData(color: Colors.blueGrey.shade100),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildCaseSnapshot(),
      drawer: const MyDrawer(),
    );
  }

  final dataMap = <String, double>{
    "Flutter": 5,
  };

  buildCaseSnapshot() {
    return Form(
        key: _formKeyCaseSnapshot,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
            constraints: BoxConstraints(
                minWidth: _shareMinWidth, maxWidth: _shareMaxWidth),
            padding: context.extensionPadding20(),
            decoration: context.extensionThemaWhiteContainer(),
            child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: context.extensionWrapSpacing10(),
                spacing: context.extensionWrapSpacing20(),
                direction: Axis.horizontal,
                children: [
                  Container(
                    color: Colors.grey,
                    width: 300,
                    height: 300,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: PieChart(
                      dataMap: dataMap,
                      chartType: ChartType.ring,
                      baseChartColor: Colors.grey[50]!.withOpacity(0.15),
                      colorList: [Colors.greenAccent],
                      chartValuesOptions: ChartValuesOptions(
                        showChartValuesInPercentage: true,
                      ),
                      totalValue: 20,
                    ),
                  )
                ]),
          )),
        ));
  }
}
