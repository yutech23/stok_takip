import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/get_keys.dart';
import 'package:stok_takip/validations/format_upper_case_text_format.dart';
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
  final _controlleraddress = TextEditingController();
  final _controllerTaxNumber = TextEditingController();
  final _controllerCargoCode = TextEditingController();
  final _controllerCargoName = TextEditingController();
  final _controllerCompanyName = TextEditingController();
  final _controllerBankName = TextEditingController();
  final _controllerIban = TextEditingController();
  final _controllerSupplierName = TextEditingController();
  final _controllerTC = TextEditingController();

  final String _labelBankName = "Banka İsmi";
  final String _labelCompanyName = "Firma Adını Giriniz";
  final String _labelCustomerName = "Müşteri adını giriniz";
  final String _labelCustomerLastname = "Müşteri Soyadını giriniz";
  final String _labelSupplierName = "Tedarikçi İsmini Giriniz";
  final String _labelTC = "TC Kimlik Numarası giriniz";

  late List<dynamic> listCustomerRegister;

  String? _selectedCity;
  String? _selectDistrict;
  String? _selectedTaxOffice;
  late bool _visibleDistrict;
  Customer? _customer;

  //Müşteri Tipi Seçimini başka stateless Widget Çağırma Callback Func. kullanarak.
  var customerTypeitems = <String>["Şahıs", "Şirket", "Tedarikçi"];
  String? _customerType = "Şahıs";

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
    _controllerIban.text = "TR";
    _customerType = "Şahıs";

    ///İlk ekran açıldığında gelmesi için burası koyuldu. Bir sorun il ilçe seçimini
    ///listenin içine alındığında il seçiminde ilçe çıkmıyor. visible konusu çalışmıyor.
    ///liste içindeki nesneye ulaşılmıyor.
    listeEklemeSahis();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerLastName.dispose();
    _controllerPhoneNumber.dispose();
    _controlleraddress.dispose();
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
      if (_customerType == "Şahıs") {
        listCustomerRegister.clear();
        listeEklemeSahis();
      } else if (_customerType == "Şirket") {
        listCustomerRegister.clear();
        listeEklemeCompany();
      } else if (_customerType == "Tedarikçi") {
        listCustomerRegister.clear();
        listeEklemeSupplier();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Yeni Müşteri Kayıt Formu"),
        // ignore: prefer_const_literals_to_create_immutables
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
                widgetRowCityAndDistrict(),
                const Divider(),
                _customerType != "Şahıs"
                    ? widgetTaxOfficeAndTaxCodeInfo()
                    : const SizedBox(),
                _customerType != "Şahıs" ? const Divider() : const SizedBox(),
                _customerType != "Şahıs"
                    ? widgetCargoCompanyAndCargoCode()
                    : const SizedBox(),
                _customerType != "Şahıs" ? const Divider() : const SizedBox(),
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
          return Center(child: listCustomerRegister[index]);
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
          baseStyle: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          dropdownSearchDecoration: InputDecoration(
              hintText: "İl Seçiniz",
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
                ?.changeSelectedItem("İlçe Seçiniz");
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
          baseStyle: const TextStyle(fontWeight: FontWeight.bold),
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
    return Column(
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
            controller: _controlleraddress,
            etiket: "Adres",
            focusValue: false,
            karakterGostermeDurumu: false,
            validationFunc: validateAddress),
      ],
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
          baseStyle: const TextStyle(fontWeight: FontWeight.bold),
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
    return Row(
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
    );
  }

  listeEklemeSahis() {
    //TC Kimlik Numarası girilen biryer.
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
      inputFormat: [FilteringTextInputFormatter.allow(RegExp(r'[\d]'))],
      controller: _controllerTC,
      etiket: _labelTC,
      focusValue: false,
      karakterGostermeDurumu: false,
      maxCharacter: 11,
    ));
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerName,
        etiket: _labelCustomerName,
        focusValue: false,
        karakterGostermeDurumu: false,
        validationFunc: validateFirstAndLastName));
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerLastName,
        etiket: _labelCustomerLastname,
        focusValue: false,
        karakterGostermeDurumu: false,
        validationFunc: validateFirstAndLastName));
    listCustomerRegister.add(widgetCountryPhoneNumber());
  }

  listeEklemeCompany() {
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerCompanyName,
        etiket: _labelCompanyName,
        validationFunc: validateFirstAndLastName));
    listCustomerRegister.add(widgetCountryPhoneNumber());
  }

  listeEklemeSupplier() {
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerSupplierName,
        etiket: _labelSupplierName,
        validationFunc: validateFirstAndLastName));
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        keyboardInputType: TextInputType.name,
        controller: _controllerBankName,
        etiket: _labelBankName));
    listCustomerRegister
        .add(shareWidget.widgetTextFieldIban(controller: _controllerIban));
    listCustomerRegister.add(widgetCountryPhoneNumber());
  }

  widgetCargoCompanyAndCargoCode() {
    return Row(
      children: [
        Expanded(
          child: shareWidget.widgetTextFieldInput(
            controller: _controllerCargoName,
            etiket: "Kargo Firma Adını Giriniz",
          ),
        ),
        context.extensionWidhSizedBox20(),
        Expanded(
          child: shareWidget.widgetTextFieldInput(
            controller: _controllerCargoCode,
            etiket: "Kargo Kodu Giriniz",
          ),
        ),
      ],
    );
  }

  ///Deprecated Sadece Türkçe numara için özel widget yapısı.
  widgetPhoneNumber() {
    return Container(
      child: shareWidget.widgetTextFormFieldPhone(
          controllerPhoneNumber: _controllerPhoneNumber,
          validateFunc: validateNotEmpty),
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
          setState(() {
            if (_formKey.currentState!.validate()) {
              if (_customerType == 'Şahıs') {
                _customer = Customer.soleTrader(
                  soleTraderName: _controllerName.text,
                  soleTraderLastName: _controllerLastName.text,
                  phone: Sabitler.countryCode + _controllerPhoneNumber.text,
                  city: _selectedCity,
                  district: _selectDistrict,
                  address: _controlleraddress.text,
                  TCno: _controllerTC.text,
                );

                db.saveCustomerSoleTrader(_customer!).then((resValue) {
                  if (resValue.isEmpty) {
                    _controllerName.clear();
                    _controllerLastName.clear();
                    _controllerCompanyName.clear();
                    _controllerPhoneNumber.clear();
                    _selectDistrict = "";
                    _selectedCity = "";
                    _selectedTaxOffice = "";
                    _controlleraddress.clear();
                    _controllerTC.clear();

                    context.noticeBarTrue("Kayıt Başarılı", 2);
                  } else {
                    context.noticeBarError("Kayıt Başarısız", 2);
                  }
                });
              } else if (_customerType == 'Şirket') {
                _customer = Customer.company(
                    companyName: _controllerCompanyName.text,
                    phone: Sabitler.countryCode + _controllerPhoneNumber.text,
                    city: _selectedCity,
                    district: _selectDistrict,
                    address: _controlleraddress.text,
                    taxOffice: _selectedTaxOffice,
                    taxNumber: _controllerTaxNumber.text,
                    cargoName: _controllerCargoName.text,
                    cargoNumber: _controllerCargoCode.text);

                db.saveCustomerCompany(_customer!).then((resValue) {
                  if (resValue.isEmpty) {
                    _controllerName.clear();
                    _controllerLastName.clear();
                    _controllerCompanyName.clear();
                    _controllerPhoneNumber.clear();
                    _controlleraddress.clear();
                    _controllerTaxNumber.clear();
                    _controllerCargoName.clear();
                    _controllerCargoCode.clear();
                    context.noticeBarTrue("Kayıt Başarılı", 2);
                  } else {
                    context.noticeBarError("Kayıt Başarısız", 2);
                  }
                });
              } else if (_customerType == 'Tedarikçi') {
                ///
                String? iban;
                if (_controllerIban.text.length > 2) {
                  iban = _controllerIban.text.replaceAll(" ", "");
                } else {
                  iban = null;
                }
                _customer = Customer.supplier(
                    supplierName: _controllerSupplierName.text,
                    bankName: _controllerBankName.text,
                    iban: iban,
                    phone: Sabitler.countryCode + _controllerPhoneNumber.text,
                    city: _selectedCity,
                    district: _selectDistrict,
                    address: _controlleraddress.text,
                    taxOffice: _selectedTaxOffice,
                    taxNumber: _controllerTaxNumber.text,
                    cargoName: _controllerCargoName.text,
                    cargoNumber: _controllerCargoCode.text);

                db.saveSuppliers(_customer!).then((value) {
                  if (value.isEmpty) {
                    _controllerSupplierName.clear();
                    _controllerBankName.clear();
                    _controllerIban.clear();
                    _controllerName.clear();
                    _controllerLastName.clear();
                    _controllerCompanyName.clear();
                    _controllerPhoneNumber.clear();
                    _controlleraddress.clear();
                    _controllerTaxNumber.clear();
                    _controllerCargoName.clear();
                    _controllerCargoCode.clear();
                    context.noticeBarTrue("Kayıt Başarılı", 2);
                  } else {
                    context.noticeBarError("Kayıt Başarısız", 2);
                  }
                });
              } else if (_customerType == null) {
                context.extensionShowErrorSnackBar(
                    message: "Lütfen Firma Türünü Seçiniz");
              }

              /// save yapar iken Firma Türü seçilmediğinde veya eksik validate
              /// olduğunda doldurulan değerleri sıfırlıyor. var responce; degeri
              /// ataması yapıldığında database değer dönmediğinde gene Null oluyor.
              /// buda sıfırlama yapıyor. Bu yüzden int? degeri belirlenmesi ve database
              /// dönen değer 1 eşitleniyor.

            }
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
