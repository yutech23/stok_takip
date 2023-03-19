import 'dart:async';

import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/models/payment.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_func.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import '../data/database_category_product_filtre.dart';
import '../data/database_helper.dart';
import '../data/database_mango.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import '../modified_lib/searchfield.dart';
import '../utilities/convert_string_currency_digits.dart';
import '../utilities/custom_dropdown/widget_dropdown_map_type.dart';
import '../utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/format_decimal_3by3_financial.dart';
import '../validations/format_decimal_limit.dart';
import '../validations/format_upper_case_text_format.dart';
import '../validations/validation.dart';
import 'drawer.dart';

class ScreenStockEdit extends StatefulWidget {
  const ScreenStockEdit({Key? key}) : super(key: key);

  @override
  State<ScreenStockEdit> createState() => _ScreenStockEditState();
}

class _ScreenStockEditState extends State<ScreenStockEdit> with Validation {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final List<Map<int, String>> _category1;
  late final List<Map<int, String>> _category2;
  late final List<Map<int, String>> _category3;
  late final List<Map<int, String>> _category4;
  late final List<Map<int, String>> _category5;

  final TextEditingController _controllerTextProductCode =
      TextEditingController();

  bool _disableCategory1 = false;
  bool _disableCategory2 = false;
  bool _disableCategory3 = false;
  bool _disableCategory4 = false;
  bool _disableCategory5 = false;

/*-------------Update Bölümü için------------- */
  final _controllerSupplier = TextEditingController();
  final FocusNode _searchFocusSupplier = FocusNode();
  final String _labelInvoiceCode = "Fatura Kodu";
  final String _labelSearchSuppiler = "Tedarikci İsmini Giriniz";

  final _controllerInvoiceCode = TextEditingController();
  final _valueNotifierPaid = ValueNotifier<double>(0);
  final _valueNotifierBalance = ValueNotifier<double>(0);
  final _valueNotifierButtonDateTimeState = ValueNotifier<bool>(false);
  final _controllerPaymentTotal = TextEditingController();
  final _controllerCashValue = TextEditingController();
  final _controllerBankValue = TextEditingController();
  final _controllerEftHavaleValue = TextEditingController();

  final String _totalPayment = "Toplam Tutarı Giriniz";
  final String _balance = "Kalan Tutar : ";
  final String _paid = "Ödenen Toplam Tutar : ";
  final String _cash = "Nakit İle Ödenen Tutar";
  final String _eftHavale = "EFT/HAVALE İle Ödenen Tutar";
  final String _bankCard = "Kart İle Ödenen Tutar";
  String _buttonDateTimeLabel = "Ödeme Tarihi Ekle";
  final String _labelCurrencySelect = "Para Birimi Seçiniz";
  final String _labelKDV = "KDV Oranın Seçiniz";

  final String _paymentSections = "Ödeme Bölümü";
  String? _selectDateTime;
  final double _shareTextFormFieldPaymentSystemWidth = 250;
  double _cashValue = 0, _bankValue = 0, _eftHavaleValue = 0;
  double _totalPaymentValue = 0;

  late Color _colorBackgroundCurrencyUSD;
  late Color _colorBackgroundCurrencyTRY;
  late Color _colorBackgroundCurrencyEUR;
  late String _selectUnitOfCurrencySymbol;
  late String _selectUnitOfCurrencyAbridgment;

  final Map<String, dynamic> _mapUnitOfCurrency = {
    "Türkiye": {"symbol": "₺", "abridgment": "TL"},
    "amerika": {"symbol": '\$', "abridgment": "USD"},
    "avrupa": {"symbol": '€', "abridgment": "EURO"}
  };

  /*-------------------------END UPDATE------------------------------*/
  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  int? _selectedCategory1Id;

  final String _labelFooterPageRowCount = "Sayfa Satır Sayısı:";

  void _getCategory1(int? value) {
    setState(() {
      _selectedCategory1Id = value;
      _selectedCategory2Id = null;
      _selectedCategory3Id = null;
      _selectedCategory4Id = null;
      _selectedCategory5Id = null;
      _disableCategory1 = false;
      _disableCategory2 = false;
      _disableCategory3 = true;
      _disableCategory4 = true;
      _disableCategory5 = true;
    });
  }

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  int? _selectedCategory2Id;

  void _getCategory2(int? value) {
    setState(() {
      _selectedCategory2Id = value;
      _selectedCategory3Id = null;
      _selectedCategory4Id = null;
      _selectedCategory5Id = null;
      _disableCategory1 = false;
      _disableCategory2 = false;
      _disableCategory3 = false;
      _disableCategory4 = true;
      _disableCategory5 = true;
    });
  }

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  int? _selectedCategory3Id;

  void _getCategory3(int? value) {
    setState(() {
      _selectedCategory3Id = value;
      _selectedCategory4Id = null;
      _selectedCategory5Id = null;
      _disableCategory1 = false;
      _disableCategory2 = false;
      _disableCategory3 = false;
      _disableCategory4 = false;
      _disableCategory5 = true;
    });
  }

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  int? _selectedCategory4Id;

  void _getCategory4(int? value) {
    setState(() {
      _selectedCategory4Id = value;
      _selectedCategory5Id = null;
      _disableCategory1 = false;
      _disableCategory2 = false;
      _disableCategory3 = false;
      _disableCategory4 = false;
      _disableCategory5 = false;
    });
  }

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  int? _selectedCategory5Id;

  void _getCategory5(int? value) {
    setState(() {
      _selectedCategory5Id = value;
    });
  }

  ///***************DataTable AYARLARI******************************************
  late List<Map<String, dynamic>> _sourceProductTableOrjinal;
  late List<Map<String, dynamic>> _sourceProductTableOrjinalRange;
  late List<Map<String, dynamic>> _sourceProductTableSearch;
  late List<Map<String, dynamic>> _sourceProductTableSearchRange;
  late List<Map<String, dynamic>> _sourceProductTableFiltre;
  late List<Map<String, dynamic>> _sourceProductTableFiltreRange;

  late List<List<Map<String, dynamic>>> _sourceList;

  static bool _editState = false;
  int _status = 0;
  int _totalNumberOfProduct = 0;

  final List<Map<String, dynamic>> _selected = [];
  final List<int> _rowPerPages = [10, 20, 50, 100];
  int? _numberOfRowsPerPage = 10;
  int _listLength = 0;
  int _listBegin = 0;
  int _listEnd = 10;
  int _upperBound = 10;
  int _lowerBound = 1;
  int _whichSource = 1;
  int _lenghtFiltre = 0;
  bool _absorbingFotters = true;

