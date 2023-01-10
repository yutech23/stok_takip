import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:searchfield/searchfield.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_decimal_3by3.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import 'package:adaptivex/adaptivex.dart';
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

  List<bool>? _expanded = [];
  List<Map<String, dynamic>> _sourceList = [];
  List<Map<String, dynamic>> _selecteds = [];

  late List<DatatableHeader> _headers = [];

  List<TextEditingController> _listTextEditingControllerPrice =
      <TextEditingController>[];

  List<TextEditingController> _listTextEditingControllerAmount =
      <TextEditingController>[];

  TextEditingController _controllerAmount = TextEditingController();
  TextEditingController _controllerPrice = TextEditingController();
  final double _widthSearch = 360;
  int simpleIntInput = 0;
  @override
  void initState() {
    super.initState();
    exchangeRateService.getExchangeRate();
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
        flex: 1,
        editable: true,

        /*     sourceBuilder: (value, row) {
          print(value);
           return Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TextFormField(
             
                  textAlign: TextAlign.center,
                  initialValue: "1",
                  decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      isDense: true,
                      border: OutlineInputBorder()),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ]));
        }, */
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Fiyat",
        value: "price",
        editable: true,

        /*  sourceBuilder: (value, row) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: TextFormField(
              decoration: const InputDecoration(
                  isDense: true, border: OutlineInputBorder()),
              inputFormatters: [FormatterDecimalThreeByThree()],
            ),
          );
        }, */
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Tutar",
        value: "total",
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _listTextEditingControllerAmount.add(TextEditingController());
    _listTextEditingControllerPrice.add(TextEditingController());
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
                        widgetProductSaleList()
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
      onPressed: () {},
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
      onPressed: () async {
        if (_controllerSearchProductCode.text.isNotEmpty) {
          Product? selectProductDetail =
              await db.getProductDetail(_controllerSearchProductCode.text);

          setState(() {
            _sourceList.add({
              'productCode': selectProductDetail!.productCode,
              'price': selectProductDetail.currentSallingPriceWithoutTax,
              'total': '2000'
            });
            _expanded!.add(false);
          });
        }
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
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 600),
            child: Card(
                elevation: 5,
                shadowColor: Colors.black,
                clipBehavior: Clip.none,
                child: ResponsiveDatatable(
                  ///Kendim Ekledim Row Yüksekli Sadece Masaüstü Listesinde
                  rowHeight: 60,
                  title: TextButton.icon(
                    onPressed: () => {},
                    icon: Icon(Icons.add),
                    label: Text("new item"),
                  ),
                  reponseScreenSizes: [ScreenSize.xs],
                  headers: _headers,
                  source: _sourceList,
                  selecteds: _selecteds,
                  autoHeight: false,
                  /* dropContainer: (data) {
                    if (int.tryParse(data['id'].toString())!.isEven) {
                      return Text("is Even");
                    }
                    return _DropDownContainer(data: data);
                  }, */
                  /*  onTabRow: (data) {
                    print(data);
                  }, */
                  expanded: _expanded,
                  /* sortAscending: _sortAscending,
                  sortColumn: _sortColumn,
                  onSelect: (value, item) {
                    print("$value  $item ");
                    if (value!) {
                      setState(() => _selecteds.add(item));
                    } else {
                      setState(
                          () => _selecteds.removeAt(_selecteds.indexOf(item)));
                    }
                  }, */

                  headerDecoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      border: const Border(
                          bottom: BorderSide(color: Colors.red, width: 1))),
                  selectedDecoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.green[300]!, width: 1)),
                    color: Colors.green,
                  ),
                  headerTextStyle:
                      context.theme.titleMedium!.copyWith(color: Colors.white),
                  rowTextStyle: context.theme.titleSmall,
                  selectedTextStyle: TextStyle(color: Colors.white),
                )),
          ),
        ]));
  }

  Divider widgetDivider() {
    return const Divider(color: Colors.blueGrey, thickness: 2.5, height: 40);
  }

  widgetProductSaleList() {
    return SingleChildScrollView(
        child: Container(
      width: 600,
      height: 500,
      child: ListView.separated(
          itemBuilder: (context, index) {
            return rowListView(
                "ERK233-233", _controllerAmount, _controllerPrice);
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: 5),
    ));
  }

  Row rowListView(String productName, TextEditingController controllerAmount,
      TextEditingController controllerPrice) {
    double? total;
    /*   total = double.parse(controllerAmount.text) *
        double.parse(controllerPrice.text); */
    total = 1;
    return Row(
      children: [
        Flexible(
            child: Column(
          children: [Text(productName)],
        )),
        Flexible(
            child: Column(
          children: [rowListviewTextFormField(controllerAmount)],
        )),
        Flexible(
            child: Column(
          children: [rowListviewTextFormField(controllerPrice)],
        )),
        Flexible(
            child: Column(
          children: [Text(total.toStringAsFixed(2))],
        ))
      ],
    );
  }

  TextFormField rowListviewTextFormField(
      TextEditingController controllerAmount) {
    return TextFormField(
        controller: controllerAmount,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            isDense: true,
            border: OutlineInputBorder()),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]);
  }
}
