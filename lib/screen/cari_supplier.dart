import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/bloc/bloc_cari_supplier.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/database_mango.dart';
import 'package:stok_takip/models/cari_get_pay.dart';
import 'package:stok_takip/modified_lib/searchfield.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/popup/popup_cari_supplier_payment.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/format_convert_point_comma.dart';
import '../validations/format_decimal_limit.dart';
import 'drawer.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ScreenCariSupplier extends StatefulWidget {
  const ScreenCariSupplier({super.key});

  @override
  State<ScreenCariSupplier> createState() => _ScreenCariSupplierState();
}

class _ScreenCariSupplierState extends State<ScreenCariSupplier> {
  final _formKeyCari = GlobalKey<FormState>();
  late double _screenWidth;
  final double _shareMinWidth = 360;
  final double _shareMaxWidth = 1200;
  final double _shareHeightInputTextField = 40;
  final String _labelHeading = "Cari Hesaplar";
  final String _labelInvoice = "Fatura No";
  final String _labelSearchInvoice = "Fatura No ile";
  late final BlocCariSuppleirs _blocCariSupplier;
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
  final _focusSearchSupplier = FocusNode();

  /*--------------------------------------------------------------------- */
  /*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  List<Map<String, dynamic>> _selecteds = [];
  final double _dataTableWidth = 745;
  final double _dataTableHeight = 710;
/*------------------------------------------------------------------------- */
  /*----------------BAŞLANGIÇ - ÖDEME ALINDIĞI YER------------- */

  final _controllerCashValue = TextEditingController();
  final _controllerBankValue = TextEditingController();
  final _controllerEftHavaleValue = TextEditingController();

