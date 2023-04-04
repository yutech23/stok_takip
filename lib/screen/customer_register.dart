import 'package:adaptivex/adaptivex.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/bloc/bloc_customer_register.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/get_keys.dart';
import 'package:stok_takip/validations/format_upper_case_text_format.dart';
import 'package:stok_takip/validations/validation.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
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
  final _controllerAddress = TextEditingController();
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

  final double _sectionCustomerSaveWidthMin = 360;
  final double _sectionCustomerSaveWidthMax = 500;
  final double _sectionHeight = 800;
  late List<dynamic> listCustomerRegister;

  String? _selectedCity;
  String? _selectDistrict;
  String? _selectedTaxOffice;
  late bool _visibleDistrict;
  Customer? _customer;

  //Müşteri Tipi Seçimini başka stateless Widget Çağırma Callback Func. kullanarak.
  var customerTypeitems = <String>["Şahıs", "Firma", "Tedarikçi"];

  String? _customerType;

  void _getCustomerType(String value) {
    setState(() {
      _customerType = value;
      _fillListViewByRoleType();
    });
  }

  late BlocCustomerRegister _blocCustomerRegister;

/*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  List<Map<String, dynamic>> _selecteds = [];
  final double _dataTableWidth = 700;

  final TextEditingController _controllerSearchCustomerName =
      TextEditingController();

  final String _labelSearchHint = 'İsim ile Arama Yapınız';

  final String _labelTcNo = "TC No: ";
  final String _labelAddress = "Adres: ";
  final String _labelTaxNumber = "Vergi Numarası: ";
  final String _labelTaxOffice = "Vergi Dairesi: ";
  final String _labelCargoCompany = "Kargo Firma: ";
  final String _labelCargoNo = "Kargo No: ";
  final String _labelBankname = "Banka Adı: ";
  final String _labelIban = "IBAN: ";

  /*--------------------------ARAMA BÖLÜMÜ------------------------------- */
