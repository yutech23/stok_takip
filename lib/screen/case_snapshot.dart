import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:stok_takip/bloc/bloc_case_snapshot.dart';
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
  final double _shareHeightCard = 310;
  final double _shareWidthChartContainer = 150;
  final double _shareHeightChartContainer = 235;
  late double _responsiveWidth;
  final double _dataTableDailyWidth = 340;
  double deger = -1;
  late BlocCaseSnapshot _blocCaseSnapshot;

  /*------------------------TAHSİLAT BÖLÜMÜ------------------------------- */
  final String _labelCollectionHeader = "TAHSİLATLAR";
  final String _labelCollected = "TAHSİL EDİLEN";
  final String _labelCollectionWill = "TAHSİL EDİLECEKLER";

  /*---------------------------------------------------------------------- */
  /*------------------------ÖDEME BÖLÜMÜ------------------------------- */
  final String _labelPaymentHeader = "ÖDEMELER";
  final String _labelPaid = "YAPILAN ÖDEMELER";
  final String _labelPayable = "YAPILACAK ÖDEMELER";
  final String _labelTotal = "TOPLAM";
  /*---------------------------------------------------------------------- */

  final String _labelTotalTableHeader = "Toplam";
  final String _labelTotalCollectionBySale = "Satıştan Gelen";
  final String _labelReceivePaymant = "Alınan Ödemeler";
  final String _labelCurrentStatus = "DURUM";
  final String _labelDailySnapshoot = "GÜNLÜK";
  final String _labelTotalSold = "Toplam Satış";
  final String _labelTotalPayment = "Toplam Ödemeler";
  final String _labelCashBoxHeader = "ANLIK KASA";
  final String _labelCashSnapshoot = "Nakit";
  final String _labelBankSnapshoot = "Banka";
  final String _labelGeneralSituation = "GENEL";
  final String _labelProfit = "Kar";
  final String _labelCapital = "Depo'daki Sermaye";

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

  buildCaseSnapshot() {
    ///Mobil ve Web için değişken genişlik alınıyor.
    _responsiveWidth = getWidth();
    return Form(
        key: _formKeyCaseSnapshot,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
            constraints:
                BoxConstraints(minWidth: _shareMinWidth, maxWidth: 1200),
            padding: context.extensionPadding20(),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              direction: Axis.horizontal,
              children: [
                widgetDailyAndSnapshoot(),
                Column(
                  children: [
                    widgetCollectionSection(),
                    context.extensionHighSizedBox10(),
                    widgetPaymentSection(),
                  ],
                ),
              ],
            ),
          )),
        ));
  }

  ///Günlük Durum Bölümü
  widgetDailyAndSnapshoot() {
    return Container(
      width: _responsiveWidth <= 400 ? 340 : 400,
      constraints: BoxConstraints(minHeight: _shareHeightCard * 2 + 10),
      height: 600,
      child: Card(
        elevation: 10,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  _labelCurrentStatus,
                  style: context.theme.headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              widgetDivider(),
              Padding(
                padding: const EdgeInsets.all(12.0),

                ///GÜNLÜK BÖLÜMÜ
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: context.extensionWrapSpacing20(),
                  spacing: 50,
                  direction: Axis.horizontal,
                  children: [
                    StreamBuilder<Map<String, num>>(
                        stream: _blocCaseSnapshot.getStreamCalculateDaily,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && !snapshot.hasError) {
                            return Container(
                              width: _dataTableDailyWidth,
                              alignment: Alignment.centerRight,
                              child: Column(
                                children: [
                                  ///TOPLAM SATIŞ BÖLÜMÜ
                                  Container(
                                    width: double.infinity,
                                    color: Colors.grey.shade600,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      _labelDailySnapshoot,
                                      style: context.theme.headline6!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                  Table(
                                      columnWidths: {
                                        0: FixedColumnWidth(
                                            _dataTableDailyWidth / 2),
                                        1: FixedColumnWidth(
                                            _dataTableDailyWidth / 2),
                                      },
                                      border:
                                          TableBorder.all(color: Colors.grey),
                                      children: [
                                        buildRowRight(
                                          _labelTotalSold,
                                          FormatterConvert().currencyShow(
                                              snapshot.data!['totalSale']),
                                        ),
                                      ]),

                                  ///TAHSİLAT BÖLÜMÜ
                                  Container(
                                    width: double.infinity,
                                    color: context.extensionDisableColor,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      _labelCollectionHeader,
                                      style: context.theme.titleMedium!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                  Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(
                                          _dataTableDailyWidth / 2),
                                      1: FixedColumnWidth(
                                          _dataTableDailyWidth / 2),
                                    },
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      buildRowRight(
                                        _labelTotalCollectionBySale,
                                        FormatterConvert().currencyShow(snapshot
                                            .data!['totalCollectionBySale']),
                                      ),
                                      buildRowRight(
                                        _labelReceivePaymant,
                                        FormatterConvert().currencyShow(snapshot
                                            .data!['totalCollectionLate']),
                                      ),
                                      buildRowRight(
                                        _labelTotalTableHeader,
                                        FormatterConvert().currencyShow(
                                            snapshot.data!['totalCollection']),
                                      ),
                                    ],
                                  ),

                                  ///ÖDEMELER BÖLÜMÜ
                                  Container(
                                    width: double.infinity,
                                    color: context.extensionDisableColor,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      _labelPaymentHeader,
                                      style: context.theme.titleMedium!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                  Table(
                                      columnWidths: {
                                        0: FixedColumnWidth(
                                            _dataTableDailyWidth / 2),
                                        1: FixedColumnWidth(
                                            _dataTableDailyWidth / 2),
                                      },
                                      border:
                                          TableBorder.all(color: Colors.grey),
                                      children: [
                                        buildRowRight(
                                          _labelTotalPayment,
                                          FormatterConvert().currencyShow(
                                              snapshot.data!['totalPayment']),
                                        ),
                                      ]),
                                ],
                              ),
                            );
                          } else {
                            return widgetShareCircularProgress(context);
                          }
                        }),
                    StreamBuilder<Map<String, num>>(
                      stream:
                          _blocCaseSnapshot.getStreamCalculateCashBoxSnapshoot,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && !snapshot.hasError) {
                          return Container(
                            width: _dataTableDailyWidth,
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                ///KASA BAŞLIK
                                Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade600,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    _labelCashBoxHeader,
                                    style: context.theme.headline6!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                                Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(
                                          _dataTableDailyWidth / 2),
                                      1: FixedColumnWidth(
                                          _dataTableDailyWidth / 2),
                                    },
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      buildRowRight(
                                        _labelCashSnapshoot,
                                        FormatterConvert().currencyShow(
                                            snapshot.data!['snapshootCash']),
                                      ),
                                      buildRowRight(
                                        _labelBankSnapshoot,
                                        FormatterConvert().currencyShow(
                                            snapshot.data!['snapshootBank']),
                                      ),
                                      buildRowRight(
                                        _labelTotalTableHeader,
                                        FormatterConvert().currencyShow(
                                            snapshot.data!['snapshootTotal']),
                                      ),
                                    ]),
                              ],
                            ),
                          );
                        } else {
                          return widgetShareCircularProgress(context);
                        }
                      },
                    ),

                    ///KAR SERMAYE
                    StreamBuilder<Map<String, num>>(
                      stream:
                          _blocCaseSnapshot.getStreamCalculateGeneralSituation,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && !snapshot.hasError) {
                          return Container(
                            width: _dataTableDailyWidth,
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                ///KAR SERMAYE
                                Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade600,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    _labelGeneralSituation,
                                    style: context.theme.headline6!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                                Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(
                                          _dataTableDailyWidth / 2),
                                      1: FixedColumnWidth(
                                          _dataTableDailyWidth / 2),
                                    },
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      buildRowRight(
                                        _labelProfit,
                                        FormatterConvert().currencyShow(
                                            snapshot.data!['totalProfit']),
                                      ),
                                      buildRowRight(
                                        _labelCapital,
                                        FormatterConvert().currencyShow(
                                            snapshot.data!['totalStockPrice']),
                                      ),
                                    ]),
                              ],
                            ),
                          );
                        } else {
                          return widgetShareCircularProgress(context);
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Tahsilat bölümü
  widgetCollectionSection() {
    return Container(
      width: _responsiveWidth,
      constraints: BoxConstraints(minHeight: _shareHeightCard),
      child: Card(
        elevation: 10,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
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
                child: StreamBuilder<Map<String, double>>(
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.hasError) {
                      return Wrap(
                          alignment: WrapAlignment.center,
                          runSpacing: context.extensionWrapSpacing20(),
                          spacing: 50,
                          direction: Axis.horizontal,
                          children: [
                            ///Tahsil Edilen
                            widgetShareChart({
                              'Nakit': snapshot.data!['Nakit']!,
                              'Banka': snapshot.data!['Banka']!
                            }, [
                              Colors.amberAccent,
                              Colors.grey.shade400,
                            ], _labelCollected, true,
                                labelRow: true, totalValue: true),

                            widgetShareChart({
                              'Kalan': snapshot.data!['Kalan']!,
                            }, [
                              Colors.red,
                            ], _labelCollectionWill, false, labelRow: false),

                            widgetShareChart({
                              'Toplam': snapshot.data!['Toplam']!,
                            }, [
                              Colors.green,
                            ], _labelTotal, false, labelRow: false),
                          ]);
                    } else {
                      return widgetShareCircularProgress(context);
                    }
                  },
                  stream: _blocCaseSnapshot.getStreamCollection,
                )),
          ],
        ),
      ),
    );
  }

  ///Ödeme Bölümü
  widgetPaymentSection() {
    return Container(
      width: _responsiveWidth,
      constraints: BoxConstraints(minHeight: _shareHeightCard),
      child: Card(
        elevation: 10,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
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
              child: StreamBuilder<Map<String, num>>(
                  stream: _blocCaseSnapshot.getStreamPayment,
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
                              'Nakit': snapshot.data!['Nakit']!.toDouble(),
                              'Banka': snapshot.data!['Banka']!.toDouble(),
                            }, [
                              Colors.amberAccent,
                              Colors.grey.shade400,
                            ], _labelPaid, true,
                                labelRow: true, totalValue: true),

                            ///Yapılacak Ödemeler
                            widgetShareChart({
                              'Kalan': snapshot.data!['Kalan']!.toDouble(),
                            }, [
                              Colors.red,
                            ], _labelPayable, false, labelRow: false),

                            ///Toplam Ödemeler
                            widgetShareChart({
                              'Toplam': snapshot.data!['Toplam']!.toDouble(),
                            }, [
                              Colors.green,
                            ], _labelTotal, false, labelRow: false),
                          ]);
                    } else {
                      return widgetShareCircularProgress(context);
                    }
                  }),
            ),
          ],
        ),
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
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            backgroundColor: Colors.amberAccent,
            color: context.extensionDisableColor,
          )),
    );
  }

  SizedBox widgetShareChart(Map<String, double> dataMap, List<Color> colorList,
      String labelHeader, bool showlabel,
      {bool labelRow = false, bool totalValue = false}) {
    num totalDouble = 0;
    if (totalValue) {
      dataMap.forEach((key, value) {
        totalDouble += value;
      });
    }

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
              //     print("gelendeger: $value");
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
          Visibility(
              visible: totalValue,
              child: Text(
                "Toplam: ${FormatterConvert().currencyShow(totalDouble)}",
                style: context.theme.titleSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  double getWidth() {
    double width;
    width = MediaQuery.of(context).size.width <= 400 ? 340 : 600;
    return width;
  }
}
