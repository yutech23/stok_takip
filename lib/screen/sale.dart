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
  final GlobalKey<FormState> _formKeySale = GlobalKey();
  final _controllerSearchCustomer = TextEditingController();
  final _focusSearchCustomer = FocusNode();
  final _controllerSearchProductCode = TextEditingController();
  final _focusSearchProductCode = FocusNode();
  final _valueNotifierListTotal = ValueNotifier<List<double>>([]);

  bool isLoading = false;

  final String _labelHeading = "Satış Ekranı";
  final String _labelNewCustomer = "Yeni Müşteri Ekle";
  final String _labelSearchCustomer = "Müşteri İsmi Veya Telefon Numarası ";
  final String _labelSearchProductCode = "Ürün Kodunu Seçiniz";
  final String _labelAddProduct = "Ürünü Ekle";

  /*------------ BAŞLANGIÇ - PARABİRİMİ SEÇİMİ------------------- */
  late Color _colorBackgroundCurrencyUSD;
  late Color _colorBackgroundCurrencyTRY;
  late Color _colorBackgroundCurrencyEUR;
  late String _selectUnitOfCurrencySymbol;
  late String _selectUnitOfCurrencyAbridgment;
  final String _labelCurrencySelect = "Para Birimi Seçiniz";
  final Map<String, dynamic> _mapUnitOfCurrency = {
    "Türkiye": {"symbol": "₺", "abridgment": "TL"},
    "amerika": {"symbol": '\$', "abridgment": "USD"},
    "avrupa": {"symbol": '€', "abridgment": "EURO"}
  };
