import 'package:adaptivex/adaptivex.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';
import 'package:stok_takip/bloc/bloc_cari_customer.dart';
import 'package:stok_takip/models/cari_get_pay.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/validations/format_decimal_3by3_financial.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import '../utilities/popup/popup_cari_sale_detail.dart';
import '../utilities/share_func.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/format_convert_point_comma.dart';
import 'drawer.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;

class ScreenCariCustomer extends StatefulWidget {
  const ScreenCariCustomer({super.key});

  @override
  State<ScreenCariCustomer> createState() => _ScreenCariCustomerState();
}

class _ScreenCariCustomerState extends State<ScreenCariCustomer> {
  final _formKeyCari = GlobalKey<FormState>();
  late double _screenWidth;
  final double _shareMinWidth = 360;
  final double _shareHeightInputTextField = 40;
  final String _labelHeading = "Müşteri Cari Ekranı";
  final String _labelInvoice = "Fatura No";
  final String _labelSearchInvoice = "Fatura No ile";
  late final BlocCariCustomer _blocCari;
  late CariGetPay cariGetpay;
  /*-------------------BAŞLANGIÇ TARİH ARALIĞI SEÇİMİ ----------------------*/

  late DateTimeRange? _selectDateTimeRange;
  final DateTime _startDateTime = DateTime.now();
  final DateTime _endDateTime = DateTime.now();
  final String _labelStartDate = "Başlangıç Tarihi";
  final String _labelEndDate = "Bitiş Tarihi";

  final TextEditingController _controllerStartDate = TextEditingController();
  final TextEditingController _controllerEndDate = TextEditingController();
  /*----------------------------------------------------------------------- */

  /*-------------------BAŞLANGIÇ MÜŞTERİ ADI İLE ARAMA---------------------*/
  final TextEditingController _controllerSearchByName = TextEditingController();
  final String _labelGetCari = "Cari Getir";
  final String _labelSearchCustomerName = "Müşteri Adı";
  final double _searchByNameItemHeight = 30;
  final _focusSearchCustomer = FocusNode();

  /*--------------------------------------------------------------------- */
  /*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  List<Map<String, dynamic>> _selecteds = [];
  final double _heightTableDesktop = 560;
  final double _heightTableMobil = 470;
/*------------------------------------------------------------------------- */
  /*----------------BAŞLANGIÇ - ÖDEME ALINDIĞI YER------------- */

  final _controllerCashValue = TextEditingController();
  final _controllerBankValue = TextEditingController();
  final _controllerEftHavaleValue = TextEditingController();

