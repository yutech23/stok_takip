import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/get_keys.dart';
import 'package:stok_takip/validations/validation.dart';
import '../utilities/constants.dart';
import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';

class ReferanceByPass {
  int? value;
}

class ScreenCustomerRegister extends StatefulWidget {
  const ScreenCustomerRegister({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ScreenCustomerSave();
  }
}

class _ScreenCustomerSave extends State with Validation {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _controllerName = TextEditingController();
  final _controllerLastName = TextEditingController();
  final _controllerPhoneNumber = TextEditingController();
  final _controllerAdress = TextEditingController();
  final _controllerTaxNumber = TextEditingController();
  final _controllerCargoCode = TextEditingController();
  final _controllerCargoName = TextEditingController();
  final _controllerCompanyName = TextEditingController();

  late List<dynamic> listCustomerRegister;

  String? _selectedCity;
  String? _selectDistrict;
  String? _selectedTaxOffice;
  late bool _visibleDistrict;
  Customer? _customer;

  //Müşteri Tipi Seçimini başka stateless Widget Çağırma Callback Func. kullanarak.
  var customerTypeitems = <String>[
    "Şahıs Firma",
    "Kurumsal Firma",
    "Tedarikci"
  ];
  String? _customerType;
  void _getCustomerType(String value) {
    setState(() {
      _customerType = value;
      _fillListViewByRoleType();
    });
  }

  @override
  void initState() {
    super.initState();
    listCustomerRegister = <dynamic>[];
    _visibleDistrict = false;
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerLastName.dispose();
    _controllerPhoneNumber.dispose();
    _controllerAdress.dispose();
    _controllerTaxNumber.dispose();
    _controllerCargoCode.dispose();
    _controllerCargoName.dispose();
    _controllerCompanyName.dispose();
    _formKey.currentState!.dispose();
    super.dispose();
  }

  //DropdownButtonFormField farklı bir sınıftan setState Fonksiyonu ile veri almak için kullanılan Contrast yapısı.
  void _fillListViewByRoleType() {
    setState(() {
      if (_customerType == "Şahıs Firma") {
        listCustomerRegister.clear();
        listeEklemeSahis();
      } else if (_customerType == "Kurumsal Firma" ||
          _customerType == "Tedarikci") {
        listCustomerRegister.clear();
        listeEklemeCompanyAndSupplier();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Müşteri Kayıt Formu"),
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildCustomerRegister(),
      drawer: const MyDrawer(),
    );
  }

  ///Widget ların oluşturulduğu builder Fonksiyonu
  buildCustomerRegister() {
    return Form(
        key: _formKey,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: context.extensionThemaGreyContainer(),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              padding: context.extensionPadding20(),
              alignment: Alignment.center,
              decoration: context.extensionThemaWhiteContainer(),
              constraints: const BoxConstraints(minWidth: 360, maxWidth: 750),
              child: Column(children: [
                const Divider(),
                ShareDropdown(
                    hint: "Müşteri Tipini Seçiniz.",
                    itemList: customerTypeitems,
                    selectValue: _customerType,
                    getShareDropdownCallbackFunc: _getCustomerType),
                widgetListCustomerInformationInput(),
                //Deprecated yaptım.
                //  widgetPhoneNumber(),
                widgetCountryPhoneNumber(),
                const Divider(),
                widgetRowCityAndDistrict(),
                const Divider(),
                widgetTaxOfficeAndTaxCodeInfo(),
                const Divider(),
                widgetCargoCompanyAndCargoCode(),
                const Divider(),
                widgetCustomerSaveButton(),
                const Divider(),
              ]),
            ),
          ),
        ));
  }

//Müşteri bilgilerin girildiği input listesini içerir.
  ListView widgetListCustomerInformationInput() {
    return ListView.separated(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        shrinkWrap: true,
        itemCount: listCustomerRegister.length,
        itemBuilder: ((context, index) {
          return Container(
            child: Center(child: listCustomerRegister[index]),
          );
        }),
        separatorBuilder: (context, index) => const Divider(
              color: Colors.transparent,
            ));
  }

