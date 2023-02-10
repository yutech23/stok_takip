import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/get_keys.dart';
import 'package:stok_takip/validations/format_upper_case_text_format.dart';
import 'package:stok_takip/validations/validation.dart';

import '../constants.dart';
import '../share_widgets.dart';

// ignore: must_be_immutable
class PopupSupplierRegister extends StatefulWidget {
  String newSupplier;
  PopupSupplierRegister(this.newSupplier, {super.key});

  @override
  State<PopupSupplierRegister> createState() => _ScreenCustomerSave();
}

class _ScreenCustomerSave extends State<PopupSupplierRegister> with Validation {
  final GlobalKey<FormState> _formKeySupplier = GlobalKey<FormState>();
  final _controllerCargoName = TextEditingController();
  final _controllerPhoneNumber = TextEditingController();
  final _controlleraddress = TextEditingController();
  final _controllerTaxNumber = TextEditingController();
  final _controllerCargoCode = TextEditingController();
  final _controllerSupplierName = TextEditingController();
  final _controllerIban = TextEditingController();
  final _controllerBankName = TextEditingController();

  late AutovalidateMode _autovalidateMode;

  ///iban Kodları bir sonraki
  /* Map<String, int> ibanLenghtForCountry = {
    "DE": 22,
    "AD": 24,
    "AL": 28,
    "AT": 20,
    "AZ": 28,
    "BH": 22,
    "BY": 28,
    "BE": 16,
    "AE": 23,
    "GB": 22,
    "BA": 20,
    "BR": 29,
    "BG": 22,
    "GI": 23,
    "DK": 18,
    "DO": 28,
    "TL": 23,
    "SV": 28,
    "EE": 20,
    "FO": 18,
    "PS": 29,
    "FI": 18,
    "FR": 27,
    "GL": 18,
    "GT": 28,
    "GE": 22,
    "NL": 18,
    "HR": 21,
    "IE": 22,
    "ES": 24,
    "IL": 23,
    "SE": 24,
    "CH": 21,
    "IT": 27,
    "IS": 26,
    "ME": 22,
    "QA": 29,
    "KZ": 20,
    "XK": 20,
    "CR": 22,
    "KW": 30,
    "CY": 28,
    "LV": 21,
    "LI": 21,
    "LT": 20,
    "LB": 28,
    "LU": 20,
    "HU": 28,
    "MK": 19,
    "MT": 31,
    "MU": 30,
    "MD": 24,
    "MC": 27,
    "MR": 27,
    "NO": 15,
    "PK": 24,
    "PL": 28,
    "PT": 25,
    "RO": 24,
    "LC": 32,
    "SM": 27,
    "ST": 25,
    "SC": 31,
    "SK": 24,
    "SI": 19,
    "SA": 24,
    "RS": 22,
    "TN": 24,
    "TR": 26,
    "UA": 29,
    "VG": 24,
    "GR": 27,
    "CZ": 24,
    "JO": 30,
    "IQ": 23,
  };
 */
  String? _selectedCity;
  String? _selectDistrict;
  String? _selectedTaxOffice;
  late bool _visibleDistrict;
  Customer? _customer;
  final String _headerSupplier = "Yeni Tedarikçi Ekleme";
  final String _labelBankName = "Banka Adı";
  final _labelCargoName = "Kargo Firma Adını Giriniz";
  final _labelCargoCode = "Kargo Kodu Giriniz";

  @override
  void initState() {
    super.initState();
    _controllerIban.text = "TR";
    //   funcIbanLenghtForCountry();
    _visibleDistrict = false;
    _autovalidateMode = AutovalidateMode.onUserInteraction;
    //Diğer Sayfadan Gelen Tedarikçi Adını Aktarıyor.
    _controllerSupplierName.text = widget.newSupplier;
  }

  ///karakter sınırlama için
  /*  void funcIbanLenghtForCountry() {
    ibanLenghtForCountry.forEach((key, value) {
      if (_controllerIban.text == key) {
        _ibanMaxCharacter = value;
      }
    });
  } */

