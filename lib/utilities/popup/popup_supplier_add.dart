import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/get_keys.dart';
import 'package:stok_takip/validations/validation.dart';

import '../constants.dart';
import '../share_widgets.dart';

class PopupSupplierRegister extends StatefulWidget {
  const PopupSupplierRegister({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ScreenCustomerSave();
  }
}

class _ScreenCustomerSave extends State with Validation {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _controllerCargoName = TextEditingController();
  final _controllerPhoneNumber = TextEditingController();
  final _controllerAdress = TextEditingController();
  final _controllerTaxNumber = TextEditingController();
  final _controllerCargoCode = TextEditingController();
  final _controllerCompanyName = TextEditingController();

  String? _selectedCity;
  String? _selectDistrict;
  String? _selectedTaxOffice;
  late bool _visibleDistrict;

  Customer? _customer;

  final String _headerSupplier = "Yeni Tedarikçi Ekleme";
  final String _type = "Tedarikçi";

  @override
  void initState() {
    super.initState();

    _visibleDistrict = false;
  }

  @override
  void dispose() {
    _controllerPhoneNumber.dispose();
    _controllerAdress.dispose();
    _controllerTaxNumber.dispose();
    _controllerCargoCode.dispose();
    _controllerCargoName.dispose();
    _controllerCompanyName.dispose();
    _formKey.currentState!.dispose();
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
          key: _formKey,
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
              widgetTaxOfficeAndTaxCodeInfo(),
              context.extensionHighSizedBox20(),
              widgetCargoCompanyAndCargoCode(),
              context.extensionHighSizedBox20(),
              widgetCustomerSaveButton(),
            ]),
          ),
        ),
      ),
    );
  }

  ///Tedarikçi isminin giriş yeri.
  widgetTextFieldSupplierName() {
    return shareWidget.widgetTextFieldInput(
        controller: _controllerCompanyName,
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
          bool isThereSupplierName =
              await db.isThereOnSupplierName(_controllerCompanyName.text);
          if (isThereSupplierName) {
            // ignore: use_build_context_synchronously
            context.noticeBarError("Aynı isimde Tedarikçi bulunmaktadır", 5);
          }
          setState(() {
            if (_formKey.currentState!.validate() &&
                isThereSupplierName == false) {
              _customer = Customer.company(
                  type: _type,
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
                  if (value == null) {
                    _controllerCompanyName.clear();
                    _controllerPhoneNumber.clear();
                    _controllerAdress.clear();
                    _controllerTaxNumber.clear();
                    _controllerCargoName.clear();
                    _controllerCargoCode.clear();
                  }
                });
              }
              context.noticeBarTrue("Kayıt Başarılı", 3);
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
