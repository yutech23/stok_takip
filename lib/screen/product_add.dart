import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/user_security_storage.dart';
import 'package:stok_takip/models/category.dart';
import 'package:stok_takip/models/payment.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/screen/drawer.dart';
import 'package:stok_takip/utilities/convert_string_currency_digits.dart';
import 'package:stok_takip/utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stok_takip/utilities/popup/popup_supplier_add.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/utilities/widget_category_show.dart';
import 'package:stok_takip/validations/format_decimal_limit.dart';
import 'package:stok_takip/validations/validation.dart';
import '../modified_lib/searchfield.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/format_decimal_3by3.dart';
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
  final _valueNotifierPaid = ValueNotifier<double>(0);
  final _valueNotifierBalance = ValueNotifier<double>(0);
  final _valueNotifierButtonDateTimeState = ValueNotifier<bool>(false);
  final _controllerProductCode = TextEditingController();
  final _controllerSupplier = TextEditingController();
  final _controllerProductAmountOfStock = TextEditingController();

  final _controllerSallingPriceWithoutTax = TextEditingController();
  final _controllerCashValue = TextEditingController();
  final _controllerBankValue = TextEditingController();
  final _controllerEftHavaleValue = TextEditingController();
  final _controllerPaymentTotal = TextEditingController();
  final _controllerInvoiceCode = TextEditingController();
  late AutovalidateMode _autovalidateMode;

  final double _containerMainMinWidth = 360, _containerMainMaxWidth = 750;

  // late Product? _product;

  late Category _category;
  final List<String> _categoryList = [];
  bool _visibleQrCode = false;
  final _productTaxList = <String>['% 8', '% 18'];
  String? _selectedTax;
  bool _isThereProductCode = true;
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _searchFocusSupplier = FocusNode();
  late List<String>? _productCodeList;
  final String _paymentSections = "??deme B??l??m??";
  String _newSuppleirAdd = "";
  final String _totalPayment = "Toplam Tutar?? Giriniz";
  final String _balance = "Kalan Tutar : ";
  final String _paid = "??denen Toplam Tutar : ";
  final String _cash = "Nakit ??le ??denen Tutar";
  final String _eftHavale = "EFT/HAVALE ??le ??denen Tutar";
  final String _bankCard = "Kart ??le ??denen Tutar";
  final double _shareTextFormFieldPaymentSystemWidth = 250;

  double _cashValue = 0, _bankValue = 0, _eftHavaleValue = 0;
  double _totalPaymentValue = 0;
  String _buttonDateTimeLabel = "??deme Tarihi Ekle";
  String? _selectDateTime;
  late Color _colorBackgroundCurrencyUSD;
  late Color _colorBackgroundCurrencyTRY;
  late Color _colorBackgroundCurrencyEUR;
  late String _selectUnitOfCurrencySymbol;
  late String _selectUnitOfCurrencyAbridgment;
  final String _labelCurrencySelect = "Para Birimi Se??iniz";
  final String _labelAmountOfStock = "Stok Miktar?? (Adet)";
  final String _labelKDV = "KDV Oran??n Se??iniz";
  final String _labelInvoiceCode = "Fatura Kodu";
  final String _labelSearchSuppiler = "Tedarikci ??smini Giriniz";

  final Map<String, dynamic> _mapUnitOfCurrency = {
    "T??rkiye": {"symbol": "???", "abridgment": "TL"},
    "amerika": {"symbol": '\$', "abridgment": "USD"},
    "avrupa": {"symbol": '???', "abridgment": "EURO"}
  };

  ///KDV se??ilip Se??ilmedi??ini kontrol ediyorum.
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
    _autovalidateMode = AutovalidateMode.onUserInteraction;
    _selectUnitOfCurrencySymbol = _mapUnitOfCurrency["T??rkiye"]["symbol"];
    _selectUnitOfCurrencyAbridgment =
        _mapUnitOfCurrency["T??rkiye"]["abridgment"];
    //   roleCheck();
    _productCodeList = [];

    /* _product = Product(
        productCode: "",
        currentAmountOfStock: 0,
        currentBuyingPriceWithoutTax: 0,
        category: null,
        currentSallingPriceWithoutTax: 0,
        taxRate: 0); */
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
        title: const Text("Yeni ??r??n Ekleme"),
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