/*----------------------POPUP BÖLÜMÜ GÜNCELLEME VE SİLME----------------- */
  final String _labelPopupUpdateHeader = "Güncelleme";
  final GlobalKey<FormState> _formKeyUpdate = GlobalKey<FormState>();

  ///Silme İşlemi
  final String _header = "Hizmeti silmek istediğinizden emin misiniz?";
  final String _yesText = "Evet";

  /*---------------------------Güncelleme ------------------------------- */
  @override
  void initState() {
    _blocCustomerRegister = BlocCustomerRegister();
    _headers = [];
    listCustomerRegister = <dynamic>[];
    _visibleDistrict = false;
    _controllerIban.text = "TR";

    ///İlk ekran açıldığında gelmesi için burası koyuldu. Bir sorun il ilçe seçimini
    ///listenin içine alındığında il seçiminde ilçe çıkmıyor. visible konusu çalışmıyor.
    ///liste içindeki nesneye ulaşılmıyor.
    listeEklemeSahis();

    _headers.add(DatatableHeader(
        text: "Tip",
        value: "type",
        show: true,
        flex: 1,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Müşteri İsmi",
        value: "name",
        show: true,
        flex: 4,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "İletişim",
        value: "phone",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Sil ve Güncelle",
        value: "detail",
        show: true,
        sortable: false,
        flex: 2,
        sourceBuilder: (value, row) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ///Silme Buttonu
              IconButton(
                focusNode: FocusNode(skipTraversal: true),
                iconSize: 20,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return popupDelete(row, _controllerSearchCustomerName);
                    },
                  );
                },
              ),

              ///Güncelleme Buttonu
              IconButton(
                focusNode: FocusNode(skipTraversal: true),
                iconSize: 20,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _customerType = row['type'];
                    if (row['type'] == "Şahıs") {
                      listCustomerRegister.clear();
                      listeEklemeSahis();
                      _controllerTC.text = row['tc_no'];
                      _controllerName.text = row['copyName'];
                      _controllerLastName.text = row['last_name'];
                      _controllerPhoneNumber.text = row['phone'];
                      _selectedCity = row['city'];
                      _selectDistrict = row['district'];
                      _controllerAddress.text = row['address'];
                    } else if (row['type'] == "Firma") {
                      listCustomerRegister.clear();
                      listeEklemeCompany();
                    } else if (row['type'] == "Tedarikçi") {
                      listCustomerRegister.clear();
                      listeEklemeSupplier();
                    }
                  });
                },
              )
            ],
          );
        },
        textAlign: TextAlign.center));

    super.initState();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerLastName.dispose();
    _controllerPhoneNumber.dispose();
    _controllerAddress.dispose();
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
      } else if (_customerType == "Firma") {
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
      resizeToAvoidBottomInset: true,
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
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: context.extensionThemaGreyContainer(),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: context.extensionWrapSpacing10(),
                runSpacing: context.extensionWrapSpacing10(),
                children: [
                  ///Müşteri Tablosu Bulunduğu yer.
                  Container(
                    width: _dataTableWidth,
                    height: _sectionHeight,
                    padding: context.extensionPadding20(),
                    decoration: context.extensionThemaWhiteContainer(),
                    child: widgetDateTable(),
                  ),

                  ///Müşteri Kayıt Bölümü
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    alignment: Alignment.center,
                    decoration: context.extensionThemaWhiteContainer(),
                    constraints: BoxConstraints(
                        minWidth: _sectionCustomerSaveWidthMin,
                        maxWidth: _sectionCustomerSaveWidthMax),
                    height: _sectionHeight,
                    child: Column(children: [
                      const Divider(),
                      ShareDropdown(
                          hint: "Müşteri Tipini Seçiniz.",
                          itemList: customerTypeitems,
                          selectValue: _customerType,
                          getShareDropdownCallbackFunc: _getCustomerType),
                      widgetListCustomerInformationInput(),
                      widgetRowCityAndDistrict(),
                      const Divider(),
                      _customerType != "Şahıs"
                          ? widgetTaxOfficeAndTaxCodeInfo()
                          : const SizedBox(),
                      _customerType != "Şahıs"
                          ? const Divider()
                          : const SizedBox(),
                      _customerType != "Şahıs"
                          ? widgetCargoCompanyAndCargoCode()
                          : const SizedBox(),
                      _customerType != "Şahıs"
                          ? const Divider()
                          : const SizedBox(),
                      widgetCustomerSaveButton(),
                      const Divider(),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  /*--------------Müşteri Gösterme,Düzenleme, Silme Tablosu ---------------- */
  widgetDateTable() {
    return SizedBox(
      width: _dataTableWidth,
      child: Card(
        margin: const EdgeInsets.only(top: 5),
        elevation: 5,
        shadowColor: Colors.black,
        clipBehavior: Clip.none,
        child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _blocCustomerRegister.getStremAllCustomer,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {}

              return ResponsiveDatatable(
                reponseScreenSizes: const [ScreenSize.xs],
                headers: _headers,
                source: snapshot.data,
                selecteds: _selecteds,
                expanded: _blocCustomerRegister.getterDatatableExpanded,
                autoHeight: false,
                actions: [
                  Expanded(
                      child: TextField(
                    controller: _controllerSearchCustomerName,
                    onChanged: (value) {
                      _blocCustomerRegister.searchList(value);
                    },
                    decoration: InputDecoration(
                      hintText: _labelSearchHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ))
                ],
                dropContainer: (value) {
                  if (value['type'] == "Şahıs") {
                    return Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widgetRichTextDetail(_labelTcNo, value['tc_no']),
                            widgetRichTextDetail(_labelAddress,
                                "${value['address']} \n ${value['city']}/${value['district']}"),
                          ],
                        ));
                  } else if (value['type'] == "Firma") {
                    return Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                widgetRichTextDetail(
                                    _labelTaxNumber, value['tax_number']),
                                widgetRichTextDetail(
                                    _labelTaxOffice, value['tax_office']),
                                widgetRichTextDetail(_labelAddress,
                                    "${value['address']} \n ${value['city']}/${value['district']}"),
                              ],
                            ),
                            Column(
                              children: [
                                widgetRichTextDetail(
                                    _labelCargoCompany, value['cargo_company']),
                                widgetRichTextDetail(
                                    _labelCargoNo, value['cargo_number']),
                              ],
                            )
                          ],
                        ));
                  } else {
                    return Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                widgetRichTextDetail(
                                    _labelTaxNumber, value['tax_number']),
                                widgetRichTextDetail(
                                    _labelTaxOffice, value['tax_office']),
                                widgetRichTextDetail(_labelAddress,
                                    "${value['address']} \n ${value['city']}/${value['district']}"),
                              ],
                            ),
                            Column(
                              children: [
                                widgetRichTextDetail(
                                    _labelCargoCompany, value['cargo_company']),
                                widgetRichTextDetail(
                                    _labelCargoNo, value['cargo_number']),
                                widgetRichTextDetail(
                                    _labelBankName, value['bank_name']),
                                widgetRichTextDetail(_labelIban, value['iban']),
                              ],
                            )
                          ],
                        ));
                  }
                },
                sortAscending: true,
                headerDecoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    border: const Border(
                        bottom: BorderSide(color: Colors.red, width: 1))),
                selectedDecoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.red, width: 1)),
                  color: Colors.green,
                ),
                headerTextStyle:
                    context.theme.titleMedium!.copyWith(color: Colors.white),
                rowTextStyle: context.theme.titleSmall,
                selectedTextStyle: const TextStyle(color: Colors.grey),
              );
            }),
      ),
    );
  }

