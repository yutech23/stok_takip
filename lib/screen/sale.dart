import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/widget_share/sale_custom_table.dart';
import '../modified_lib/searchfield.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/validation.dart';
import '../widget_share/sale_custom_table_row.dart';
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
/*------------ SON - (PARABİRİMİ SEÇİMİ)------------------- */

  final double _saleMinWidth = 360, _saleMaxWidth = 830;
  final double _shareWidth = 220, _shareheight = 40;
  int tableRowIndex = 0;
  final double _widthSearch = 330;
  int simpleIntInput = 0;
  final double _shareWidthPaymentSection = 200;

  Product? _selectProduct;
  final List<Product> _listAddProduct = <Product>[];

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
                            WidgetSaleList(
                              selectUnitOfCurrencySymbol:
                                  _selectUnitOfCurrencySymbol,
                              addProduct: _selectProduct,
                              listProduct: _listAddProduct,
                            )
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
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(100, 50)),
                            onPressed: () {
                              for (var element in _listAddProduct) {
                                print(
                                    "${element.productCode} : ${element.total} : ${element.sallingAmount}");
                              }
                            },
                            child: Text("Verileri Çek")),
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
            _selectProduct = await db
                .fetchProductDetailForSale(_controllerSearchProductCode.text);

            _listAddProduct.add(_selectProduct!);

            setState(() {});
          }
        },
        label: Text(_labelAddProduct),
      ),
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
}
