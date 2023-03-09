// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/models/category.dart';
import 'package:stok_takip/models/payment.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/screen/drawer.dart';
import 'package:stok_takip/utilities/convert_string_currency_digits.dart';
import 'package:stok_takip/utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/popup/popup_supplier_add.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/utilities/widget_category_show.dart';
import 'package:stok_takip/validations/format_decimal_limit.dart';
import 'package:stok_takip/validations/validation.dart';
import '../modified_lib/searchfield.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/format_convert_point_comma.dart';
import '../validations/format_decimal_3by3_financial.dart';
import '../validations/format_upper_case_text_format.dart';

class ScreenProductAdd extends StatefulWidget {
  const ScreenProductAdd({Key? key}) : super(key: key);

  @override
  State<ScreenProductAdd> createState() => _ScreenProductAddState();
}

class _ScreenProductAddState extends State<ScreenProductAdd>
    with Validation, SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _valueNotifierProductBuyWithoutTax = ValueNotifier<double>(0);
  final _valueNotifierProductSaleWithTax = ValueNotifier<double>(0);
  final _controllerProductCode = TextEditingController();
  final _controllerSupplier = TextEditingController();
  final _controllerProductAmountOfStock = TextEditingController();
  final _controllerSallingPriceWithoutTax = TextEditingController();
  final _controllerInvoiceCode = TextEditingController();
  late AutovalidateMode _autovalidateMode;

  final double _containerMainMinWidth = 360, _containerMainMaxWidth = 750;
  double? _responceWidth;
  // late Product? _product;

  late Category _category;
  final List<String?> _categoryList = [];

  // ignore: unused_field
  bool _isThereProductCode = true;
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _searchFocusSupplier = FocusNode();
  late List<String>? _productCodeList;
  final String _paymentSections = "Ödeme Bölümü";
  // ignore: unused_field
  String _newSuppleirAdd = "";

  /*----------------BAŞLANGIÇ - ÖDEME ALINDIĞI YER------------- */
  final _valueNotifierPaid = ValueNotifier<double>(0);
  final _valueNotifierBalance = ValueNotifier<double>(0);
  final _valueNotifierButtonDateTimeState = ValueNotifier<bool>(false);
  final _controllerCashValue = TextEditingController();
  final _controllerBankValue = TextEditingController();
  final _controllerEftHavaleValue = TextEditingController();
  final _controllerPaymentTotal = TextEditingController();

  final String _totalPayment = "Toplam Tutarı Giriniz";
  final String _balance = "Kalan Tutar : ";
  final String _paid = "Ödenen Toplam Tutar : ";
  final String _cash = "Nakit İle Ödenen Tutar";
  final String _eftHavale = "EFT/HAVALE İle Ödenen Tutar";
  final String _bankCard = "Kart İle Ödenen Tutar";
  final double _shareTextFormFieldPaymentSystemWidth = 250;

  double _cashValue = 0, _bankValue = 0, _eftHavaleValue = 0;
  double _totalPaymentValue = 0;
  String _buttonDateTimeLabel = "Ödeme Tarihi Ekle";
  String? _selectDateTime;
/*??????????????????***SON - (ÖDEME ALINDIĞI YER)??????????????? */

  final String _labelAmountOfStock = "Stok Miktarı (Adet)";
  final String _labelKDV = "KDV Oranın Seçiniz";
  final String _labelInvoiceCode = "Fatura Kodu";
  final String _labelSearchSuppiler = "Tedarikci İsmini Giriniz";
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

/*-------------------KATEGORİ BÖLÜMÜ----------------------*/
  final String _categorySections = "Kategori";
  String categoryList = "";

/*-------------------------------------------------------- */