  @override
  void dispose() {
    _controllerPhoneNumber.dispose();
    _controlleraddress.dispose();
    _controllerTaxNumber.dispose();
    _controllerCargoCode.dispose();
    _controllerCargoName.dispose();
    _controllerSupplierName.dispose();
    _controllerIban.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildCustomerRegister();
  }

  ///Widget ların oluşturulduğu builder Fonksiyonu
  buildCustomerRegister() {
    return AlertDialog(
      title: Text(
        textAlign: TextAlign.center,
        _headerSupplier,
        style: context.theme.headline5!.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKeySupplier,
          autovalidateMode: _autovalidateMode,
          child: Container(
            padding: context.extensionPadding20(),
            alignment: Alignment.center,
            width: 600,
            child: Column(children: [
              const Divider(),
              widgetTextFieldSupplierName(),
              context.extensionHighSizedBox20(),
              widgetCountryPhoneNumber(),
              context.extensionHighSizedBox20(),
              widgetRowCityAndDistrict(),
              context.extensionHighSizedBox20(),
              widgetBankAndIban(),
              context.extensionHighSizedBox20(),
              widgetTaxOfficeAndTaxCodeInfo(),
              context.extensionHighSizedBox20(),
              widgetCargoCompanyAndCargoCode(),
              context.extensionHighSizedBox20(),
              widgetSupplierSaveButton(),
            ]),
          ),
        ),
      ),
    );
  }

  ///Tedarikçi isminin giriş yeri.
  widgetTextFieldSupplierName() {
    return shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerSupplierName,
        etiket: "Tedarikçi adını giriniz",
        focusValue: false,
        karakterGostermeDurumu: false,
        validationFunc: validateFirstAndLastName);
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
        validator: validateNotEmptySelect,
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
        validator: validateNotEmptySelect,
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

  ///Banka Adı Ve İban Numarası
  widgetBankAndIban() {
    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: context.extensionWrapSpacing20(),
      children: [
        //banka Adı
        shareWidget.widgetTextFieldInput(
            etiket: _labelBankName, controller: _controllerBankName),
        //iban bölümü
        shareWidget.widgetTextFieldIban(controller: _controllerIban)
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
        validator: validateNotEmptySelect,
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

  widgetCargoCompanyAndCargoCode() {
    return Row(
      children: [
        Expanded(
          child: shareWidget.widgetTextFieldInput(
            controller: _controllerCargoName,
            etiket: _labelCargoName,
          ),
        ),
        context.extensionWidhSizedBox20(),
        Expanded(
          child: shareWidget.widgetTextFieldInput(
            controller: _controllerCargoCode,
            etiket: _labelCargoCode,
          ),
        ),
      ],
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

  widgetSupplierSaveButton() {
    return ElevatedButton(
        onPressed: () async {
          if (_formKeySupplier.currentState!.validate()) {
            String? iban;
            if (_controllerIban.text.length > 2) {
              iban = _controllerIban.text.replaceAll(" ", "");
            } else {
              iban = "";
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

            var returnValue = await db.saveSuppliers(_customer!);

            if (returnValue.isEmpty) {
              setState(() {
                _autovalidateMode = AutovalidateMode.disabled;
              });

              widget.newSupplier = _controllerSupplierName.text;
              _controllerSupplierName.clear();
              _controllerBankName.clear();
              _controllerIban.clear();
              _controllerPhoneNumber.clear();
              _controlleraddress.clear();
              _controllerTaxNumber.clear();
              _controllerCargoName.clear();
              _controllerCargoCode.clear();

              ///Navigator Kapanması için noticeBar işleminin bitmesi gerekiyor.
              ///Yoksa Hata veriyor.
              context
                  .noticeBarTrue("Kayıt Başarılı", 2)
                  .then((value) => Navigator.of(context).pop());

              ///popup tan sonra tedarikçi ismini ürün ekleme saydasına taşıyor

            } else {
              context.noticeBarError("Kayıtlı olan bir Tedarikçi girdiniz.", 2);
            }
          }
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
