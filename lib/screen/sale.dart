import 'dart:async';

import 'package:adaptivex/adaptivex.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:searchfield/searchfield.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/validation.dart';
import 'drawer.dart';

class ScreenSale extends StatefulWidget {
  const ScreenSale({super.key});

  @override
  State<ScreenSale> createState() => _ScreenSallingState();
}

class _ScreenSallingState extends State<ScreenSale> with Validation {
  final double _saleMinWidth = 360, _saleMaxWidth = 1000;
  final GlobalKey<FormState> _formKeySale = GlobalKey();
  final _controllerSearchCustomer = TextEditingController();
  final _focusSearchCustomer = FocusNode();
  final _controllerSearchProductCode = TextEditingController();
  final _focusSearchProductCode = FocusNode();

  final String _labelHeading = "Satış Ekranı";
  final String _labelNewCustomer = "Yeni Müşteri Ekle";
  final String _labelSearchCustomer =
      "Müşteri İsmini Veya Telefon Numarası Giriniz";
  final String _labelSearchProductCode = "Ürün Kodunu Seçiniz";
  final String _labelAddProduct = "Ürünü Ekle";
  List<bool>? _expanded;
  final List<Map<String, dynamic>> _sourceList = [];
  final List<DatatableHeader> _headers = [];
  final double _widthSearch = 360;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(hours: 1), (timer) {
      exchangeRateService.getExchangeRate();
    });
    _headers.add(DatatableHeader(
        text: "Ürün Kodu",
        value: "productCode",
        show: true,
        flex: 2,
        sortable: true,
        editable: false,
        textAlign: TextAlign.left));
    _headers.add(DatatableHeader(
        text: "Miktar",
        value: "amount",
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Fiyat",
        value: "price",
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Tutar",
        value: "total",
        show: true,
        sortable: true,
        textAlign: TextAlign.center));

    _expanded = List.generate(0, (index) => false);

    _sourceList.add({
      'productCode': 'erk-0001',
      'amount': '250',
      'price': '1500',
      'total': '250000'
    });
  }

  @override
  void dispose() {
    super.dispose();
    exchangeRateService.getStreamExchangeRate.close();
  }

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
            child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: context.extensionWrapSpacing10(),
                spacing: context.extensionWrapSpacing20(),
                children: [
                  Column(children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: context.extensionWrapSpacing20(),
                      runSpacing: context.extensionWrapSpacing10(),
                      children: [
                        widgetSearchFieldCustomer(),
                        widgetButtonNewCustomer(),
                        widgetSearchFieldProductCode(),
                        widgetButtonAddProduct(),
                        widgetProductTableAndUpdateTable()
                      ],
                    ),
                  ]),
                  widgetExchangeRate()
                ]),
          )),
        ));
  }

  ///Döviz Kurları Tablosu
  StreamBuilder<Map<String, double>> widgetExchangeRate() {
    return StreamBuilder<Map<String, double>>(
        initialData: const {'USD': 0, 'EUR': 0},
        stream: exchangeRateService.getStreamExchangeRate.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SizedBox(
              width: 150,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1)
                },
                border: TableBorder.all(
                  color: context.extensionDefaultColor,
                ),
                children: [
                  widgetTableRow(context, "USD", snapshot.data!['USD']),
                  widgetTableRow(context, "EURO", snapshot.data!['EUR']),
                ],
              ),
            );
          } else {
            //Veri Gelmedi zaman Ekrana Çıkan Nesne
            return Container(
              width: 150,
              decoration: BoxDecoration(border: Border.all()),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  ///Döviz Kurları Tablosu TableRow widgetı.
  TableRow widgetTableRow(
      BuildContext context, String exchangeRateName, double? exchangeRateUnit) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
            style:
                context.theme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            exchangeRateName),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
            textAlign: TextAlign.start,
            style:
                context.theme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
            exchangeRateUnit.toString()),
      )
    ]);
  }

  ///Müşteri Search Listesi
  widgetSearchFieldCustomer() {
    return SizedBox(
      width: _widthSearch,
      child: FutureBuilder<List<String>>(
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            return SearchField(
              validator: validateNotEmpty,
              controller: _controllerSearchCustomer,
              searchInputDecoration: InputDecoration(
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  label: Text(_labelSearchCustomer),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  )),
              suggestions: snapshot.data!.map((e) {
                return SearchFieldListItem(e);
              }).toList(),
              focusNode: _focusSearchCustomer,
              onSuggestionTap: (selectedValue) {
                _focusSearchCustomer.unfocus();
              },
              maxSuggestionsInViewPort: 6,
            );
          }
          return Container();
        },
        future: db.fetchCustomerAndPhone(),
      ),
    );
  }

  ///Yeni Müşteri Ekleme
  ElevatedButton widgetButtonNewCustomer() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(minimumSize: const Size(220, 60)),
      icon: const Icon(Icons.person_add),
      onPressed: () {
        exchangeRateService.getExchangeRate();
      },
      label: Text(_labelNewCustomer),
    );
  }

  ///Ürün Search Listesi
  widgetSearchFieldProductCode() {
    return SizedBox(
      width: _widthSearch,
      child: FutureBuilder<List<String>>(
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            return SearchField(
              validator: validateNotEmpty,
              controller: _controllerSearchProductCode,
              searchInputDecoration: InputDecoration(
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  label: Text(_labelSearchProductCode),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  )),
              suggestions: snapshot.data!.map((e) {
                return SearchFieldListItem(e);
              }).toList(),
              focusNode: _focusSearchProductCode,
              onSuggestionTap: (selectedValue) {
                _focusSearchProductCode.unfocus();
              },
              maxSuggestionsInViewPort: 6,
            );
          }
          return Container();
        },
        future: db.getProductCode(),
      ),
    );
  }

  ///Yeni Müşteri Ekleme
  ElevatedButton widgetButtonAddProduct() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(minimumSize: const Size(220, 60)),
      icon: const Icon(Icons.playlist_add),
      onPressed: () {
        print(_controllerSearchProductCode.text);
      },
      label: Text(_labelAddProduct),
    );
  }