  ///Şehirleri sıralayan SearchDropdown
  Theme widgetSearchDropdownCities() {
    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
            subtitle1: TextStyle(
                locale: Locale('tr', 'TR'),
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      child: DropdownSearch<String>(
        asyncItems: (value) => db.getCities(value),
        selectedItem: _selectedCity,
        popupProps: const PopupProps.menu(
          menuProps: MenuProps(
            elevation: 50,
          ),
          showSearchBox: true,
          showSelectedItems: true,
          searchFieldProps: TextFieldProps(
              autofocus: true,
              decoration: InputDecoration(
                  prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.black,
                size: 35,
              ))),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          textAlign: TextAlign.center,
          dropdownSearchDecoration: InputDecoration(
              hintText: "Lütfen İl Seçiniz",
              hintStyle: context.theme.headline6!
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1))),
        ),
        onChanged: (value) {
          _selectedCity = value;
          setState(() {
            if (!_visibleDistrict) {
              _visibleDistrict = true;
            }

            GetKeys.keyDistrict.currentState
                ?.changeSelectedItem("Lütfen İlçe Seçiniz");
          });
        },
      ),
    );
  }

  ///Şehire Göre İlçeleri Sıralıyor
  Theme widgetSearchDropdownDistrict() {
    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
            subtitle1: TextStyle(
                locale: Locale('tr', 'TR'),
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      child: DropdownSearch<String>(
        enabled: _visibleDistrict,
        asyncItems: (value) => db.getDistricts(value, _selectedCity!),
        selectedItem: _selectDistrict,
        popupProps: const PopupProps.menu(
          menuProps: MenuProps(
            elevation: 50,
          ),
          showSearchBox: true,
          showSelectedItems: true,
          searchFieldProps: TextFieldProps(
              autofocus: true,
              decoration: InputDecoration(
                  prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.black,
                size: 35,
              ))),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          textAlign: TextAlign.center,
          dropdownSearchDecoration: InputDecoration(
              hintText: "İlk Önce İl Seçiniz",
              hintStyle: context.theme.headline6!
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1))),
        ),
        onChanged: (value) {
          _selectDistrict = value;
        },
      ),
    );
  }

//İl ve İlçe Satır Fonksiyonu
  widgetRowCityAndDistrict() {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: widgetSearchDropdownCities(),
              ),
              context.extensionWidhSizedBox20(),
              Expanded(child: widgetSearchDropdownDistrict()),
            ],
          ),
          const Divider(color: Colors.transparent),
          shareWidget.widgetTextFieldInput(
              controller: _controllerAdress,
              etiket: "Adres",
              focusValue: false,
              karakterGostermeDurumu: false,
              validationFunc: validateAddress),
        ],
      ),
    );
  }

  ///Vergi Daire Listesi
  widgetSearchDropdownTaxOfficeList() {
    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
            subtitle1: TextStyle(
                locale: Locale('tr', 'TR'),
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      child: DropdownSearch<String>(
        asyncItems: (value) => db.getTaxOfficeList(value, _selectedCity!),
        selectedItem: _selectedTaxOffice,
        popupProps: const PopupProps.menu(
          menuProps: MenuProps(
            elevation: 50,
          ),
          showSearchBox: true,
          showSelectedItems: true,
          searchFieldProps: TextFieldProps(
              autofocus: true,
              decoration: InputDecoration(
                  prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.black,
                size: 35,
              ))),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          textAlign: TextAlign.center,
          dropdownSearchDecoration: InputDecoration(
              hintText: "Vergi Dairesini Seçiniz",
              hintStyle: context.theme.headline6!
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1))),
        ),
        onChanged: (value) {
          _selectedTaxOffice = value;
        },
      ),
    );
  }

  ///Vergi Daire ve Vergi Numara Satırı
  widgetTaxOfficeAndTaxCodeInfo() {
    return Container(
      child: Row(
        children: [
          Expanded(child: widgetSearchDropdownTaxOfficeList()),
          context.extensionWidhSizedBox20(),
          Expanded(
              child: shareWidget.widgetTextFieldInput(
                  controller: _controllerTaxNumber,
                  etiket: "Vergi Numaranızı Giriniz",
                  focusValue: false,
                  karakterGostermeDurumu: false,
                  maxCharacter: 11,
                  validationFunc: validateTaxNumber,
                  inputFormat: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]"))
              ]))
        ],
      ),
    );
  }

  listeEklemeSahis() {
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        controller: _controllerName,
        etiket: "Müşteri adını giriniz",
        focusValue: false,
        karakterGostermeDurumu: false,
        validationFunc: validateFirstAndLastName));
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        controller: _controllerLastName,
        etiket: "Müşteri Soyadını giriniz",
        focusValue: false,
        karakterGostermeDurumu: false,
        validationFunc: validateFirstAndLastName));
  }

  listeEklemeCompanyAndSupplier() {
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        controller: _controllerCompanyName,
        etiket: "Fima adını giriniz",
        focusValue: false,
        karakterGostermeDurumu: false,
        validationFunc: validateFirstAndLastName));
  }

  Container widgetCargoCompanyAndCargoCode() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: shareWidget.widgetTextFieldInput(
                controller: _controllerCargoName,
                etiket: "Kargo Firma Adını Giriniz",
                validationFunc: validatenNotEmpty),
          ),
          context.extensionWidhSizedBox20(),
          Expanded(
            child: shareWidget.widgetTextFieldInput(
                controller: _controllerCargoCode,
                etiket: "Kargo Kodu Giriniz",
                validationFunc: validatenNotEmpty),
          ),
        ],
      ),
    );
  }

  ///Deprecated Sadece Türkçe numara için özel widget yapısı.
  widgetPhoneNumber() {
    return Container(
      child: shareWidget.widgetTextFormFieldPhone(
          controllerPhoneNumber: _controllerPhoneNumber,
          validateFunc: validatenNotEmpty),
    );
  }

