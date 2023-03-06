import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:stok_takip/bloc/bloc_case_snapshot.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';

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
  final double _shareWidthChartContainer = 150;
  final double _shareHeightChartContainer = 235;

  late BlocCaseSnapshot _blocCaseSnapshot;

  /*------------------------TAHSİLAT BÖLÜMÜ------------------------------- */
  final String _labelCollectionHeader = "TAHSİLAT";
  final String _labelCollected = "TAHSİL EDİLEN";
  final String _labelCollectionWill = "TAHSİL EDİLECEKLER";
  final String _labeltotalCollected = "TOPLAM";
  /*---------------------------------------------------------------------- */
  /*------------------------ÖDEME BÖLÜMÜ------------------------------- */
  final String _labelPaymentHeader = "ÖDEMELER";
  final String _labelPaid = "YAPILAN";
  final String _labelPayable = "YAPILACAK";
  final String _labelTotal = "TOPLAM";
  /*---------------------------------------------------------------------- */

  @override
  void initState() {
    _blocCaseSnapshot = BlocCaseSnapshot();

    super.initState();
  }

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

  final dataMap = <String, double>{"Nakit": 903249500, "Banka": 103249500};
  final dataMap2 = <String, double>{"Nakit": 903249500};
  final dataMap1 = <String, String>{"Nakit": '903249500', "Banka": '103249500'};

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
            child: Column(
              children: [
                Card(
                  elevation: 10,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _labelCollectionHeader,
                          style: context.theme.headline6,
                        ),
                      ),
                      Divider(
                          color: context.extensionDisableColor, thickness: 1),
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FutureBuilder<Map<String, double>>(
                            builder: (context, snapshot) {
                              if (snapshot.hasData && !snapshot.hasError) {
                                return Wrap(
                                    alignment: WrapAlignment.center,
                                    runSpacing:
                                        context.extensionWrapSpacing20(),
                                    spacing: 50,
                                    direction: Axis.horizontal,
                                    children: [
                                      ///Tahsil Edilen
                                      widgetShareChart({
                                        'Kasa': snapshot.data!['Kasa']!,
                                        'Banka': snapshot.data!['Banka']!
                                      }, [
                                        Colors.amberAccent,
                                        Colors.grey.shade400,
                                      ], _labelCollected, true, labelRow: true),

                                      widgetShareChart({
                                        'Kalan': snapshot.data!['Kalan']!,
                                      }, [
                                        Colors.redAccent,
                                      ], _labeltotalCollected, true,
                                          labelRow: false),

                                      widgetShareChart({
                                        'Toplam': snapshot.data!['Toplam']!,
                                      }, [
                                        Colors.amberAccent,
                                      ], _labeltotalCollected, true,
                                          labelRow: false),
                                    ]);
                              } else {
                                return widgetShareCircularProgress(context);
                              }
                            },
                            future: _blocCaseSnapshot.getCollection(),
                          )),
                    ],
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _labelPaymentHeader,
                          style: context.theme.headline6,
                        ),
                      ),
                      Divider(
                          color: context.extensionDisableColor, thickness: 1),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Wrap(
                            alignment: WrapAlignment.center,
                            runSpacing: context.extensionWrapSpacing20(),
                            spacing: 50,
                            direction: Axis.horizontal,
                            children: [
                              widgetShareChart(
                                  dataMap,
                                  [
                                    Colors.amberAccent,
                                    Colors.grey.shade400,
                                  ],
                                  _labelPaid,
                                  true,
                                  labelRow: true),
                              widgetShareChart(dataMap2, [Colors.amberAccent],
                                  _labelPayable, false),
                              widgetShareChart(
                                  dataMap2, [Colors.grey], _labelTotal, false)
                            ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ));
  }

  Container widgetShareCircularProgress(BuildContext context) {
    return Container(
      width: _shareWidthChartContainer,
      height: _shareHeightChartContainer,
      alignment: Alignment.center,
      child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            backgroundColor: Colors.amberAccent,
            color: context.extensionDisableColor,
          )),
    );
  }

  SizedBox widgetShareChart(Map<String, double> dataMap, List<Color> colorList,
      String labelHeader, bool showlabel,
      {bool labelRow = false}) {
    return SizedBox(
      width: _shareWidthChartContainer,
      height: _shareHeightChartContainer,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                labelHeader,
                style: context.theme.titleSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PieChart(
            animationDuration: const Duration(seconds: 1, milliseconds: 200),
            chartLegendSpacing: 12,
            legendOptions: LegendOptions(
              legendPosition: LegendPosition.bottom,
              showLegendsInRow: labelRow,
              showLegends: showlabel,
            ),
            formatChartValues: (value) {
              return FormatterConvert()
                  .currencyShow(value, unitOfCurrency: "₺");
            },
            dataMap: dataMap,
            chartType: ChartType.ring,
            baseChartColor: Colors.grey[50]!.withOpacity(0.15),
            colorList: colorList,
            chartValuesOptions: const ChartValuesOptions(
                chartValueBackgroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
