import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_limit.dart';
import 'package:stok_takip/widget_share/sale_custom_table.dart';
import 'package:stok_takip/widget_share/sale_custom_table_row.dart';
import '../modified_lib/searchfield.dart';
import '../utilities/convert_string_currency_digits.dart';
import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/format_decimal_3by3.dart';
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
/*???????????????? SON - (PARABİRİMİ SEÇİMİ) ???????????????? */

  final double _saleMinWidth = 360, _saleMaxWidth = 880;
  final double _shareWidth = 220, _shareheight = 40;
  int tableRowIndex = 0;
  final double _widthSearch = 330;
  int simpleIntInput = 0;
  final double _shareWidthPaymentSection = 250;
  final double _exchangeHeight = 70;
  Product? _selectProduct;
  final List<Product> _listAddProduct = <Product>[];

  /*-------------------BAŞLANGIÇ TOPLAM TUTAR BÖLMÜ-------------------- */
  final String _labelTotalprice = "Toplam Tutar";
  final String _labelTaxRate = "KDV %";
  final String _labelGeneralTotal = "Genel Toplam";
  double _totalSales = 0;

  /*????????????????????????????? SON ???????????????????????????????*/

  /*----------------BAŞLANGIÇ - ÖDEME ALINDIĞI YER------------- */
  final _valueNotifierPaid = ValueNotifier<double>(0);
  final _valueNotifierBalance = ValueNotifier<double>(0);
  final _valueNotifierButtonDateTimeState = ValueNotifier<bool>(false);
  final _valueNotifierCashValue = ValueNotifier<double>(0);
  final _valueNotifierBankCardValue = ValueNotifier<double>(0);
  final _valueNotifierEftAndHavaleValue = ValueNotifier<double>(0);
  final _controllerCashValue = TextEditingController();
  final _controllerBankValue = TextEditingController();
  final _controllerEftHavaleValue = TextEditingController();

  final String _balance = "Kalan Tutar : ";
  final String _cash = "Nakit İle Ödenen Tutar";
  final String _eftHavale = "EFT/HAVALE İle Ödenen Tutar";
  final String _bankCard = "Kart İle Ödenen Tutar";
  final String _labelPaymentInfo = "Ödeme Bilgileri";

  double _cashValue = 0, _bankValue = 0, _eftHavaleValue = 0;

  String _buttonDateTimeLabel = "Ödeme Tarihi Ekle";
  String? _selectDateTime;