  final String _cash = "Nakit İle Ödenen Tutar";
  final String _eftHavale = "EFT/HAVALE İle Ödenen Tutar";
  final String _bankCard = "Kart İle Ödenen Tutar";
  final String _labelPaymentInfo = "Ödeme Bilgileri";
  final String _labelGetPay = "Ödeme Al";

/*--------------------------------------------------------------------------- */
  /*------------ BAŞLANGIÇ - PARABİRİMİ SEÇİMİ------------------- */
  late Color _colorBackgroundCurrencyUSD;
  late Color _colorBackgroundCurrencyTRY;
  late Color _colorBackgroundCurrencyEUR;
  late String _selectUnitOfCurrencySymbol;
  late String _selectUnitOfCurrencyAbridgment;
  final String _labelCurrencySelect = "Para Birimi Seçiniz";
  final Map<String, dynamic> _mapUnitOfCurrency = {
    "Türkiye": {"symbol": "₺", "abridgment": "TL"},
    "amerika": {"symbol": '\$', "abridgment": "USD"},
    "avrupa": {"symbol": '€', "abridgment": "EURO"}
  };
  final double _widthCurrency = 250;
  /*---------------------FATURA NO--------------------------------------- */
  final _controllerInvoiceNo = TextEditingController();
/*???????????????? SON - (PARABİRİMİ SEÇİMİ) ???????????????? */
  @override
  void initState() {
    _blocCari = BlocCariCustomer();
    //  _blocCari.getOnlyUseDateTimeForSoldList();
    _selectDateTimeRange =
        DateTimeRange(start: _startDateTime, end: _endDateTime);
    /*-------------------DATATABLE--------------------------------------- */

    _headers = [];

    _headers.add(DatatableHeader(
        text: "Tarih - Saat",
        value: "dateTime",
        show: true,
        sortable: true,
        flex: 3,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Tür",
        value: "type",
        show: true,
        flex: 2,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Müşteri İsmi",
        value: "customerName",
        show: true,
        flex: 3,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Fatura No",
        value: "invoiceNumber",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Toplam Tutar",
        value: "totalPrice",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Ödenen Tutar",
        value: "payment",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Kalan Tutar",
        value: "balance",
        show: true,
        sortable: false,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Sil ve Detay",
        value: "detail",
        show: true,
        sortable: false,
        flex: 2,
        sourceBuilder: (value, row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ///Silme Buttonu
              IconButton(
                iconSize: 20,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                icon: const Icon(Icons.delete),
                onPressed: () {
                  ///Stok bitmeden silmeyi engelliyor.
                  widgetDeleteInvoice(row['invoiceNumber'], row['totalPrice']);
                },
              ),
              row['totalPrice'] != "-"
                  ? IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.only(bottom: 20),
                      alignment: Alignment.center,
                      icon: const Icon(Icons.list),
                      onPressed: () async {
                        ///satır bilgisi aktarılıyor
                        _blocCari.setterRowCustomerInfo = row;
                        //  print(row);

                        ///Fatura No'suna göre detaylar geliyor.
                        await _blocCari.getSaleDetail(row['invoiceNumber']);
                        await _blocCari.getSaleInfo(row['invoiceNumber']);

                        // ignore: use_build_context_synchronously
                        showDialog(
                            context: context,
                            builder: (context) {
                              return PopupSaleDetail(_blocCari);
                            });
                      },
                    )
                  : const Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 20),
                      child: Icon(Icons.disabled_by_default),
                    ),
            ],
          );
        },
        textAlign: TextAlign.center));

/*------------ BAŞLANGIÇ - PARABİRİMİ SEÇİMİ------------------- */
    _selectUnitOfCurrencySymbol = _mapUnitOfCurrency["Türkiye"]["symbol"];
    _selectUnitOfCurrencyAbridgment =
        _mapUnitOfCurrency["Türkiye"]["abridgment"];
    _colorBackgroundCurrencyUSD = context.extensionDefaultColor;
    _colorBackgroundCurrencyTRY = context.extensionDisableColor;
    _colorBackgroundCurrencyEUR = context.extensionDefaultColor;

