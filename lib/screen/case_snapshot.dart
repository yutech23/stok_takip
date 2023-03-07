import 'dart:ui';

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
  double deger = -1;

  late BlocCaseSnapshot _blocCaseSnapshot;

  /*------------------------TAHSİLAT BÖLÜMÜ------------------------------- */
  final String _labelCollectionHeader = "TAHSİLAT";
  final String _labelCollected = "TAHSİL EDİLEN";
  final String _labelCollectionWill = "TAHSİL EDİLECEKLER";

  /*---------------------------------------------------------------------- */
  /*------------------------ÖDEME BÖLÜMÜ------------------------------- */
  final String _labelPaymentHeader = "ÖDEMELER";
  final String _labelPaid = "YAPILAN ÖDEMELER";
  final String _labelPayable = "YAPILACAK ÖDEMELER";
  final String _labelTotal = "TOPLAM";
  /*---------------------------------------------------------------------- */
  List<TableRow> listTableRow = [];

  @override
  void initState() {
    _blocCaseSnapshot = BlocCaseSnapshot();

    super.initState();
    /*   WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    }); */
    _blocCaseSnapshot.getCollection()!.then((value) {
      print(value);
      setState(() {
        deger = value['Kasa']!;
      });
    });
  }

  /*  _asyncMethod() async {
    _blocCaseSnapshot.getCollection().then((value) {
      setState(() {
        _blocvalue
      });
    });
  } */

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
                          style: context.theme.headline6!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      widgetDivider(),
                      Padding(
                          padding: const EdgeInsets.all(12.0),

                          ///TAHSİLAT BÖLÜMÜ
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
                                      ], _labelCollectionWill, false,
                                          labelRow: false),

                                      widgetShareChart({
                                        'Toplam': snapshot.data!['Toplam']!,
                                      }, [
                                        Colors.amberAccent,
                                      ], _labelTotal, false, labelRow: false),
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
                          style: context.theme.headline6!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      widgetDivider(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),

                        ///ÖDEME BÖLÜMÜ
                        child: FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.hasData && !snapshot.hasError) {
                              return Wrap(
                                  alignment: WrapAlignment.center,
                                  runSpacing: context.extensionWrapSpacing20(),
                                  spacing: 50,
                                  direction: Axis.horizontal,
                                  children: [
                                    ///YAPILAN Ödemeler
                                    widgetShareChart({
                                      'Kasa': snapshot.data!['Kasa']!,
                                      'Banka': snapshot.data!['Banka']!
                                    }, [
                                      Colors.amberAccent,
                                      Colors.grey.shade400,
                                    ], _labelPaid, true, labelRow: true),

                                    ///Yapılacak Ödemeler
                                    widgetShareChart({
                                      'Kalan': snapshot.data!['Kalan']!,
                                    }, [
                                      Colors.redAccent,
                                    ], _labelPayable, false, labelRow: false),

                                    ///Toplam Ödemeler
                                    widgetShareChart({
                                      'Toplam': snapshot.data!['Toplam']!,
                                    }, [
                                      Colors.amberAccent,
                                    ], _labelTotal, false, labelRow: false),
                                  ]);
                            } else {
                              return widgetShareCircularProgress(context);
                            }
                          },
                          future: _blocCaseSnapshot.getPayment(),
                        ),
                      ),
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
                          style: context.theme.headline6!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      widgetDivider(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),

                        ///ÖDEME BÖLÜMÜ

                        child: widgetDataTableSnapshootDaily(),
                        /* return Wrap(
                                  alignment: WrapAlignment.center,
                                  runSpacing: context.extensionWrapSpacing20(),
                                  spacing: 50,
                                  direction: Axis.horizontal,
                                  children: [
                                    ///YAPILAN Ödemeler
                                    widgetShareChart({
                                      'Anlık Kasa':
                                          snapshot.data!['Anlık Kasa']!,
                                    }, [
                                      Colors.amberAccent,
                                      Colors.grey.shade400,
                                    ], _labelPaid, true, labelRow: true),

                                    ///Yapılacak Ödemeler
                                    widgetShareChart({
                                      'Anlık Banka':
                                          snapshot.data!['Anlık Banka']!
                                    }, [
                                      Colors.redAccent,
                                    ], _labelPayable, false, labelRow: false),

                                    ///Toplam Ödemeler
                                    widgetShareChart({
                                      'Kar': snapshot.data!['Kar']!,
                                    }, [
                                      Colors.amberAccent,
                                    ], _labelTotal, false, labelRow: false),
                                  ]); */
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ));
  }

  widgetDataTableSnapshootDaily() {
    listTableRow.add(buildRowRight(
        "${FormatterConvert().currencyShow(deger)} ₺",
        "${FormatterConvert().currencyShow(_blocCaseSnapshot.calculateCase['Anlık Banka'])} ₺"));
    return Container(
      height: 100,
      width: 275,
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: context.extensionDisableColor,
            alignment: Alignment.center,
            padding: EdgeInsets.all(4),
            child: Text(
              "GÜNLÜK DURUM",
              style: context.theme.headline6!.copyWith(color: Colors.white),
            ),
          ),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(140),
              1: FixedColumnWidth(135),
            },
            border: TableBorder.symmetric(
                inside: const BorderSide(color: Colors.white)),
            children: [
              buildRowHeader("Kasa", "Banka"),
              for (int i = 0; i < listTableRow.length; i++) listTableRow[i],
            ],
          ),
        ],
      ),
    );
  }

  TableRow buildRowRight(String header, String value) => TableRow(
          decoration: BoxDecoration(
              // color: context.extensionDisableColor,
              ),
          children: [
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.centerRight,
                    child: Text(
                      header,
                      style: context.theme.titleSmall!
                          .copyWith(color: Colors.black),
                    ))),
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.fromLTRB(15, 4, 0, 4),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: context.theme.titleSmall!
                          .copyWith(color: Colors.black),
                    ))),
          ]);

  TableRow buildRowHeader(String header, String value) => TableRow(
          decoration: BoxDecoration(
            color: context.extensionDisableColor,
          ),
          children: [
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.center,
                    child: Text(
                      header,
                      style: context.theme.titleMedium!
                          .copyWith(color: Colors.white),
                    ))),
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.center,
                    child: Text(
                      value,
                      style: context.theme.titleMedium!
                          .copyWith(color: Colors.white),
                    ))),
          ]);

  Divider widgetDivider() {
    return Divider(
        height: 1, color: context.extensionDisableColor, thickness: 1);
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