/*??????????????????***SON - (ÖDEME ALINDIĞI YER)??????????????? */

  @override
  void initState() {
/*------------ BAŞLANGIÇ - PARABİRİMİ SEÇİMİ------------------- */
    _selectUnitOfCurrencySymbol = _mapUnitOfCurrency["Türkiye"]["symbol"];
    _selectUnitOfCurrencyAbridgment =
        _mapUnitOfCurrency["Türkiye"]["abridgment"];
    _colorBackgroundCurrencyUSD = context.extensionDefaultColor;
    _colorBackgroundCurrencyTRY = context.extensionDisableColor;
    _colorBackgroundCurrencyEUR = context.extensionDefaultColor;
/*?????????????????? SON - PARABİRİMİ SEÇİMİ ?????????????????? */

    ///Sayfa Başladığında bir kez veri çekiyor.yoksa 1 saat sonra çeker.
    exchangeRateService.getExchangeRate();

    ///Her 1 saat te bir döviz kurlarını çekiyor. Future Fonksiyon.
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
                            WidgetSaleTable(
                              selectUnitOfCurrencySymbol:
                                  _selectUnitOfCurrencySymbol,
                              listProduct: _listAddProduct,
                            ),
                          ],
                        ),
                        widgetTotalPriceSectionRow()
                      ]),
                  Wrap(
                      direction: Axis.vertical,
                      alignment: WrapAlignment.center,
                      runSpacing: context.extensionWrapSpacing10(),
                      spacing: context.extensionWrapSpacing20(),
                      children: [
                        widgetExchangeRate(),
                        widgetCurrencySelectSection(),
                        widgetTotalPriceSection(),
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
            return Container(
              width: _shareWidthPaymentSection,
              height: _exchangeHeight,
              decoration: BoxDecoration(
                  color: context.extensionDefaultColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "USD : ${FormatterConvert().pointToCommaAndDecimalTwo(snapshot.data!['USD']!, 4)}",
                      style: context.theme.headline6!
                          .copyWith(color: Colors.white)),
                  const Divider(
                      color: Colors.white,
                      endIndent: 20,
                      indent: 20,
                      height: 8),
                  Text(
                      "EUR : ${FormatterConvert().pointToCommaAndDecimalTwo(snapshot.data!['EUR']!, 4)}",
                      style: context.theme.headline6!
                          .copyWith(color: Colors.white)),
                ],
              ),
            );
          } else {
            //Veri Gelmedi zaman Ekrana Çıkan Nesne
            return Container(
              width: _shareWidthPaymentSection,
              height: _exchangeHeight,
              decoration: BoxDecoration(border: Border.all()),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
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
            //seçilen ürün kodunun özellikleri alınıyor.
            _selectProduct = await db
                .fetchProductDetailForSale(_controllerSearchProductCode.text);
            //nesne kıyaslaması yapılıyor. equatable kullanarak
            if (!_listAddProduct.contains(_selectProduct)) {
              SaleTableRow.valueNotifier.value.add(_selectProduct!);
              setState(() {
                _listAddProduct.add(_selectProduct!);
              });
            }
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
                partOfWidgetshareInkwellCurrency(
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
                partOfWidgetshareInkwellCurrency(
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
                partOfWidgetshareInkwellCurrency(
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
          left: 60,
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
  partOfWidgetshareInkwellCurrency(
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

  //Ödemenin Alındığı Yer - Ödeme Bilgisi
  widgetTotalPriceSection() {
    return ValueListenableBuilder<List<Product>>(
        valueListenable: SaleTableRow.valueNotifier,
        builder: (context, value, child) {
          ///Eklenen rünlerin Tutarlarını Topluyor
          _totalSales = 0;
          for (var element in value) {
            _totalSales = _totalSales + element.total!;
          }
          double? totalSalesWithoutTax;
          int? taxRate;
          if (value.isNotEmpty) {
            taxRate = value[0].taxRate;
            totalSalesWithoutTax = _totalSales / ((100 + taxRate) / 100);
          }
          calculateBalance();

          return Container(
            width: _shareWidthPaymentSection,
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 5,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widgetTotalPriceSectionHeader(
                        context, _labelPaymentInfo, Colors.grey),
                    widgetPaymentOptions(),
                  ]),
            ),
          );
        });
  }

  ///Toplam Tutar Ve Genel Tutarın hesaplandığı yer
  ///Normalde Sale_custom_table sayfasında yapılmalı ama ilk dizayna uymadığından
  ///sorun çıkıyor. Buradan ürünlerin toplam fiyatı alınıp Ödeme bilgiler bölümünden
  ///kalan tutarı hesaplama için yapılıyor. Ayrıca Calculatebalance Var Baştan
  ///dizayn
  widgetTotalPriceSectionRow() {
    return ValueListenableBuilder<List<Product>>(
        valueListenable: SaleTableRow.valueNotifier,
        builder: (context, value, child) {
          ///Eklenen rünlerin Tutarlarını Topluyor
          _totalSales = 0;
          for (var element in value) {
            _totalSales = _totalSales + element.total!;
          }
          double? totalSalesWithoutTax;
          int? taxRate;
          if (value.isNotEmpty) {
            taxRate = value[0].taxRate;
            totalSalesWithoutTax = _totalSales / ((100 + taxRate) / 100);
          }
          calculateBalance();

          return SizedBox(
            width: 570,
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 5,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                widgetTotalPriceSectionHeader1(
                    context, _labelTotalprice, context.extensionDefaultColor),
                widgetTotalPriceSectionBody1(context, totalSalesWithoutTax),
                widgetTotalPriceSectionHeaderKDV(
                    context, _labelTaxRate, context.extensionDefaultColor),
                widgetTotalPriceSectionBodyKDV(context, taxRate),
                widgetTotalPriceSectionHeader1(
                    context, _labelGeneralTotal, context.extensionDefaultColor),
                widgetTotalPriceSectionBody1(context, _totalSales),
              ]),
            ),
          );
        });
  }

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  Container widgetTotalPriceSectionHeader(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.headline6!.copyWith(color: Colors.white);
    return Container(
      alignment: Alignment.center,
      width: _shareWidthPaymentSection,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: styleHeader,
      ),
    );
  }

  /// EK -- Toplam Ödemelerin Gövde Bölümü
  Container widgetTotalPriceSectionBody(
      BuildContext context, num? totalSalesWithoutTax) {
    TextStyle styleBody = context.theme.headline6!;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        FormatterConvert().currencyShow(totalSalesWithoutTax ?? 0),
        style: styleBody,
      ),
    );
  }

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  widgetTotalPriceSectionHeader1(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.titleMedium!.copyWith(color: Colors.white);
    return Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Text(
          label,
          style: styleHeader,
        ),
      ),
    );
  }

  /// EK -- Toplam Ödemelerin Gövde Bölümü
  widgetTotalPriceSectionBody1(
      BuildContext context, num? totalSalesWithoutTax) {
    TextStyle styleBody = context.theme.titleMedium!;
    return Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          FormatterConvert().currencyShow(totalSalesWithoutTax ?? 0),
          style: styleBody,
        ),
      ),
    );
  }

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  widgetTotalPriceSectionHeaderKDV(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.titleMedium!.copyWith(color: Colors.white);
    return Expanded(
      flex: 1,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Text(
          label,
          style: styleHeader,
        ),
      ),
    );
  }

  /// EK -- Toplam Ödemelerin Gövde Bölümü
  widgetTotalPriceSectionBodyKDV(
      BuildContext context, num? totalSalesWithoutTax) {
    TextStyle styleBody = context.theme.titleMedium!;
    return Expanded(
      flex: 1,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          FormatterConvert().currencyShow(totalSalesWithoutTax ?? 0),
          style: styleBody,
        ),
      ),
    );
  }

  ///Ödeme verilerin alındığı yer.
  widgetPaymentOptions() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      alignment: Alignment.center,
      width: _shareWidthPaymentSection,
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        spacing: 5,
        children: [
          ///Nakit Ödeme
          sharedTextFormField(
            width: _shareWidthPaymentSection,
            labelText: _cash,
            controller: _controllerCashValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _valueNotifierCashValue.value =
                    FormatterConvert().commaToPointDouble(value);
              } else {
                _valueNotifierCashValue.value = 0;
              }
              calculateBalance();
            },
          ),
          //Bankakartı Ödeme Widget
          sharedTextFormField(
            width: _shareWidthPaymentSection,
            labelText: _bankCard,
            controller: _controllerBankValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _valueNotifierBankCardValue.value =
                    FormatterConvert().commaToPointDouble(value);
              } else {
                _valueNotifierBankCardValue.value = 0;
              }
              calculateBalance();
            },
          ),
          //EFTveHavale Ödeme Widget
          sharedTextFormField(
            width: _shareWidthPaymentSection,
            labelText: _eftHavale,
            controller: _controllerEftHavaleValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _valueNotifierEftAndHavaleValue.value =
                    FormatterConvert().commaToPointDouble(value);
              } else {
                _valueNotifierEftAndHavaleValue.value = 0;
              }
              calculateBalance();
            },
          ),

          ///kalan Tutar
          partOfwidgetValueListenableBuilderPaid(),

          ///İleri Ödeme Tarihi Belirlenen button.
          ///ValueListenableBuilder Buttonun aktif veya pasif olmasını belirliyor. Toplam Tutar girilmediyse Button Pasif Oluyor.
          ValueListenableBuilder(
            valueListenable: _valueNotifierButtonDateTimeState,
            builder: (context, value, child) {
              return Container(
                padding: context.extensionPadding10(),
                width: _shareWidthPaymentSection,
                child: shareWidget.widgetElevatedButton(
                    onPressedDoSomething:
                        _valueNotifierButtonDateTimeState.value
                            ? () async {
                                //Takvimden veri alınıyor.
                                final dataForCalendar = await pickDate();

                                if (dataForCalendar != null) {
                                  //
                                  _selectDateTime = DateFormat('dd/MM/yyyy')
                                      .format(dataForCalendar);
                                  setState(() {
                                    _buttonDateTimeLabel =
                                        "Seçilen Tarih \n ${dataForCalendar.day}/${dataForCalendar.month}/${dataForCalendar.year}";
                                  });
                                }
                              }
                            : null,
                    label: _buttonDateTimeLabel),
              );
            },
          ),
          widgetButtonSale(context)
        ],
      ),
    );
  }

  ///Kalan tutarı hesaplıyor ve ona göre ödeme tarihi butttonu aktif ediyor.
  void calculateBalance() {
    _valueNotifierBalance.value = _totalSales -
        _valueNotifierCashValue.value -
        _valueNotifierBankCardValue.value -
        _valueNotifierEftAndHavaleValue.value;
    if (_valueNotifierBalance.value > 0) {
      _buttonDateTimeLabel = "Ödeme Tarihi Seçiniz";
      _valueNotifierButtonDateTimeState.value = true;
    } else {
      _valueNotifierButtonDateTimeState.value = false;
    }
  }

  partOfwidgetValueListenableBuilderPaid() {
    return Container(
      alignment: Alignment.center,
      width: _shareWidthPaymentSection,
      child: ValueListenableBuilder<double>(
        valueListenable: _valueNotifierBalance,
        builder: (context, value, child) {
          return Container(
            padding: context.extensionPaddingHorizantal10(),
            alignment: Alignment.centerLeft,
            width: _shareWidthPaymentSection,
            height: 43,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: context.extensionDisableColor))),
            child: RichText(
              maxLines: 2,
              text: TextSpan(children: [
                TextSpan(
                  text: _balance,
                  style: context.theme.titleMedium!.copyWith(
                      color: context.extensionDefaultColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                TextSpan(
                    text:
                        "${FormatterConvert().currencyShow(value)} $_selectUnitOfCurrencySymbol",
                    style: context.theme.titleMedium!.copyWith(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1))
              ]),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Container widgetButtonSale(BuildContext context) {
    return Container(
      padding: context.extensionPaddingHorizantal10(),
      width: _shareWidthPaymentSection,
      child: shareWidget.widgetElevatedButton(
          onPressedDoSomething: () {
            /* ///Toplam Ödenen Miktar
                  _valueNotifierPaid.value =
                      _cashValue + _bankValue + _eftHavaleValue;

                  ///Kalan Borç
                  _valueNotifierBalance.value =
                      _totalSales - _valueNotifierPaid.value;

                  _valueNotifierButtonDateTimeState.value = false;

                  if (_valueNotifierBalance.value > 0) {
                    _buttonDateTimeLabel = "Ödeme Tarihi Seçiniz";
                    _valueNotifierButtonDateTimeState.value = true;
                  } */
          },
          label: "Satışı Tamamla"),
    );
  }

  sharedTextFormField(
      {required double width,
      required String labelText,
      required TextEditingController controller,
      required void Function(String)? onChanged,
      String? Function(String?)? validator}) {
    return Container(
      padding: context.extensionPadding10(),
      width: width,
      child: TextFormField(
        validator: validator,
        onChanged: onChanged,
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
          FormatterDecimalLimit(decimalRange: 2)
        ],
        keyboardType: TextInputType.number,
        style: context.theme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: context.extensionDefaultColor),
          isDense: true,
          errorBorder: const UnderlineInputBorder(borderSide: BorderSide()),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide()),
        ),
      ),
    );
  }

  ///Tarih seçildiği yer.
  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
      );
}