/*----------------------KDV BÖLÜMÜ------------------------ */
  final _productTaxList = <String>['% 0', '% 8', '% 18'];
  int? _selectedTaxValueInt;

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  bool _selectedTax = false;

  void _getProductTax(String value) {
    setState(() {
      _selectedTaxValueInt = int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    });
    _selectedTax = true;
  }
  /*------------------------------------------------------ */

  @override
  void initState() {
    _autovalidateMode = AutovalidateMode.onUserInteraction;
    /*------------ BAŞLANGIÇ - PARABİRİMİ SEÇİMİ------------------- */
    _selectUnitOfCurrencySymbol = _mapUnitOfCurrency["Türkiye"]["symbol"];
    _selectUnitOfCurrencyAbridgment =
        _mapUnitOfCurrency["Türkiye"]["abridgment"];
    _colorBackgroundCurrencyUSD = context.extensionDefaultColor;
    _colorBackgroundCurrencyTRY = context.extensionDisableColor;
    _colorBackgroundCurrencyEUR = context.extensionDefaultColor;
    /*------------ SON - PARABİRİMİ SEÇİMİ------------------- */
    _productCodeList = [];
    _category = Category();
    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState!.dispose();
    _controllerProductCode.dispose();
    _controllerProductAmountOfStock.dispose();
    _controllerSallingPriceWithoutTax.dispose();
    _categoryList.clear();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getWidthScreenSize(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Yeni Ürün Ekleme"),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildProductAdd(),
      drawer: const MyDrawer(),
    );
  }

  buildProductAdd() {
    return Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
            constraints: BoxConstraints(
                minWidth: _containerMainMinWidth,
                maxWidth: _containerMainMaxWidth),
            padding: context.extensionPadding20(),
            decoration: context.extensionThemaWhiteContainer(),
            child: Column(
              children: [
                Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    spacing: 30,
                    runSpacing: 10,
                    children: [
                      Wrap(
                        direction: Axis.horizontal,
                        spacing: context.extensionWrapSpacing20(),
                        runSpacing: context.extensionWrapSpacing20(),
                        children: [
                          widgetWrapTextFieldMinAndMaxWidth(
                              widgetSearchTextFieldProductCodeUpperCase()),
                          widgetWrapTextFieldMinAndMaxWidth(
                            widgetInvoiceCode(),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: widgetSearchTextFieldSupplier(),
                      )
                    ]),
                widgetDividerHeader(_categorySections, 35),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: widgetCategorySelectSection(),
                ),
                const Divider(),
                widgetDividerHeader(_paymentSections, null),
                widgetPaymentOptions(),
                Divider(
                    color: context.extensionLineColor,
                    endIndent: 30,
                    indent: 30,
                    thickness: 2.5,
                    height: 20),
                const Divider(),
                widgetProductUnitSection(),
                const Divider(),
                widgetSaveProduct(),
              ],
            ),
          )),
        ));
  }