//Country Telefon Numarası widget Search kısmına autoFocus Eklendi Kütüphaneden
  widgetCountryPhoneNumber() {
    return Container(
      child: shareWidget.widgetIntlPhoneField(
        controllerPhoneNumber: _controllerPhoneNumber,
      ),
    );
  }

  widgetCustomerSaveButton() {
    return ElevatedButton(
        onPressed: () async {
          ///Butona  basıldığında tüm form içindeki validetion aktif ediyor.
          ///Key kavramı ile.
          _formKey.currentState!.validate();
          setState(() {
            if (_customerType == 'Şahıs Firma') {
              _customer = Customer.soleTrader(
                  type: _customerType!,
                  soleTraderName: _controllerName.text,
                  soleTraderLastName: _controllerLastName.text,
                  phone: Sabitler.countryCode + _controllerPhoneNumber.text,
                  city: _selectedCity,
                  district: _selectDistrict,
                  adress: _controllerAdress.text,
                  taxOffice: _selectedTaxOffice,
                  taxNumber: _controllerTaxNumber.text,
                  cargoName: _controllerCargoName.text,
                  cargoNumber: _controllerCargoCode.text);

              ///Telefon Bölümünde alan kodu otamatik olarak geldiği için ve
              /// en az 4 karakter gelebiliyor.Bu yüzden Telefon bölümü validate
              /// atlıyor. Bu yüzden buradaki if yapısı ile kontrol ediyorum.
              if (_controllerPhoneNumber.text.length > 4) {
                db.saveCustomerSoleTrader(context, _customer!).then((value) {
                  if (value == null) {
                    Duration(seconds: 2);
                    _controllerName.clear();
                    _controllerLastName.clear();
                    _controllerCompanyName.clear();
                    _controllerPhoneNumber.clear();
                    _selectDistrict = "";
                    _selectedCity = "";
                    _selectedTaxOffice = "";
                    _controllerAdress.clear();
                    _controllerTaxNumber.clear();
                    _controllerCargoName.clear();
                    _controllerCargoCode.clear();
                  }
                });
              } else {
                context.extensionShowErrorSnackBar(
                    message: "Lütfen Telefon Numarısını Giriniz.");
              }
            } else if (_customerType == 'Kurumsal Firma' ||
                _customerType == "Tedarikci") {
              _customer = Customer.company(
                  type: _customerType!,
                  companyName: _controllerCompanyName.text,
                  phone: Sabitler.countryCode + _controllerPhoneNumber.text,
                  city: _selectedCity,
                  district: _selectDistrict,
                  adress: _controllerAdress.text,
                  taxOffice: _selectedTaxOffice,
                  taxNumber: _controllerTaxNumber.text,
                  cargoName: _controllerCargoName.text,
                  cargoNumber: _controllerCargoCode.text);

              if (_controllerPhoneNumber.text.length > 4 &&
                  _controllerCompanyName.text.isNotEmpty &&
                  _controllerTaxNumber.text.isNotEmpty) {
                db.saveCustomerCompany(context, _customer!).then((value) {
                  const Duration(seconds: 2);
                  if (value == null) {
                    _controllerName.clear();
                    _controllerLastName.clear();
                    _controllerCompanyName.clear();
                    _controllerPhoneNumber.clear();
                    _controllerAdress.clear();
                    _controllerTaxNumber.clear();
                    _controllerCargoName.clear();
                    _controllerCargoCode.clear();
                  }
                });
              } else {
                context.extensionShowErrorSnackBar(
                    message: "Zorunlu Alanları Doldurunuz");
              }
            } else if (_customerType == null) {
              context.extensionShowErrorSnackBar(
                  message: "Lütfen Firma Türünü Seçiniz");
            }

            /// save yapar iken Firma Türü seçilmediğinde veya eksik validate
            /// olduğunda doldurulan değerleri sıfırlıyor. var responce; degeri
            /// ataması yapıldığında database değer dönmediğinde gene Null oluyor.
            /// buda sıfırlama yapıyor. Bu yüzden int? degeri belirlenmesi ve database
            /// dönen değer 1 eşitleniyor.
          });
        },
        child: Container(
          alignment: Alignment.center,
          height: 50,
          // ignore: prefer_const_constructors
          child: Text(
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            "KAYIT",
          ),
        ));
  }
}
