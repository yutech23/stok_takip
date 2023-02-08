import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

import '../../data/database_helper.dart';
import '../../models/customer.dart';
import '../../validations/format_upper_case_text_format.dart';
import '../../validations/validation.dart';
import '../constants.dart';
import '../get_keys.dart';
import '../share_widgets.dart';

class PopupCustomerAdd extends StatefulWidget {
  String newSupplier;
  PopupCustomerAdd(this.newSupplier, {super.key});

  @override
  State<PopupCustomerAdd> createState() => _ScreenCustomerSave();
}

class _ScreenCustomerSave extends State<PopupCustomerAdd> with Validation {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _customerRegisterHeader = "Yeni Müşteri Kayıt";
  final AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  final _controllerName = TextEditingController();
  final _controllerLastName = TextEditingController();
  final _controllerPhoneNumber = TextEditingController();
  final _controllerAdress = TextEditingController();
  final _controllerTaxNumber = TextEditingController();
  final _controllerCargoCode = TextEditingController();
  final _controllerCargoName = TextEditingController();
  final _controllerCompanyName = TextEditingController();
  final _controllerIban = TextEditingController();
  final _controllerTC = TextEditingController();

  final String _labelCustomerName = "Müşteri adını giriniz";
  final String _labelCustomerLastname = "Müşteri Soyadını giriniz";
  final String _labelTC = "TC Kimlik Numarası giriniz";

  final double _widthShareInputText = 360;

  String? _selectedCity;
  String? _selectDistrict;
  String? _selectedTaxOffice;
  late bool _visibleDistrict;
  Customer? _customer;
  late double _widthMediaQuery;
  final _responseWidth = const BoxConstraints(maxWidth: 600, minWidth: 200);

  @override
  void initState() {
    _visibleDistrict = false;
    _controllerIban.text = "TR";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getWidthScreenSize(context);
    return buildCustomerRegister();
  }

  Widget buildCustomerRegister() {
    return AlertDialog(
      title: Text(
        textAlign: TextAlign.center,
        _customerRegisterHeader,
        style: context.theme.headline5!.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Container(
            width: _widthMediaQuery,
            padding: context.extensionPadding10(),
            alignment: Alignment.center,
            child: Column(children: [
              widgetTextFieldTC(),
              spaceColumn,
              widgetTextFieldFormName(),
              spaceColumn,
              widgetTextFieldFormLastName(),
              spaceColumn,
              widgetCountryPhoneNumber(),
              spaceColumn,
              _widthMediaQuery < 500
                  ? widgetColumnCityAndDistrictMobil()
                  : widgetRowCityAndDistrict(),
              spaceColumn,
              widgetAddress(),
              /*  spaceColumn,
              widgetTaxOfficeAndTaxCodeInfo(),
              spaceColumn,as
              widgetCargoCompanyAndCargoCode(), */
              spaceColumn,
              widgetCustomerSaveButton(),
            ]),
          ),
        ),
      ),
    );
  }

  widgetTextFieldTC() {
    //TC Kimlik Numarası girilen biryer.
    return Container(
      constraints: _responseWidth,
      child: shareWidget.widgetTextFieldInput(
        inputFormat: [FilteringTextInputFormatter.allow(RegExp(r'[\d]'))],
        controller: _controllerTC,
        etiket: _labelTC,
        focusValue: false,
        karakterGostermeDurumu: false,
        maxCharacter: 11,
      ),
    );
  }

  widgetTextFieldFormName() {
    return Container(
      constraints: _responseWidth,
      child: shareWidget.widgetTextFieldInput(
          inputFormat: [
            FormatterUpperCaseTextFormatter(),
            FilteringTextInputFormatter.allow(RegExp(r'[\D]'))
          ],
          controller: _controllerName,
          etiket: _labelCustomerName,
          focusValue: false,
          karakterGostermeDurumu: false,
          validationFunc: validateFirstAndLastName),
    );
  }

  widgetTextFieldFormLastName() {
    return Container(
      constraints: _responseWidth,
      child: shareWidget.widgetTextFieldInput(
          inputFormat: [FormatterUpperCaseTextFormatter()],
          controller: _controllerLastName,
          etiket: _labelCustomerLastname,
          focusValue: false,
          karakterGostermeDurumu: false,
          validationFunc: validateFirstAndLastName),
    );
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
    return Container(
      constraints: _responseWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: widgetSearchDropdownCities(),
          ),
          spaceRowSizedBox,
          Expanded(child: widgetSearchDropdownDistrict()),
        ],
      ),
    );
  }

//Mobil
  widgetColumnCityAndDistrictMobil() {
    return Container(
      height: 110,
      constraints: _responseWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: widgetSearchDropdownCities(),
          ),
          spaceColumn,
          Expanded(child: widgetSearchDropdownDistrict()),
        ],
      ),
    );
  }

  widgetAddress() {
    return Container(
      constraints: _responseWidth,
      child: shareWidget.widgetTextFieldInput(
          controller: _controllerAdress,
          etiket: "Adres",
          focusValue: false,
          karakterGostermeDurumu: false,
          validationFunc: validateAddress),
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
    return Container(
      constraints: _responseWidth,
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

  widgetCargoCompanyAndCargoCode() {
    return Container(
      constraints: _responseWidth,
      child: Row(
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
      ),
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
      constraints: _responseWidth,
      child: shareWidget.widgetIntlPhoneField(
        controllerPhoneNumber: _controllerPhoneNumber,
      ),
    );
  }

  widgetCustomerSaveButton() {
    return SizedBox(
      width: _widthShareInputText,
      child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _customer = Customer.soleTrader(
                soleTraderName: _controllerName.text,
                soleTraderLastName: _controllerLastName.text,
                phone: Sabitler.countryCode + _controllerPhoneNumber.text,
                city: _selectedCity,
                district: _selectDistrict,
                adress: _controllerAdress.text,
                TCno: _controllerTC.text,
              );

              String resDataValue = await db.saveCustomerSoleTrader(_customer!);

              if (resDataValue.isEmpty) {
                _controllerName.clear();
                _controllerLastName.clear();
                _controllerCompanyName.clear();
                _controllerPhoneNumber.clear();
                _selectDistrict = "";
                _selectedCity = "";
                _controllerAdress.clear();
                _controllerTC.clear();

                // ignore: use_build_context_synchronously
                context
                    .noticeBarTrue("Kayıt Başarılı", 2)
                    .then((value) => Navigator.of(context).pop());
              } else {
                // ignore: use_build_context_synchronously
                context.noticeBarError(
                    "Kayıt Başarısız \n HATA : $resDataValue", 3);
              }
            } else {
              context.noticeBarError("Lütfen bilgileri eksiksiz giriniz.", 2);
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
          )),
    );
  }

  void getWidthScreenSize(BuildContext context) {
    _widthMediaQuery = MediaQuery.of(context).size.width < 500 ? 360 : 600;
    print(_widthMediaQuery);
  }
}