/*------------ SON - PARABİRİMİ SEÇİMİ------------------- */
  final double _saleMinWidth = 360, _saleMaxWidth = 830;
  final double _shareWidth = 220, _shareheight = 40;
  final double _tableWidth = 570, _tableHeight = 500;

  List<TextEditingController> _listTextEditingControllerPrice =
      <TextEditingController>[];

  List<TextEditingController> _listTextEditingControllerAmount =
      <TextEditingController>[];

  List<Color?> __listTableRowBackgroundColor = <Color>[];

  List<Widget> _listRowTable = <Widget>[];

  List<Product> _listProductDetailByTable = <Product>[];

  List<Row> _listRow = <Row>[];

  int tableRowIndex = 0;

  final double _widthSearch = 330;
  int simpleIntInput = 0;
  final double _shareWidthPaymentSection = 200;

  @override
  void initState() {
/*------------ BAŞLANGIÇ - PARABİRİMİ SEÇİMİ------------------- */
    _selectUnitOfCurrencySymbol = _mapUnitOfCurrency["Türkiye"]["symbol"];
    _selectUnitOfCurrencyAbridgment =
        _mapUnitOfCurrency["Türkiye"]["abridgment"];
    _colorBackgroundCurrencyUSD = context.extensionDefaultColor;
    _colorBackgroundCurrencyTRY = context.extensionDisableColor;
    _colorBackgroundCurrencyEUR = context.extensionDefaultColor;
/*------------ SON - PARABİRİMİ SEÇİMİ------------------- */

    exchangeRateService.getExchangeRate();
    Timer.periodic(const Duration(hours: 1), (timer) {
      exchangeRateService.getExchangeRate();
    });
    super.initState();
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
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      verticalDirection: VerticalDirection.down,
                      children: [
                        Wrap(
                          verticalDirection: VerticalDirection.down,
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
                  Wrap(
                      direction: Axis.vertical,
                      alignment: WrapAlignment.center,
                      runSpacing: context.extensionWrapSpacing10(),
                      spacing: context.extensionWrapSpacing20(),
                      children: [
                        widgetExchangeRate(),
                        widgetCurrencySelectSection(),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                              onPressed: () {
                                print("döngü");
                                for (var i = 0;
                                    i < _listProductDetailByTable.length;
                                    i++) {
                                  print(_listProductDetailByTable[i].total);
                                }

                                setState(() {
                                  _listProductDetailByTable;
                                });
                                print("---------");
                              },
                              child: Text("Veri Çek")),
                        ),
                      ]),
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
              width: _shareWidthPaymentSection,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1)
                },
                border: TableBorder.all(
                  color: context.extensionDefaultColor,
                ),
                children: [
                  widgetExchangeTableRow(context, "USD", snapshot.data!['USD']),
                  widgetExchangeTableRow(
                      context, "EURO", snapshot.data!['EUR']),
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
  TableRow widgetExchangeTableRow(
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

  ///Yeni Ürün Ekleme
  widgetButtonAddProduct() {
    return SizedBox(
      height: _shareheight,
      width: _shareWidth,
      child: ElevatedButton.icon(
        // style: ElevatedButton.styleFrom(minimumSize: const Size(220, 40)),
        icon: const Icon(Icons.playlist_add),

        onPressed: () async {
          if (_controllerSearchProductCode.text.isNotEmpty) {
            Product? selectProductDetail = await db
                .fetchProductDetailForSale(_controllerSearchProductCode.text);

            selectProductDetail!.sallingAmount = 1;
            selectProductDetail.total =
                selectProductDetail.currentSallingPriceWith;

            ///productların değerlerinin tutluldu liste
            _listProductDetailByTable.add(selectProductDetail);

            ///İlk miktar 1 otamatik giriliyor ve Satış fiyatı üzerine
            ///KDV ekleniyor ve oda veri olarak gönderiliyor.
            /*   _listTextEditingControllerAmount.add(TextEditingController(
                text: selectProductDetail.sallingAmount.toString()));

            _listTextEditingControllerPrice.add(TextEditingController(
                text: selectProductDetail.currentSallingPriceWith!
                    .toStringAsFixed(2))); */

            __listTableRowBackgroundColor.add(Colors.white);

            /* _valueNotifierListTotal.value =
                List.of(_valueNotifierListTotal.value)
                  ..add(selectProductDetail.total!); */

            setState(() {
              /* _listRowTable.add(rowListView(
                  selectProductDetail,
                  _listTextEditingControllerAmount[tableRowIndex],
                  _listTextEditingControllerPrice[tableRowIndex],
                  tableRowIndex));
                   */
              _listRowTable.add(rowListView(
                  selectProductDetail,
                  TextEditingController(
                      text: selectProductDetail.sallingAmount.toString()),
                  TextEditingController(
                      text: selectProductDetail.currentSallingPriceWith!
                          .toStringAsFixed(2)),
                  tableRowIndex));

              _listRow.add(rowTest(
                  selectProductDetail,
                  TextEditingController(
                      text: selectProductDetail.sallingAmount.toString()),
                  TextEditingController(
                      text: selectProductDetail.currentSallingPriceWith!
                          .toStringAsFixed(2)),
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
      width: _tableWidth,
      height: _tableHeight,
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
            flex: 1,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(delete, style: defaultStyle)),
          ),
          Expanded(
            flex: 4,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(productName, style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(amount, style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text("$price ($_selectUnitOfCurrencySymbol)",
                    style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text("$total ($_selectUnitOfCurrencySymbol)",
                    style: defaultStyle)),
          ),
        ],
      ),
    );
  }

  ///Ek-Ürün Ekleme Tablo Satır Sayısı
  rowListView(
      Product selectProductDetail,
      TextEditingController controllerAmount,
      TextEditingController controllerPrice,
      int index) {
    print(_listProductDetailByTable[index].total);

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
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            color: __listTableRowBackgroundColor[index],
            border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 1.5))),
        child: Row(
          children: [
            const Expanded(
                flex: 1,
                child: Center(
                  child: Icon(Icons.delete),
                )),
            Expanded(
                flex: 4,
                child: Container(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(selectProductDetail.productCode))),
            Expanded(
                flex: 2,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: rowListviewTextFormFieldAmount(
                        controllerAmount, index))),
            Expanded(
              flex: 2,
              child: Container(
                  child: rowListviewTextFormFieldPrice(controllerPrice, index)),
            ),
            Expanded(
              flex: 2,
              child: Container(
                  alignment: Alignment.center,
                  child: Text(selectProductDetail.total!.toStringAsFixed(2))),
            ),
          ],
        ),
      ),
    );
  }

//Ek- Ürün Ekleme Tablosu Miktar TextField
  TextFormField rowListviewTextFormFieldAmount(
      TextEditingController controllerAmount, int index) {
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
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      onChanged: (value) {
        setState(() {
          _listProductDetailByTable[index].sallingAmount = int.parse(value);

          double total = int.parse(value) *
              _listProductDetailByTable[index].currentSallingPriceWith!;

          _listProductDetailByTable[index].total = total;
        });
      },
    );
  }

