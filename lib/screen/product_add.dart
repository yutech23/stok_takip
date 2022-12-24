import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:searchfield/searchfield.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/models/category.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/screen/drawer.dart';
import 'package:stok_takip/utilities/convert_string_currency_digits.dart';
import 'package:stok_takip/utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stok_takip/utilities/popup/popup_supplier_add.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/utilities/widget_category_show.dart';
import 'package:stok_takip/validations/input_format_decimal_limit.dart';
import 'package:stok_takip/validations/validation.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/input_format_decimal_3by3.dart';
import '../validations/upper_case_text_format.dart';

class ScreenProductAdd extends StatefulWidget {
  const ScreenProductAdd({Key? key}) : super(key: key);

  @override
  State<ScreenProductAdd> createState() => _ScreenProductAddState();
}

class _ScreenProductAddState extends State<ScreenProductAdd>
    with Validation, SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _valueNotifierProductBuyWithTax = ValueNotifier<double>(0);
  final _valueNotifierProductSaleWithTax = ValueNotifier<double>(0);
  final _valueNotifierPaid = ValueNotifier<double>(0);
  final _valueNotifierBalance = ValueNotifier<double>(0);
  final _valueNotifierButtonDateTimeState = ValueNotifier<bool>(false);
  final _controllerProductCode = TextEditingController();
  final _controllerSupplier = TextEditingController();
  final _controllerProductAmountOfStock = TextEditingController();
  final _controllerBuyingPriceWithoutTax = TextEditingController();
  final _controllerSallingPriceWithoutTax = TextEditingController();
  final _controllerCashValue = TextEditingController();
  final _controllerBankValue = TextEditingController();
  final _controllerEftHavaleValue = TextEditingController();
  final _controllerPaymentValue = TextEditingController();
  final _controllerBillingCode = TextEditingController();

  final double _containerMainMinWidth = 360, _containerMainMaxWidth = 750;

  late Product? _product;
  late Category _category;
  final List<String> _categoryList = [];
  bool _visibleQrCode = false;
  final _productTaxList = <String>['% 8', '% 18'];
  String? _selectedTax;
  bool _isThereProductCode = true;
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _searchFocusSupplier = FocusNode();
  late List<String>? _productCodeList;
  final String _paymentSections = "Ödeme Bölümü";
  String _newSuppleirAdd = "";
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
  DateTime selectDateTime = DateTime.now();

  late Color _colorBackgroundCurrencyUSD;
  late Color _colorBackgroundCurrencyTRY;
  late Color _colorBackgroundCurrencyEUR;
  String _selectCurrency = "₺";
  final String _labelCurrencySelect = "Para Birimi Seçiniz";
  final String _labelAmountOfStock = "Stok Miktarı (Adet)";
  final String _labelKDV = "KDV Oranın Seçiniz";
  final String _labelBillingCode = "Fatura Kodu";

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  int _selectedTaxToInt = 0;
  void _getProductTax(String value) {
    setState(() {
      _selectedTax = value;
    });
    _selectedTaxToInt =
        int.parse(_selectedTax!.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  roleCheck() async {
    String? role = await SecurityStorageUser.getUserRole();
  }

  @override
  void initState() {
    //   roleCheck();
    _productCodeList = [];

    _product = Product(
        productCodeAndQrCode: null,
        amountOfStock: null,
        buyingpriceWithoutTax: null,
        category: null,
        sallingPriceWithoutTax: null,
        taxRate: null);
    _category = Category();
    _colorBackgroundCurrencyUSD = context.extensionDefaultColor;
    _colorBackgroundCurrencyTRY = context.extensionDisableColor;
    _colorBackgroundCurrencyEUR = context.extensionDefaultColor;
    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState!.dispose();
    _controllerProductCode.dispose();
    _controllerBuyingPriceWithoutTax.dispose();
    _controllerProductAmountOfStock.dispose();
    _controllerSallingPriceWithoutTax.dispose();
    _categoryList.clear();
    _searchFocus.dispose();
    super.dispose();
  }

  double sideLength = 50;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Ürün Ekleme"),
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
                            widgetBillingCode(),
                          ),
                        ],
                      ),
                      widgetSearchTextFieldSupplier(),
                    ]),
                const Divider(),
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  verticalDirection: VerticalDirection.down,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    widgetQrCodeSection(),
                    widgetCategorySelectSection(),
                  ],
                ),
                const Divider(),
                widgetDividerHeader(_paymentSections),
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
            controller: _controllerProductCode,
            searchInputDecoration: const InputDecoration(
                label: Text("Ürün Kodunu Giriniz"),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                )),
            inputFormatters: [UpperCaseTextFormatter()],
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
  TextFormField widgetBillingCode() {
    return TextFormField(
      maxLength: 25,
      controller: _controllerBillingCode,
      decoration: InputDecoration(
          counterText: "", //maxLen gözükmesini engelliyor
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          labelText: _labelBillingCode,
          border: OutlineInputBorder(
              borderRadius: context.extensionRadiusDefault5,
              borderSide: BorderSide(color: context.extensionDefaultColor))),
    );
  }

  ///Tedarikçi Bölümü.
  widgetSearchTextFieldSupplier() {
    return Row(
      children: [
        SizedBox(
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
                  return PopupSupplierRegister(_newSuppleirAdd);
                },
              );
            },
          ),
        ),
        context.extensionWidhSizedBox20(),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: db.getSuppliersNameStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasError &&
                  snapshot.hasData &&
                  snapshot.data!.isNotEmpty) {
                return SearchField(
                  controller: _controllerSupplier,
                  searchInputDecoration: const InputDecoration(
                      label: Text("Tedarikci İsmini Giriniz"),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      enabledBorder: OutlineInputBorder(
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

  ///Qr-Code Blok kodu
  widgetQrCodeSection() {
    return Container(
      width: 220,
      height: 300,
      padding: const EdgeInsets.only(top: 10),
      child: Column(children: [
        widgetButtonQrcode(),
        context.extensionHighSizedBox20(),
        Container(
          alignment: Alignment.center,
          height: 220,
          decoration: BoxDecoration(border: Border.all()),
          child: _visibleQrCode
              ? QrImage(
                  data: _controllerProductCode.text,
                  version: QrVersions.auto,
                  size: 200.0,
                )
              : Text(
                  "QR-Kod Oluşturmadınız",
                  style: context.theme.headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
        ),
      ]),
    );
  }

  ///Qr-Code Oluşturma Buttonu
  widgetButtonQrcode() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(220, 50)),
        onPressed: () {
          bool isThereProductCodeByProductList =
              _productCodeList!.contains(_controllerProductCode.text);

          if (isThereProductCodeByProductList == false &&
              _controllerProductCode.text.isNotEmpty) {
            _searchFocus.unfocus();
            setState(() {
              _isThereProductCode = true;
              _visibleQrCode = true;
            });
          } else if (_controllerProductCode.text.isEmpty ||
              isThereProductCodeByProductList == true) {
            setState(() {
              _visibleQrCode = false;
            });
          } else if (isThereProductCodeByProductList) {
            context.extensionShowErrorSnackBar(
                message: 'Kayıtlı bir ürün kodu girdiniz.');
          }
        },
        child: const Text(
          "QR-Kod Oluştur",
        ));
  }

  widgetCategorySelectSection() {
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
            child: WidgetCategoryShow(_category),
            constraints: BoxConstraints(maxHeight: 500),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  if (_category.category1 == null ||
                      _category.category2 == null ||
                      _category.category3 == null ||
                      _category.category4 == null ||
                      _category.category5 == null) {
                    context.extensionShowErrorSnackBar(
                        message: "Lütfen Kategori Seçimini Tamamlayınız");
                  } else {
                    setState(() {
                      _categoryList.clear();
                      _categoryList.add(_category.category1!.values.first);
                      _categoryList.add(_category.category2!.values.first);
                      _categoryList.add(_category.category3!.values.first);
                      _categoryList.add(_category.category4!.values.first);
                      _categoryList.add(_category.category5!.values.first);
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Seç'))
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
        Stack(
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
                            _selectCurrency = "₺";
                            _colorBackgroundCurrencyTRY =
                                context.extensionDisableColor;
                            _colorBackgroundCurrencyUSD =
                                context.extensionDefaultColor;
                            _colorBackgroundCurrencyEUR =
                                context.extensionDefaultColor;
                          });
                        },
                        sembol: '₺',
                        backgroundColor: _colorBackgroundCurrencyTRY),
                    const SizedBox(
                      width: 2,
                    ),
                    shareInkwellCurrency(
                        onTap: () {
                          setState(() {
                            _selectCurrency = "\$";
                            _colorBackgroundCurrencyTRY =
                                context.extensionDefaultColor;
                            _colorBackgroundCurrencyUSD =
                                context.extensionDisableColor;
                            _colorBackgroundCurrencyEUR =
                                context.extensionDefaultColor;
                          });
                        },
                        sembol: '\$',
                        backgroundColor: _colorBackgroundCurrencyUSD),
                    const SizedBox(
                      width: 2,
                    ),
                    shareInkwellCurrency(
                        onTap: () {
                          setState(() {
                            _selectCurrency = "€";
                            _colorBackgroundCurrencyTRY =
                                context.extensionDefaultColor;
                            _colorBackgroundCurrencyUSD =
                                context.extensionDefaultColor;
                            _colorBackgroundCurrencyEUR =
                                context.extensionDisableColor;
                          });
                        },
                        sembol: '€',
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
        ),
        //KDV Bölümü.
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 2),
            width: _shareTextFormFieldPaymentSystemWidth,
            height: 74,
            child: ShareDropdown(
              validator: validatenNotEmpty,
              hint: _labelKDV,
              itemList: _productTaxList,
              selectValue: _selectedTax,
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
  widgetDividerHeader(String header) {
    return Row(
      children: [
        Expanded(
          child: Divider(
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
      if (item['type'] == "Tedarikçi") {
        listSupplier
            .add(SearchFieldListItem(item['name'], child: Text(item['name'])));
      }
    }
    return listSupplier;
  }

  ///Ödeme verilerin alındığı yer.
  widgetPaymentOptions() {
    double insideContainerWidth = 250;
    return Container(
      padding: context.extensionPadding20(),
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
                sharedTextFormField(
                  width: _shareTextFormFieldPaymentSystemWidth,
                  labelText: _totalPayment,
                  controller: _controllerPaymentValue,
                  onChanged: (value) {
                    value.isEmpty
                        ? _totalPaymentValue = 0
                        : _totalPaymentValue =
                            double.parse(value.replaceAll(RegExp(r'\D'), ""));

                    if (_controllerProductAmountOfStock.text.isNotEmpty) {
                      _valueNotifierProductBuyWithTax.value =
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
                sharedTextFormField(
                  width: _shareTextFormFieldPaymentSystemWidth,
                  labelText: _cash,
                  controller: _controllerCashValue,
                  onChanged: (value) {
                    value.isEmpty
                        ? _cashValue = 0
                        : _cashValue =
                            double.parse(value.replaceAll(RegExp(r'\D'), ""));
                  },
                ),
                sharedTextFormField(
                  width: _shareTextFormFieldPaymentSystemWidth,
                  labelText: _bankCard,
                  controller: _controllerBankValue,
                  onChanged: (value) {
                    value.isEmpty
                        ? _bankValue = 0
                        : _bankValue =
                            double.parse(value.replaceAll(RegExp(r'\D'), ""));
                  },
                ),
                sharedTextFormField(
                  width: _shareTextFormFieldPaymentSystemWidth,
                  labelText: _eftHavale,
                  controller: _controllerEftHavaleValue,
                  onChanged: (value) {
                    value.isEmpty
                        ? _eftHavaleValue = 0
                        : _eftHavaleValue =
                            double.parse(value.replaceAll(RegExp(r'\D'), ""));
                  },
                ),
              ],
            ),
          ),

          ///İleri Ödeme Tarihi Belirlenen button.
          ValueListenableBuilder(
            valueListenable: _valueNotifierButtonDateTimeState,
            builder: (context, value, child) {
              return SizedBox(
                width: _shareTextFormFieldPaymentSystemWidth,
                child: shareWidget.widgetElevatedButton(
                    onPressedDoSomething:
                        _valueNotifierButtonDateTimeState.value
                            ? () async {
                                final data = await pickDate();
                                if (data == null) return; //pressed Cancel
                                selectDateTime = data;
                                if (data != null) {
                                  setState(() {
                                    _buttonDateTimeLabel =
                                        "Seçilen Tarih \n ${selectDateTime.day}/${selectDateTime.month}/${selectDateTime.year}";
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

  ///Maliyet ve Birim Satışı Bölümü.
  widgetProductUnitSection() {
    return Container(
      width: 500,
      child: Wrap(
        direction: Axis.horizontal,
        verticalDirection: VerticalDirection.down,
        alignment: WrapAlignment.center,
        spacing: context.extensionWrapSpacing20(),
        runSpacing: context.extensionWrapSpacing10(),
        children: [
          Container(
            width: 230,
            height: 50,
            child: shareWidget.widgetTextFieldInput(
              etiket: _labelAmountOfStock,
              maxCharacter: 7,
              inputFormat: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardInputType: TextInputType.number,
              controller: _controllerProductAmountOfStock,
              validationFunc: validatenNotEmpty,
              onChanged: (p0) {
                //çift taraflı şekilde yapıldı Birim Başı Maliyet Hesaplama
                if (_controllerPaymentValue.text.isNotEmpty) {
                  _valueNotifierProductBuyWithTax.value =
                      _totalPaymentValue / double.parse(p0);
                }
              },
            ),
          ),
          Container(
            width: 230,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: context.extensionRadiusDefault10),
            child: ValueListenableBuilder<double>(
              valueListenable: _valueNotifierProductBuyWithTax,
              builder: (context, value, child) => RichText(
                text: TextSpan(
                    text: 'Birim Başı Maliyet : ',
                    style: context.theme.labelLarge!.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                    children: [
                      TextSpan(
                          text: "${value.toStringAsFixed(2)} $_selectCurrency",
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
            width: 230,
            height: 70,
            child: shareWidget.widgetTextFieldInput(
              etiket: 'Vergiler Hariç Satış (Birim Fiyat)',
              inputFormat: [
                InputFormatterDecimalLimit(decimalRange: 2),
              ],
              controller: _controllerSallingPriceWithoutTax,
              validationFunc: validatenNotEmpty,
              onChanged: (value) {
                ///TextField içinde yazıp sildiğinde hiç bir karakter kalmayınca isEmpty
                ///dönüyor. Buradaki notifier double olduğu için isEmpty dönmesi sorun bunu
                ///eğer isEmpty is 0 atanıyor. '0' olması sebebi giden değer ile KDV
                ///hesabı yapılıyor.
                value.isEmpty
                    ? _valueNotifierProductSaleWithTax.value = 0
                    : _valueNotifierProductSaleWithTax.value =
                        double.parse(value);
              },
            ),
          ),
          Container(
            width: 230,
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
                          text: _selectedTaxToInt == 0
                              ? 'KDV Seçilmedi'
                              : "${(value * (1 + (_selectedTaxToInt / 100))).toStringAsFixed(2)} $_selectCurrency",
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
      onPressed: _isThereProductCode
          ? () async {
              if (_formKey.currentState!.validate() &&
                  _category.category1 != null &&
                  _controllerProductCode.text.isNotEmpty) {
                bool isThereProductCodeByProductList =
                    _productCodeList!.contains(_controllerProductCode.text);

                if (isThereProductCodeByProductList == false) {
                  _product = Product(
                      productCodeAndQrCode: _controllerProductCode.text,
                      amountOfStock:
                          int.parse(_controllerProductAmountOfStock.text),
                      taxRate: _selectedTaxToInt,
                      buyingpriceWithoutTax:
                          double.parse(_controllerBuyingPriceWithoutTax.text),
                      sallingPriceWithoutTax:
                          double.parse(_controllerSallingPriceWithoutTax.text),
                      category: _category,
                      billingCode: _controllerBillingCode.text);
                  db.saveProduct(context, _product!).then((value) {
                    /// kayıt başarılı olunca degerleri sıfırlıyor.
                    if (value) {
                      _controllerProductAmountOfStock.clear();
                      _controllerBuyingPriceWithoutTax.clear();
                      _controllerSallingPriceWithoutTax.clear();
                      _valueNotifierProductSaleWithTax.value = 0;
                      _valueNotifierProductBuyWithTax.value = 0;
                      setState(() {
                        _controllerProductCode.clear();
                        _visibleQrCode = false;
                        _categoryList.clear();
                      });
                    }
                  });
                } else {
                  context.extensionShowErrorSnackBar(
                      message: "Kayıtlı bir ürün kodu girdiniz.");
                }
              } else {
                context.extensionShowErrorSnackBar(
                    message: "Lütfen Gerekli Alanları Doldurun");
              }
            }
          : null,
      child: const Text(
        "Kaydet",
      ),
    );
  }

  sharedTextFormField(
      {required double width,
      required String labelText,
      required TextEditingController controller,
      required void Function(String)? onChanged}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        onChanged: onChanged,
        controller: controller,
        autovalidateMode: AutovalidateMode.always,
        inputFormatters: [
          InputFormatterDecimalThreeByThree(),
        ],
        keyboardType: TextInputType.number,
        style: context.theme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: context.extensionDefaultColor),
          isDense: true,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
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
                      "${convertStringToCurrencyDigitThreeByThree.convertStringToDigit3By3(value.toString())} $_selectCurrency",
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
        initialDate: selectDateTime,
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
      );

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
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 345),
      child: widget,
    );
  }
}