  final String _cash = "Nakit İle Ödenen Tutar";
  final String _eftHavale = "EFT/HAVALE İle Ödenen Tutar";
  final String _bankCard = "Kart İle Ödenen Tutar";
  final String _labelPaymentInfo = "Ödeme Bilgileri";
  final String _labelPay = "Ödeme Yap";

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
    _blocCariSupplier = BlocCariSuppleirs();
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
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Tedarikçi",
        value: "supplierName",
        show: true,
        flex: 3,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Toplam Tutar",
        value: "totalPrice",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Yapılan Ödeme",
        value: "payment",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Kalan Ödeme",
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
          return Container(
            alignment: Alignment.centerRight,
            child: Row(
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
                    widgetDeleteSupplierPayment(row);
                  },
                ),
                row['totalPrice'] != "-"
                    ? IconButton(
                        iconSize: 20,
                        padding: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.center,
                        icon: const Icon(Icons.list),
                        onPressed: () async {
                          Map<String, dynamic> paymentInfo = await db
                              .fetchPaymentInfoByPaymentId(row['paymentId']);
                          Map<String, dynamic> supplierInfo =
                              await db.fetchSupplierInfo(row['supplierName']);

                          paymentInfo['seller'] = await _blocCariSupplier
                              .getSaleInfo(dbHive.getValues('uuid'));

                          showDialog(
                              context: context,
                              builder: (context) {
                                return PopupCariSupplierPayment(
                                    paymentInfo, supplierInfo);
                              });
                        },
                      )
                    : const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 20),
                        child: Icon(Icons.disabled_by_default),
                      ),
              ],
            ),
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
      drawer: const MyDrawer(),
    );
  }

  Widget buildCari() {
    return Form(
        key: _formKeyCari,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          decoration: context.extensionThemaGreyContainer(),
          child: SingleChildScrollView(
              child: Container(
            constraints: BoxConstraints(
                minWidth: _shareMinWidth, maxWidth: _shareMaxWidth),
            padding: context.extensionPadding20(),
            decoration: context.extensionThemaWhiteContainer(),
            child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: context.extensionWrapSpacing10(),
                spacing: context.extensionWrapSpacing20(),
                direction: Axis.horizontal,
                children: [
                  Column(children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: context.extensionWrapSpacing10(),
                      spacing: 25,
                      children: [
                        //Tarih Bölümü Seçme
                        widgetRangeSelectDateTime(),
                        //Fatura Kodu ile Arama Bölümü
                        Wrap(
                          direction: Axis.vertical,
                          verticalDirection: VerticalDirection.down,
                          alignment: WrapAlignment.center,
                          spacing: context.extensionWrapSpacing20(),
                          runSpacing: context.extensionWrapSpacing10(),
                          children: [
                            widgetSearchFieldInvoice(),
                          ],
                        ),
                      ],
                    ),
                    context.extensionHighSizedBox10(),
                    widgetGetCariByName(),
                    context.extensionHighSizedBox10(),
                    widgetDateTable(),
                  ]),
                  widgetPaymentInformationSection()
                ]),
          )),
        ));
  }

  ///Fatura no ile arama
  widgetSearchFieldInvoice() {
    return SizedBox(
      width: _shareMinWidth,
      height: _shareHeightInputTextField,
      child: Row(children: [
        Expanded(
            child: shareWidget.widgetTextFieldInput(
                controller: _controllerInvoiceNo, etiket: _labelInvoice)),
        context.extensionWidhSizedBox10(),
        SizedBox(
          width: 180,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await _blocCariSupplier
                  .getCariByInvoiceNo(_controllerInvoiceNo.text);
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
      width: _shareMinWidth,
      height: _shareHeightInputTextField,
      child: Row(
        children: [
          shareWidgetDateTimeTextFormField(
              _controllerStartDate, _labelStartDate, (value) {
            if (value.length == 10) {
              _blocCariSupplier.setterStartDate =
                  DateFormat('dd/MM/yyyy').parse(value);
            }
          }),
          context.extensionWidhSizedBox10(),
          shareWidgetDateTimeTextFormField(_controllerEndDate, _labelEndDate,
              (value) {
            if (value.length == 10) {
              _blocCariSupplier.setterEndDate = DateFormat('dd/MM/yyyy')
                  .parse(value)
                  .add(const Duration(hours: 23, minutes: 59, seconds: 59));
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
      _blocCariSupplier.setDateRange(_selectDateTimeRange);

      //seçilen tarihler inputlara aktarılıyor.
      _controllerStartDate.text =
          dateTimeConvertFormatString(_blocCariSupplier.getterStartDate);

      _controllerEndDate.text =
          dateTimeConvertFormatString(_blocCariSupplier.getterEndDate);
    }
  }

  ///-----Textfield ekranına basmak için DateTime verisini String çeviriyor.
  String dateTimeConvertFormatString(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  ///isim ile cari getirme
  widgetGetCariByName() {
    return SizedBox(
        width: _dataTableWidth,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          direction: Axis.horizontal,
          runAlignment: WrapAlignment.center,
          children: [
            StreamBuilder<List<Map<String, String>>>(
                stream: _blocCariSupplier.getStreamSuppliers,
                builder: (context, snapshot) {
                  List<SearchFieldListItem<String>> listSearch =
                      <SearchFieldListItem<String>>[];
                  listSearch.add(SearchFieldListItem("Veriler Yükleniyor"));

                  if (snapshot.hasData && !snapshot.hasError) {
                    listSearch.clear();

                    for (var element in snapshot.data!) {
                      listSearch.add(SearchFieldListItem(element['name']!,
                          item: element['phone']));
                    }
                  }
                  return SizedBox(
                    width: _screenWidth <= 450 ? 360 : 555,
                    child: SearchField(
                      searchHeight: _shareHeightInputTextField,
                      itemHeight: _searchByNameItemHeight,
                      searchInputDecoration: InputDecoration(
                          isDense: true,
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          label: Text(_labelSearchCustomerName),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.black),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(),
                          )),
                      controller: _controllerSearchByName,
                      suggestions: listSearch,
                      focusNode: _focusSearchSupplier,
                      searchStyle: const TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.fade,
                      ),
                      onSuggestionTap: (p0) {
                        ///Her şeçimde müşteri bilgileri atanıyor.
                        List<String> convertMap = p0.searchKey.split(' - ');

                        _blocCariSupplier.setterSelectedSupplier = {
                          'name': convertMap[0],
                          'phone': convertMap[1]
                        };

                        _focusSearchSupplier.unfocus();
                      },
                      maxSuggestionsInViewPort: 6,
                    ),
                  );
                }),
            widgetButtonCariGetir(),
          ],
        ));
  }

  ///Button Cari Getir
  widgetButtonCariGetir() {
    return SizedBox(
      width: (_screenWidth >= 450) ? 180 : 360,
      height: _shareHeightInputTextField,
      child: ElevatedButton.icon(
          icon: const Icon(Icons.format_list_bulleted_sharp),
          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () async {
            ///Sadece Müşteri seçildiğinde
            if (_controllerSearchByName.text.isNotEmpty &&
                _controllerStartDate.text == "" &&
                _controllerEndDate.text == "") {
              _blocCariSupplier.getPaymentListOfSelectedSupplier();
              //Müşteri ve Tarihler seçildiğinde
            } else if (_controllerSearchByName.text.isNotEmpty &&
                _controllerStartDate.text.isNotEmpty &&
                _controllerEndDate.text.isNotEmpty) {
              await _blocCariSupplier.getPaymentListOfSelectedSupplier();
              await _blocCariSupplier.filtreSoldListByDateTime();
              //Sadece Tarih seçildiğinde
            } else if (_controllerStartDate.text.isNotEmpty &&
                _controllerEndDate.text.isNotEmpty &&
                _controllerSearchByName.text == "") {
              await _blocCariSupplier.getOnlyUseDateTimeForPaymentList();
              //Tümü Boş iken buda o günkü satışları getirir
            } else if (_controllerSearchByName.text == "" &&
                _controllerStartDate.text == "" &&
                _controllerEndDate.text == "") {
              _blocCariSupplier.setToday();
              await _blocCariSupplier.getOnlyUseDateTimeForPaymentList();
            }
          },
          label: Text(_labelGetCari)),
    );
  }

  ///cari Liste tablosu
  widgetDateTable() {
    return SizedBox(
      width: _dataTableWidth,
      height: _dataTableHeight,
      child: Card(
        margin: const EdgeInsets.only(top: 5),
        elevation: 5,
        shadowColor: Colors.black,
        clipBehavior: Clip.none,
        child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _blocCariSupplier.getStreamSoldList.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {}

              return ResponsiveDatatable(
                reponseScreenSizes: const [ScreenSize.xs],
                headers: _headers,
                source: snapshot.data,
                selecteds: _selecteds,
                expanded: _blocCariSupplier.getterExpandad,
                autoHeight: false,
                sortColumn: 'dataTime',
                sortAscending: true,
                actions: [widgetButtonPrinter(snapshot)],
                dropContainer: (value) {
                  if (value.containsKey('productName')) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: RichText(
                        text: TextSpan(
                            style: context.theme.titleSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                            text: "ÜRÜN KODU: ",
                            children: [
                              TextSpan(
                                  text: " ${value['productName']}",
                                  style: context.theme.titleSmall!)
                            ]),
                      ),
                    );
                  }
                  return Text("");
                },
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
                                _blocCariSupplier
                                    .getterCalculationRow['totalPrice']),
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
                                        _blocCariSupplier.getterCalculationRow[
                                            'totalPayment']),
                                    style: context.theme.titleMedium!
                                        .copyWith(color: Colors.white))
                              ]),
                          TextSpan(text: "   Kalan Tutar : ", children: [
                            TextSpan(
                                text: FormatterConvert().currencyShow(
                                    _blocCariSupplier
                                        .getterCalculationRow['balance']),
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
  Expanded shareWidgetDateTimeTextFormField(TextEditingController controller,
      String label, Function(String)? onChanged) {
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
        _blocCariSupplier.setterEndDate = DateFormat('dd/MM/yyyy').parse(value);
      },
    ));
  }

  //Ödemenin Alındığı Yer - Ödeme Bilgisi
  widgetPaymentInformationSection() {
    return SizedBox(
      width: _shareMinWidth,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          partOfWidgetHeader(context, _labelPaymentInfo, Colors.grey),
          Container(
              margin: const EdgeInsets.only(top: 20),
              child: widgetCurrencySelectSection()),
          widgetPaymentOptionsTextFieldAndButton(),
        ]),
      ),
    );
  }

  ///Ödeme verilerin alındığı yer.
  widgetPaymentOptionsTextFieldAndButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      width: _shareMinWidth,
      height: 320,
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        spacing: 10,
        children: [
          ///Nakit Ödeme
          sharedTextFormField(
            width: _shareMinWidth - 20,
            labelText: _cash,
            controller: _controllerCashValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _blocCariSupplier.setPaymentCashValue(value);
              } else {
                _blocCariSupplier.setPaymentCashValue("0");
              }
            },
          ),
          //Bankakartı Ödeme Widget
          sharedTextFormField(
            width: _shareMinWidth - 20,
            labelText: _bankCard,
            controller: _controllerBankValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _blocCariSupplier.setPaymentBankCardValue(value);
              } else {
                _blocCariSupplier.setPaymentBankCardValue("0");
              }
            },
          ),
          //EFTveHavale Ödeme Widget
          sharedTextFormField(
            width: _shareMinWidth - 20,
            labelText: _eftHavale,
            controller: _controllerEftHavaleValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _blocCariSupplier.setPaymentEftHavaleValue(value);
              } else {
                _blocCariSupplier.setPaymentEftHavaleValue("0");
              }
            },
          ),

          ///Button Ödeme Al
          shareWidget.widgetElevatedButton(
              buttonStyle: ElevatedButton.styleFrom(
                  fixedSize: Size(_shareMinWidth - 20, 40)),
              onPressedDoSomething: () async {
                ///Müşteri seçilme veya seçildikten sonra silinme durumunda
                ///uyarı veriyor.
                if (_blocCariSupplier.getterSelectedSupplier['name'] == null ||
                    _controllerSearchByName.text == "") {
                  context.noticeBarError("Lütfen tedarikçi seçiniz.", 3);

                  ///Ödeme için bir veri girilmediyse kayıt olmaması için.
                } else if (_controllerEftHavaleValue.text == "" &&
                    _controllerBankValue.text == "" &&
                    _controllerCashValue.text == "") {
                  context.noticeBarError("Ödeme alanı boş.", 3);

                  ///veri kaydediliyor Burada.
                } else {
                  ///Dönen Veride "hata" null dönerse veri kaydediliyor.
                  ///null dönmezse hata mesajı dönüyor.
                  final ret = await _blocCariSupplier
                      .savePayment(_selectUnitOfCurrencyAbridgment);
                  if (ret['hata'] == null) {
                    _blocCariSupplier.resetPaymentsValue();
                    _controllerBankValue.clear();
                    _controllerCashValue.clear();
                    _controllerEftHavaleValue.clear();
                    _controllerStartDate.clear();
                    _controllerEndDate.clear();

                    _blocCariSupplier.getPaymentListOfSelectedSupplier();

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
              label: _labelPay),
        ],
      ),
    );
  }

  ///PaymentSystem textfield
  sharedTextFormField(
      {required double width,
      required String labelText,
      required TextEditingController controller,
      required void Function(String)? onChanged,
      String? Function(String?)? validator}) {
    return Container(
      padding: context.extensionPadding10(),
      width: width,
      child: TextFormField(
        validator: validator,
        onChanged: onChanged,
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
          FormatterDecimalLimit(decimalRange: 2)
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

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  Container partOfWidgetHeader(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.headline6!.copyWith(color: Colors.white);
    return Container(
      alignment: Alignment.center,
      width: _shareMinWidth,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
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
  widgetDeleteSupplierPayment(Map<String?, dynamic> selectRowInfo) {
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
                            await _blocCariSupplier
                                .deletePaymentAndCariSupplierOrjinalSource(
                                    selectRowInfo);
                            //Müşteri ve Tarihler seçildiğinde
                          } else if (_controllerSearchByName.text.isNotEmpty &&
                              _controllerStartDate.text.isNotEmpty &&
                              _controllerEndDate.text.isNotEmpty) {
                            await _blocCariSupplier
                                .deletePaymentAndCariSupplierFilterSource(
                                    selectRowInfo);
                            //Sadece Tarih seçildiğinde
                          } else if (_controllerStartDate.text.isNotEmpty &&
                              _controllerEndDate.text.isNotEmpty &&
                              _controllerSearchByName.text == "") {
                            await _blocCariSupplier
                                .deletePaymentAndCariSupplierOrjinalSource(
                                    selectRowInfo);
                            //Tümü Boş iken buda o günkü satışları getirir
                          } else if (_controllerSearchByName.text == "" &&
                              _controllerStartDate.text == "" &&
                              _controllerEndDate.text == "") {
                            await _blocCariSupplier
                                .deletePaymentAndCariSupplierOrjinalSource(
                                    selectRowInfo);
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
            printPDF(_headers, snapshot.data,
                _blocCariSupplier.getterCalculationRow);
          }
        },
        icon: Icon(
          Icons.print_rounded,
          color: Colors.grey,
        ));
  }

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
}
