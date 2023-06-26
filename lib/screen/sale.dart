import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:searchfield/searchfield.dart';
import 'package:stok_takip/bloc/bloc_invoice.dart';
import 'package:stok_takip/bloc/bloc_sale.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/service/exchange_rate.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/popup/popup_add_customer.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_3by3_financial.dart';
import 'package:stok_takip/widget_share/sale_custom_table.dart';
import 'package:turkish/turkish.dart';
import '../utilities/share_func.dart';
import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/validation.dart';
import 'drawer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

@RoutePage()
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
  final String _labelNewCustomer = "Yeni Müşteri";
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

  /*-----------------------BAŞLANGIÇ - SATIŞ TABLO ------------------ */

  final List<Product> _listAddProduct = <Product>[];
  late BlocSale blocSale;

  /*?????????????????????? SON - SATIŞ TABLO ?????????????????????????*/

  late double _widthScreen;
  final double _shareHeight = 40;
  final double _searchItemHeight = 30;
  int tableRowIndex = 0;
  int simpleIntInput = 0;
  final double _shareWidthPaymentSection = 340;
  final double _exchangeHeight = 70;
  Product? _selectProduct;
  late double _widthMediaQuery;
  final double _paymentCardHeight = 420;

  /*----------------BAŞLANGIÇ - ÖDEME ALINDIĞI YER------------- */

  final _valueNotifierButtonDateTimeState = ValueNotifier<bool>(false);
  final _controllerCashValue = TextEditingController();
  final _controllerBankValue = TextEditingController();
  final _controllerEftHavaleValue = TextEditingController();

  final String _balance = "Kalan Tutar : ";
  final String _cash = "Nakit İle Ödenen Tutar";
  final String _eftHavale = "EFT/HAVALE İle Ödenen Tutar";
  final String _bankCard = "Kart İle Ödenen Tutar";
  final String _labelPaymentInfo = "Ödeme Bilgileri";
  String _buttonDateTimeLabel = "Ödeme Tarihi Ekle";

  String? _selectNextPaymentDateTimeString;
  DateTime? _nextPaymentDateTime;
//Hizmet ekleme bölümündeki tarih.
  DateTime _selectedSaleDateTime = DateTime.now();
/*??????????????????***SON - (ÖDEME ALINDIĞI YER)??????????????? */
  num? totalPriceForListProduct;
  late String _selectCustomerType;
  late String _customerPhone;

  ///Kalan tutarı dinleyere "Ödeme tarihi Ekle" aktif veya pasif oluyor.
  late final StreamSubscription _streamSubScriptionBalanceValue;