  List<bool>? _expanded;
  late final List<DatatableHeader> _headers;
  Stream<List<Map<String, dynamic>>>? _stream;
  String? _selectedSearchValue;

  final _productTaxList = <String>['% 0', '% 8', '% 18'];

  String? _selectedTaxValueString;
  int? _selectedTaxValueInt;

  ///KDV seçilip Seçilmediğini kontrol ediyorum.
  bool _selectedTax = true;

  void _getProductTax(String value) {
    setState(() {
      ///TODO: KDV DEĞİŞTİRDİĞİNDE VERGİLER DAHİL SATIŞ DEĞİŞMİYOR BURADA
      ///VALUENOTİFİER DEĞİERİNİ ALIP KDV'SİZ YAPIP YENİ KDV EKLEYEREK ATAM YAPILMALI

      _selectedTaxValueInt = int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    });

    _selectedTax = true;
  }

  @override
  void initState() {
    /* if (Sabitler.token != null) {
      print(Sabitler.token);
      db.supabase.auth.setAuth(Sabitler.token!);
    } */

    /*  WidgetsBinding.instance.addPostFrameCallback((_) {
      if (db.supabase.auth.session() == null) {
        Navigator.of(context).pushNamed('/');
      }
    }); */

    /*    print("---------------------------");

    userSession.sessionManager.get("id").then((value) => print(value));
    userSession.sessionManager.get("name").then((value) => print(value));
    userSession.sessionManager.get("lastName").then((value) => print(value));
    userSession.sessionManager.get("token").then((value) => print(value));
    userSession.sessionManager.get("role").then((value) => print(value));
    userSession.sessionManager
        .get("refreshToken")
        .then((value) => print(value));
    print("---------------------------"); */

    _category1 = [];
    _category2 = [];
    _category3 = [];
    _category4 = [];
    _category5 = [];

    _sourceProductTableOrjinalRange = [];
    _sourceProductTableSearch = [];
    _sourceProductTableOrjinal = [];
    _sourceProductTableSearchRange = [];
    _sourceProductTableFiltre = [];
    _sourceProductTableFiltreRange = [];
    _sourceList = [];
    _sourceList.add(_sourceProductTableOrjinal);
    _sourceList.add(_sourceProductTableOrjinalRange);
    _sourceList.add(_sourceProductTableFiltre);
    _sourceList.add(_sourceProductTableFiltreRange);
    _sourceList.add(_sourceProductTableSearch);
    _sourceList.add(_sourceProductTableSearchRange);

    _stream = db.fetchProductDetail();
    _headers = [];
    _headers.add(DatatableHeader(
        text: "Ürün Kodu",
        value: "productCode",
        show: true,
        flex: 2,
        sortable: true,
        editable: false,
        textAlign: TextAlign.left));
    _headers.add(DatatableHeader(
        text: "Alış Fiyatı(KDV Hariç)",
        value: "buyingPriceWithoutTax",
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Satış Fiyatı(KDV Hariç)",
        value: "sallingPriceWithoutTax",
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Alış Fiyatı(KDV Dahil)",
        value: "buyingPriceTax",
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Satış Fiyatı(KDV Dahil)",
        value: "sallingPriceTax",
        show: true,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Stok Sayısı",
        value: "amountOfStock",
        show: true,
        sortable: false,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Güncelleme \n Ve Silme",
        value: "update",
        show: true,
        sortable: false,
        sourceBuilder: (value, row) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ///Update Buttonu
              IconButton(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.edit),
                onPressed: () {
                  for (var productValue in _sourceList[0]) {
                    if (productValue['productCode'] == row['productCode']) {
                      var category = Category();
                      category.category1Id = productValue['category1Id'];
                      category.category2Id = productValue['category2Id'];
                      category.category3Id = productValue['category3Id'];
                      category.category4Id = productValue['category4Id'];
                      category.category5Id = productValue['category5Id'];

                      Product selectProduct = Product(
                          productCode: productValue['productCode'],
                          currentAmountOfStock: productValue['amountOfStock'],
                          taxRate: productValue['taxRate'],
                          currentBuyingPriceWithoutTax: double.parse(
                              productValue['buyingPriceWithoutTax']),
                          currentSallingPriceWithoutTax: double.parse(
                              productValue['sallingPriceWithoutTax']),
                          category: category);

                      widgetUpdateProductPriceAndStock(selectProduct);
                      break;
                    }
                  }
                },
              ),

              ///Silme Buttonu
              IconButton(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.delete),
                onPressed: () {
                  ///Stok bitmeden silmeyi engelliyor.
                  if (row['amountOfStock'] == 0) {
                    widgetDeleteProduct(row['productCode']);
                  } else {
                    context.extensionShowErrorSnackBar(
                        message: "Stok bitmediği için silemezsiniz.");
                  }
                },
              ),
            ],
          );
        },
        textAlign: TextAlign.center));

    /*------------UPDATE---------------*/
    _selectUnitOfCurrencySymbol = _mapUnitOfCurrency["Türkiye"]["symbol"];
    _selectUnitOfCurrencyAbridgment =
        _mapUnitOfCurrency["Türkiye"]["abridgment"];

    _colorBackgroundCurrencyUSD = context.extensionDefaultColor;
    _colorBackgroundCurrencyTRY = context.extensionDisableColor;
    _colorBackgroundCurrencyEUR = context.extensionDefaultColor;
    /**---------------------------------------------------------- */

    super.initState();
  }

  @override
  void dispose() {
    _controllerTextProductCode.dispose();
    _category1 = [];
    _category2 = [];
    _category3 = [];
    _category4 = [];
    _category5 = [];
    _headers = [];
    _sourceProductTableOrjinalRange = [];
    _sourceProductTableSearch = [];
    _sourceProductTableOrjinal = [];
    _sourceProductTableSearchRange = [];
    _sourceProductTableFiltre = [];
    _sourceProductTableFiltreRange = [];
    _sourceList = [];

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Stok Güncelleme Ekranı"),
        actionsIconTheme: IconThemeData(color: Colors.blueGrey.shade100),
        actions: [
          ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildStockEdit(),
      drawer: const MyDrawer(),
    );
  }

  buildStockEdit() {
    return Form(
        key: _formKey,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
            constraints: const BoxConstraints(minWidth: 360, maxWidth: 1000),
            padding: context.extensionPadding20(),
            decoration: context.extensionThemaWhiteContainer(),
            child: Column(
              children: [
                Text(
                  "KATEGORİ FİLTRE",
                  style: context.theme.headlineMedium,
                ),
                const Divider(),
                widgetCategoryFiltreSection(),
                const Divider(
                    color: Colors.blueGrey, thickness: 2.5, height: 40),
                widgetProductTableAndUpdateTable(),
              ],
            ),
          )),
        ));
  }

  widgetCategory1DropdownMenu() {
    return StreamBuilder(
      stream: categoryProductFiltre.fetchCategory1(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasError &&
            snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          List<Map<int, String>> category1 = [];
          for (var element in snapshot.data!) {
            category1.add({element['category1_id']: element['name']});
          }
          return SizedBox(
            width: 220,
            child: ShareDropdownFiltre(
              disable: _disableCategory1,
              hint: "Kategori-1",
              itemList: category1,
              getShareDropdownCallbackFunc: _getCategory1,
              selectValue: _selectedCategory1Id,
            ),
          );
        } else {
          _selectedCategory1Id = null;
          return SizedBox(
            width: 220,
            child: ShareDropdownFiltre(
              disable: true,
              hint: "Kategori-1",
              itemList: _category1,
              getShareDropdownCallbackFunc: _getCategory1,
              selectValue: _selectedCategory1Id,
            ),
          );
        }
      },
    );
  }

  widgetCategory2DropdownMenu(int? selectedCategory1Id) {
    return StreamBuilder(
        stream: categoryProductFiltre.fetchCategory2(selectedCategory1Id),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasError &&
              snapshot.hasData &&
              snapshot.data!.isNotEmpty) {
            List<Map<int, String>> category2 = [];

            for (var element in snapshot.data!) {
              category2.add({element['category2_id']: element['name']});
            }
            //   _selectedCategory2Id = _category2[0].keys.first;
            return Container(
              width: 220,
              child: ShareDropdownFiltre(
                disable: _disableCategory2,
                hint: "Kategori-2",
                itemList: category2,
                getShareDropdownCallbackFunc: _getCategory2,
                selectValue: _selectedCategory2Id,
              ),
            );
          } else {
            _selectedCategory2Id = null;
            return Container(
              width: 220,
              child: ShareDropdownFiltre(
                disable: true,
                hint: "Kategori-2",
                itemList: _category2,
                getShareDropdownCallbackFunc: _getCategory2,
                selectValue: _selectedCategory2Id,
              ),
            );
          }
        });
  }

  widgetCategory3DropdownMenu(int? selectedCategory2Id) {
    return StreamBuilder(
        stream: categoryProductFiltre.fetchCategory3(selectedCategory2Id),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasError &&
              snapshot.hasData &&
              snapshot.data!.isNotEmpty) {
            List<Map<int, String>> category3 = [];

            for (var element in snapshot.data!) {
              category3.add({element['category3_id']: element['name']});
            }

            return Container(
              width: 220,
              child: ShareDropdownFiltre(
                disable: _disableCategory3,
                hint: "Kategori-3",
                itemList: category3,
                getShareDropdownCallbackFunc: _getCategory3,
                selectValue: _selectedCategory3Id,
              ),
            );
          } else {
            _selectedCategory3Id = null;
            return Container(
              width: 220,
              child: ShareDropdownFiltre(
                disable: true,
                hint: "Kategori-3",
                itemList: _category3,
                getShareDropdownCallbackFunc: _getCategory3,
                selectValue: _selectedCategory3Id,
              ),
            );
          }
        });
  }

  widgetCategory4DropdownMenu(int? selectedCategory3Id) {
    return StreamBuilder(
      stream: categoryProductFiltre.fetchCategory4(selectedCategory3Id),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasError &&
            snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          List<Map<int, String>> category4 = [];

          for (var element in snapshot.data!) {
            category4.add({element['category4_id']: element['name']});
          }

          return Container(
            width: 220,
            child: ShareDropdownFiltre(
              disable: _disableCategory4,
              hint: "Kategori-4",
              itemList: category4,
              getShareDropdownCallbackFunc: _getCategory4,
              selectValue: _selectedCategory4Id,
            ),
          );
        } else {
          _selectedCategory4Id = null;
          return Container(
            width: 220,
            child: ShareDropdownFiltre(
              disable: true,
              hint: "Kategori-4",
              itemList: _category4,
              getShareDropdownCallbackFunc: _getCategory4,
              selectValue: _selectedCategory4Id,
            ),
          );
        }
      },
    );
  }

  widgetCategory5DropdownMenu(int? selectedCategory4Id) {
    return StreamBuilder(
      stream: categoryProductFiltre.fetchCategory5(selectedCategory4Id),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasError &&
            snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          List<Map<int, String>> category5 = [];

          for (var element in snapshot.data!) {
            category5.add({element['category5_id']: element['name']});
          }
          //  _selectedCategory5Id = _category5[0].keys.first;
          return Container(
            width: 220,
            child: ShareDropdownFiltre(
              disable: _disableCategory5,
              hint: "Kategori-5",
              itemList: category5,
              getShareDropdownCallbackFunc: _getCategory5,
              selectValue: _selectedCategory5Id,
            ),
          );
        } else {
          _selectedCategory5Id = null;
          return Container(
            width: 220,
            child: ShareDropdownFiltre(
              disable: true,
              hint: "Kategori-5",
              itemList: _category5,
              getShareDropdownCallbackFunc: _getCategory5,
              selectValue: _selectedCategory5Id,
            ),
          );
        }
      },
    );
  }

  widgetProductTableAndUpdateTable() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(
        maxHeight: 600,
      ),
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        clipBehavior: Clip.none,
        child: StreamBuilder(
            stream: _stream!,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && !snapshot.hasError) {
                ///streambuilder başladığında 2 kez verileri dolduruyor o yüzden listeyi
                ///burada temizliyorum.
                if (_editState == false) {
                  _sourceList[0].clear();
                  //  print("snapdata : ${snapshot.data}");
                  for (var item in snapshot.data!) {
                    ///Ürünün sadece Gösterilmek istenen verileri tutuluyor.

                    _sourceList[0].add({
                      //  'productId': item['product_id'],
                      'productCode': item['product_code'],
                      'buyingPriceWithoutTax':
                          (item['current_buying_price_without_tax'] + 0.001)
                              .toStringAsFixed(2),
                      'sallingPriceWithoutTax':
                          (item['current_salling_price_without_tax'] + 0.001)
                              .toStringAsFixed(2),
                      'buyingPriceTax': context
                          .extensionGetPercentageOfNumber(
                              item['current_buying_price_without_tax'],
                              item['tax_rate'])
                          .toStringAsFixed(2),
                      'sallingPriceTax': context
                          .extensionGetPercentageOfNumber(
                              item['current_salling_price_without_tax'],
                              item['tax_rate'])
                          .toStringAsFixed(2),
                      'taxRate': item['tax_rate'],
                      'amountOfStock': item['current_amount_of_stock'],
                      'category1Id': item['fk_category1_id'],
                      'category2Id': item['fk_category2_id'],
                      'category3Id': item['fk_category3_id'],
                      'category4Id': item['fk_category4_id'],
                      'category5Id': item['fk_category5_id'],
                    });
                  }
                }

                ///Satırların tablo içinde genişlemesi gerekiyor yoksa sorun çıkıyor
                ///bu yüzden satır sayısı kadar bool tipi bir liste gerekiyor.
                _expanded =
                    List.generate(_sourceList[0].length, (index) => false);

                ///Search kullanılmaya başlandığında buraya _reapterBolok 1 artarak
                ///gelir. ve bu bölüm çalışmaz Burası çalıştığında ileri - geri ikonu
                ///sorun çıkıyor.

                if (_selectedSearchValue == null &&
                    _selectedCategory1Id == null) {
                  _status = 0;
                } else if (_selectedCategory1Id != null &&
                    _selectedSearchValue == null) {
                  _status = 1;
                } else if (_selectedSearchValue != null &&
                    _selectedCategory1Id == null) {
                  _status = 2;
                } else if (_selectedCategory1Id != null &&
                    _selectedSearchValue != null) {
                  _status = 3;
                }

                ///ilk durumda eğer liste uzunluğu sayfa satırsayısından küçük ise listEnd burada
                ///liste uzunluğunu atamamız lazım.
                if (_status == 0) {
                  _listLength = _sourceList[0].length;
                  if (_numberOfRowsPerPage! > _listLength) {
                    _listEnd = _sourceList[0].length;
                  }
                  _totalNumberOfProduct = _listLength;
                }

                ///ilk sayfa sınırına göre dolduruyor.her kategori seçildiğinde
                ///tekrardan nesneler dolduruluyor ileride farklı bir nesne
                ///dolduracak diye yük binmesi önlendi.
                if (_status == 0) {
                  ///Liste 1 filtre olmadan aralıklık dolduruluyoru.
                  _sourceList[1] =
                      _sourceList[0].getRange(_listBegin, _listEnd).toList();
                } else if (_status == 1) {
                  _absorbingFotters = true;
                  _sourceList[2].clear();
                  if (_selectedCategory1Id != null &&
                      _selectedCategory2Id == null) {
                    ///filtre kullanıldığında Liste-4 dolduruluyor.
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id) {
                        _sourceList[2].add(item);
                      }
                    }
                  } else if (_selectedCategory1Id != null &&
                      _selectedCategory2Id != null &&
                      _selectedCategory3Id == null) {
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id &&
                          item['category2Id'] == _selectedCategory2Id) {
                        _sourceList[2].add(item);
                      }
                    }
                  } else if (_selectedCategory1Id != null &&
                      _selectedCategory2Id != null &&
                      _selectedCategory3Id != null &&
                      _selectedCategory4Id == null) {
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id &&
                          item['category2Id'] == _selectedCategory2Id &&
                          item['category3Id'] == _selectedCategory3Id) {
                        _sourceList[2].add(item);
                      }
                    }
                  } else if (_selectedCategory1Id != null &&
                      _selectedCategory2Id != null &&
                      _selectedCategory3Id != null &&
                      _selectedCategory4Id != null &&
                      _selectedCategory5Id == null) {
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id &&
                          item['category2Id'] == _selectedCategory2Id &&
                          item['category3Id'] == _selectedCategory3Id &&
                          item['category4Id'] == _selectedCategory4Id) {
                        _sourceList[2].add(item);
                      }
                    }
                  } else if (_selectedCategory1Id != null &&
                      _selectedCategory2Id != null &&
                      _selectedCategory3Id != null &&
                      _selectedCategory4Id != null &&
                      _selectedCategory5Id != null) {
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id &&
                          item['category2Id'] == _selectedCategory2Id &&
                          item['category3Id'] == _selectedCategory3Id &&
                          item['category4Id'] == _selectedCategory4Id &&
                          item['category5Id'] == _selectedCategory5Id) {
                        _sourceList[2].add(item);
                      }
                    }
                  }

                  _listLength = _sourceList[2].length;
                  _totalNumberOfProduct = _listLength;

                  ///liste uzunluğu değişti artık terkardan burada belirleniyor.
                  ///sayfa aralığpına göre uzunluk kontrol ediliyor.
                  if (_numberOfRowsPerPage! > _sourceList[2].length) {
                    _listEnd = _sourceList[2].length;
                  }

                  ///Burası Kategori değiştirdiğinde çalışıyor. Bu sayede
                  ///sayfa ayarları tekrar yapılabiliyor.
                  if (_sourceList[2].length != _lenghtFiltre) {
                    _lowerBound = 1;
                    _upperBound = _numberOfRowsPerPage!;
                    _listBegin = 0;
                    if (_numberOfRowsPerPage! > _sourceList[2].length) {
                      _listEnd = _sourceList[2].length;
                    } else {
                      _listEnd = _numberOfRowsPerPage!;
                    }
                  }

                  ///Burası bir üstteki veri için kullanılıyor.
                  _lenghtFiltre = _sourceList[2].length;

                  ///Liste-1 aralıklı filtre verisi dolduruluyor. İlk Liste-1
                  ///stream ediliyor.
                  _sourceList[3] =
                      _sourceList[2].getRange(_listBegin, _listEnd).toList();

                  _whichSource = 3;
                }

                ///Search için Verilerin dolduğu yer. Burada Filtre Seçilmediğinde girer.
                if (_status == 2) {
                  _sourceList[5].clear();
                  _sourceList[5] =
                      _sourceList[4].getRange(_listBegin, _listEnd).toList();
                  _totalNumberOfProduct = _sourceList[4].length;
                  _whichSource = 5;
                }

                /// Search ve Filtre aynı anda çalıştığı yer.
                if (_status == 3) {
                  _absorbingFotters = false;
                  _sourceList[4].clear();
                  if (_selectedCategory1Id != null &&
                      _selectedCategory2Id == null) {
                    ///filtre kullanıldığında Liste-4 dolduruluyor.
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id) {
                        _sourceList[4].add(item);
                      }
                    }
                  } else if (_selectedCategory1Id != null &&
                      _selectedCategory2Id != null &&
                      _selectedCategory3Id == null) {
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id &&
                          item['category2Id'] == _selectedCategory2Id) {
                        _sourceList[4].add(item);
                      }
                    }
                  } else if (_selectedCategory1Id != null &&
                      _selectedCategory2Id != null &&
                      _selectedCategory3Id != null &&
                      _selectedCategory4Id == null) {
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id &&
                          item['category2Id'] == _selectedCategory2Id &&
                          item['category3Id'] == _selectedCategory3Id) {
                        _sourceList[4].add(item);
                      }
                    }
                  } else if (_selectedCategory1Id != null &&
                      _selectedCategory2Id != null &&
                      _selectedCategory3Id != null &&
                      _selectedCategory4Id != null &&
                      _selectedCategory5Id == null) {
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id &&
                          item['category2Id'] == _selectedCategory2Id &&
                          item['category3Id'] == _selectedCategory3Id &&
                          item['category4Id'] == _selectedCategory4Id) {
                        _sourceList[4].add(item);
                      }
                    }
                  } else if (_selectedCategory1Id != null &&
                      _selectedCategory2Id != null &&
                      _selectedCategory3Id != null &&
                      _selectedCategory4Id != null &&
                      _selectedCategory5Id != null) {
                    for (var item in _sourceList[0]) {
                      if (item['category1Id'] == _selectedCategory1Id &&
                          item['category2Id'] == _selectedCategory2Id &&
                          item['category3Id'] == _selectedCategory3Id &&
                          item['category4Id'] == _selectedCategory4Id &&
                          item['category5Id'] == _selectedCategory5Id) {
                        _sourceList[4].add(item);
                      }
                    }
                  }

                  _sourceList[5] = _sourceList[4]
                      .where((element) => element['productCode']
                          .contains(_selectedSearchValue!.toUpperCase()))
                      .toList();

                  _totalNumberOfProduct = _sourceList[5].length;

                  _whichSource = 5;
                }

                _editState = false;
                /*    print(
                    "****************************START**************************");
                print(
                    "**************** ORJİNAL *******************************");
                print("Orjinal(List[0]) : ${_sourceList[0]}");
                print(
                    "******************* Aralıklı Veri **********************");
                print("filtre (List[1]): ${_sourceList[1]}");
                print("******************* SEARCH *******************");
                print("search (List[2]): ${_sourceList[2]}");
                print("***************END***********************");
                print("search_V2 (List[3]): ${_sourceList[3]}");

                print("------------------------------------");
                print("Filtre orjinal (List-4): ${_sourceList[4]}");
                print("------------------------------------");
                print("Filtre Range (List-5): ${_sourceList[5]}");
                print(
                    "Listbegin : $_listBegin , ListEnd : $_listEnd , ListLength : $_listLength");
                print("----------------------sınır---------");
                print("source kaynağı $_whichSource");
                print("statu degeri : $_statu"); */

                return ResponsiveDatatable(
                  reponseScreenSizes: [ScreenSize.xs],

                  ///Search kısmını oluşturuyoruz.
                  actions: [
                    Expanded(
                        child: TextField(
                      controller: _controllerTextProductCode,
                      onChanged: (value) {
                        _selectedSearchValue = value;

                        searchTextFieldFiltre(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Ürün Kodu ile Arama Yapınız',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ))
                  ],
                  headers: _headers,
                  source: _sourceList[_whichSource],
                  selecteds: _selected,
                  expanded: _expanded,
                  autoHeight: false,
                  /* commonMobileView: true,
                  dropContainer: (value) {
                    return Text(value['productCode'] +
                        value['amountOfStock'].toString());
                  }, */

                  footers: [
                    Container(
                      height:
                          50, //Fotter kısmın yüksekliği bozulmasın diye belirtim
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: RichText(
                        text: TextSpan(
                            text: "Toplam ürün sayısı : ",
                            style: context.theme.headline6,
                            children: [
                              TextSpan(
                                  text: _totalNumberOfProduct.toString(),
                                  style: context.theme.headline6!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                            ]),
                      ),
                    ),
                    if (_absorbingFotters)
                      for (var items in widgetFooters()) items,
                  ],
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
                );
              } else
                return Container(child: Text('Database bağlanamadı'));
            }),
      ),
    );
  }

  widgetUpdateProductPriceAndStock(Product selectedProduct) {
    final GlobalKey<FormState> keyPopupForm = GlobalKey<FormState>();
    final Map<String, dynamic> productDetailToBeupdateMap = {};
    final valueNotifierProductBuyWithoutTax = ValueNotifier<double>(0);
    final valueNotifierProductSaleWithTax = ValueNotifier<double>(0);
    final controllerProductAmountOfStockNewValue = TextEditingController();
    final controllerSallingPriceWithoutTax = TextEditingController();

    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;
    int? oldStockValue = selectedProduct.currentAmountOfStock;
    double? oldBuyingPriceWithoutTax =
        selectedProduct.currentBuyingPriceWithoutTax!.toDouble();
    int newStockValue;

    ///Gelen Değerler Atanıyor
    /* controllerBuyingPriceWithoutTax.text =
        selectedProduct.currentBuyingPriceWithoutTax.toString();
    controllerSallingPriceWithoutTax.text =
        selectedProduct.currentSallingPriceWithoutTax.toString();

    valueNotifierProductBuyWithTax.value =
        selectedProduct.currentBuyingPriceWithoutTax!;
    valueNotifierProductSaleWithTax.value =
        selectedProduct.currentSallingPriceWithoutTax!; */

    ///gelen değer integer o yüzden tekrar String dönüştürüyorum. Listedeki Tipe
    ///Dropdown seçilen değer
    _selectedTaxValueString = "% ${selectedProduct.taxRate.toString()}";
    //Verfiler Dahil Satış bölümündeki kdv seçinizi yazısı kalkması için.
    _selectedTaxValueInt = selectedProduct.taxRate;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              contentPadding: context.extensionPadding20(),
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                  textAlign: TextAlign.center,
                  'STOK GÜNCELLEME',
                  style: context.theme.headline6!
                      .copyWith(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: keyPopupForm,
                  autovalidateMode: autovalidateMode,
                  child: SizedBox(
                    width: context.extendFixedWightContainer,
                    // constraints: const BoxConstraints(maxHeight: 700),
                    child: Wrap(
                      direction: Axis.horizontal,
                      verticalDirection: VerticalDirection.down,
                      alignment: WrapAlignment.center,
                      spacing: context.extensionWrapSpacing10(),
                      runSpacing: context.extensionWrapSpacing10(),
                      children: [
                        //STOKTA KALAN ÜRÜN BAŞLIK LABEL
                        Container(
                          width: 360,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: Colors.blueGrey.shade700),
                              borderRadius: BorderRadius.circular(15)),
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: 'Stokta Kalan Ürün Sayısı: ',
                                  style: context.theme.headline6!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: selectedProduct.currentAmountOfStock
                                          .toString(),
                                      style: context.theme.headline6!.copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ])),
                        ),
                        const Divider(),
                        widgetSearchTextFieldSupplier(),
                        widgetDividerHeader(_paymentSections),
                        widgetPaymentOptions(
                            controllerProductAmountOfStockNewValue,
                            valueNotifierProductBuyWithoutTax,
                            setState),
                        Divider(
                            color: context.extensionLineColor,
                            endIndent: 30,
                            indent: 30,
                            thickness: 2.5,
                            height: 20),

                        widgetProductUnitSection(
                            controllerProductAmountOfStockNewValue,
                            controllerSallingPriceWithoutTax,
                            valueNotifierProductBuyWithoutTax,
                            valueNotifierProductSaleWithTax)
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                //GÜNCELLEME BUTTON

                ElevatedButton(
                    onPressed: () async {
                      if (keyPopupForm.currentState!.validate()) {
                        ///Yeni verilerin aktarıldığı değişkenler.
                        newStockValue = int.parse(
                            controllerProductAmountOfStockNewValue.text);

                        double newBuyingPriceWithoutTax =
                            valueNotifierProductBuyWithoutTax.value;
                        double newSallingPriceWithoutTax = FormatterConvert()
                            .commaToPointDouble(
                                controllerSallingPriceWithoutTax.text);

                        if (oldStockValue! < 0) {
                          newStockValue = newStockValue + oldStockValue!;
                          oldStockValue = 0;
                        }

                        ///fiyat ortalama hesabı ve yeni fiyatın belirlenmesi
                        double newAverageBuyingPriceWithoutTax =
                            (oldStockValue! * oldBuyingPriceWithoutTax +
                                    newStockValue * newBuyingPriceWithoutTax) /
                                (oldStockValue! + newStockValue);
                        double profit = newSallingPriceWithoutTax -
                            newBuyingPriceWithoutTax;

                        newSallingPriceWithoutTax =
                            newAverageBuyingPriceWithoutTax + profit;

                        ///Test Print
                        /*  print(double.parse(
                            _controllerPaymentTotal.text.replaceAll(".", "")));
                        print(double.tryParse(
                            _controllerCashValue.text.replaceAll(".", "")));
                        print(double.tryParse(
                            _controllerBankValue.text.replaceAll(".", "")));
                        print(double.tryParse(_controllerEftHavaleValue.text
                            .replaceAll(".", "")));
                        print(_selectDateTime);
                        print(controllerProductAmountOfStockNewValue.text);
                        print(_selectUnitOfCurrencyAbridgment);
                        print(_controllerInvoiceCode.text);
                        print(_controllerSupplier.text);
                        print(selectedProduct.productCode);
                        print(newBuyingPriceWithoutTax);
                        print(newSallingPriceWithoutTax); */

                        String? userId = dbHive.getValues('uuid');

                        //Ödeme Nesnesi
                        var newPayment = Payment(
                            invoiceCode: _controllerInvoiceCode.text,
                            suppliersFk: _controllerSupplier.text,
                            productFk: selectedProduct.productCode,
                            unitOfCurrency: _selectUnitOfCurrencyAbridgment,
                            total: FormatterConvert().commaToPointDouble(
                                _controllerPaymentTotal.text),
                            cash: FormatterConvert()
                                .commaToPointDouble(_controllerCashValue.text),
                            bankcard: FormatterConvert()
                                .commaToPointDouble(_controllerBankValue.text),
                            eftHavale: FormatterConvert().commaToPointDouble(
                                _controllerEftHavaleValue.text),
                            buyingPriceWithoutTax: newBuyingPriceWithoutTax,
                            sallingPriceWithoutTax: newSallingPriceWithoutTax,
                            amountOfStock: newStockValue,
                            repaymentDateTime: _selectDateTime,
                            userId: userId!);

                        //Product Nesmesi
                        productDetailToBeupdateMap.addAll({
                          'current_amount_of_stock':
                              (oldStockValue! + newStockValue),
                          'tax_rate': _selectedTaxValueInt,
                          'current_buying_price_without_tax':
                              newAverageBuyingPriceWithoutTax
                                  .toStringAsFixed(2),
                          'current_salling_price_without_tax':
                              newSallingPriceWithoutTax.toStringAsFixed(2),
                        });

                        /// database yüklenen yer.
                        String resDatabase = await db.updateProductDetail(
                            selectedProduct.productCode,
                            productDetailToBeupdateMap,
                            newPayment);

                        if (resDatabase == "") {
                          _controllerPaymentTotal.clear();
                          _controllerBankValue.clear();
                          _controllerCashValue.clear();
                          _controllerEftHavaleValue.clear();
                          _controllerSupplier.clear();
                          _controllerInvoiceCode.clear();
                          _valueNotifierBalance.value = 0;
                          _valueNotifierPaid.value = 0;
                          _selectDateTime = "";
                          controllerProductAmountOfStockNewValue.clear();
                          controllerSallingPriceWithoutTax.clear();
                          _cashValue = 0;
                          _bankValue = 0;
                          _bankValue = 0;

                          context.noticeBarTrue("Kayıt Başarılı", 1);
                        } else {
                          context.noticeBarError(
                              "Kayıt Başarısız : \n $resDatabase", 2);
                        }

                        /// Ekranda görülen verilerin güncellemeleri.
                        for (var element in _sourceList[0]) {
                          if (element['productCode'] ==
                              selectedProduct.productCode) {
                            element['buyingPriceWithoutTax'] =
                                productDetailToBeupdateMap[
                                    'current_buying_price_without_tax'];
                            element['sallingPriceWithoutTax'] =
                                productDetailToBeupdateMap[
                                    'current_salling_price_without_tax'];
                            element['buyingPriceTax'] = (double.parse(
                                        productDetailToBeupdateMap[
                                            'current_buying_price_without_tax']) *
                                    1.18)
                                .toStringAsFixed(2);
                            element['sallingPriceTax'] = (double.parse(
                                        productDetailToBeupdateMap[
                                            'current_salling_price_without_tax']) *
                                    1.18)
                                .toStringAsFixed(2);
                            element['amountOfStock'] =
                                productDetailToBeupdateMap[
                                    'current_amount_of_stock'];
                          }
                        }

                        ///Ekrandali Search özelliği kullanıldağıki veriyi düzenliyor.
                        for (var element in _sourceList[2]) {
                          if (element['productCode'] ==
                              selectedProduct.productCode) {
                            element['buyingPriceWithoutTax'] =
                                productDetailToBeupdateMap[
                                    'current_buying_price_without_tax'];
                            element['sallingPriceWithoutTax'] =
                                productDetailToBeupdateMap[
                                    'current_salling_price_without_tax'];
                            element['buyingPriceTax'] = (double.parse(
                                        productDetailToBeupdateMap[
                                            'current_buying_price_without_tax']) *
                                    1.18)
                                .toStringAsFixed(2);
                            element['sallingPriceTax'] = (double.parse(
                                        productDetailToBeupdateMap[
                                            'current_salling_price_without_tax']) *
                                    1.18)
                                .toStringAsFixed(2);
                            element['amountOfStock'] =
                                productDetailToBeupdateMap[
                                    'current_amount_of_stock'];
                          }
                        }

                        ///Ekrandaki Filtre>Search yapıldığında Liste[3] veriyi düzenliyor.
                        for (var element in _sourceList[3]) {
                          if (element['productCode'] ==
                              selectedProduct.productCode) {
                            element['buyingPriceWithoutTax'] =
                                productDetailToBeupdateMap[
                                    'current_buying_price_without_tax'];
                            element['sallingPriceWithoutTax'] =
                                productDetailToBeupdateMap[
                                    'current_salling_price_without_tax'];
                            element['buyingPriceTax'] = (double.parse(
                                        productDetailToBeupdateMap[
                                            'current_buying_price_without_tax']) *
                                    1.18)
                                .toStringAsFixed(2);
                            element['sallingPriceTax'] = (double.parse(
                                        productDetailToBeupdateMap[
                                            'current_salling_price_without_tax']) *
                                    1.18)
                                .toStringAsFixed(2);
                            element['amountOfStock'] =
                                productDetailToBeupdateMap[
                                    'current_amount_of_stock'];
                          }
                        }

                        ///Eğer 3 sn beklemezse hata veriyor.çünkü
                        ///noticeBar gözüktü widget yok oluyor.
                        Timer(const Duration(seconds: 1, milliseconds: 20), () {
                          Navigator.pop(context);
                        });
                        _editState = true;

                        ///Listeyi güncellemek için bu Mapleri tekrar oluşturuyoruz.
                        setState(() {
                          _sourceList[0];
                          _sourceList[2];
                          _sourceList[3];
                        });
                      } else {
                        context.noticeBarError(
                            'Lütfen bilgileri eksiksiz giriniz.', 5);
                      }
                    },
                    child: Text('Güncelle'))
              ],
            ),
          );
        });
  }

  widgetDeleteProduct(String productCode) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: context.extensionPadding20(),
            actionsAlignment: MainAxisAlignment.center,
            title: Text(
                textAlign: TextAlign.center,
                'Ürünü silmek istediğinizden emin misiniz?',
                style: context.theme.headline6!
                    .copyWith(fontWeight: FontWeight.bold)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Hayır")),
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                        onPressed: () {
                          db.deleteProduct(productCode).then((value) {
                            if (value.isEmpty) {
                              context.noticeBarTrue("İşlem gerçekleşmiştir", 3);
                              setState(() {
                                /// Bellekte yüklenen nesnelerin içinden siliyor.
                                _sourceList[0].removeWhere((element) =>
                                    element['productCode'] == productCode);
                                _sourceList[1].removeWhere((element) {
                                  return element['productCode'] == productCode;
                                });

                                _sourceList[2].removeWhere((element) =>
                                    element['productCode'] == productCode);
                                _sourceList[3].removeWhere((element) {
                                  /*     _deleteListEnd = _listEnd - 1;
                                  _deleteListLength = _listLength - 1;
                                  _deleteState = true;*/

                                  return element['productCode'] == productCode;
                                });
                                _listEnd = _listEnd - 1;
                                _listLength = _listLength - 1;

                                ///bellekteki neseneleri yeniliyor. Çünkü silinince
                                ///nesneler yenilenmiyor.
                                _stream = db.fetchProductDetail();

                                ///stream yenielndiğinde searc içindeki değer kayboluyoru
                                ///bunu önlemek için yapılan iş.
                                _controllerTextProductCode.text =
                                    _selectedSearchValue == null
                                        ? ""
                                        : _selectedSearchValue!;
                              });
                            } else {
                              context.noticeBarError(
                                  "Bir hata ile Karşılaşıldı \n $value", 3);
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Evet")),
                  )
                ],
              ),
            ],
          );
        });
  }

  widgetCategoryFiltreSection() {
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      verticalDirection: VerticalDirection.down,
      spacing: 20,
      runSpacing: 20,
      children: [
        widgetCategory1DropdownMenu(),
        widgetCategory2DropdownMenu(_selectedCategory1Id),
        widgetCategory3DropdownMenu(_selectedCategory2Id),
        widgetCategory4DropdownMenu(_selectedCategory3Id),
        widgetCategory5DropdownMenu(_selectedCategory4Id),
      ],
    );
  }

  searchTextFieldFiltre(String value) {
    if (value.isEmpty && value == "") {
      ///search içine yazılan silindiğinde eski duruma getirilmesi için
      ///Listenin getRange ayarları sıfırlama yapılıyor.
      setState(() {
        _selectedSearchValue = null;
        _lowerBound = 1;
        _upperBound = _numberOfRowsPerPage!;
        _status = 0;
        _listBegin = 0;
        _listEnd = _numberOfRowsPerPage!;

        _whichSource = 1;
        _sourceList[4].clear();
        _sourceList[5].clear();
      });
    } else {
      _lowerBound = 1;
      _upperBound = _numberOfRowsPerPage!;
      _sourceList[4] = _sourceList[0]
          .where(
              (element) => element['productCode'].contains(value.toUpperCase()))
          .toList();

      setState(() {
        _listBegin = 0;
        if (_sourceList[4].length > _numberOfRowsPerPage!) {
          _listEnd = _numberOfRowsPerPage!;
        } else {
          _listEnd = _sourceList[4].length;
        }
        _listLength = _sourceList[4].length;
      });
    }
  }

  List<Widget> widgetFooters() {
    List<Widget> footerList = [];
    footerList.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(_labelFooterPageRowCount),
    ));
    if (_rowPerPages.isNotEmpty) {
      footerList.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: DropdownButton<int>(
          value: _numberOfRowsPerPage,
          items: _rowPerPages
              .map((e) => DropdownMenuItem<int>(
                    child: Text("$e"),
                    value: e,
                  ))
              .toList(),
          onChanged: (dynamic value) {
            setState(() {
              ///Sayfadaki Satır Sayısı değiştirlidiğinde gerekli
              ///ayarlamalar yapılıyor.
              _listBegin = 0;
              _lowerBound = 1;
              _numberOfRowsPerPage = value;
              _upperBound = value;
              if (value > _listLength) {
                _listEnd = _listLength;
              } else {
                _listEnd = value;
              }
            });
          },
          isExpanded: false,
        ),
      ));
    }

    footerList.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text("$_lowerBound - $_upperBound"),
    ));

    footerList.add(IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
        size: 16,
      ),
      onPressed: _lowerBound < 11
          ? null
          : () {
              _lowerBound -= _numberOfRowsPerPage!;
              _upperBound -= _numberOfRowsPerPage!;
              setState(() {
                _listBegin -= _numberOfRowsPerPage!;

                /// yukarıda çıkarma yapıldığı için burada tekrar
                /// ekleme yapılıyor. Yoksa üst sınırı kıyas yapmadan
                /// düşmüş oluyor.
                _upperBound + _numberOfRowsPerPage! > _listEnd
                    ? _listEnd = _upperBound
                    : _listEnd -= _numberOfRowsPerPage!;
              });
            },
      padding: const EdgeInsets.symmetric(horizontal: 15),
    ));
    footerList.add(IconButton(
      icon: const Icon(Icons.arrow_forward_ios, size: 16),
      onPressed: _upperBound + 1 > _listLength
          ? null
          : () {
              _upperBound += _numberOfRowsPerPage!;
              _lowerBound += _numberOfRowsPerPage!;
              setState(() {
                _listBegin += _numberOfRowsPerPage!;
                _upperBound > _listLength
                    ? _listEnd = _listLength
                    : _listEnd += _numberOfRowsPerPage!;
              });
            },
      padding: const EdgeInsets.symmetric(horizontal: 15),
    ));

    return footerList;
  }

  ///Ödeme verilerin alındığı yer.
  widgetPaymentOptions(TextEditingController controllerProductAmountOfStock,
      ValueNotifier valueNotifierProductBuyWithoutTax, StateSetter setState) {
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
          widgetCurrencyAndKdvSection(setState),
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

                    if (controllerProductAmountOfStock.text.isNotEmpty) {
                      valueNotifierProductBuyWithoutTax.value =
                          _totalPaymentValue /
                              FormatterConvert().commaToPointDouble(
                                  controllerProductAmountOfStock.text);
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

  ///Stok Ve KDV
  widgetCurrencyAndKdvSection(StateSetter setState) {
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
        ),
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
              selectValue: _selectedTaxValueString,
              getShareDropdownCallbackFunc: _getProductTax,
            )),
      ],
    );
  }

  ///Maliyet ve Birim Satışı Bölümü.
  widgetProductUnitSection(
      TextEditingController? controllerProductAmountOfStock,
      TextEditingController controllerSallingPriceWithoutTax,
      ValueNotifier<double> valueNotifierProductBuyWithoutTax,
      ValueNotifier<double> valueNotifierProductSaleWithTax) {
    return SizedBox(
      width: 500,
      child: Wrap(
        direction: Axis.horizontal,
        verticalDirection: VerticalDirection.down,
        alignment: WrapAlignment.center,
        spacing: context.extensionWrapSpacing20(),
        runSpacing: context.extensionWrapSpacing10(),
        children: [
          //EKLENECEK ÜRÜN ADETİ
          SizedBox(
            width: 230,
            height: 70,
            child: shareWidget.widgetTextFieldInput(
              etiket: "Eklenecek Ürün (Adeti)",
              maxCharacter: 7,
              inputFormat: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardInputType: TextInputType.number,
              controller: controllerProductAmountOfStock,
              validationFunc: validateNotEmpty,
              onChanged: (p0) {
                //çift taraflı şekilde yapıldı Birim Başı Maliyet Hesaplama
                if (_controllerPaymentTotal.text.isNotEmpty) {
                  if (p0.isNotEmpty) {
                    valueNotifierProductBuyWithoutTax.value =
                        _totalPaymentValue /
                            FormatterConvert().commaToPointDouble(p0);
                  } else {
                    valueNotifierProductBuyWithoutTax.value = 0;
                  }
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
              valueListenable: valueNotifierProductBuyWithoutTax,
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
                              "${FormatterConvert().currencyShow(value)} $_selectUnitOfCurrencySymbol",
                          style: context.theme.labelLarge!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1))
                    ]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          //Vergiler Harıç Satış
          SizedBox(
            width: 230,
            height: 70,
            child: shareWidget.widgetTextFieldInput(
              etiket: 'Vergiler Hariç Satış (Birim Fiyat)',
              inputFormat: [
                FormatterDecimalLimit(decimalRange: 2),
              ],
              controller: controllerSallingPriceWithoutTax,
              validationFunc: validateNotEmpty,
              onChanged: (value) {
                ///TextField içinde yazıp sildiğinde hiç bir karakter kalmayınca isEmpty
                ///dönüyor. Buradaki notifier double olduğu için isEmpty dönmesi sorun bunu
                ///eğer isEmpty is 0 atanıyor. '0' olması sebebi giden değer ile KDV
                ///hesabı yapılıyor.

                value == ""
                    ? valueNotifierProductSaleWithTax.value = 0
                    : valueNotifierProductSaleWithTax.value =
                        FormatterConvert().commaToPointDouble(value);
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
              valueListenable: valueNotifierProductSaleWithTax,
              builder: (context, value, child) {
                return RichText(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ///Tedarikçi Bölümü.
  widgetSearchTextFieldSupplier() {
    double height = 75, width = 250;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width,
          height: height,
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
        context.extensionWidhSizedBox20(),

        ///Tedarikçi Ekleme Buttonu.
        SizedBox(
          width: width,
          height: height,
          child: TextFormField(
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
                    borderSide:
                        BorderSide(color: context.extensionDefaultColor))),
          ),
        ),
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
}