/*----------------------------------------------------------------------- */

    cariGetpay = CariGetPay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_labelHeading),

        iconTheme: IconThemeData(color: Colors.blueGrey.shade100),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildCari(),
      drawerScrimColor: Colors.transparent,
      drawer: const MyDrawer(),
    );
  }

  Widget buildCari() {
    return Form(
        key: _formKeyCari,
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
              _screenWidth <= 500
                  ? widgetMainSectionMobil()
                  : widgetMainSectionDesktop(),
              widgetPaymentInformationSection()
            ],
          )),
        ));
  }

  Container widgetMainSectionDesktop() {
    return Container(
      width: dimension.widthMainSection,
      height: dimension.heightSection,
      padding: context.extensionPadding20(),
      decoration: context.extensionThemaWhiteContainer(),
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            widgetRangeSelectDateTime(),
            context.extensionWidhSizedBox20(),
            //Fatura Kodu ile Arama Bölümü
            widgetSearchFieldInvoice(),
          ],
        ),
        context.extensionHighSizedBox10(),
        widgetGetCariByNameDesktop(),
        context.extensionHighSizedBox10(),
        widgetDateTable(),
      ]),
    );
  }

  Container widgetMainSectionMobil() {
    return Container(
      width: dimension.widthMainSection,
      height: dimension.heightSection,
      padding: context.extensionPadding20(),
      decoration: context.extensionThemaWhiteContainer(),
      child: Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          runSpacing: 10,
          children: [
            widgetRangeSelectDateTime(),
            widgetSearchFieldInvoice(),
            widgetGetCariByNameMobil(),
            widgetDateTable(),
          ]),
    );
  }

  ///Fatura no ile arama
  widgetSearchFieldInvoice() {
    return SizedBox(
      width: _screenWidth <= 500
          ? dimension.widthMobilButtonAndTextfield
          : dimension.widthMainSectionInsideHalfOfTheRow,
      height: dimension.heightInputTextAnDropdown40,
      child: Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
            child: shareWidget.widgetTextFieldInput(
                controller: _controllerInvoiceNo, etiket: _labelInvoice)),
        context.extensionWidhSizedBox10(),
        SizedBox(
          width: 180,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await _blocCari.getCariByInvoiceNo(_controllerInvoiceNo.text);
            },
            label: Text(_labelSearchInvoice),
          ),
        ),
      ]),
    );
  }

  ///Zaman Aralı Seçildiği yer
  widgetRangeSelectDateTime() {
    return SizedBox(
      width: _screenWidth <= 500
          ? dimension.widthMobilButtonAndTextfield
          : dimension.widthMainSectionInsideHalfOfTheRow,
      height: dimension.heightInputTextAnDropdown40,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          shareWidgetSaveDateTimeTextFormField(
              _controllerStartDate, _labelStartDate, (value) {
            if (value.length == 10) {
              _blocCari.setterStartDate = DateFormat('dd/MM/yyyy').parse(value);
            }
          }),
          context.extensionWidhSizedBox10(),
          shareWidgetSaveDateTimeTextFormField(
              _controllerEndDate, _labelEndDate, (value) {
            if (value.length == 10) {
              _blocCari.setterEndDate = DateFormat('dd/MM/yyyy').parse(value);
            }
          }),
        ],
      ),
    );
  }

  ///Tarihin seçilip geldiği yer.
  Future<DateTimeRange?> pickDateRange() async {
    _selectDateTimeRange = await showDateRangePicker(
        context: context,
        initialDateRange:
            DateTimeRange(start: _startDateTime, end: _endDateTime),
        firstDate: DateTime(2010),
        lastDate: DateTime(2035),
        helpText: "Zaman Aralığı Seçiniz",
        saveText: "Tamam",
        builder: (context, child) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: SizedBox(
                  height: 500,
                  width: 450,
                  child: child,
                ),
              ),
            ],
          );
        });

    if (_selectDateTimeRange != null) {
      _blocCari.setDateRange(_selectDateTimeRange);

      //seçilen tarihler inputlara aktarılıyor.
      _controllerStartDate.text =
          dateTimeConvertFormatString(_blocCari.getterStartDate);

      _controllerEndDate.text =
          dateTimeConvertFormatString(_blocCari.getterEndDate);
    }
  }

  ///-----Textfield ekranına basmak için DateTime verisini String çeviriyor.
  String dateTimeConvertFormatString(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  ///isim ile cari getirme
  widgetGetCariByNameDesktop() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        StreamBuilder<List<Map<String, String>>>(
            stream: _blocCari.getStreamAllCustomer,
            builder: (context, snapshot) {
              List<SearchFieldListItem<String>> listSearch =
                  <SearchFieldListItem<String>>[];
              listSearch.add(SearchFieldListItem("Veriler Yükleniyor"));

              if (snapshot.hasData && !snapshot.hasError) {
                listSearch.clear();

                for (var element in snapshot.data!) {
                  listSearch.add(SearchFieldListItem(
                      "${element['type']} - ${element['name']!}",
                      item: element['type']));
                }
              }
              return Expanded(
                child: SearchField(
                  itemHeight: _searchByNameItemHeight,
                  searchInputDecoration: InputDecoration(
                      isDense: true,
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      label: Text(_labelSearchCustomerName),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      )),
                  controller: _controllerSearchByName,
                  suggestions: listSearch,
                  focusNode: _focusSearchCustomer,
                  searchStyle: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.fade,
                  ),
                  onSuggestionTap: (p0) {
                    ///Her şeçimde müşteri bilgileri atanıyor.
                    List<String> convertMap = p0.searchKey.split(' - ');

                    if (convertMap[0] == 'Şahıs') {
                      _blocCari.setterSelectedCustomer = {
                        'type': convertMap[0],
                        'name': convertMap[1],
                        'phone': convertMap[2].split(' ')[1]
                      };
                    } else {
                      _blocCari.setterSelectedCustomer = {
                        'type': convertMap[0],
                        'name': convertMap[1],
                        'phone': convertMap[2].split(' ')[1]
                      };
                    }
                    _focusSearchCustomer.unfocus();
                  },
                  maxSuggestionsInViewPort: 6,
                ),
              );
            }),
        context.extensionWidhSizedBox20(),
        widgetButtonCariGetir(),
      ],
    );
  }

  ///isim ile cari getirme
  widgetGetCariByNameMobil() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<List<Map<String, String>>>(
            stream: _blocCari.getStreamAllCustomer,
            builder: (context, snapshot) {
              List<SearchFieldListItem<String>> listSearch =
                  <SearchFieldListItem<String>>[];
              listSearch.add(SearchFieldListItem("Veriler Yükleniyor"));

              if (snapshot.hasData && !snapshot.hasError) {
                listSearch.clear();

                for (var element in snapshot.data!) {
                  listSearch.add(SearchFieldListItem(
                      "${element['type']} - ${element['name']!}",
                      item: element['type']));
                }
              }
              return SizedBox(
                width: dimension.widthMobilButtonAndTextfield,
                height: dimension.heightInputTextAnDropdown50,
                child: SearchField(
                  itemHeight: _searchByNameItemHeight,
                  searchInputDecoration: InputDecoration(
                      isDense: true,
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      label: Text(_labelSearchCustomerName),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      )),
                  controller: _controllerSearchByName,
                  suggestions: listSearch,
                  focusNode: _focusSearchCustomer,
                  searchStyle: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.fade,
                  ),
                  onSuggestionTap: (p0) {
                    ///Her şeçimde müşteri bilgileri atanıyor.
                    List<String> convertMap = p0.searchKey.split(' - ');

                    if (convertMap[0] == 'Şahıs') {
                      _blocCari.setterSelectedCustomer = {
                        'type': convertMap[0],
                        'name': convertMap[1],
                        'phone': convertMap[2].split(' ')[1]
                      };
                    } else {
                      _blocCari.setterSelectedCustomer = {
                        'type': convertMap[0],
                        'name': convertMap[1],
                        'phone': convertMap[2].split(' ')[1]
                      };
                    }
                    _focusSearchCustomer.unfocus();
                  },
                  maxSuggestionsInViewPort: 6,
                ),
              );
            }),
        context.extensionHighSizedBox10(),
        widgetButtonCariGetir(),
      ],
    );
  }

  ///Button Cari Getir
  widgetButtonCariGetir() {
    return SizedBox(
      width: _screenWidth <= 500 ? dimension.widthMobilButtonAndTextfield : 180,
      height: dimension.heightInputTextAnDropdown40,
      child: ElevatedButton.icon(
          icon: const Icon(Icons.format_list_bulleted_sharp),
          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () async {
            ///Sadece Müşteri seçildiğinde
            if (_controllerSearchByName.text.isNotEmpty &&
                _controllerStartDate.text == "" &&
                _controllerEndDate.text == "") {
              _blocCari.getSoldListOfSelectedCustomer();
              //Müşteri ve Tarihler seçildiğinde
            } else if (_controllerSearchByName.text.isNotEmpty &&
                _controllerStartDate.text.isNotEmpty &&
                _controllerEndDate.text.isNotEmpty) {
              await _blocCari.getSoldListOfSelectedCustomer();
              await _blocCari.filtreSoldListByDateTime();
              //Sadece Tarih seçildiğinde
            } else if (_controllerStartDate.text.isNotEmpty &&
                _controllerEndDate.text.isNotEmpty &&
                _controllerSearchByName.text == "") {
              await _blocCari.getOnlyUseDateTimeForSoldList();
              //Tümü Boş iken buda o günkü satışları getirir
            } else if (_controllerSearchByName.text == "" &&
                _controllerStartDate.text == "" &&
                _controllerEndDate.text == "") {
              _blocCari.setToday();
              await _blocCari.getOnlyUseDateTimeForSoldList();
            }
          },
          label: Text(_labelGetCari)),
    );
  }

  ///cari Liste tablosu
  widgetDateTable() {
    return SizedBox(
      width: dimension.widthTable,
      height: _screenWidth <= 500 ? _heightTableMobil : _heightTableDesktop,
      child: Card(
        margin: const EdgeInsets.only(top: 5),
        elevation: 5,
        shadowColor: Colors.black,
        clipBehavior: Clip.none,
        child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _blocCari.getStreamSoldList.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {}

              return ResponsiveDatatable(
                reponseScreenSizes: const [ScreenSize.xs],
                headers: _headers,
                source: snapshot.data,
                selecteds: _selecteds,
                expanded: _blocCari.getterExpandad,
                autoHeight: false,
                actions: [widgetButtonPrinter(snapshot)],
                footerDecoration:
                    BoxDecoration(color: context.extensionDefaultColor),
                footers: [
                  RichText(
                    overflow: TextOverflow.visible,
                    text: TextSpan(
                        text: "Toplam Tutar : ",
                        style: context.theme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white),
                        children: [
                          TextSpan(
                            text: FormatterConvert().currencyShow(
                                _blocCari.getterCalculationRow['totalPrice']),
                            style: context.theme.titleMedium!
                                .copyWith(color: Colors.white),
                          ),
                          TextSpan(
                              text: "   Ödenen Tutar : ",
                              style: const TextStyle(
                                  color: Colors.white, letterSpacing: 1),
                              children: [
                                TextSpan(
                                    text: FormatterConvert().currencyShow(
                                        _blocCari.getterCalculationRow[
                                            'totalPayment']),
                                    style: context.theme.titleMedium!
                                        .copyWith(color: Colors.white))
                              ]),
                          TextSpan(text: "   Kalan Tutar : ", children: [
                            TextSpan(
                                text: FormatterConvert().currencyShow(
                                    _blocCari.getterCalculationRow['balance']),
                                style: context.theme.titleMedium!.copyWith(
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white))
                          ]),
                        ]),
                  ),
                ],
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

  ///Zaman Aralık için textformfiled
  Expanded shareWidgetSaveDateTimeTextFormField(
      TextEditingController controller,
      String label,
      Function(String)? onChanged) {
    return Expanded(
        child: TextFormField(
      textAlign: TextAlign.start,
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
          hintText: "gg/aa/yyyy",
          contentPadding: const EdgeInsets.only(top: 40),
          prefixIcon: IconButton(
            color: context.extensionDefaultColor,
            icon: const Icon(Icons.date_range),
            onPressed: () async => await pickDateRange(),
          ),
          counterText: "",
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          )),
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
      ],
      onChanged: onChanged,
      onFieldSubmitted: (value) {
        _blocCari.setterEndDate = DateFormat('dd/MM/yyyy').parse(value);
      },
    ));
  }

  //Ödemenin Alındığı Yer - Ödeme Bilgisi
  widgetPaymentInformationSection() {
    return SizedBox(
      width: dimension.widthSideSectionAndMobil,
      height: dimension.heightSection,
      child: Column(
        children: [
          partOfWidgetHeader(context, _labelPaymentInfo, Colors.grey),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                  boxShadow: context.extensionBoxShadow()),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                shareWidgetDateTimeTextFormField(),
                const Divider(
                  color: Colors.grey,
                  thickness: 1.5,
                  endIndent: 20,
                  indent: 20,
                  height: 40,
                ),
                Container(
                    // margin: const EdgeInsets.only(top: 10),
                    child: widgetCurrencySelectSection()),
                context.extensionHighSizedBox20(),
                widgetPaymentOptionsTextFieldAndButton(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  ///Ödeme verilerin alındığı yer.
  widgetPaymentOptionsTextFieldAndButton() {
    return Wrap(
      alignment: WrapAlignment.center,
      direction: Axis.vertical,
      spacing: 20,
      children: [
        ///Nakit Ödeme
        sharedTextFormField(
          labelText: _cash,
          controller: _controllerCashValue,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _blocCari.setPaymentCashValue(value);
            } else {
              _blocCari.setPaymentCashValue("0");
            }
          },
        ),
        //Bankakartı Ödeme Widget
        sharedTextFormField(
          labelText: _bankCard,
          controller: _controllerBankValue,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _blocCari.setPaymentBankCardValue(value);
            } else {
              _blocCari.setPaymentBankCardValue("0");
            }
          },
        ),
        //EFTveHavale Ödeme Widget
        sharedTextFormField(
          labelText: _eftHavale,
          controller: _controllerEftHavaleValue,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _blocCari.setPaymentEftHavaleValue(value);
            } else {
              _blocCari.setPaymentEftHavaleValue("0");
            }
          },
        ),

        ///Button Ödeme Al
        shareWidget.widgetElevatedButton(
            buttonStyle: ElevatedButton.styleFrom(fixedSize: Size(320, 40)),
            onPressedDoSomething: () async {
              ///Müşteri seçilme veya seçildikten sonra silinme durumunda
              ///uyarı veriyor.
              if (_blocCari.getterSelectedCustomer['name'] == null ||
                  _controllerSearchByName.text == "") {
                context.noticeBarError("Lütfen müşteri seçiniz.", 3);

                ///Ödeme için bir veri girilmediyse kayıt olmaması için.
              } else if (_controllerEftHavaleValue.text == "" &&
                  _controllerBankValue.text == "" &&
                  _controllerCashValue.text == "") {
                context.noticeBarError("Ödeme alanı boş.", 3);

                ///veri kaydediliyor Burada.
              } else {
                ///Dönen Veride "hata" null dönerse veri kaydediliyor.
                ///null dönmezse hata mesajı dönüyor.
                final ret = await _blocCari
                    .savePayment(_selectUnitOfCurrencyAbridgment);
                if (ret['hata'] == null) {
                  _blocCari.resetPaymentsValue();
                  _controllerBankValue.clear();
                  _controllerCashValue.clear();
                  _controllerEftHavaleValue.clear();
                  _controllerStartDate.clear();
                  _controllerEndDate.clear();

                  _blocCari.getSoldListOfSelectedCustomer();

                  ///Bura aktif olur ise ödeme alındığında kendi alanında kalır.
                  /*  ///Sadece Müşteri seçildiğinde
                  if (_controllerSearchByName.text.isNotEmpty &&
                      _controllerStartDate.text == "" &&
                      _controllerEndDate.text == "") {
                    _blocCari.getSoldListOfSelectedCustomer();
                    //Müşteri ve Tarihler seçildiğinde
                  } else if (_controllerSearchByName.text.isNotEmpty &&
                      _controllerStartDate.text.isNotEmpty &&
                      _controllerEndDate.text.isNotEmpty) {
                    await _blocCari.getSoldListOfSelectedCustomer();
                    await _blocCari.filtreSoldListByDateTime();
                    //Sadece Tarih seçildiğinde
                  } else if (_controllerStartDate.text.isNotEmpty &&
                      _controllerEndDate.text.isNotEmpty &&
                      _controllerSearchByName.text == "") {
                    await _blocCari.getOnlyUseDateTimeForSoldList();
                    //Tümü Boş iken buda o günkü satışları getirir
                  } else if (_controllerSearchByName.text == "" &&
                      _controllerStartDate.text == "" &&
                      _controllerEndDate.text == "") {
                    _blocCari.setToday();
                    await _blocCari.getOnlyUseDateTimeForSoldList();
                  } */

                  // ignore: use_build_context_synchronously
                  context.noticeBarTrue("Ödeme başarılı.", 2);
                } else {
                  // ignore: use_build_context_synchronously
                  context.noticeBarError(ret['hata'], 3);
                }
              }
            },
            label: _labelGetPay),
      ],
    );
  }

  ///PaymentSystem textfield
  sharedTextFormField(
      {required String labelText,
      required TextEditingController controller,
      required void Function(String)? onChanged,
      String? Function(String?)? validator}) {
    return SizedBox(
      width: 320,
      child: TextFormField(
        validator: validator,
        onChanged: onChanged,
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: [FormatterDecimalThreeByThreeFinancial()],
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

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  Container partOfWidgetHeader(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.titleLarge!.copyWith(color: Colors.white);
    return Container(
      alignment: Alignment.center,
      width: _shareMinWidth,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          color: backgroundColor, boxShadow: context.extensionBoxShadow()),
      child: Text(
        label,
        style: styleHeader,
      ),
    );
  }

  ///Para birimin seçildi yer
  widgetCurrencySelectSection() {
    return Stack(
      children: [
        Positioned(
          child: Container(
            alignment: Alignment.center,
            width: _widthCurrency,
            height: 50,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: context.extensionRadiusDefault10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                partOfWidgetshareInkwellCurrency(
                    onTap: () {
                      //Tekrar Seçildiğinde onu engellemek için if konuldu

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
                partOfWidgetshareInkwellCurrency(
                    onTap: () {
                      //Tekrar Seçildiğinde onu engellemek için if konuldu

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
                partOfWidgetshareInkwellCurrency(
                    onTap: () {
                      //Tekrar Seçildiğinde onu engellemek için if konuldu

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
    );
  }

  ///Ek- Parabirimi Seçildiği yer için yardımcı Widget
  partOfWidgetshareInkwellCurrency(
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

  ///Silme buttonu
  widgetDeleteInvoice(int invoiceNumber, String totalPrice) {
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

                    ///Fatura silme buttonu
                    child: ElevatedButton(
                        onPressed: () async {
                          ///Sadece Müşteri seçildiğinde
                          if (_controllerSearchByName.text.isNotEmpty &&
                              _controllerStartDate.text == "" &&
                              _controllerEndDate.text == "") {
                            await _blocCari.deleteInvoiceOrjinalSource(
                                invoiceNumber, totalPrice);
                            //Müşteri ve Tarihler seçildiğinde
                          } else if (_controllerSearchByName.text.isNotEmpty &&
                              _controllerStartDate.text.isNotEmpty &&
                              _controllerEndDate.text.isNotEmpty) {
                            await _blocCari.deleteInvoiceFiltreSource(
                                invoiceNumber, totalPrice);
                            //Sadece Tarih seçildiğinde
                          } else if (_controllerStartDate.text.isNotEmpty &&
                              _controllerEndDate.text.isNotEmpty &&
                              _controllerSearchByName.text == "") {
                            await _blocCari.deleteInvoiceOrjinalSource(
                                invoiceNumber, totalPrice);
                            //Tümü Boş iken buda o günkü satışları getirir
                          } else if (_controllerSearchByName.text == "" &&
                              _controllerStartDate.text == "" &&
                              _controllerEndDate.text == "") {
                            await _blocCari.deleteInvoiceOrjinalSource(
                                invoiceNumber, totalPrice);
                          }

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

  widgetButtonPrinter(AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    return IconButton(
        onPressed: () async {
          ///tablo boş ise pdf dökme hata veriyor. O yüzden burada verinin dolu kontrol ediliyor.

          if (snapshot.hasData) {
            printPDF(_headers, snapshot.data, _blocCari.getterCalculationRow);
          }
        },
        icon: Icon(
          Icons.print_rounded,
          color: Colors.grey,
        ));
  }

  ///Zaman Bölümü
  shareWidgetDateTimeTextFormField() {
    return Container(
        width: _widthCurrency,
        height: _shareHeightInputTextField,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: context.extensionDefaultColor),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: TextButton.icon(
            onPressed: () async {
              _blocCari.selectedSaveDateTime =
                  await pickDateSaveTime() ?? DateTime.now();
              TimeOfDay? timeRes = await pickTime();

              setState(() {
                if (timeRes != null) {
                  _blocCari.selectedSaveDateTime =
                      _blocCari.selectedSaveDateTime.add(Duration(
                          hours: timeRes.hour, minutes: timeRes.minute));
                }
              });
            },
            icon: Icon(
              Icons.date_range,
              color: context.extensionDefaultColor,
            ),
            label: Text(
              shareFunc
                  .dateTimeConvertFormatString(_blocCari.selectedSaveDateTime),
              style: context.theme.titleSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            )));
  }

  ///Tarih seçildiği yer.
  Future<DateTime?> pickDateSaveTime() => showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2050),
      confirmText: "Tamam");

  ///Saat seçildiği yer.
  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

  /*----------------------------------------------------------------------- */

  ///PDF ekleme
  printPDF(List<DatatableHeader> headers, List<Map<String, dynamic>>? source,
      Map<String, dynamic> footer) {
    ///son kolonda simge var diye buradan kaldırılıyor.

    Printing.layoutPdf(onLayout: ((format) async {
      var myFont = await PdfGoogleFonts.poppinsMedium();
      final pw.TextStyle letterCharacter =
          pw.TextStyle(font: myFont, fontSize: 9);
      final pw.TextStyle letterCharacterBold = pw.TextStyle(
          font: myFont, fontSize: 12, fontWeight: pw.FontWeight.bold);
      final pw.TextStyle letterHeader =
          pw.TextStyle(font: myFont, fontSize: 16);
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          maxPages: 100,
          build: (pw.Context context) => [
            pw.Center(
                heightFactor: 2.0,
                child: pw.Text('CARİ DÖKÜMÜ', style: letterHeader)),
            pw.Table(
              defaultColumnWidth: const pw.FixedColumnWidth(120.0),
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#8E8E8E'), width: 0.5),
              children: [
                ///İlk satır başlıkları Yapıyor.
                pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey,
                    ),
                    children: [
                      for (int i = 0; i < headers.length - 1; i++)
                        pw.Container(
                            margin: const pw.EdgeInsets.all(2.0),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(headers[i].text,
                                textAlign: pw.TextAlign.center,
                                style: letterCharacterBold))
                    ]),

                ///Satırları yapıldığı yer.
                for (int index = 0; index < source!.length; index++)
                  pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    decoration: pw.BoxDecoration(
                        color: index % 2 == 1
                            ? PdfColors.grey200
                            : PdfColors.white),
                    children: [
                      for (int i = 0; i < headers.length - 1; i++)
                        pw.Container(
                            margin: const pw.EdgeInsets.all(2.0),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                source[index][headers[i].value].toString(),
                                style: letterCharacter)),
                    ],
                  ),
              ],
            ),

            ///En alt satır.Toplam tutarların bölümü
            pw.Table(
                defaultColumnWidth: const pw.FixedColumnWidth(160),
                border: pw.TableBorder.symmetric(
                    outside: pw.BorderSide(
                        color: PdfColor.fromHex('#8E8E8E'), width: 0.5)),
                children: [
                  pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        pw.Container(
                            margin: const pw.EdgeInsets.all(2.0),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                "Toplam Tutar: ${FormatterConvert().currencyShow(footer['totalPrice'])}",
                                textAlign: pw.TextAlign.center,
                                style: letterCharacter)),
                        pw.Container(
                            margin: const pw.EdgeInsets.all(2.0),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                "Ödenen Tutar: ${FormatterConvert().currencyShow(footer['totalPayment'])}",
                                textAlign: pw.TextAlign.center,
                                style: letterCharacter)),
                        pw.Container(
                            margin: const pw.EdgeInsets.all(2.0),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                "Kalan Tutar: ${FormatterConvert().currencyShow(footer['balance'])}",
                                textAlign: pw.TextAlign.center,
                                style: letterCharacter))
                      ]),
                ])
          ],
        ),
      );
      return pdf.save();
    }));
  }

  getResponseWidth() {
    double currentWidth = MediaQuery.of(context).size.width;
  }
}