/*-------------------------------------------------------------------------- */
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

        ///Adres giriş bölümü
        TextFormField(
          controller: _controllerAddress,
          validator: validateAddress,
          decoration: InputDecoration(
              counterText: "",
              labelText: _labelAddress,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              )),
        ),
      ],
    );
  }

  //İl ve İlçe Satır Fonksiyonu
  widgetRowCityAndDistrictColumn() {
    return Column(
      children: [
        widgetSearchDropdownCities(),
        context.extensionHighSizedBox10(),
        widgetSearchDropdownDistrict(),
        const Divider(color: Colors.transparent),

        ///Adres giriş bölümü
        TextFormField(
          controller: _controllerAddress,
          validator: validateAddress,
          decoration: InputDecoration(
              counterText: "",
              labelText: _labelAddress,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              )),
        ),
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
                skipTravelFocusValue: false,
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
      skipTravelFocusValue: false,
      karakterGostermeDurumu: false,
      maxCharacter: 11,
    ));
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerName,
        etiket: _labelCustomerName,
        skipTravelFocusValue: false,
        karakterGostermeDurumu: false,
        validationFunc: validateFirstAndLastName));
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerLastName,
        etiket: _labelCustomerLastname,
        skipTravelFocusValue: false,
        karakterGostermeDurumu: false,
        validationFunc: validateFirstAndLastName));
    listCustomerRegister.add(widgetCountryPhoneNumber());
  }

  listeEklemeCompany() {
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerCompanyName,
        etiket: _labelCompanyName,
        maxCharacter: 100,
        validationFunc: validateCompanyName));
    listCustomerRegister.add(widgetCountryPhoneNumber());
  }

  listeEklemeSupplier() {
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerSupplierName,
        etiket: _labelSupplierName,
        maxCharacter: 100,
        validationFunc: validateCompanyName));
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

//Country Telefon Numarası widget Search kısmına autoFocus Eklendi Kütüphaneden
  widgetCountryPhoneNumber() {
    return Container(
      child: shareWidget.widgetIntlPhoneField(
          controllerPhoneNumber: _controllerPhoneNumber),
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
                  address: _controllerAddress.text,
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
                    _controllerAddress.clear();
                    _controllerTC.clear();

                    context.noticeBarTrue("Kayıt Başarılı", 2);
                  } else {
                    context.noticeBarError("Kayıt Başarısız", 2);
                  }
                });
              } else if (_customerType == 'Firma') {
                _customer = Customer.company(
                    companyName: _controllerCompanyName.text,
                    phone: Sabitler.countryCode + _controllerPhoneNumber.text,
                    city: _selectedCity,
                    district: _selectDistrict,
                    address: _controllerAddress.text,
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
                    _controllerAddress.clear();
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
                    address: _controllerAddress.text,
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
                    _controllerAddress.clear();
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

  ///Silme popup bölümü
  popupDelete(
      Map<String?, dynamic> serviceId, TextEditingController controllerSearch) {
    return AlertDialog(
      title: Text('UYARI',
          textAlign: TextAlign.center,
          style:
              context.theme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
      alignment: Alignment.center,
      content: Text(_header,
          style:
              context.theme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: <Widget>[
        SizedBox(
          width: 100,
          height: 30,
          child: ElevatedButton(
              onPressed: () async {
                ///Stok bitmeden silmeyi engelliyor.

                String res =
                    await _blocCustomerRegister.deleteCustomer(serviceId);
                if (res.isEmpty) {
                  controllerSearch.clear();
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  await context.noticeBarTrue("İşlem başarılı.", 2);

                  // ignore: use_build_context_synchronously
                } else {
                  // ignore: use_build_context_synchronously
                  context.noticeBarError("Hata $res", 3);
                }
              },
              child: Text(_yesText,
                  style:
                      context.theme.titleSmall!.copyWith(color: Colors.white))),
        ),
        SizedBox(
          width: 100,
          height: 30,
          child: ElevatedButton(
            child: Text("İptal",
                style: context.theme.titleSmall!.copyWith(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  ///Detay bölümü için RichText
  widgetRichTextDetail(String header, String? value) {
    return RichText(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,
        text: TextSpan(
            text: header,
            style: context.theme.titleSmall!
                .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
            children: [
              TextSpan(style: context.theme.titleSmall, text: value)
            ]));
  }
}
