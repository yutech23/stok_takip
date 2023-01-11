import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_decimal_3by3.dart';
import '../modified_lib/searchfield.dart';
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
  final String _labelSearchCustomer = "Müşteri İsmi Veya Telefon Numarası ";
  final String _labelSearchProductCode = "Ürün Kodunu Seçiniz";
  final String _labelAddProduct = "Ürünü Ekle";

  final double _shareWidth = 220, _shareheight = 40;
  final List<TextEditingController> _listTextEditingControllerPrice =
      <TextEditingController>[];

  final List<TextEditingController> _listTextEditingControllerAmount =
      <TextEditingController>[];

  List<Color?> __listTableRowBackgroundColor = <Color>[];

  List<Widget> _listRowTable = <Widget>[];

  int tableRowIndex = 0;

  final double _widthSearch = 360;
  int simpleIntInput = 0;
  @override
  void initState() {
    super.initState();
    exchangeRateService.getExchangeRate();
    Timer.periodic(const Duration(hours: 1), (timer) {
      exchangeRateService.getExchangeRate();
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
                        widgetProductSaleList(),
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
              searchHeight: _shareheight,
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
  widgetButtonNewCustomer() {
    return SizedBox(
      height: _shareheight,
      width: _shareWidth,
      child: ElevatedButton.icon(
        //  style: ElevatedButton.styleFrom(minimumSize: const Size(220, 48)),
        icon: const Icon(Icons.person_add),
        onPressed: () {},
        label: Text(_labelNewCustomer),
      ),
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
              searchHeight: _shareheight,
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
  widgetButtonAddProduct() {
    return SizedBox(
      height: _shareheight,
      width: _shareWidth,
      child: ElevatedButton.icon(
        // style: ElevatedButton.styleFrom(minimumSize: const Size(220, 40)),
        icon: const Icon(Icons.playlist_add),

        onPressed: () async {
          if (_controllerSearchProductCode.text.isNotEmpty) {
            Product? selectProductDetail =
                await db.getProductDetail(_controllerSearchProductCode.text);

            double priceWithTax =
                (selectProductDetail!.currentSallingPriceWithoutTax! *
                    (1 + (selectProductDetail.taxRate / 100)));
            _listTextEditingControllerAmount
                .add(TextEditingController(text: "1"));
            _listTextEditingControllerPrice
                .add(TextEditingController(text: priceWithTax.toString()));
            __listTableRowBackgroundColor.add(Colors.white);

            setState(() {
              _listRowTable.add(rowListView(
                  selectProductDetail.productCode,
                  _listTextEditingControllerAmount[tableRowIndex],
                  _listTextEditingControllerPrice[tableRowIndex],
                  tableRowIndex));
            });
            tableRowIndex++;
          }
        },
        label: Text(_labelAddProduct),
      ),
    );
  }

  ///Ürün Ekleme Tablosu
  widgetProductSaleList() {
    return SingleChildScrollView(
        child: Container(
      width: 600,
      height: 500,
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            columnHeaderListView(
                "Ürün Kodu", "Miktar", "Fiyat", "Tutar", "Sil"),
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    return _listRowTable[index];
                  },
                  itemCount: _listRowTable.length),
            ),
          ],
        ),
      ),
    ));
  }

  ///Ek Ürün Ekleme Tablo Başlık Bölümü
  columnHeaderListView(String productName, String amount, String price,
      String total, String delete) {
    const TextStyle defaultStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );
    const EdgeInsets paddingAll = EdgeInsets.all(5);
    return Container(
      color: context.extensionDefaultColor,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(productName, style: defaultStyle)),
          ),
          Expanded(
            flex: 1,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(amount, style: defaultStyle)),
          ),
          Expanded(
            flex: 1,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(price, style: defaultStyle)),
          ),
          Expanded(
            flex: 1,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(total, style: defaultStyle)),
          ),
          Expanded(
            flex: 1,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(delete, style: defaultStyle)),
          ),
        ],
      ),
    );
  }

  ///Ek-Ürün Ekleme Tablo Satır Sayısı
  rowListView(String productName, TextEditingController controllerAmount,
      TextEditingController controllerPrice, int index) {
    double? total;

    total = 1;
    return InkWell(
      /*   onTap: () {
        setState(() {
          __listTableRowBackgroundColor[index] = Colors.amber;
        });
        print(__listTableRowBackgroundColor[index]);
      },
      onHover: (value) {
        setState(() {
          if (value) {
            __listTableRowBackgroundColor[index] = Colors.grey;
            print(__listTableRowBackgroundColor[index]);
          }
        });
      }, */
      child: Container(
        height: 35,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: __listTableRowBackgroundColor[index],
            border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 1.5))),
        child: Row(
          children: [
            Expanded(flex: 2, child: Container(child: Text(productName))),
            Expanded(
                flex: 1,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: rowListviewTextFormFieldAmount(controllerAmount))),
            Expanded(
              flex: 1,
              child: Container(
                  child: rowListviewTextFormFieldPrice(controllerPrice)),
            ),
            Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(total.toStringAsFixed(2)),
                )),
            const Expanded(
                flex: 1,
                child: Center(
                  child: Icon(Icons.delete),
                ))
          ],
        ),
      ),
    );
  }

//Ek- Ürün Ekleme Tablosu Miktar TextField
  TextFormField rowListviewTextFormFieldAmount(
      TextEditingController controllerAmount) {
    return TextFormField(
        controller: controllerAmount,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLines: 1,
        maxLength: 3,
        decoration: const InputDecoration(
            counterText: "",
            contentPadding: EdgeInsets.zero,
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            border: OutlineInputBorder()),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]);
  }

//Ek- Ürün Ekleme Tablosu Fİyat TextField
  TextFormField rowListviewTextFormFieldPrice(
      TextEditingController controllerAmount) {
    return TextFormField(
        controller: controllerAmount,
        textAlign: TextAlign.left,
        keyboardType: TextInputType.number,
        maxLines: 1,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.only(left: 3),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            border: OutlineInputBorder()),
        inputFormatters: [FormatterDecimalThreeByThree()]);
  }

  Divider widgetDivider() {
    return const Divider(color: Colors.blueGrey, thickness: 2.5, height: 40);
  }
}