//Widget ??r??n Kodu Giriniz Search
  widgetSearchTextFieldProductCodeUpperCase() {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (!snapshot.hasError && snapshot.hasData) {
          _productCodeList = snapshot.data;
          return SearchField(
            validator: validateNotEmpty,
            controller: _controllerProductCode,
            searchInputDecoration: const InputDecoration(
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
                label: Text("??r??n Kodunu Giriniz"),
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

  ///Fatura Kodu giri?? b??l??m??.
  TextFormField widgetInvoiceCode() {
    return TextFormField(
      maxLength: 25,
      controller: _controllerInvoiceCode,
      inputFormatters: [
        FormatterUpperCaseTextFormatter(),
        FormatterUpperCaseTextFormatter()
      ],
      decoration: InputDecoration(
          counterText: "", //maxLen g??z??kmesini engelliyor
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          labelText: _labelInvoiceCode,
          border: OutlineInputBorder(
              borderRadius: context.extensionRadiusDefault5,
              borderSide: BorderSide(color: context.extensionDefaultColor))),
    );
  }

  ///Tedarik??i B??l??m??.
  widgetSearchTextFieldSupplier() {
    return Row(
      children: [
        ///Tedarik??i Ekleme Buttonu.
        SizedBox(
          height: 50,
          child: FloatingActionButton(
            heroTag: "Tedarik??i Arama",
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
        context.extensionWidhSizedBox20(),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: db.getSuppliersNameStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasError &&
                  snapshot.hasData &&
                  snapshot.data!.isNotEmpty) {
                return SearchField(
                  validator: validateNotEmpty,
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
                  "QR-Kod Olu??turmad??n??z",
                  style: context.theme.headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
        ),
      ]),
    );
  }

  ///Qr-Code Olu??turma Buttonu
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
                message: 'Kay??tl?? bir ??r??n kodu girdiniz.');
          }
        },
        child: const Text(
          "QR-Kod Olu??tur",
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
                        "Kategori Se??iniz",
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

          ///Kategori alt??ndaki container dolduruyor. _category1 bo?? ise Liste
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
                            "Se??ilen Kategori",
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
                    "Kategori Se??ilmedi.",
                    textAlign: TextAlign.center,
                    style: context.theme.headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  )),
        ],
      ),
    );
  }

  ///Kategori Se?? t??kland?????? a????lan pop-up Kategori se??me
  Future widgetCategorySelectPopUp() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: context.extensionPadding20(),
          actionsAlignment: MainAxisAlignment.center,
          title: Text(
              textAlign: TextAlign.center,
              'Kategori Se??iniz',
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
                        message: "L??tfen Kategori Se??imini Tamamlay??n??z");
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
                child: Text('Se??'))
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
        ///Para Birimi Se??ilen yer.
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
                            _selectUnitOfCurrencyAbridgment =
                                _mapUnitOfCurrency["T??rkiye"]["abridgment"];
                            _selectUnitOfCurrencySymbol =
                                _mapUnitOfCurrency["T??rkiye"]["symbol"];
                            _colorBackgroundCurrencyTRY =
                                context.extensionDisableColor;
                            _colorBackgroundCurrencyUSD =
                                context.extensionDefaultColor;
                            _colorBackgroundCurrencyEUR =
                                context.extensionDefaultColor;
                          });
                        },
                        sembol: _mapUnitOfCurrency["T??rkiye"]["symbol"],
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
        ),
        //KDV B??l??m??.
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 2),
            width: _shareTextFormFieldPaymentSystemWidth,
            height: 80,
            child: ShareDropdown(
              validator: validateNotEmpty,
              hint: _labelKDV,
              itemList: _productTaxList,
              selectValue: _selectedTax,
              getShareDropdownCallbackFunc: _getProductTax,
            )),
      ],
    );
  }

  ///Stok Kodu ayn?? girildi??inde Ekran Hatas?? i??in.
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
                    text: "Kay??tl?? olan ??r??n kodu se??tiniz.",
                    style: context.theme.headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text:
                              "\nE??er stok g??ncellemesi yapacaksan??z. L??tfen ",
                          style: context.theme.headline6!
                              .copyWith(color: Colors.redAccent)),
                      TextSpan(
                          text: "\"Stok G??ncelleme Ekran??n'dan\"",
                          style: context.theme.headline6!.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: " yap??n??z.",
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

  /// B??l??m Ba??l?????? Orta k??sm??nda Ba??l??k yaz??l??.
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

  /// Tedarik??i Search Listesini burada d??zenliyor. G??sterim ??ekli.
  List<SearchFieldListItem<dynamic>> searchFieldListItemSupplierName(
      List<Map<String, dynamic>> snapshotData) {
    List<SearchFieldListItem> listSupplier = [];
    for (var item in snapshotData) {
      listSupplier
          .add(SearchFieldListItem(item['name'], child: Text(item['name'])));
    }
    return listSupplier;
  }

  ///??deme verilerin al??nd?????? yer.
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
                            double.parse(value.replaceAll(RegExp(r'\D'), ""));

                    ///Stok adeti ??nce girildiyse toplam tutar sonra girilmesi
                    ///durumunda birim ba???? maliyet hesaplamak i??indir bu b??l??m.

                    if (_controllerProductAmountOfStock.text.isNotEmpty) {
                      _valueNotifierProductBuyWithoutTax.value =
                          _totalPaymentValue /
                              double.parse(
                                  _controllerProductAmountOfStock.text);
                    }
                  },
                ),

                ///??denen Toplam Tutar yeri.
                shareValueListenableBuilder(
                    valueListenable: _valueNotifierPaid, firstText: _paid),

                ///Kalan Tutar??n B??l??m??.
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
                ///Nakit ??deme
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
                //Bankakart?? ??deme Widget
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
                //EFTveHavale ??deme Widget
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

          ///??leri ??deme Tarihi Belirlenen button.
          ///ValueListenableBuilder Buttonun aktif veya pasif olmas??n?? belirliyor. Toplam Tutar girilmediyse Button Pasif Oluyor.
          ValueListenableBuilder(
            valueListenable: _valueNotifierButtonDateTimeState,
            builder: (context, value, child) {
              return SizedBox(
                width: _shareTextFormFieldPaymentSystemWidth,
                child: shareWidget.widgetElevatedButton(
                    onPressedDoSomething:
                        _valueNotifierButtonDateTimeState.value
                            ? () async {
                                //Takvimden veri al??n??yor.
                                final dataForCalendar = await pickDate();

                                if (dataForCalendar != null) {
                                  //
                                  _selectDateTime = DateFormat('dd/MM/yyyy')
                                      .format(dataForCalendar);
                                  setState(() {
                                    _buttonDateTimeLabel =
                                        "Se??ilen Tarih \n ${dataForCalendar.day}/${dataForCalendar.month}/${dataForCalendar.year}";
                                  });
                                }
                              }
                            : null,
                    label: _buttonDateTimeLabel),
              );
            },
          ),

          ///Tutar Ve ??demenin Yaps??n??n Hesaplayan Button.
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
                    _buttonDateTimeLabel = "??deme Tarihi Se??iniz";
                    _valueNotifierButtonDateTimeState.value = true;
                  }
                },
                label: "Hesapla"),
          )
        ],
      ),
    );
  }

  ///Maliyeti Stok ve Birim Sat?????? B??l??m??.
  widgetProductUnitSection() {
    return SizedBox(
      width: 500,
      child: Wrap(
        direction: Axis.horizontal,
        verticalDirection: VerticalDirection.down,
        alignment: WrapAlignment.center,
        spacing: context.extensionWrapSpacing20(),
        runSpacing: context.extensionWrapSpacing10(),
        children: [
          SizedBox(
            width: 230,
            height: 70,
            //Stok Say??s??n??n Girildi??i Yer.
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
                //??ift tarafl?? ??ekilde yap??ld?? Birim Ba???? Maliyet Hesaplama
                if (_controllerPaymentTotal.text.isNotEmpty) {
                  _valueNotifierProductBuyWithoutTax.value =
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
              valueListenable: _valueNotifierProductBuyWithoutTax,
              builder: (context, value, child) => RichText(
                text: TextSpan(
                    text: 'Birim Ba???? Maliyet : ',
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
            width: 230,
            height: 70,
            child: shareWidget.widgetTextFieldInput(
              etiket: 'Vergiler Hari?? Sat???? (Birim Fiyat)',
              inputFormat: [
                FormatterDecimalLimit(decimalRange: 2),
              ],
              controller: _controllerSallingPriceWithoutTax,
              validationFunc: validateNotEmpty,
              onChanged: (value) {
                ///TextField i??inde yaz??p sildi??inde hi?? bir karakter kalmay??nca isEmpty
                ///d??n??yor. Buradaki notifier double oldu??u i??in isEmpty d??nmesi sorun bunu
                ///e??er isEmpty is 0 atan??yor. '0' olmas?? sebebi giden de??er ile KDV
                ///hesab?? yap??l??yor.
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
                    text: 'Vergiler Dahil Sat???? : ',
                    style: context.theme.labelLarge!.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                    children: [
                      TextSpan(
                          text: _selectedTaxToInt == 0
                              ? 'KDV Se??ilmedi'
                              : "${(value * (1 + (_selectedTaxToInt / 100))).toStringAsFixed(2)} $_selectUnitOfCurrencySymbol",
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

  ///??r??n Kayd?? yap??ld?? yer.
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
                  ///Depo se??imi koyulmad??????ndan bu b??l??m ??imdilik sabit veriliyor.
                  const storehouse = "Ana Depo";

                  ///??R??N ??ZELL??KLER??N EKLENMES??.
                  var product = Product(
                    productCode: _controllerProductCode.text,
                    currentAmountOfStock:
                        int.parse(_controllerProductAmountOfStock.text),
                    taxRate: _selectedTaxToInt,
                    currentBuyingPriceWithoutTax:
                        _valueNotifierProductBuyWithoutTax.value,
                    currentSallingPriceWithoutTax:
                        double.parse(_controllerSallingPriceWithoutTax.text),
                    category: _category,
                  );

                  ///??DEME T??R??N??N EKLENMES??.
                  var payment = Payment(
                      suppliersFk: _controllerSupplier.text,
                      productFk: _controllerProductCode.text,
                      amountOfStock:
                          int.parse(_controllerProductAmountOfStock.text),
                      invoiceCode: _controllerInvoiceCode.text,
                      unitOfCurrency: _selectUnitOfCurrencyAbridgment,
                      total: double.parse(
                          _controllerPaymentTotal.text.replaceAll(".", "")),
                      cash: double.tryParse(
                          _controllerCashValue.text.replaceAll(".", "")),
                      bankcard: double.tryParse(
                          _controllerBankValue.text.replaceAll(".", "")),
                      eftHavale: double.tryParse(
                          _controllerEftHavaleValue.text.replaceAll(".", "")),
                      buyingPriceWithoutTax:
                          _valueNotifierProductBuyWithoutTax.value,
                      sallingPriceWithoutTax:
                          double.parse(_controllerSallingPriceWithoutTax.text),
                      repaymentDateTime: _selectDateTime);

                  ///KAYITIN GER??EKLE??T?????? YER.
                  if (_valueNotifierBalance.value >= 0) {
                    db.saveNewProduct(product, payment).then((value) {
                      /// kay??t ba??ar??l?? olunca degerleri s??f??rl??yor.
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

                        ///global olarak tan??mlad?????? i??in pe?? pe??e 2 ??r??n kaydetmek oldu??unda de??erler global de??i??ken oldu??u i??in veriler bir sonrakiye giri??i etkiliyor. O y??zden s??f??rlamak laz??m.
                        _cashValue = 0;
                        _bankValue = 0;
                        _eftHavaleValue = 0;
                        _totalPaymentValue = 0;

                        setState(() {
                          _controllerProductCode.clear();
                          _visibleQrCode = false;
                          _categoryList.clear();
                        });
                        context.noticeBarTrue("??r??n kaydedildi.", 1);
                      }
                    });
                  } else {
                    context.noticeBarError(
                        "Kalan Tutar 0'dan k??????k olamaz.", 2);
                  }
                } else {
                  context.extensionShowErrorSnackBar(
                      message: "Kay??tl?? bir ??r??n kodu girdiniz.");
                }
              } else {
                context.extensionShowErrorSnackBar(
                    message: "L??tfen Gerekli Alanlar?? Doldurun");
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
          FormatterDecimalThreeByThree(),
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
                      "${convertStringToCurrencyDigitThreeByThree.convertStringToDigit3By3(value.toString())} $_selectUnitOfCurrencySymbol",
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

  ///Tarih se??ildi??i yer.
  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
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
