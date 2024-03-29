import 'package:adaptivex/adaptivex.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:stok_takip/bloc/bloc_customer_register.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/customer.dart';
import 'package:stok_takip/utilities/custom_dropdown/widget_share_dropdown_string_type.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/get_keys.dart';
import 'package:stok_takip/validations/format_upper_case_text_format.dart';
import 'package:stok_takip/validations/validation.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import 'package:phone_number_metadata/phone_number_metadata.dart';
import 'drawer.dart';

@RoutePage()
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
  final _controllerAddress = TextEditingController();
  final _controllerTaxNumber = TextEditingController();
  final _controllerCargoCode = TextEditingController();
  final _controllerCargoName = TextEditingController();
  final _controllerCompanyName = TextEditingController();
  final _controllerBankName = TextEditingController();
  final _controllerIban = TextEditingController();
  final _controllerSupplierName = TextEditingController();
  final _controllerTC = TextEditingController();

  final String _labelPageHeader = "Müşteri & Tedarikçi Ekranı";
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
  final List<Map<String, dynamic>> _selecteds = [];

  final TextEditingController _controllerSearchCustomerName =
      TextEditingController();

  final String _labelSearchHint = 'İsim ile arama yapınız';
  final String _labelTcNo = "TC No: ";
  final String _labelAddress = "Adres: ";
  final String _labelTaxNumber = "Vergi Numarası: ";
  final String _labelTaxOffice = "Vergi Dairesi: ";
  final String _labelCargoCompany = "Kargo Firma: ";
  final String _labelCargoNo = "Kargo No: ";
  final String _labelIban = "IBAN: ";
  final String _labelDropdownBankName = "Banka İsmi: ";
  final String _labelAddNewCustomer = "Yeni Müşteri Ekle";

  /*--------------------------ARAMA BÖLÜMÜ------------------------------- */