//Ek- Ürün Ekleme Tablosu Fİyat TextField
  TextFormField rowListviewTextFormFieldPrice(
      TextEditingController controllerAmount, int index) {
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
      inputFormatters: [FormatterDecimalThreeByThree()],
      onChanged: (value) {
        _listProductDetailByTable[index].currentSallingPriceWith =
            double.parse(value.replaceAll(".", ""));

        print(_listProductDetailByTable[index].currentSallingPriceWith);
      },
    );
  }

  ///Para birimin seçildi yer
  widgetCurrencySelectSection() {
    return Stack(
      children: [
        Positioned(
          child: Container(
            alignment: Alignment.center,
            width: _shareWidthPaymentSection,
            height: 50,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: context.extensionRadiusDefault10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                shareInkwellCurrency(
                    onTap: () {
                      setState(() {
                        _selectUnitOfCurrencyAbridgment =
                            _mapUnitOfCurrency["Türkiye"]["abridgment"];
                        _selectUnitOfCurrencySymbol =
                            _mapUnitOfCurrency["Türkiye"]["symbol"];
                        _colorBackgroundCurrencyTRY =
                            context.extensionDisableColor;
                        _colorBackgroundCurrencyUSD =
                            context.extensionDefaultColor;
                        _colorBackgroundCurrencyEUR =
                            context.extensionDefaultColor;
                      });
                    },
                    sembol: _mapUnitOfCurrency["Türkiye"]["symbol"],
                    backgroundColor: _colorBackgroundCurrencyTRY),
                const SizedBox(
                  width: 2,
                ),
                shareInkwellCurrency(
                    onTap: () {
                      setState(() {
                        _selectUnitOfCurrencyAbridgment =
                            _mapUnitOfCurrency["amerika"]["abridgment"];
                        _selectUnitOfCurrencySymbol =
                            _mapUnitOfCurrency["amerika"]["symbol"];
                        _colorBackgroundCurrencyTRY =
                            context.extensionDefaultColor;
                        _colorBackgroundCurrencyUSD =
                            context.extensionDisableColor;
                        _colorBackgroundCurrencyEUR =
                            context.extensionDefaultColor;
                      });
                    },
                    sembol: _mapUnitOfCurrency["amerika"]["symbol"],
                    backgroundColor: _colorBackgroundCurrencyUSD),
                const SizedBox(
                  width: 2,
                ),
                shareInkwellCurrency(
                    onTap: () {
                      setState(() {
                        _selectUnitOfCurrencyAbridgment =
                            _mapUnitOfCurrency["avrupa"]["abridgment"];
                        _selectUnitOfCurrencySymbol =
                            _mapUnitOfCurrency["avrupa"]["symbol"];
                        _colorBackgroundCurrencyTRY =
                            context.extensionDefaultColor;
                        _colorBackgroundCurrencyUSD =
                            context.extensionDefaultColor;
                        _colorBackgroundCurrencyEUR =
                            context.extensionDisableColor;
                      });
                    },
                    sembol: _mapUnitOfCurrency["avrupa"]["symbol"],
                    backgroundColor: _colorBackgroundCurrencyEUR),
              ],
            ),
          ),
        ),
        Positioned(
          left: 34,
          child: Container(
            padding: EdgeInsets.zero,
            color: Colors.white,
            child: Text(
              textAlign: TextAlign.center,
              _labelCurrencySelect,
              style: context.theme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.extensionDefaultColor),
            ),
          ),
        ),
      ],
    );
  }

  ///Ek- Parabirimi Seçildiği yer için yardımcı Widget
  shareInkwellCurrency(
      {required void Function()? onTap,
      required String sembol,
      Color? backgroundColor}) {
    return InkWell(
        focusNode: FocusNode(skipTraversal: true),
        onTap: onTap,
        child: Container(
          color: backgroundColor,
          alignment: Alignment.center,
          width: 30,
          height: 30,
          child: Text(
            sembol,
            style: context.theme.headline5!.copyWith(
              color: Colors.white,
            ),
          ),
        ));
  }

  Divider widgetDivider() {
    return const Divider(color: Colors.blueGrey, thickness: 2.5, height: 40);
  }

  rowTest(Product selectProductDetail, TextEditingController controllerAmount,
      TextEditingController controllerPrice, int index) {
    return Row(
      children: [
        const Expanded(
            flex: 1,
            child: Center(
              child: Icon(Icons.delete),
            )),
        Expanded(
            flex: 4,
            child: Container(
                padding: const EdgeInsets.only(left: 5),
                child: Text(selectProductDetail.productCode))),
        Expanded(
            flex: 2,
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child:
                    rowListviewTextFormFieldAmount(controllerAmount, index))),
        Expanded(
          flex: 2,
          child: Container(
              child: rowListviewTextFormFieldPrice(controllerPrice, index)),
        ),
        Expanded(
          flex: 2,
          child: Container(
              alignment: Alignment.center,
              child: Text(selectProductDetail.total!.toStringAsFixed(2))),
        ),
      ],
    );
  }
}