/*-------------------------------------------------------------- */
  @override
  void initState() {
    blocSale = BlocSale();

    blocSale.clearValues();
    _selectUnitOfCurrencySymbol = "₺";
    blocSale.getTotalPriceSection(_selectUnitOfCurrencySymbol);
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

    _streamSubScriptionBalanceValue =
        blocSale.getStreamPaymentSystem.listen((event) {
      if (event > 0) {
        _valueNotifierButtonDateTimeState.value = true;
      } else {
        _valueNotifierButtonDateTimeState.value = false;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    blocSale.clearValues();
    _listAddProduct.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _widthScreen = MediaQuery.of(context).size.width;
    getWidthScreenSize(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Wrap(
            alignment: WrapAlignment.center,
            spacing: context.extensionWrapSpacing10(),
            runSpacing: context.extensionWrapSpacing10(),
            children: [
              _widthScreen <= 500
                  ? widgetMainSectionTableMobil()
                  : widgetMainSectionTableDesktop(),
              Container(
                width: dimension.widthSideSectionAndMobil,
                height: dimension.heightSection,
                padding: EdgeInsets.all(dimension.paddingMainAndSide),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: context.extensionBoxShadow()),
                child: Wrap(
                    direction: Axis.vertical,
                    alignment: WrapAlignment.center,
                    runSpacing: context.extensionWrapSpacing10(),
                    spacing: context.extensionWrapSpacing20(),
                    children: [
                      shareWidgetDateTimeTextFormField(),
                      widgetExchangeRate(),
                      widgetCurrencySelectSection(),
                      widgetPaymentInformationSection(),
                    ]),
              ),
            ],
          )),
        ));
  }

  Container widgetMainSectionTableDesktop() {
    return Container(
      width: dimension.widthMainSection,
      constraints: BoxConstraints(minHeight: dimension.heightSection),
      padding: context.extensionPadding20(),
      decoration: context.extensionThemaWhiteContainer(),
      child: Wrap(
          alignment: WrapAlignment.center,
          spacing: context.extensionWrapSpacing20(),
          runSpacing: context.extensionWrapSpacing10(),
          children: [
            Row(children: [
              widgetSearchFieldCustomerDesktop(),
              context.extensionWidhSizedBox20(),
              widgetButtonNewCustomer(),
            ]),
            Row(children: [
              widgetSearchFieldProductCodeDesktop(),
              context.extensionWidhSizedBox20(),
              widgetButtonAddProduct(),
            ]),
            WidgetSaleTable(
              selectUnitOfCurrencySymbol: _selectUnitOfCurrencySymbol,
              listProduct: _listAddProduct,
              blocSale: blocSale,
              tableWidth: dimension.widthTable,
            ),
          ]),
    );
  }

  Container widgetMainSectionTableMobil() {
    return Container(
      width: dimension.widthSideSectionAndMobil,
      constraints: BoxConstraints(minHeight: dimension.heightSection),
      padding: context.extensionPadding20(),
      decoration: context.extensionThemaWhiteContainer(),
      child: Wrap(
          alignment: WrapAlignment.center,
          spacing: context.extensionWrapSpacing10(),
          runSpacing: context.extensionWrapSpacing10(),
          direction: Axis.vertical,
          children: [
            widgetSearchFieldCustomerMobil(),
            widgetButtonNewCustomer(),
            widgetSearchFieldProductCodeMobil(),
            widgetButtonAddProduct(),
            WidgetSaleTable(
              selectUnitOfCurrencySymbol: _selectUnitOfCurrencySymbol,
              listProduct: _listAddProduct,
              blocSale: blocSale,
              tableWidth: dimension.widthMobilButtonAndTextfield,
            ),
          ]),
    );
  }

  ///Döviz Kurları Tablosu
  StreamBuilder<Map<String, double>> widgetExchangeRate() {
    return StreamBuilder<Map<String, double>>(
        initialData: const {'USD': 0, 'EUR': 0},
        stream: exchangeRateService.getStreamExchangeRate,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: dimension.widthMobilButtonAndTextfield,
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

  ///Müşteri Search Listesi Desktop
  widgetSearchFieldCustomerDesktop() {
    return Expanded(
      child: StreamBuilder2(
        builder: (context, snapshot) {
          if (snapshot.snapshot1.hasData && snapshot.snapshot2.hasData) {
            final listCustomer = <Map<String, String>>[];
            listCustomer.clear();

            for (var item in snapshot.snapshot1.data) {
              listCustomer.add({
                'type': item['type'],
                'name': "${item['name']} ${item['last_name']}",
                'phone': item['phone']
              });
            }
            for (var item in snapshot.snapshot2.data) {
              listCustomer.add({
                'type': item['type'],
                'name': item['name'],
                'phone': item['phone']
              });
            }

            List<SearchFieldListItem<String>> listSearch =
                <SearchFieldListItem<String>>[];

            for (var element in listCustomer) {
              ///item müşterinin type atıyorum.
              listSearch.add(SearchFieldListItem(
                  "${element['type']} - ${element['name']!} - ${element['phone']}",
                  item: element['type']));
            }
            return SearchField(
              scrollbarAlwaysVisible: true,
              itemHeight: _searchItemHeight,
              validator: validateNotEmpty,
              controller: _controllerSearchCustomer,
              searchInputDecoration: InputDecoration(
                  isDense: true,
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  label: Text(_labelSearchCustomer),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  )),
              suggestions: listSearch,
              focusNode: _focusSearchCustomer,
              searchStyle: const TextStyle(
                fontSize: 14,
                //  overflow: TextOverflow.fade,
              ),
              onSuggestionTap: (selectedValue) {
                ///seçilen search tümleşik olarak type-isim-numara geliyor.Burada ayırıyoruz.
                var _customerInfoList = selectedValue.searchKey.split(' - ');
                //  print(_customerInfoList);
                _selectCustomerType = _customerInfoList[0];

                ///Burası müşterinin id sini öğrenmek için yapılıyor. Telefon
                /// numarsı üzerinden id buluncak. telefon numarası unique.
                ///  Müşteri seçer iken id çekmiyoruz güvenlik için.
                //Bunun ilk olmasının sebebi telefon numarası seçilirse diye.

                _customerPhone = _customerInfoList[2];
                // print(_customerPhone);
                /* for (var element in listCustomer) {
                  if (element['name'] == selectedValue.searchKey) {
                    _customerPhone = element['phone']!;
                    break;
                  }
                } */

                _focusSearchCustomer.unfocus();
              },
              maxSuggestionsInViewPort: 6,
            );
          }
          return Container();
        },
        streams: StreamTuple2(db.fetchSoloCustomerAndPhoneStream(),
            db.fetchCompanyCustomerAndPhoneStream()),
      ),
    );
  }

  ///Müşteri Search Listesi Mobil
  widgetSearchFieldCustomerMobil() {
    return StreamBuilder2(
      builder: (context, snapshot) {
        if (snapshot.snapshot1.hasData && snapshot.snapshot2.hasData) {
          final listCustomer = <Map<String, String>>[];
          listCustomer.clear();

          for (var item in snapshot.snapshot1.data) {
            listCustomer.add({
              'type': item['type'],
              'name': "${item['name']} ${item['last_name']}",
              'phone': item['phone']
            });
          }
          for (var item in snapshot.snapshot2.data) {
            listCustomer.add({
              'type': item['type'],
              'name': item['name'],
              'phone': item['phone']
            });
          }

          List<SearchFieldListItem<String>> listSearch =
              <SearchFieldListItem<String>>[];

          for (var element in listCustomer) {
            ///item müşterinin type atıyorum.
            listSearch.add(SearchFieldListItem(
                "${element['type']} - ${element['name']!} - ${element['phone']}",
                item: element['type']));
          }
          return SizedBox(
            width: dimension.widthMobilButtonAndTextfield,
            height: dimension.heightInputTextAnDropdown50,
            child: SearchField(
              scrollbarAlwaysVisible: true,
              itemHeight: _searchItemHeight,
              validator: validateNotEmpty,
              controller: _controllerSearchCustomer,
              searchInputDecoration: InputDecoration(
                  isDense: true,
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  label: Text(_labelSearchCustomer),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  )),
              suggestions: listSearch,
              focusNode: _focusSearchCustomer,
              searchStyle: const TextStyle(
                fontSize: 14,
                //  overflow: TextOverflow.fade,
              ),
              onSuggestionTap: (selectedValue) {
                ///seçilen search tümleşik olarak type-isim-numara geliyor.Burada ayırıyoruz.
                var _customerInfoList = selectedValue.searchKey.split(' - ');
                //  print(_customerInfoList);
                _selectCustomerType = _customerInfoList[0];

                ///Burası müşterinin id sini öğrenmek için yapılıyor. Telefon
                /// numarsı üzerinden id buluncak. telefon numarası unique.
                ///  Müşteri seçer iken id çekmiyoruz güvenlik için.
                //Bunun ilk olmasının sebebi telefon numarası seçilirse diye.

                _customerPhone = _customerInfoList[2];
                // print(_customerPhone);
                /* for (var element in listCustomer) {
                  if (element['name'] == selectedValue.searchKey) {
                    _customerPhone = element['phone']!;
                    break;
                  }
                } */

                _focusSearchCustomer.unfocus();
              },
              maxSuggestionsInViewPort: 6,
            ),
          );
        }
        return Container();
      },
      streams: StreamTuple2(db.fetchSoloCustomerAndPhoneStream(),
          db.fetchCompanyCustomerAndPhoneStream()),
    );
  }

  ///Yeni Müşteri Ekleme
  widgetButtonNewCustomer() {
    return SizedBox(
      height: dimension.heightInputTextAnDropdown40,
      width: _widthMediaQuery,
      child: ElevatedButton.icon(
        //  style: ElevatedButton.styleFrom(minimumSize: const Size(220, 48)),
        icon: const Icon(Icons.person_add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String ad = "yusuf";
              return PopupCustomerAdd(ad);
            },
          );
        },
        label: Text(_labelNewCustomer),
      ),
    );
  }

  ///Ürün Search Listesi Desktop
  widgetSearchFieldProductCodeDesktop() {
    return Expanded(
      child: FutureBuilder<List<String>>(
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            return SearchField(
              itemHeight: _searchItemHeight,
              validator: validateNotEmpty,
              controller: _controllerSearchProductCode,
              searchInputDecoration: InputDecoration(
                  isDense: true,
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
              searchStyle: const TextStyle(
                fontSize: 14,
                //  overflow: TextOverflow.fade,
              ),
              onSubmit: (p0) async {
                if (p0.isNotEmpty) {
                  //seçilen ürün kodunun özellikleri alınıyor.
                  if (snapshot.data!.contains(p0)) {
                    _selectProduct = await db.fetchProductDetailForSale(
                        _controllerSearchProductCode.text);
                    blocSale.addProduct(_selectProduct!);
                    blocSale.getTotalPriceSection(_selectUnitOfCurrencySymbol);
                    blocSale.balance();
                    //enter yapıldıktan sonra ürün kod bölümü temizleniyor.
                    _controllerSearchProductCode.clear();
                    _focusSearchProductCode.requestFocus();
                  }
                }
              },
              maxSuggestionsInViewPort: 3,
            );
          }
          return Container();
        },
        future: db.getProductCode(),
      ),
    );
  }

  ///Ürün Search Listesi Mobil
  widgetSearchFieldProductCodeMobil() {
    return FutureBuilder<List<String>>(
      builder: (context, snapshot) {
        if (!snapshot.hasError && snapshot.hasData) {
          return SizedBox(
            width: dimension.widthMobilButtonAndTextfield,
            height: dimension.heightInputTextAnDropdown50,
            child: SearchField(
              itemHeight: _searchItemHeight,
              validator: validateNotEmpty,
              controller: _controllerSearchProductCode,
              searchInputDecoration: InputDecoration(
                  isDense: true,
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
              searchStyle: const TextStyle(
                fontSize: 14,
                //  overflow: TextOverflow.fade,
              ),
              onSubmit: (p0) async {
                if (p0.isNotEmpty) {
                  //seçilen ürün kodunun özellikleri alınıyor.
                  if (snapshot.data!.contains(p0)) {
                    _selectProduct = await db.fetchProductDetailForSale(
                        _controllerSearchProductCode.text);
                    blocSale.addProduct(_selectProduct!);
                    blocSale.getTotalPriceSection(_selectUnitOfCurrencySymbol);
                    blocSale.balance();
                    //enter yapıldıktan sonra ürün kod bölümü temizleniyor.
                    _controllerSearchProductCode.clear();
                  }
                }
              },
              maxSuggestionsInViewPort: 6,
            ),
          );
        }
        return Container();
      },
      future: db.getProductCode(),
    );
  }

  ///Yeni Ürün Ekleme
  widgetButtonAddProduct() {
    return SizedBox(
      height: _shareHeight,
      width: _widthMediaQuery,
      child: ElevatedButton.icon(
        // style: ElevatedButton.styleFrom(minimumSize: const Size(220, 40)),
        icon: const Icon(Icons.playlist_add),
        onPressed: () async {
          if (_controllerSearchProductCode.text.isNotEmpty) {
            //seçilen ürün kodunun özellikleri alınıyor.

            if (blocSale.getterProductCodeList
                .contains(_controllerSearchProductCode.text)) {
              _selectProduct = await db
                  .fetchProductDetailForSale(_controllerSearchProductCode.text);

              blocSale.addProduct(_selectProduct!);

              blocSale.getTotalPriceSection(_selectUnitOfCurrencySymbol);
              blocSale.balance();
            }
            /* //nesne kıyaslaması yapılıyor. equatable kullanarak
            if (!_listAddProduct.contains(_selectProduct)) {
              SaleTableRow.valueNotifier.value.add(_selectProduct!);
              setState(() {
                _listAddProduct.add(_selectProduct!);
              });
            } */
            //enter yapıldıktan sonra ürün kod bölümü temizleniyor.
            _controllerSearchProductCode.clear();
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
            width: dimension.widthMobilButtonAndTextfield,
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
                      //Tekrar Seçildiğinde onu engellemek için if konuldu

                      setState(() {
                        if (_selectUnitOfCurrencySymbol != "₺") {
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

                          blocSale.getTotalPriceSection(
                              _selectUnitOfCurrencySymbol);
                        }
                      });
                    },
                    sembol: _mapUnitOfCurrency["Türkiye"]["symbol"],
                    backgroundColor: _colorBackgroundCurrencyTRY),
                const SizedBox(
                  width: 2,
                ),
                partOfWidgetshareInkwellCurrency(
                    onTap: () {
                      //Tekrar Seçildiğinde onu engellemek için if konuldu

                      setState(() {
                        if (_selectUnitOfCurrencySymbol != "\$") {
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

                          blocSale.getTotalPriceSection(
                              _selectUnitOfCurrencySymbol);
                        }
                      });
                    },
                    sembol: _mapUnitOfCurrency["amerika"]["symbol"],
                    backgroundColor: _colorBackgroundCurrencyUSD),
                const SizedBox(
                  width: 2,
                ),
                partOfWidgetshareInkwellCurrency(
                    onTap: () {
                      //Tekrar Seçildiğinde onu engellemek için if konuldu

                      setState(() {
                        if (_selectUnitOfCurrencySymbol != "€") {
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

                          blocSale.getTotalPriceSection(
                              _selectUnitOfCurrencySymbol);
                        }
                      });
                    },
                    sembol: _mapUnitOfCurrency["avrupa"]["symbol"],
                    backgroundColor: _colorBackgroundCurrencyEUR),
              ],
            ),
          ),
        ),
        Positioned(
          left: 100,
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
            style: context.theme.headlineSmall!.copyWith(
              color: Colors.white,
            ),
          ),
        ));
  }

  //Ödemenin Alındığı Yer - Ödeme Bilgisi
  widgetPaymentInformationSection() {
    return SizedBox(
      width: dimension.widthMobilButtonAndTextfield,
      height: _paymentCardHeight,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          partOfWidgetHeader(context, _labelPaymentInfo, Colors.grey),
          widgetPaymentOptions(),
        ]),
      ),
    );
  }

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  Container partOfWidgetHeader(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.titleLarge!.copyWith(color: Colors.white);
    return Container(
      alignment: Alignment.center,
      width: _shareWidthPaymentSection,
      height: dimension.heightInputTextAnDropdown40,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: styleHeader,
      ),
    );
  }

  ///Ödeme verilerin alındığı yer.
  widgetPaymentOptions() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.center,
      width: dimension.widthMobilButtonAndTextfield,
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        spacing: 5,
        children: [
          ///Nakit Ödeme
          sharedTextFormField(
            width: dimension.widthMobilButtonAndTextfield,
            labelText: _cash,
            controller: _controllerCashValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                blocSale.setPaymentCashValue(value);
              } else {
                blocSale.setPaymentCashValue("0");
              }
            },
          ),
          //Bankakartı Ödeme Widget
          sharedTextFormField(
            width: dimension.widthMobilButtonAndTextfield,
            labelText: _bankCard,
            controller: _controllerBankValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                blocSale.setPaymentBankCardValue(value);
              } else {
                blocSale.setPaymentBankCardValue("0");
              }
            },
          ),
          //EFTveHavale Ödeme Widget
          sharedTextFormField(
            width: dimension.widthMobilButtonAndTextfield,
            labelText: _eftHavale,
            controller: _controllerEftHavaleValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                blocSale.setPaymentEftHavaleValue(value);
              } else {
                blocSale.setPaymentEftHavaleValue("0");
              }
            },
          ),

          ///kalan Tutar
          partOfwidgetStreamBuilderPaid(),

          ///İleri Ödeme Tarihi Belirlenen button.
          ///ValueListenableBuilder Buttonun aktif veya pasif olmasını belirliyor. Toplam Tutar girilmediyse Button Pasif Oluyor.
          ValueListenableBuilder(
            valueListenable: _valueNotifierButtonDateTimeState,
            builder: (context, value, child) {
              return Container(
                padding: context.extensionPadding10(),
                width: dimension.widthMobilButtonAndTextfield,
                child: shareWidget.widgetElevatedButton(
                    onPressedDoSomething:
                        _valueNotifierButtonDateTimeState.value
                            ? () async {
                                //Takvimden veri alınıyor.
                                _nextPaymentDateTime = await pickDate();

                                if (_nextPaymentDateTime != null) {
                                  _selectNextPaymentDateTimeString =
                                      DateFormat('dd/MM/yyyy')
                                          .format(_nextPaymentDateTime!);
                                  setState(() {
                                    _buttonDateTimeLabel =
                                        "Seçilen Tarih \n ${_nextPaymentDateTime!.day}/${_nextPaymentDateTime!.month}/${_nextPaymentDateTime!.year}";
                                  });
                                }
                              }
                            : null,
                    label: _buttonDateTimeLabel),
              );
            },
          ),
          widgetButtonSale(context),
        ],
      ),
    );
  }

  /// Kalan Tutar Bölümü
  partOfwidgetStreamBuilderPaid() {
    return Container(
      alignment: Alignment.center,
      width: dimension.widthMobilButtonAndTextfield,
      child: StreamBuilder<double>(
          stream: blocSale.getStreamPaymentSystem,
          initialData: 0,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                padding: context.extensionPaddingHorizantal10(),
                alignment: Alignment.centerLeft,
                width: _shareWidthPaymentSection,
                height: 43,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: context.extensionDisableColor))),
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
                        text: FormatterConvert().currencyShow(snapshot.data,
                            unitOfCurrency: _selectUnitOfCurrencySymbol),
                        style: context.theme.titleMedium!.copyWith(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1))
                  ]),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  //Satış Gerçekleştirme Buttonu
  Container widgetButtonSale(BuildContext context) {
    return Container(
      padding: context.extensionPaddingHorizantal10(),
      width: dimension.widthMobilButtonAndTextfield,
      child: shareWidget.widgetElevatedButton(
          onPressedDoSomething: () async {
            if (_controllerSearchCustomer.text != "" &&
                // _controllerSearchProductCode.text != "" &&
                // ignore: prefer_is_empty
                blocSale.listProduct.length >= 1) {
              String? userId = dbHive.getValues('uuid');

              final res = await blocSale.save(
                  saleTime: _selectedSaleDateTime,
                  customerType: _selectCustomerType,
                  customerPhone: _customerPhone,
                  unitOfCurrency: _selectUnitOfCurrencyAbridgment,
                  cashPayment: _controllerCashValue.text,
                  bankcardPayment: _controllerBankValue.text,
                  eftHavalePayment: _controllerEftHavaleValue.text,
                  paymentNextDate: _selectNextPaymentDateTimeString,
                  userId: userId!);

              ///BAŞARILI kAYIT
              if (res['hata'] == null) {
                // ignore: use_build_context_synchronously
                await buildPopupDialog(context);
                _controllerBankValue.clear();
                _controllerEftHavaleValue.clear();
                _controllerCashValue.clear();
                _controllerSearchCustomer.clear();
                _controllerSearchProductCode.clear();
                _selectNextPaymentDateTimeString = null;
                setState(() {
                  ///Burada Parabirimi ayarları sıfırlanıyor.
                  _selectUnitOfCurrencyAbridgment =
                      _mapUnitOfCurrency["Türkiye"]["abridgment"];
                  _selectUnitOfCurrencySymbol =
                      _mapUnitOfCurrency["Türkiye"]["symbol"];
                  _buttonDateTimeLabel = "Ödeme Tarihi Ekle";
                  _colorBackgroundCurrencyTRY = context.extensionDisableColor;
                  _colorBackgroundCurrencyUSD = context.extensionDefaultColor;
                  _colorBackgroundCurrencyEUR = context.extensionDefaultColor;
                });
                // ignore: use_build_context_synchronously
                context.noticeBarTrue("Satış işlemi gerçekleşti.", 2);
                blocSale.clearValues();
              } else {
                context.noticeBarError(
                    "Veritabanı Hatası : Kayıt gerçekleşmedi.", 3);
              }
            } else {
              context.noticeBarError(
                  "Müşteri ve ürün seçimini yapmış olduğunuzdan emin olun.", 3);
            }
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
        inputFormatters: [FormatterDecimalThreeByThreeFinancial()],
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

  void getWidthScreenSize(BuildContext context) {
    _widthMediaQuery = MediaQuery.of(context).size.width < 500 ? 320 : 200;
  }

  /*-------------------------TARİH BÖLÜMÜ ARAMA BÖLÜMÜ --------------------- */

  ///Zaman Text
  shareWidgetDateTimeTextFormField() {
    return Container(
        width: dimension.widthMobilButtonAndTextfield,
        height: _shareHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: context.extensionDefaultColor),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: TextButton.icon(
            onPressed: () async {
              _selectedSaleDateTime =
                  await pickDateSaveTime() ?? DateTime.now();
              TimeOfDay? timeRes = await pickTime();

              setState(() {
                if (timeRes != null) {
                  _selectedSaleDateTime = _selectedSaleDateTime.add(
                      Duration(hours: timeRes.hour, minutes: timeRes.minute));
                }
              });
            },
            icon: Icon(
              Icons.date_range,
              color: context.extensionDefaultColor,
            ),
            label: Text(
              shareFunc.dateTimeConvertFormatString(_selectedSaleDateTime),
              style: context.theme.titleSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            )));
  }

  ///Tarih seçildiği yer.
  Future<DateTime?> pickDateSaveTime() => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
      );

  ///Saat seçildiği yer.
  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

  /*----------------------------------------------------------------------- */

  /*----------------------PDF BÖLÜMÜ ----------------------------------*/
  createPdfInvoice() async {
    await blocInvoice.getCompanyInformation();
    await blocInvoice.getCustomerInformation(
        _selectCustomerType, _customerPhone);

    final doc = pw.Document();
    final pngImage = await imageFromAssetBundle('assets/logo.png');
    /*     String svgRaw = await rootBundle.loadString('/logo.svg');
    final svgImage = pw.SvgImage(svg: svgRaw); */

    var myFont = await PdfGoogleFonts.poppinsMedium();

    final pw.TextStyle letterCharacter =
        pw.TextStyle(font: myFont, fontSize: 9);
    final pw.TextStyle letterCharacterBold =
        pw.TextStyle(font: myFont, fontSize: 9, fontWeight: pw.FontWeight.bold);

    final pw.TextStyle letterCharacterHeader = pw.TextStyle(
        font: myFont, fontSize: 11, fontWeight: pw.FontWeight.bold);

//Tablo Row yapıldı Yer.
    pw.TableRow buildRow(List<String> cells) => pw.TableRow(
            children: cells.map((cell) {
          return pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(4, 2, 0, 2),
              child: pw.Text(
                cell,
                style: letterCharacterBold,
              ));
        }).toList());
    pw.TableRow buildRowRight(List<String> cells) => pw.TableRow(
            children: cells.map((cell) {
          return pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(4, 2, 2, 2),
              child: pw.Text(
                textAlign: pw.TextAlign.right,
                cell,
                style: letterCharacterBold,
              ));
        }).toList());

    pw.TableRow buildRowCenter(List<String> cells) => pw.TableRow(
            children: cells.map((cell) {
          return pw.Center(
              child: pw.Text(
            cell,
            style: letterCharacterBold,
          ));
        }).toList());

    pw.TableRow buildRowHeader(List<String> cells) => pw.TableRow(
            children: cells.map((cell) {
          return pw.Center(
              child: pw.Text(
            cell,
            style: letterCharacterHeader,
          ));
        }).toList());

    ///SATIŞ yapılan Kişi ve Firma Bilgilerin blundu yer.
    pw.RichText buildRichTextCompanyAndSoloInformation() {
      if (_selectCustomerType == "Şahıs") {
        return pw.RichText(
            text: pw.TextSpan(
                text:
                    "${blocInvoice.getCustomerInfo.soleTraderName} ${blocInvoice.getCustomerInfo.soleTraderLastName} \n",
                style: letterCharacter,
                children: [
              pw.TextSpan(
                  text: "Adres : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${blocInvoice.getCustomerInfo.address!.toUpperCaseTr()}\n")
                  ]),
              pw.TextSpan(
                  text: "Tel : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${blocInvoice.getCustomerInfo.phone.toUpperCaseTr()}\n")
                  ]),
              pw.TextSpan(
                  text:
                      "TCKN : ${blocInvoice.getCustomerInfo.TCno!.toUpperCaseTr()}\n")
            ]));

        ///Fİrmaların Verisisnin Dolduğu yer
      } else {
        return pw.RichText(
            text: pw.TextSpan(
                text: "${blocInvoice.getCustomerInfo.companyName}  \n",
                style: letterCharacter,
                children: [
              pw.TextSpan(
                  text: "Adres : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${blocInvoice.getCustomerInfo.address!.toUpperCaseTr()}\n")
                  ]),
              pw.TextSpan(
                  text: "Tel : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${blocInvoice.getCustomerInfo.phone.toUpperCase()}\n")
                  ]),
              pw.TextSpan(
                  text:
                      "Vergi Dairesi : ${blocInvoice.getCustomerInfo.taxOffice!.toUpperCase()}\n"),
              pw.TextSpan(
                  text:
                      "Vergi No : ${blocInvoice.getCustomerInfo.taxNumber!.toUpperCase()}\n")
            ]));
      }
    }

    ///Ürünlerin Listeye Eklendiği List.
    List<pw.TableRow> buildRowProductList() {
      List<pw.TableRow> listTableRow = [];
      for (var element in blocSale.listProduct) {
        listTableRow.add(buildRowCenter([
          element.productCode,
          element.sallingAmount.toString(),
          FormatterConvert().currencyShow(element.currentSallingPriceWithoutTax,
              unitOfCurrency: _mapUnitOfCurrency['Türkiye']['symbol']),
          FormatterConvert().currencyShow(element.total,
              unitOfCurrency: _mapUnitOfCurrency['Türkiye']['symbol']),
        ]));
      }
      return listTableRow;
    }

    ///Ürünler Listesinin Widget bölümü.
    pw.Table pdfWidgetTableProductList(
        pw.TableRow Function(List<String> cells) buildRowHeader,
        List<pw.TableRow> Function() buildRowProductList) {
      return pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(140),
            1: const pw.FixedColumnWidth(50),
            2: const pw.FixedColumnWidth(80),
            3: const pw.FixedColumnWidth(80)
          },
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          children: [
            buildRowHeader(['MAL NO', 'MİKTAR', 'FİYAT', 'TUTAR']),
            for (int i = 0; i < buildRowProductList().length; i++)
              buildRowProductList()[i],
          ]);
    }

    ///Şirket Bilgilerin Widget Bölümü.
    pw.Container pdfWidgetMyCompanyInfo(
        pw.TextStyle letterCharacter, pw.TextStyle letterCharacterBold) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(4),
        decoration: const pw.BoxDecoration(
            border: pw.Border.symmetric(horizontal: pw.BorderSide(width: 2))),
        width: 180,
        child: pw.RichText(
            text: pw.TextSpan(
                text: "${blocInvoice.getInvoice!.name.toUpperCaseTr()} \n",
                style: letterCharacter,
                children: [
              pw.TextSpan(
                  text: "Adres : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${blocInvoice.getInvoice!.address.toUpperCaseTr()}\n")
                  ]),
              pw.TextSpan(
                  text: "Tel : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${blocInvoice.getInvoice!.phone.toUpperCaseTr()}\n")
                  ]),
              pw.TextSpan(
                  text: "instagram Adresi : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text: "${blocInvoice.getInvoice!.instgramAddress}\n")
                  ])
            ])),
      );
    }

    ///Dökümanın oluşturlduğu yer.
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Container(
            alignment: pw.Alignment.topCenter,
            child: pw.Column(children: [
              ///İlk Satır
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pdfWidgetMyCompanyInfo(
                        letterCharacter, letterCharacterBold),
                    pw.Container(
                        color: PdfColors.amber,
                        width: 150,
                        height: 100,
                        child: pw.Image(fit: pw.BoxFit.fitWidth, pngImage))
                  ]),
              pdfwidgetDivider(),

              ///ikinci Satır
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        decoration: const pw.BoxDecoration(
                            border: pw.Border.symmetric(
                                horizontal: pw.BorderSide(width: 2))),
                        width: 180,
                        child: buildRichTextCompanyAndSoloInformation()),
                    pdfWidgetDateTimeAndInvoice(buildRow),
                  ]),
              pdfwidgetDivider(height: 20),

              ///Ürün Tablosu
              pdfWidgetTableProductList(buildRowHeader, buildRowProductList),
              pdfwidgetDivider(height: 20),
              pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.SizedBox(
                      width: 220,
                      child: pw.Table(
                          columnWidths: {
                            0: const pw.FixedColumnWidth(130),
                            1: const pw.FixedColumnWidth(90),
                          },
                          border: pw.TableBorder.all(
                              color: PdfColors.black, width: 1),
                          children: [
                            buildRowRight([
                              'Mal Hizmet Toplam Tutarı',
                              FormatterConvert().currencyShow(
                                  blocSale
                                      .totalPriceAndKdv['total_without_tax'],
                                  unitOfCurrency: _selectUnitOfCurrencySymbol)
                            ]),
                            buildRowRight([
                              'Hesaplanan KDV(%${blocSale.totalPriceAndKdv['kdv']})',
                              FormatterConvert().currencyShow(
                                  blocInvoice.calculatorKdvValue(
                                      blocSale.totalPriceAndKdv['kdv']!.toInt(),
                                      blocSale.totalPriceAndKdv[
                                              'total_without_tax']!
                                          .toDouble()),
                                  unitOfCurrency: _selectUnitOfCurrencySymbol)
                            ]),
                            buildRowRight([
                              'Vergiler Dahil Toplam Tutar',
                              FormatterConvert().currencyShow(
                                  blocSale.totalPriceAndKdv['total_with_tax'],
                                  unitOfCurrency: _selectUnitOfCurrencySymbol)
                            ]),
                            buildRowRight([
                              'Ödenen Tutar',
                              FormatterConvert().currencyShow(
                                  blocSale.paymentTotalValue(),
                                  unitOfCurrency: _selectUnitOfCurrencySymbol)
                            ]),
                            buildRowRight([
                              'Kalan Borç Tutar',
                              FormatterConvert().currencyShow(
                                  blocSale.getBalanceValue,
                                  unitOfCurrency: _selectUnitOfCurrencySymbol)
                            ]),
                            buildRowRight([
                              'Ödeme Tarihi ',
                              _selectNextPaymentDateTimeString ?? 'Girilmedi'
                            ])
                          ])))
            ]));
      },
    ));

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
    );

    /* //Başka uygulamada paylaşmak istersen 
    await Printing.sharePdf(bytes: await doc.save(), filename: 'fatura.pdf');
     */
  }

  pw.Divider pdfwidgetDivider({double? height}) =>
      pw.Divider(borderStyle: pw.BorderStyle.none, height: height);

  pw.Table pdfWidgetDateTimeAndInvoice(
      pw.TableRow Function(List<String> cells) buildRow) {
    final zaman = DateTime.now();
    return pw.Table(
        columnWidths: {
          0: const pw.FixedColumnWidth(100),
          1: const pw.FixedColumnWidth(60)
        },
        border: pw.TableBorder.all(color: PdfColors.black, width: 1),
        children: [
          buildRow(['İrsaliye No:', blocSale.getInvoiceNumber.toString()]),
          buildRow(
              ['Düzenlenme Tarihi:', DateFormat('dd/MM/yyyy').format(zaman)]),
          buildRow(['Düzenlenme Zamanı:', DateFormat.Hms().format(zaman)]),
        ]);
  }

/*------------------------------------------------------------------------- */
  ///Stok Kodu aynı girildiğinde Ekran Hatası için.
  buildPopupDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('UYARI',
              textAlign: TextAlign.center,
              style: context.theme.headline5!
                  .copyWith(fontWeight: FontWeight.bold)),
          content: Text("İrsaliye Faturası yazdırmak ister misin?",
              style: context.theme.headline6!
                  .copyWith(fontWeight: FontWeight.bold)),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            SizedBox(
              width: 150,
              child: ElevatedButton(
                  onPressed: () async {
                    await createPdfInvoice();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: const Text("Yazdır")),
            ),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                child: const Text("İptal"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