/*----------------------POPUP BÖLÜMÜ GÜNCELLEME VE SİLME----------------- */
  bool _isNewCustomerSaveButton = true;
  bool _isUpdateButton = false;
  final String _labelUpdate = "Güncelle";
  final String _labelNewCustomerSave = "Yeni Müşteri Kaydet";
  late int _customerId;

  final PhoneController _phoneController = PhoneController(null);

  ///Silme İşlemi
  final String _header = "Hizmeti silmek istediğinizden emin misiniz?";
  final String _yesText = "Evet";
  bool _isDisableCustomerType = false;

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
        text: "Düzenle",
        value: "detail",
        show: true,
        sortable: false,
        flex: 1,
        sourceBuilder: (value, row) {
          return Container(
            alignment: Alignment.center,
            child: IconButton(
              focusNode: FocusNode(skipTraversal: true),
              iconSize: 20,
              padding: const EdgeInsets.only(bottom: 20),
              alignment: Alignment.center,
              icon: const Icon(Icons.edit),
              onPressed: () {
                _isUpdateButton = true;
                // _isDisableCustomerType = true;
                _isNewCustomerSaveButton = false;
                _customerId = row['id'];
                setState(() {
                  _customerType = row['type'];
                  if (row['type'] == "Şahıs") {
                    listCustomerRegister.clear();
                    listeEklemeSahis();
                    _controllerTC.text = row['tc_no'];
                    _controllerName.text = row['copyName'];
                    _controllerLastName.text = row['last_name'];

                    ///Veritabanında ülke kodları sayı ile tutuyorum
                    ///Bu gelen veriyi direk telefon bölümüne akataramıyorum
                    ///çünkü widget sadece Isocode(Tr) ile veri gönderilebiliyor.
                    ///Bu yüzden kütüphanenin listesinde  gelen kodu arama
                    ///yapıyorum ki güncelleme sırasında ekrana değişkliği yapabilsin.
                    countryCodeToIsoCode.forEach((key, value) {
                      if (key == row['country_code']) {
                        _phoneController.value =
                            PhoneNumber(isoCode: value[0], nsn: row['phone']);
                      }
                    });

                    _selectedCity = row['city'];
                    _selectDistrict = row['district'];
                    _controllerAddress.text = row['address'];

                    ///Firma Güncelleme Bölümü
                  } else if (row['type'] == "Firma") {
                    listCustomerRegister.clear();
                    listeEklemeCompany();

                    _controllerCompanyName.text = row['name'];

                    ///Veritabanında ülke kodları sayı ile tutuyorum
                    ///Bu gelen veriyi direk telefon bölümüne akataramıyorum
                    ///çünkü widget sadece Isocode(Tr) ile veri gönderilebiliyor.
                    ///Bu yüzden kütüphanenin listesinde  gelen kodu arama
                    ///yapıyorum ki güncelleme sırasında ekrana değişkliği yapabilsin.
                    countryCodeToIsoCode.forEach((key, value) {
                      if (key == row['country_code']) {
                        _phoneController.value =
                            PhoneNumber(isoCode: value[0], nsn: row['phone']);
                      }
                    });

                    _selectedCity = row['city'];
                    _selectDistrict = row['district'];
                    _controllerAddress.text = row['address'];
                    _selectedTaxOffice = row['tax_office'];
                    _controllerTaxNumber.text = row['tax_number'];
                    _controllerCargoName.text = row['cargo_company'];
                    _controllerCargoCode.text = row['cargo_number'];

                    ///Tedarikçi Güncelleme Bölümü
                  } else if (row['type'] == "Tedarikçi") {
                    listCustomerRegister.clear();
                    listeEklemeSupplier();

                    _controllerSupplierName.text = row['name'];
                    _controllerBankName.text = row['bank_name'];
                    // _controllerIban.text = row['iban'];

                    ///Veritabanında ülke kodları sayı ile tutuyorum
                    ///Bu gelen veriyi direk telefon bölümüne akataramıyorum
                    ///çünkü widget sadece Isocode(Tr) ile veri gönderilebiliyor.
                    ///Bu yüzden kütüphanenin listesinde  gelen kodu arama
                    ///yapıyorum ki güncelleme sırasında ekrana değişkliği yapabilsin.
                    countryCodeToIsoCode.forEach((key, value) {
                      if (key == row['country_code']) {
                        _phoneController.value =
                            PhoneNumber(isoCode: value[0], nsn: row['phone']);
                      }
                    });

                    _selectedCity = row['city'];
                    _selectDistrict = row['district'];
                    _controllerAddress.text = row['address'];
                    _selectedTaxOffice = row['tax_office'];
                    _controllerTaxNumber.text = row['tax_number'];
                    _controllerCargoName.text = row['cargo_company'];
                    _controllerCargoCode.text = row['cargo_number'];
                  }
                });
              },
            ),
          );
        },
        textAlign: TextAlign.center));

    super.initState();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerLastName.dispose();
    _phoneController.dispose();
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
        title: Text(_labelPageHeader),
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
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: context.extensionWrapSpacing10(),
              runSpacing: context.extensionWrapSpacing10(),
              children: [
                ///Müşteri Tablosu Bulunduğu yer.
                Container(
                  width: dimension.widthMainSection,
                  height: dimension.heightSection,
                  padding: context.extensionPadding20(),
                  decoration: context.extensionThemaWhiteContainer(),
                  child: widgetDateTable(),
                ),

                ///Müşteri Kayıt Bölümü
                SizedBox(
                  width: dimension.widthSideSectionAndMobil,
                  height: dimension.heightSection,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ///Yeni Müşteri Ekle Buttonu
                      Container(
                        width: dimension.widthSideSectionAndMobil,
                        height: 40,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color: Colors.blueGrey.shade100,
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  blurRadius: 8)
                            ]),
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isNewCustomerSaveButton = true;
                              _isDisableCustomerType = false;
                              _isUpdateButton = false;
                              _customerType = null;
                              _controllerCompanyName.clear();
                              _controllerSupplierName.clear();
                              _controllerBankName.clear();
                              _controllerIban.clear();
                              _controllerName.clear();
                              _controllerLastName.clear();
                              _phoneController.reset();
                              _controllerAddress.clear();
                              _controllerTaxNumber.clear();
                              _controllerCargoName.clear();
                              _controllerCargoCode.clear();
                              _controllerTC.clear();
                              _selectDistrict = null;
                              _selectedCity = null;
                              _selectedTaxOffice = null;
                            });
                          },
                          icon: Icon(Icons.add,
                              color: context.extensionDefaultColor),
                          label: Text(
                            _labelAddNewCustomer,
                            style: context.theme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          style: ButtonStyle(overlayColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.blueGrey.shade700.withOpacity(0.2);
                            }
                            return null;
                          })),
                        ),
                      ),

                      ///Müşteri Ekleme Bölümü
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                    blurRadius: 8)
                              ]),
                          child: Column(children: [
                            const Divider(
                              height: 10,
                            ),
                            widgetDropdownSelectCustomerType(),
                            widgetListCustomerInformationInput(),
                            widgetRowCityAndDistrict(),
                            const Divider(
                              height: 10,
                            ),
                            _customerType != "Şahıs"
                                ? widgetTaxOfficeAndTaxCodeInfo()
                                : const SizedBox(
                                    height: 10,
                                  ),
                            _customerType != "Şahıs"
                                ? const Divider()
                                : const SizedBox(
                                    height: 10,
                                  ),
                            _customerType != "Şahıs"
                                ? widgetCargoCompanyAndCargoCode()
                                : const SizedBox(
                                    height: 10,
                                  ),
                            _customerType != "Şahıs"
                                ? const Divider(
                                    height: 10,
                                  )
                                : const SizedBox(
                                    height: 10,
                                  ),
                            Visibility(
                              visible: _isNewCustomerSaveButton,
                              child: widgetCustomerSaveButton(),
                            ),
                            Visibility(
                              visible: _isUpdateButton,
                              child: widgetCustomerUpdateButton(),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  widgetDropdownSelectCustomerType() {
    return SizedBox(
      height: 40,
      child: ShareDropdown(
          hint: "Müşteri Tipini Seçiniz.",
          itemList: customerTypeitems,
          selectValue: _customerType,
          getShareDropdownCallbackFunc: _getCustomerType,
          isDisable: _isDisableCustomerType),
    );
  }

  /*--------------Müşteri Gösterme,Düzenleme, Silme Tablosu ---------------- */
  widgetDateTable() {
    return Card(
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
              skipFocusNode: true,
              rowHeight: 40,
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
                                  _labelDropdownBankName, value['bank_name']),
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
                border: Border(bottom: BorderSide(color: Colors.red, width: 1)),
                color: Colors.green,
              ),
              headerTextStyle:
                  context.theme.titleMedium!.copyWith(color: Colors.white),
              rowTextStyle: context.theme.titleSmall,
              selectedTextStyle: const TextStyle(color: Colors.grey),
            );
          }),
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
              height: 10,
              color: Colors.transparent,
            ));
  }

  ///Şehirleri sıralayan SearchDropdown
  Theme widgetSearchDropdownCities() {
    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
            titleMedium: TextStyle(
                locale: Locale('tr', 'TR'),
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
      child: SizedBox(
        height: dimension.heightInputTextAnDropdown50,
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
                    isDense: true,
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
                isDense: true,
                hintText: "İl Seçiniz",
                hintStyle: context.theme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
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
      ),
    );
  }

  ///Şehire Göre İlçeleri Sıralıyor
  Theme widgetSearchDropdownDistrict() {
    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
            titleMedium: TextStyle(
                locale: Locale('tr', 'TR'),
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
      child: SizedBox(
        height: dimension.heightInputTextAnDropdown50,
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
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    isDense: true,
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
                isDense: true,
                hintText: "İlk Önce İl Seçiniz",
                hintStyle: context.theme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1))),
          ),
          onChanged: (value) {
            _selectDistrict = value;
          },
        ),
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
        const Divider(
          color: Colors.transparent,
          height: 10,
        ),

        ///Adres giriş bölümü
        shareWidget.widgetTextFieldInput(
            controller: _controllerAddress,
            validationFunc: validateAddress,
            etiket: _labelAddress),
      ],
    );
  }

  ///Vergi Daire Listesi
  widgetSearchDropdownTaxOfficeList() {
    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
            titleMedium: TextStyle(
                locale: Locale('tr', 'TR'),
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
      child: SizedBox(
        height: dimension.heightInputTextAnDropdown50,
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
                    isDense: true,
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
                isDense: true,
                hintText: "Vergi Dairesi",
                hintStyle: context.theme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1))),
          ),
          onChanged: (value) {
            _selectedTaxOffice = value;
          },
        ),
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
                etiket: "Vergi Numarası",
                skipTravelFocusValue: false,
                karakterGostermeDurumu: false,
                maxCharacter: 11,
                style: context.theme.titleSmall,
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
    //Şirket Adı
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        inputFormat: [FormatterUpperCaseTextFormatter()],
        controller: _controllerSupplierName,
        etiket: _labelSupplierName,
        maxCharacter: 100,
        validationFunc: validateCompanyName));
    //Banka Adı
    listCustomerRegister.add(shareWidget.widgetTextFieldInput(
        keyboardInputType: TextInputType.name,
        controller: _controllerBankName,
        etiket: _labelBankName));
    //IBAN Bölümü
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
              etiket: "Kargo Firma Adı",
              style: context.theme.titleSmall),
        ),
        context.extensionWidhSizedBox20(),
        Expanded(
          child: shareWidget.widgetTextFieldInput(
              controller: _controllerCargoCode,
              etiket: "Kargo Kodu",
              style: context.theme.titleSmall),
        ),
      ],
    );
  }

  String? deger;