/*   widgetTableCart(BuildContext context) {
    return Container(
      width: 800,
      height: 500,
      child: ExpandableTheme(
          data: ExpandableThemeData(context),
          child: ExpandableDataTable(
            headers: tableCartColumn(),
            rows: [tableCartRows()],
            visibleColumnCount: 5,
          )),
    );
  }

  List<ExpandableColumn<dynamic>> tableCartColumn() {
    List<ExpandableColumn<dynamic>> headers = [
      ExpandableColumn<int>(columnTitle: "Ürün Kodu", columnFlex: 3),
      ExpandableColumn<String>(columnTitle: "Miktar", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Fiyat", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Tutar", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Sil", columnFlex: 1),
    ];

    return headers;
  }

  ExpandableRow tableCartRows() {
    return ExpandableRow(cells: [
      ExpandableCell<int>(columnTitle: "Ürün Kodu", value: 23),
      ExpandableCell<String>(columnTitle: "Miktar", value: "Yusuf"),
      ExpandableCell<String>(columnTitle: "Fiyat", value: "200"),
      ExpandableCell<String>(columnTitle: "Tutar", value: "12"),
      ExpandableCell<Widget>(columnTitle: "Sil", value: Icon(Icons.delete)),
    ]);
  } */

  widgetProductTableAndUpdateTable() {
    return Container(
      width: 600,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(
        maxHeight: 600,
      ),
      child: Card(
          elevation: 5,
          shadowColor: Colors.black,
          clipBehavior: Clip.none,
          child: ResponsiveDatatable(
            headers: _headers,
            autoHeight: false,
            source: _sourceList,
            headerDecoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                border: const Border(
                    bottom: BorderSide(color: Colors.red, width: 1))),
            selectedDecoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.green[300]!, width: 1)),
              color: Colors.green,
            ),
            headerTextStyle:
                context.theme.titleMedium!.copyWith(color: Colors.white),
            rowTextStyle: context.theme.titleSmall,
            selectedTextStyle: TextStyle(color: Colors.white),
          )),
    );
  }

  Divider widgetDivider() {
    return const Divider(color: Colors.blueGrey, thickness: 2.5, height: 40);
  }
}