//Widget Ürün Kodu Giriniz Search
  widgetSearchTextFieldProductCodeUpperCase() {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (!snapshot.hasError && snapshot.hasData) {
          _productCodeList = snapshot.data;
          return SearchField(
            searchHeight: 70,
            validator: validateNotEmpty,
            controller: _controllerProductCode,
            searchInputDecoration: const InputDecoration(
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
                label: Text("Ürün Kodunu Giriniz (Barkod Kodu)"),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                )),
            inputFormatters: [FormatterUpperCaseTextFormatter()],
            suggestions: snapshot.data!.map((e) {
              return SearchFieldListItem(e);
            }).toList(),
            focusNode: _searchFocus,
            onSuggestionTap: (selectedValue) {
              if (selectedValue.searchKey.isNotEmpty) {
                _searchFocus.unfocus();
                setState(() {
                  _isThereProductCode = false;
                });
                buildPopupDialog(context);
              }
            },
            maxSuggestionsInViewPort: 6,
          );
        }
        return Container();
      },
      future: db.getProductCode(),
    );
  }

  ///Fatura Kodu giriş bölümü.
  TextFormField widgetInvoiceCode() {
    return TextFormField(
      maxLength: 25,
      controller: _controllerInvoiceCode,
      inputFormatters: [
        FormatterUpperCaseTextFormatter(),
        FormatterUpperCaseTextFormatter()
      ],
      decoration: InputDecoration(
          counterText: "", //maxLen gözükmesini engelliyor
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          labelText: _labelInvoiceCode,
          border: OutlineInputBorder(
              borderRadius: context.extensionRadiusDefault5,
              borderSide: BorderSide(color: context.extensionDefaultColor))),
    );
  }

  ///Tedarikçi Bölümü.
  widgetSearchTextFieldSupplier() {
    return Row(
      children: [
        ///Tedarikçi Ekleme Buttonu.
        Container(
          height: 70,
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 50,
            child: FloatingActionButton(
              heroTag: "Tedarikçi Arama",
              autofocus: false,
              focusNode: FocusNode(skipTraversal: true),
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return PopupSupplierRegister(_controllerSupplier.text);
                  },
                );
              },
            ),
          ),
        ),
        context.extensionWidhSizedBox10(),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: db.getSuppliersNameStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasError &&
                  snapshot.hasData &&
                  snapshot.data!.isNotEmpty) {
                return SearchField(
                  searchHeight: 70,
                  //  validator: validateNotEmpty,
                  inputFormatters: [FormatterUpperCaseTextFormatter()],
                  controller: _controllerSupplier,
                  searchInputDecoration: InputDecoration(
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      labelText: _labelSearchSuppiler,
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      )),
                  suggestions: searchFieldListItemSupplierName(snapshot.data!),
                  focusNode: _searchFocusSupplier,
                  onSuggestionTap: (selectedValue) {
                    if (selectedValue.searchKey.isNotEmpty) {
                      _searchFocusSupplier.unfocus();
                    }
                  },
                  maxSuggestionsInViewPort: 6,
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  widgetCategorySelectSectionTable() {
    return SizedBox(
      height: 300,
      width: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            width: 220,
            child: Stack(
              children: [
                Positioned(
                  left: 45,
                  top: 5,
                  child: Container(
                    height: 50,
                    width: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: context.extensionDefaultColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.5))
                        ]),
                    child: TextButton(
                      focusNode: FocusNode(skipTraversal: true),
                      onPressed: () => widgetCategorySelectPopUp(),
                      child: Text(
                        "Kategori Seçiniz",
                        style: context.theme.headline6!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: FloatingActionButton.small(
                    heroTag: "Kategori Button",
                    focusColor: context.extensionDisableColor,
                    hoverColor: Colors.grey,
                    child: const Icon(Icons.add),
                    onPressed: () {
                      widgetCategorySelectPopUp();
                    },
                  ),
                ),
              ],
            ),
          ),

          ///Kategori altındaki container dolduruyor. _category1 boş ise Liste
          ///dolmuyor.
          _category.category1 != null
              ? Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(border: Border.all()),
                  height: 220,
                  child: ListView.separated(
                    itemCount: _categoryList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          alignment: Alignment.center,
                          height: 40,
                          color: Colors.blueGrey.shade700,
                          child: Text(
                            "Seçilen Kategori",
                            textAlign: TextAlign.center,
                            style: context.theme.headline6!.copyWith(
                                fontWeight: FontWeight.w100,
                                color: Colors.white),
                          ),
                        );
                      } else {
                        return Text(
                          "    ${_categoryList[index - 1]}",
                          style: context.theme.headline6!.copyWith(
                              leadingDistribution:
                                  TextLeadingDistribution.even),
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      return index == 0
                          ? Divider(
                              height: 0,
                              thickness: 1.5,
                              color: context.extensionDefaultColor,
                            )
                          : Divider(
                              thickness: 1.5,
                              color: context.extensionDefaultColor,
                            );
                    },
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  height: 220,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Text(
                    "Kategori Seçilmedi.",
                    textAlign: TextAlign.center,
                    style: context.theme.headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  )),
        ],
      ),
    );
  }

  ///Kategori Bölümü
  widgetCategorySelectSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            height: 50,
            child: FloatingActionButton(
              heroTag: "Kategori Button",
              focusColor: context.extensionDisableColor,
              hoverColor: Colors.grey,
              child: const Icon(Icons.add),
              onPressed: () {
                widgetCategorySelectPopUp();
              },
            ),
          ),
          _category.category1 != null
              ? widgetCategorySelected()
              : Container(
                  width: _responceWidth,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: context.extensionDefaultColor,
                      borderRadius: context.extensionRadiusDefault5),
                  constraints: const BoxConstraints(
                      /*    minWidth: _containerMainMinWidth,
                      maxWidth: _containerMainMaxWidth - 140, */
                      minHeight: 50,
                      maxHeight: 60),
                  child: Text(
                    "Kategori Seçilmedi.",
                    style:
                        context.theme.headline6!.copyWith(color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }

  widgetCategorySelected() {
    return Container(
      width: _responceWidth,
      constraints: BoxConstraints(
          minWidth: _containerMainMinWidth,
          maxWidth: _containerMainMaxWidth - 140,
          minHeight: 50,
          maxHeight: 60),
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: context.extensionDefaultColor,
          borderRadius: context.extensionRadiusDefault5),
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            text: "Seçilen Kategori: ",
            style: context.theme.subtitle1!.copyWith(color: Colors.white)),
        for (int i = 0; i < _categoryList.length - 1; i++)
          TextSpan(
            text: "${_categoryList[i]}> ",
            style: context.theme.subtitle1!.copyWith(color: Colors.white),
          ),
        TextSpan(
            text: _categoryList[_categoryList.length - 1],
            style: context.theme.subtitle1!.copyWith(color: Colors.white)),
      ])),
    );
  }

  fillSelectedCategory() {
    categoryList = "Seçilen Kategori> ";
    for (var i = 0; i < _categoryList.length; i++) {
      if (i != _categoryList.length - 1) {
        categoryList += "${_categoryList[i]}> ";
      } else {
        categoryList += _categoryList[i]!;
      }
    }
  }

  ///Kategori Seç tıklandığı açılan pop-up Kategori seçme
  Future widgetCategorySelectPopUp() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: context.extensionPadding20(),
          actionsAlignment: MainAxisAlignment.center,
          title: Text(
              textAlign: TextAlign.center,
              'Kategori Seçiniz',
              style: context.theme.headline5!
                  .copyWith(fontWeight: FontWeight.bold)),
          content: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 500),
            child: WidgetCategoryShow(_category),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  //Kategorinin boş olup olmadığını kontrol ederek bildirim hatası veriyor.
                  if (_category.category1 == null) {
                    context.extensionShowErrorSnackBar(
                        message: "Lütfen Kategori Seçimini Tamamlayınız");
                  } else {
                    setState(() {
                      _categoryList.clear();

                      ///BU bölümde kategory boş gelen veri sorun oluyor.
                      /// Category Sınıfı içinde değişkenlere 'null' atanamıyor.

                      if (_category.category1?.values.first != null) {
                        _categoryList.add(_category.category1!.values.first);
                      }
                      if (_category.category2?.values.first != null) {
                        _categoryList.add(_category.category2!.values.first);
                      }
                      if (_category.category3?.values.first != null) {
                        _categoryList.add(_category.category3!.values.first);
                      }
                      if (_category.category4?.values.first != null) {
                        _categoryList.add(_category.category4!.values.first);
                      }
                      if (_category.category5?.values.first != null) {
                        _categoryList.add(_category.category5!.values.first);
                      }
                    });
                    fillSelectedCategory();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Seç'))
          ],
        );
      },
    );
  }

  ///Stok Ve KDV
  widgetCurrencyAndKdvSection() {
    return Wrap(
      direction: Axis.horizontal,
      verticalDirection: VerticalDirection.down,
      spacing: context.extensionWrapSpacing20(),
      runSpacing: context.extensionWrapSpacing20(),
      children: [
        ///Para Birimi Seçilen yer.
        widgetCurrencySelectSection(),
        //KDV Bölümü.
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 2),
            width: _shareTextFormFieldPaymentSystemWidth,
            height: 80,
            child: ShareDropdown(
              validator: validateNotEmpty,
              hint: _labelKDV,
              itemList: _productTaxList,
              getShareDropdownCallbackFunc: _getProductTax,
            )),
      ],
    );
  }

  ///Stok Kodu aynı girildiğinde Ekran Hatası için.
  buildPopupDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('UYARI',
              textAlign: TextAlign.center,
              style: context.theme.headline4!
                  .copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                    text: "Kayıtlı olan ürün kodu seçtiniz.",
                    style: context.theme.headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text:
                              "\nEğer stok güncellemesi yapacaksanız. Lütfen ",
                          style: context.theme.headline6!
                              .copyWith(color: Colors.redAccent)),
                      TextSpan(
                          text: "\"Stok Güncelleme Ekranın'dan\"",
                          style: context.theme.headline6!.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: " yapınız.",
                          style: context.theme.headline6!
                              .copyWith(color: Colors.redAccent))
                    ]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            CloseButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.blueGrey,
            ),
          ],
        );
      },
    );
  }

  /// Bölüm Başlığı Orta kısmında Başlık yazılı.
  widgetDividerHeader(String header, double? height) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            height: height,
            color: context.extensionLineColor,
            thickness: 2.5,
            indent: 30,
            endIndent: 10,
          ),
        ),
        Text(header,
            style: context.theme.headline6!.copyWith(
                color: context.extensionDefaultColor,
                fontWeight: FontWeight.bold)),
        Expanded(
            child: Divider(
          height: height,
          color: context.extensionLineColor,
          thickness: 2.5,
          indent: 10,
          endIndent: 30,
        ))
      ],
    );
  }

  /// Tedarikçi Search Listesini burada düzenliyor. Gösterim şekli.
  List<SearchFieldListItem<dynamic>> searchFieldListItemSupplierName(
      List<Map<String, dynamic>> snapshotData) {
    List<SearchFieldListItem> listSupplier = [];
    for (var item in snapshotData) {
      listSupplier
          .add(SearchFieldListItem(item['name'], child: Text(item['name'])));
    }
    return listSupplier;
  }

  ///Ödeme verilerin alındığı yer.
  widgetPaymentOptions() {
    double insideContainerWidth = 250;
    return Container(
      //  padding: context.extensionPadding20(),
      width: context.extendFixedWightContainer,
      alignment: Alignment.center,
      child: Wrap(
        alignment: WrapAlignment.start,
        direction: Axis.horizontal,
        spacing: context.extensionWrapSpacing20(),
        runSpacing: context.extensionWrapSpacing20(),
        children: [
          widgetCurrencyAndKdvSection(),
          Container(
            alignment: Alignment.center,
            width: insideContainerWidth,
            child: Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.vertical,
              spacing: context.extensionWrapSpacing20(),
              children: [
                ///Toplam Tutar Widget
                sharedTextFormField(
                  validator: validateNotEmpty,
                  width: _shareTextFormFieldPaymentSystemWidth,
                  labelText: _totalPayment,
                  controller: _controllerPaymentTotal,
                  onChanged: (value) {
                    value.isEmpty
                        ? _totalPaymentValue = 0
                        : _totalPaymentValue =
                            FormatterConvert().commaToPointDouble(value);

                    ///Stok adeti önce girildiyse toplam tutar sonra girilmesi
                    ///durumunda birim başı maliyet hesaplamak içindir bu bölüm.

                    if (_controllerProductAmountOfStock.text.isNotEmpty) {
                      _valueNotifierProductBuyWithoutTax.value =
                          _totalPaymentValue /
                              double.parse(
                                  _controllerProductAmountOfStock.text);
                    }
                  },
                ),

                ///Ödenen Toplam Tutar yeri.
                shareValueListenableBuilder(
                    valueListenable: _valueNotifierPaid, firstText: _paid),

                ///Kalan Tutarın Bölümü.
                shareValueListenableBuilder(
                    valueListenable: _valueNotifierBalance, firstText: _balance)
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: insideContainerWidth,
            child: Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.vertical,
              spacing: context.extensionWrapSpacing20(),
              children: [
                ///Nakit Ödeme
                sharedTextFormField(
                  width: _shareTextFormFieldPaymentSystemWidth,
                  labelText: _cash,
                  controller: _controllerCashValue,
                  onChanged: (value) {
                    value.isEmpty
                        ? _cashValue = 0
                        : _cashValue =
                            FormatterConvert().commaToPointDouble(value);
                  },
                ),
                //Bankakartı Ödeme Widget
                sharedTextFormField(
                  width: _shareTextFormFieldPaymentSystemWidth,
                  labelText: _bankCard,
                  controller: _controllerBankValue,
                  onChanged: (value) {
                    value.isEmpty
                        ? _bankValue = 0
                        : _bankValue =
                            FormatterConvert().commaToPointDouble(value);
                  },
                ),
                //EFTveHavale Ödeme Widget
                sharedTextFormField(
                  width: _shareTextFormFieldPaymentSystemWidth,
                  labelText: _eftHavale,
                  controller: _controllerEftHavaleValue,
                  onChanged: (value) {
                    value.isEmpty
                        ? _eftHavaleValue = 0
                        : _eftHavaleValue =
                            FormatterConvert().commaToPointDouble(value);
                  },
                ),
              ],
            ),
          ),

          ///İleri Ödeme Tarihi Belirlenen button.
          ///ValueListenableBuilder Buttonun aktif veya pasif olmasını belirliyor. Toplam Tutar girilmediyse Button Pasif Oluyor.
          ValueListenableBuilder(
            valueListenable: _valueNotifierButtonDateTimeState,
            builder: (context, value, child) {
              return SizedBox(
                width: _shareTextFormFieldPaymentSystemWidth,
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

          ///Tutar Ve Ödemenin Yapsının Hesaplayan Button.
          SizedBox(
            width: _shareTextFormFieldPaymentSystemWidth,
            child: shareWidget.widgetElevatedButton(
                onPressedDoSomething: () {
                  _valueNotifierPaid.value =
                      _cashValue + _bankValue + _eftHavaleValue;

                  _valueNotifierBalance.value =
                      _totalPaymentValue - _valueNotifierPaid.value;

                  _valueNotifierButtonDateTimeState.value = false;

                  if (_valueNotifierBalance.value > 0) {
                    _buttonDateTimeLabel = "Ödeme Tarihi Seçiniz";
                    _valueNotifierButtonDateTimeState.value = true;
                  }
                },
                label: "Hesapla"),
          )
        ],
      ),
    );
  }

  ///Maliyeti Stok ve Birim Satışı Bölümü.
  widgetProductUnitSection() {
    return SizedBox(
      width: 520,
      child: Wrap(
        direction: Axis.horizontal,
        verticalDirection: VerticalDirection.down,
        alignment: WrapAlignment.center,
        spacing: context.extensionWrapSpacing20(),
        runSpacing: context.extensionWrapSpacing10(),
        children: [
          SizedBox(
            width: _shareTextFormFieldPaymentSystemWidth,
            height: 70,
            //Stok Sayısının Girildiği Yer.
            child: shareWidget.widgetTextFieldInput(
              etiket: _labelAmountOfStock,
              maxCharacter: 7,
              inputFormat: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardInputType: TextInputType.number,
              controller: _controllerProductAmountOfStock,
              validationFunc: validateNotEmpty,
              onChanged: (p0) {
                //çift taraflı şekilde yapıldı Birim Başı Maliyet Hesaplama
                if (_controllerPaymentTotal.text.isNotEmpty) {
                  _valueNotifierProductBuyWithoutTax.value =
                      _totalPaymentValue / double.parse(p0);
                }
              },
            ),
          ),
          Container(
            width: _shareTextFormFieldPaymentSystemWidth,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: context.extensionRadiusDefault10),
            child: ValueListenableBuilder<double>(
              valueListenable: _valueNotifierProductBuyWithoutTax,
              builder: (context, value, child) => RichText(
                text: TextSpan(
                    text: 'Birim Başı Maliyet : ',
                    style: context.theme.labelLarge!.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                    children: [
                      TextSpan(
                          text:
                              "${value.toStringAsFixed(2)} $_selectUnitOfCurrencySymbol",
                          style: context.theme.labelLarge!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1))
                    ]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: _shareTextFormFieldPaymentSystemWidth,
            height: 70,
            child: shareWidget.widgetTextFieldInput(
              etiket: 'Vergiler Hariç Satış (Birim Fiyat)',
              inputFormat: [FormatterDecimalThreeByThreeFinancial()],
              controller: _controllerSallingPriceWithoutTax,
              validationFunc: validateNotEmpty,
              onChanged: (value) {
                ///TextField içinde yazıp sildiğinde hiç bir karakter kalmayınca isEmpty
                ///dönüyor. Buradaki notifier double olduğu için isEmpty dönmesi sorun bunu
                ///eğer isEmpty is 0 atanıyor. '0' olması sebebi giden değer ile KDV
                ///hesabı yapılıyor.
                value.isEmpty
                    ? _valueNotifierProductSaleWithTax.value = 0
                    : _valueNotifierProductSaleWithTax.value =
                        FormatterConvert().commaToPointDouble(value);
              },
            ),
          ),
          Container(
            width: _shareTextFormFieldPaymentSystemWidth,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: context.extensionRadiusDefault10),
            child: ValueListenableBuilder<double>(
              valueListenable: _valueNotifierProductSaleWithTax,
              builder: (context, value, child) => RichText(
                text: TextSpan(
                    text: 'Vergiler Dahil Satış : ',
                    style: context.theme.labelLarge!.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                    children: [
                      TextSpan(
                          text: _selectedTax == false
                              ? 'KDV Seçilmedi'
                              : "${(value * (1 + (_selectedTaxValueInt! / 100))).toStringAsFixed(2)} $_selectUnitOfCurrencySymbol",
                          style: context.theme.labelLarge!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1))
                    ]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///Ürün Kaydı yapıldı yer.
  widgetSaveProduct() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate() &&
            _controllerProductCode.text.isNotEmpty) {
          bool isThereProductCodeByProductList =
              _productCodeList!.contains(_controllerProductCode.text);

          if (isThereProductCodeByProductList == false) {
            ///Depo seçimi koyulmadığından bu bölüm şimdilik sabit veriliyor.
            const storehouse = "Ana Depo";
            String userId = dbHive.getValues('uuid');

            ///ÜRÜN ÖZELLİKLERİN EKLENMESİ.
            var product = Product(
              productCode: _controllerProductCode.text,
              currentAmountOfStock:
                  int.parse(_controllerProductAmountOfStock.text),
              taxRate: _selectedTaxValueInt!,
              currentBuyingPriceWithoutTax:
                  _valueNotifierProductBuyWithoutTax.value,
              currentSallingPriceWithoutTax: FormatterConvert()
                  .commaToPointDouble(_controllerSallingPriceWithoutTax.text),
              category: _category,
            );

            ///ÖDEME TÜRÜNÜN EKLENMESİ.
            var payment = Payment(
                suppliersFk: _controllerSupplier.text,
                productFk: _controllerProductCode.text,
                amountOfStock: int.parse(_controllerProductAmountOfStock.text),
                invoiceCode: _controllerInvoiceCode.text,
                unitOfCurrency: _selectUnitOfCurrencyAbridgment,
                total: FormatterConvert()
                    .commaToPointDouble(_controllerPaymentTotal.text),
                cash: FormatterConvert()
                    .commaToPointDouble(_controllerCashValue.text),
                bankcard: FormatterConvert()
                    .commaToPointDouble(_controllerBankValue.text),
                eftHavale: FormatterConvert()
                    .commaToPointDouble(_controllerEftHavaleValue.text),
                buyingPriceWithoutTax: _valueNotifierProductBuyWithoutTax.value,
                sallingPriceWithoutTax: FormatterConvert()
                    .commaToPointDouble(_controllerSallingPriceWithoutTax.text),
                repaymentDateTime: _selectDateTime,
                userId: userId);

            ///KAYITIN GERÇEKLEŞTİĞİ YER.
            //  if (_valueNotifierBalance.value >= 0) {
            db.saveNewProduct(product, payment).then((value) {
              /// kayıt başarılı olunca degerleri sıfırlıyor.
              if (value.isEmpty) {
                _controllerInvoiceCode.clear();
                _controllerPaymentTotal.clear();
                _controllerEftHavaleValue.clear();
                _controllerBankValue.clear();
                _controllerSupplier.clear();
                _controllerCashValue.clear();
                _valueNotifierBalance.value = 0;
                _valueNotifierPaid.value = 0;
                _controllerSallingPriceWithoutTax.clear();
                _controllerProductAmountOfStock.clear();
                _valueNotifierProductSaleWithTax.value = 0;
                _valueNotifierProductBuyWithoutTax.value = 0;

                ///global olarak tanımladığı için peş peşe 2 ürün kaydetmek olduğunda değerler global değişken olduğu için veriler bir sonrakiye girişi etkiliyor. O yüzden sıfırlamak lazım.
                _cashValue = 0;
                _bankValue = 0;
                _eftHavaleValue = 0;
                _totalPaymentValue = 0;

                setState(() {
                  _controllerProductCode.clear();

                  _category.category1 = null;
                });
                context.noticeBarTrue("Ürün kaydedildi.", 1);
              }
            });
            /*   } else {
              context.noticeBarError("Kalan Tutar 0'dan küçük olamaz.", 2);
            } */
          } else {
            context.extensionShowErrorSnackBar(
                message: "Kayıtlı bir ürün kodu girdiniz.");
          }
        } else {
          context.extensionShowErrorSnackBar(
              message: "Lütfen Gerekli Alanları Doldurun");
        }
      },
      child: const Text(
        "Kaydet",
      ),
    );
  }

  sharedTextFormField(
      {required double width,
      required String labelText,
      required TextEditingController controller,
      required void Function(String)? onChanged,
      String? Function(String?)? validator}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        validator: validator,
        onChanged: onChanged,
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: [
          FormatterDecimalThreeByThreeFinancial(),
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

  shareValueListenableBuilder(
      {required ValueNotifier<double> valueListenable,
      required String firstText}) {
    return ValueListenableBuilder<double>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        return Container(
          alignment: Alignment.centerLeft,
          width: _shareTextFormFieldPaymentSystemWidth,
          height: 43,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: context.extensionDisableColor))),
          child: RichText(
            maxLines: 2,
            text: TextSpan(children: [
              TextSpan(
                text: firstText,
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
    );
  }

  ///Tarih seçildiği yer.
  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
      );

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

  widgetWrapTextFieldMinAndMaxWidth(Widget widget) {
    return Container(
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 325),
      child: widget,
    );
  }

  ///Para Birimi Seçildiği Yer
  widgetCurrencySelectSection() {
    return Stack(
      children: [
        Positioned(
          child: Container(
            alignment: Alignment.center,
            width: _shareTextFormFieldPaymentSystemWidth,
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

  getWidthScreenSize(BuildContext context) {
    _responceWidth = MediaQuery.of(context).size.width < 500 ? 250 : 600;
  }
}