//Country Telefon Numarası widget Search kısmına autoFocus Eklendi Kütüphaneden
  widgetCountryPhoneNumber() {
    return Container(
      // height: dimension.heightSection,
      child: shareWidget.widgetPhoneFormField(
        controllerPhoneNumber: _phoneController,
      ),
    );
  }

  widgetCustomerSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: dimension.heightInputTextAnDropdown40,
      child: ElevatedButton(
          onPressed: () async {
            setState(() {
              if (_formKey.currentState!.validate()) {
                if (_customerType == 'Şahıs') {
                  _customer = Customer.soleTrader(
                    soleTraderName: _controllerName.text,
                    soleTraderLastName: _controllerLastName.text,
                    countryCode: _phoneController.value!.countryCode,
                    phone: _phoneController.value!.nsn,
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
                      _phoneController.reset();

                      _controllerAddress.clear();
                      _controllerTC.clear();
                      setState(() {
                        _selectDistrict = null;
                        _selectedCity = null;
                        _selectedTaxOffice = null;
                      });
                      _blocCustomerRegister.getAllCustomer();
                      context.noticeBarTrue("Kayıt Başarılı", 2);
                    } else {
                      context.noticeBarError(
                          "Kayıt Başarısız :\n $resValue", 2);
                    }
                  });

                  ///Firma Kaydetme İşlemi
                } else if (_customerType == 'Firma') {
                  _customer = Customer.company(
                      companyName: _controllerCompanyName.text,
                      countryCode: _phoneController.value!.countryCode,
                      phone: _phoneController.value!.nsn,
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
                      _phoneController.reset();
                      _controllerAddress.clear();
                      _controllerTaxNumber.clear();
                      _controllerCargoName.clear();
                      _controllerCargoCode.clear();
                      setState(() {
                        _selectDistrict = null;
                        _selectedCity = null;
                        _selectedTaxOffice = null;
                      });
                      _blocCustomerRegister.getAllCustomer();
                      context.noticeBarTrue("Kayıt Başarılı", 2);
                    } else {
                      context.noticeBarError(
                          "Kayıt Başarısız :\n $resValue", 2);
                    }
                  });

                  ///Tedarikçi Kaydetme işlemi
                } else if (_customerType == 'Tedarikçi') {
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
                      countryCode: _phoneController.value!.countryCode,
                      phone: _phoneController.value!.nsn,
                      city: _selectedCity,
                      district: _selectDistrict,
                      address: _controllerAddress.text,
                      taxOffice: _selectedTaxOffice,
                      taxNumber: _controllerTaxNumber.text,
                      cargoName: _controllerCargoName.text,
                      cargoNumber: _controllerCargoCode.text);

                  db.saveSuppliers(_customer!).then((resValue) {
                    if (resValue.isEmpty) {
                      _controllerSupplierName.clear();
                      _controllerBankName.clear();
                      _controllerIban.clear();
                      _controllerName.clear();
                      _controllerLastName.clear();
                      _controllerCompanyName.clear();
                      _phoneController.reset();
                      _controllerAddress.clear();
                      _controllerTaxNumber.clear();
                      _controllerCargoName.clear();
                      _controllerCargoCode.clear();
                      setState(() {
                        _selectDistrict = null;
                        _selectedCity = null;
                        _selectedTaxOffice = null;
                      });
                      _blocCustomerRegister.getAllCustomer();
                      context.noticeBarTrue("Kayıt Başarılı", 2);
                    } else {
                      context.noticeBarError(
                          "Kayıt Başarısız :\n $resValue", 2);
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
          child: Text(
            textAlign: TextAlign.center,
            style: context.theme.titleMedium!.copyWith(color: Colors.white),
            _labelNewCustomerSave,
          )),
    );
  }

  ///Güncelleme Button bölümü
  widgetCustomerUpdateButton() {
    return SizedBox(
      height: dimension.heightInputTextAnDropdown50,
      child: ElevatedButton(
          onPressed: () async {
            setState(() {
              if (_formKey.currentState!.validate()) {
                ///Şahıs Veri Güncelleme
                if (_customerType == 'Şahıs') {
                  _customer = Customer.soleTrader(
                    soleTraderName: _controllerName.text,
                    soleTraderLastName: _controllerLastName.text,
                    countryCode: _phoneController.value!.countryCode,
                    phone: _phoneController.value!.nsn,
                    city: _selectedCity,
                    district: _selectDistrict,
                    address: _controllerAddress.text,
                    TCno: _controllerTC.text,
                  );

                  db
                      .updateCustomerSoleTrader(_customer!,
                          customerId: _customerId)
                      .then((resValue) {
                    if (resValue.isEmpty) {
                      _controllerName.clear();
                      _controllerLastName.clear();
                      _controllerCompanyName.clear();
                      _phoneController.reset();
                      setState(() {
                        _selectDistrict = null;
                        _selectedCity = null;
                        _selectedTaxOffice = null;
                      });
                      _controllerAddress.clear();
                      _controllerTC.clear();

                      ///Güncellemeden sonra değişiklik ekrana yansıması için tekrar
                      ///veriler çekiliyor.
                      _blocCustomerRegister.getAllCustomer();
                      _controllerSearchCustomerName.clear();
                      context.noticeBarTrue("Kayıt Başarılı", 2);
                    } else {
                      context.noticeBarError("Kayıt Başarısız", 2);
                    }
                  });

                  ///Firma Veri Güncelleme
                } else if (_customerType == 'Firma') {
                  _customer = Customer.company(
                      companyName: _controllerCompanyName.text,
                      countryCode: _phoneController.value!.countryCode,
                      phone: _phoneController.value!.nsn,
                      city: _selectedCity,
                      district: _selectDistrict,
                      address: _controllerAddress.text,
                      taxOffice: _selectedTaxOffice,
                      taxNumber: _controllerTaxNumber.text,
                      cargoName: _controllerCargoName.text,
                      cargoNumber: _controllerCargoCode.text);

                  db
                      .updateCustomerCompany(_customer!,
                          customerId: _customerId)
                      .then((resValue) {
                    if (resValue.isEmpty) {
                      _controllerName.clear();
                      _controllerLastName.clear();
                      _controllerCompanyName.clear();
                      _phoneController.reset();
                      _controllerAddress.clear();
                      _controllerTaxNumber.clear();
                      _controllerCargoName.clear();
                      _controllerCargoCode.clear();
                      _phoneController.reset();
                      setState(() {
                        _selectDistrict = null;
                        _selectedCity = null;
                        _selectedTaxOffice = null;
                      });

                      ///Güncellemeden sonra değişiklik ekrana yansıması için tekrar
                      ///veriler çekiliyor.
                      _blocCustomerRegister.getAllCustomer();
                      _controllerSearchCustomerName.clear();
                      context.noticeBarTrue("Kayıt Başarılı", 2);
                    } else {
                      context.noticeBarError("Kayıt Başarısız", 2);
                    }
                  });

                  /// tedarikçi veri Güncelleme
                } else if (_customerType == 'Tedarikçi') {
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
                      countryCode: _phoneController.value!.countryCode,
                      phone: _phoneController.value!.nsn,
                      city: _selectedCity,
                      district: _selectDistrict,
                      address: _controllerAddress.text,
                      taxOffice: _selectedTaxOffice,
                      taxNumber: _controllerTaxNumber.text,
                      cargoName: _controllerCargoName.text,
                      cargoNumber: _controllerCargoCode.text);

                  db
                      .updateSuppliers(_customer!, customerId: _customerId)
                      .then((value) {
                    if (value.isEmpty) {
                      _controllerSupplierName.clear();
                      _controllerBankName.clear();
                      _controllerIban.clear();
                      _controllerName.clear();
                      _controllerLastName.clear();
                      _controllerCompanyName.clear();
                      _phoneController.reset();
                      _controllerAddress.clear();
                      _controllerTaxNumber.clear();
                      _controllerCargoName.clear();
                      _controllerCargoCode.clear();
                      _phoneController.reset();
                      setState(() {
                        _selectDistrict = null;
                        _selectedCity = null;
                        _selectedTaxOffice = null;
                      });

                      ///Güncellemeden sonra değişiklik ekrana yansıması için tekrar
                      ///veriler çekiliyor.
                      _blocCustomerRegister.getAllCustomer();
                      _controllerSearchCustomerName.clear();
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
              _labelUpdate,
            ),
          )),
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
