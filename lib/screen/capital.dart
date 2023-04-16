import 'package:adaptivex/adaptivex.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:searchfield/searchfield.dart';

import 'package:stok_takip/bloc/bloc_capital.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_3by3_financial.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';
import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import 'drawer.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;

@RoutePage()
class ScreenCapital extends StatefulWidget {
  const ScreenCapital({super.key});

  @override
  State<ScreenCapital> createState() => _ScreenCapitalState();
}

class _ScreenCapitalState extends State<ScreenCapital> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeySupplier = GlobalKey<FormState>();
  bool isLoading = false;
  late BlocCapital _blocCapital;

  final String _labelCapitalHeader = "Sermaye İşlemleri Ekranı";
  /*--------------------------KASA--------------------------- */
  final String _labelCashBoxHeader = "KASA (AÇILIŞ)";
  final String _labelCash = "Nakit";
  final String _labelBank = "Banka";
  final String _labelCashBoxTotal = "Toplam";
  /*--------------------------------------------------------- */

/*--------------------------FLOAT BUTTON--------------------------- */
  final String _labelAddbalance = "Kasa İşlemi";
  final String _labelCapitalInflow = "Sermaye İşlemleri";
  /*--------------------------------------------------------- */
  /*--------------------------POPUP KASA--------------------------- */
  final String _labelOpenBalanceCash = "Nakit";
  final String _labelOpenBalanceBank = "Banka";
  final String _labelPositiveBalance = "(+) Bakiye";
  final String _labelNegativeBalance = "(-) Bakiye";
  final TextEditingController _controllerOpenCashBox = TextEditingController();
  final TextEditingController _controllerOpenBankBox = TextEditingController();

  final String _labelSave = "Kaydet";
  /*-------------------------------------------------------------- */
  /*---------------------POPUP Sermaye Giriş Çıkış---------------- */
  final String _labelLeadingAndCreditHeader = "Serma İşlemleri";
  final String _labelLeadingAndCreditCash = "Nakit";
  final String _labelLeadingAndCreditBank = "Banka";
  final String _labelLend = "Borç verdi";
  final String _labelBorrow = "Borç aldı";
  final TextEditingController _controllerLeadingAndCreditCash =
      TextEditingController();
  final TextEditingController _controllerLeadingAndCreditBank =
      TextEditingController();
  final TextEditingController _controllerSelectedPartnerLeadingAndBorow =
      TextEditingController();
  final FocusNode _focusNodeLeadingAndCredit = FocusNode();

  /*--------------------------------------------------------- */
  /*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  final List<Map<String, dynamic>> _selecteds = [];
  final double _dataTableWidth = 600;
  final double _dataTableHeight = 500;
  final TextEditingController _controllerSelectedPartner =
      TextEditingController();
  final double _searchByNameItemHeight = 30;
  final _focusSearchCustomer = FocusNode();
  final String _labelSearchPartnerName = "Ortak İsmi";
/*------------------------------------------------------------------------- */

  @override
  void initState() {
    _blocCapital = BlocCapital();

    /*-------------------DATATABLE--------------------------------------- */

    _headers = [];
    _headers.add(DatatableHeader(
        text: "Tarih - Saat",
        value: "saveTime",
        show: true,
        sortable: true,
        flex: 3,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Çalışan İsmi",
        value: "partnerName",
        show: true,
        flex: 3,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Borç Verdi",
        value: "totalLend",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Borç Aldı",
        value: "totalBorrow",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Sil",
        value: "detail",
        headerBuilder: (value) {
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "Sil",
              style: context.theme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white),
            ),
          );
        },
        show: true,
        sortable: false,
        flex: 1,
        sourceBuilder: (value, row) {
          return IconButton(
            padding: const EdgeInsets.only(bottom: 14),
            iconSize: 20,
            alignment: Alignment.center,
            icon: const Icon(Icons.delete),
            onPressed: () {
              _blocCapital.deleteSelectedRow(row['id']).then((value) {
                if (value == "") {
                  /* setState(() {
                    isLoading = !isLoading;
                  }); */
                  _blocCapital.getSelectCariParter();
                  return context.noticeBarTrue("İşlem Başarılı.", 2);
                } else {
                  return context.noticeBarTrue("Hata \n $value", 2);
                }
              });
            },
          );
        },
        textAlign: TextAlign.center));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widgetFloatButtonMenu(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _labelCapitalHeader,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const ShareWidgetAppbarSetting(),
        ],
      ),
      body: buildCapital(context),
      drawer: const MyDrawer(),
    );
  }

  Widget buildCapital(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: context.extensionThemaGreyContainer(),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                // ignore: prefer_const_literals_to_create_immutables
                boxShadow: [
                  const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8)
                ]),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 20, bottom: 20),
            height: 720,
            width: 700,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              widgetTableCashBox(),
              context.extensionHighSizedBox20(),
              widgetDateTable(),
            ]),
          ),
        ),
      ),
    );
  }

  ///Kasa Tablosu
  widgetTableCashBox() {
    return Container(
      decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4)]),
      constraints: BoxConstraints(minWidth: 360, maxWidth: _dataTableWidth),
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey.shade600,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            child: Text(
              _labelCashBoxHeader,
              style: context.theme.titleLarge!.copyWith(color: Colors.white),
            ),
          ),
          StreamBuilder<Map<String, dynamic>>(
              stream: _blocCapital.getStreamCashBox,
              //  initialData: {'cash': '0', 'bank': '0', 'total': '0'},
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  return Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    border: TableBorder.symmetric(
                        inside: const BorderSide(color: Colors.white)),
                    children: [
                      buildRowHeader(
                          [_labelCash, _labelBank, _labelCashBoxTotal]),
                      buildRowHeader([
                        snapshot.data!['cash'],
                        snapshot.data!['bank'],
                        snapshot.data!['total'],
                      ]),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              }),
        ],
      ),
    );
  }

/*-----------------------------Tablo Satır Yardımcı Widgetlar--------------- */
  TableRow buildRowRight(String header, String value) => TableRow(children: [
        TableCell(
            child: Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(4),
                alignment: Alignment.centerRight,
                child: Text(
                  header,
                  style:
                      context.theme.titleSmall!.copyWith(color: Colors.black),
                ))),
        TableCell(
            child: Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.fromLTRB(15, 4, 0, 4),
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style:
                      context.theme.titleSmall!.copyWith(color: Colors.black),
                ))),
      ]);

  TableRow buildRowHeader(List<String> headers) => TableRow(
          decoration: BoxDecoration(
            color: context.extensionDisableColor,
          ),
          children: [
            for (String header in headers)
              TableCell(
                  child: Container(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Text(
                        header,
                        style: context.theme.titleSmall!
                            .copyWith(color: Colors.white),
                      ))),
          ]);

  ///isim ile cari getirme
  widgetSearchPartner() {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: _blocCapital.getStreamAllPartner,
        builder: (context, snapshot) {
          List<SearchFieldListItem<String>> listSearch =
              <SearchFieldListItem<String>>[];
          listSearch.add(SearchFieldListItem("Veriler Yükleniyor"));

          if (snapshot.hasData && !snapshot.hasError) {
            listSearch.clear();
            for (var element in snapshot.data!) {
              listSearch.add(SearchFieldListItem("${element['name']}",
                  item: element['uuid']));
            }
          }
          return Flexible(
            flex: 10,
            child: SearchField(
              itemHeight: _searchByNameItemHeight,
              searchInputDecoration: InputDecoration(
                  isDense: true,
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  label: Text(_labelSearchPartnerName),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  )),
              controller: _controllerSelectedPartner,
              suggestions: listSearch,
              focusNode: _focusSearchCustomer,
              onSuggestionTap: (p0) {
                _blocCapital.setterSelectedPartnerId = p0.item;
                _blocCapital.getSelectCariParter();
                _focusSearchCustomer.unfocus();
              },
              maxSuggestionsInViewPort: 6,
            ),
          );
        });
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
            stream: _blocCapital.getStreamCariPartner,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {}
              return ResponsiveDatatable(
                rowHeight: 40,
                reponseScreenSizes: const [ScreenSize.xs],
                headers: _headers,
                source: snapshot.data,
                selecteds: _selecteds,
                expanded: _blocCapital.getterExpanded,
                autoHeight: false,
                actions: [
                  Flexible(
                    child: Row(
                      children: [
                        widgetSearchPartner(),
                        widgetButtonPrinter(snapshot)
                      ],
                    ),
                  )
                ],
                footerDecoration:
                    BoxDecoration(color: context.extensionDefaultColor),
                footers: [
                  RichText(
                    text: TextSpan(
                        text: "T. Verilen Borç : ",
                        style: context.theme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white),
                        children: [
                          TextSpan(
                            text: FormatterConvert().currencyShow(
                                _blocCapital.getterCalculationRow['totalLend']),
                            style: context.theme.titleSmall!
                                .copyWith(color: Colors.white),
                          ),
                          TextSpan(
                              text: "   T. Alınan Borç: ",
                              style: context.theme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.white),
                              children: [
                                TextSpan(
                                    text: FormatterConvert().currencyShow(
                                        _blocCapital.getterCalculationRow[
                                            'totalBorrow']),
                                    style: context.theme.titleSmall!
                                        .copyWith(color: Colors.white))
                              ]),
                          TextSpan(text: "   Bakiye : ", children: [
                            TextSpan(
                                text: FormatterConvert().currencyShow(
                                    _blocCapital
                                        .getterCalculationRow['balance']),
                                style: context.theme.titleSmall!.copyWith(
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

/*------------------------------------------------------------------------- */
  ///Menu Buttonu
  SpeedDial widgetFloatButtonMenu(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.list_view,
      children: [
        ///Menu Button Bakiye Ekle (Kasaya)
        SpeedDialChild(
          backgroundColor: context.extensionDefaultColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: _labelAddbalance,
          onTap: () {
            widgetPopupCashBoxAddValue(context);
          },
        ),

        ///Sermaye Girişi
        SpeedDialChild(
          backgroundColor: context.extensionDefaultColor,
          child: const Icon(Icons.add, color: Colors.white),
          label: _labelCapitalInflow,
          onTap: () {
            widgetPopupLeadingAndBorrow(context);
          },
        ),

        /*  ///Sermaye Çıkışı
        SpeedDialChild(
          backgroundColor: context.extensionDefaultColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: _labelCapitalOutflow,
        ) */
      ],
    );
  }

  ///Bakiye Giriş POPUP
  Future<dynamic> widgetPopupCashBoxAddValue(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            title: Text(
              textAlign: TextAlign.center,
              _labelAddbalance,
              style: context.theme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKeySupplier,
                // autovalidateMode: _autovalidateMode,
                child: Container(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  width: 500,
                  child: Column(children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widgetShareTextFieldFinancial(
                            _controllerOpenCashBox, _labelOpenBalanceCash),
                        context.extensionWidhSizedBox10(),
                        widgetDropdownButtonCashBalance(
                          context,
                        )
                      ],
                    ),
                    context.extensionHighSizedBox10(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widgetShareTextFieldFinancial(
                            _controllerOpenBankBox, _labelOpenBalanceBank),
                        context.extensionWidhSizedBox10(),
                        widgetDropdownButtonBankBalance(context),
                      ],
                    ),
                    context.extensionHighSizedBox10(),
                    widgetSaveButton()
                  ]),
                ),
              ),
            ),
          );
        });
  }

  ///Kasa Nakit Bölümü
  SizedBox widgetDropdownButtonCashBalance(BuildContext context) {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      height: context.extensionTextFieldHeight,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _blocCapital.getterSelectCashBalance,
        items: [
          DropdownMenuItem(
            value: "+",
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelPositiveBalance),
            ),
          ),
          DropdownMenuItem(
            value: "-",
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelNegativeBalance),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _blocCapital.selectCashBalance = value!;
          });
        },
        decoration: const InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10)),
      ),
    );
  }

  ///Kasa Banka bölümü
  SizedBox widgetDropdownButtonBankBalance(BuildContext context) {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      height: context.extensionTextFieldHeight,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _blocCapital.getterSelectBankBalance,
        items: [
          DropdownMenuItem(
            value: "+",
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelPositiveBalance),
            ),
          ),
          DropdownMenuItem(
            value: "-",
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelNegativeBalance),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _blocCapital.selectBankBalance = value!;
          });
        },
        decoration: const InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10)),
      ),
    );
  }

  ///Sermaya girişi veye çıkışı
  widgetPopupLeadingAndBorrow(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            title: Text(
              textAlign: TextAlign.center,
              _labelLeadingAndCreditHeader,
              style: context.theme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKeySupplier,
                // autovalidateMode: _autovalidateMode,
                child: Container(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  width: 500,
                  child: Column(children: [
                    widgetSearchPartnerLeadingAndBorrow(
                        _blocCapital.getterAllParter),
                    context.extensionHighSizedBox10(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widgetShareTextFieldFinancial(
                            _controllerLeadingAndCreditCash,
                            _labelLeadingAndCreditCash),
                        context.extensionWidhSizedBox10(),
                        widgetShareTextFieldFinancial(
                            _controllerLeadingAndCreditBank,
                            _labelLeadingAndCreditBank),
                      ],
                    ),
                    context.extensionHighSizedBox10(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        context.extensionWidhSizedBox10(),
                      ],
                    ),
                    widgetDropdownButtonLeadingAndBorrow(context),
                    context.extensionHighSizedBox10(),
                    widgetSaveButtonLeadingAndCredit()
                  ]),
                ),
              ),
            ),
          );
        });
  }

  ///Ortak Arama TextField Sermaye girişi veya çıkışı bölümü
  widgetSearchPartnerLeadingAndBorrow(List<Map<String, dynamic>> allPartner) {
    List<SearchFieldListItem<String>> listSearch =
        <SearchFieldListItem<String>>[];

    listSearch.clear();
    for (var element in allPartner) {
      listSearch.add(
          SearchFieldListItem("${element['name']}", item: element['uuid']));
    }
    return SizedBox(
      width: context.extensionTextFieldWidth * 2 + 10,
      child: SearchField(
        itemHeight: _searchByNameItemHeight,
        searchInputDecoration: InputDecoration(
            isDense: true,
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.extensionDisableColor),
            ),
            label: Text(_labelSearchPartnerName),
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(),
            )),
        controller: _controllerSelectedPartnerLeadingAndBorow,
        suggestions: listSearch,
        autoCorrect: true,
        focusNode: _focusNodeLeadingAndCredit,
        searchStyle: const TextStyle(
          fontSize: 14,
          overflow: TextOverflow.fade,
        ),
        onSuggestionTap: (p0) {
          _blocCapital.setterSelectedPartnerIdPopup = p0.item;
          _focusNodeLeadingAndCredit.unfocus();
        },
        maxSuggestionsInViewPort: 6,
      ),
    );
  }

  ///Borç verme ve Alma bölümü
  SizedBox widgetDropdownButtonLeadingAndBorrow(BuildContext context) {
    return SizedBox(
      width: context.extensionTextFieldWidth * 2 + 10,
      height: context.extensionTextFieldHeight,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _blocCapital.getterSelectBankBalance,
        items: [
          DropdownMenuItem(
            value: "+",
            child: Container(
              height: 30,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelLend),
            ),
          ),
          DropdownMenuItem(
            value: "-",
            child: Container(
              height: 30,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              width: context.extensionTextFieldWidth,
              child: Text(_labelBorrow),
            ),
          ),
        ],
        onChanged: (value) {
          _blocCapital.setterSelectedLeadingAndBorrow = value!;
        },
        decoration: const InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10)),
      ),
    );
  }

  widgetShareTextFieldFinancial(
    TextEditingController controller,
    String etiket,
  ) {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      child: TextFormField(
        controller: controller,
        // validator: validationFunc,
        style: context.theme.titleMedium,

        // autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            counterText: "",
            labelText: etiket,
            /*   focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))), */
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            )),
        // focusNode: FocusNode(skipTraversal: focusValue!),
        keyboardType: TextInputType.number,
        inputFormatters: [FormatterDecimalThreeByThreeFinancial()],
      ),
    );
  }

  ///Kasa Bakiye Kaydediliyor.
  widgetSaveButton() {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      height: context.extensionTextFieldHeight,
      child: shareWidget.widgetElevatedButton(
          onPressedDoSomething: () async {
            if (_controllerOpenBankBox.text == "" &&
                _controllerOpenCashBox.text == "") {
              context.noticeBarError("Bir veri girişi yapmadınız.", 3);
            } else {
              String res = await _blocCapital.saveCashBox(
                  _controllerOpenCashBox.text, _controllerOpenBankBox.text);
              if (res == "") {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                _controllerOpenBankBox.clear();
                _controllerOpenCashBox.clear();
              } else {
                // ignore: use_build_context_synchronously
                context.noticeBarError(res, 3);
              }
            }
          },
          label: _labelSave),
    );
  }

  ///Kasa Bakiye Kaydediliyor.
  widgetSaveButtonLeadingAndCredit() {
    return SizedBox(
      width: context.extensionTextFieldWidth,
      height: context.extensionTextFieldHeight,
      child: shareWidget.widgetElevatedButton(
          onPressedDoSomething: () async {
            if (_controllerSelectedPartnerLeadingAndBorow.text != "") {
              if (_controllerLeadingAndCreditCash.text == "" &&
                  _controllerLeadingAndCreditBank.text == "") {
                context.noticeBarError(
                    "Nakit veya bank alanından en az birini giriniz.", 3);
              } else {
                String res = await _blocCapital.saveLeadingAndCreditPartner(
                    _blocCapital.getterSelectedPartnerIdPopup!,
                    _controllerLeadingAndCreditCash.text,
                    _controllerLeadingAndCreditBank.text);
                if (res == "") {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  _controllerLeadingAndCreditCash.clear();
                  _controllerLeadingAndCreditBank.clear();
                  _controllerSelectedPartnerLeadingAndBorow.clear();
                  _blocCapital.setterSelectedPartnerIdPopup = "";
                  // ignore: use_build_context_synchronously
                  context.noticeBarTrue("İşlem Başarılı", 2);
                  _blocCapital.getSelectCariParter();
                } else {
                  // ignore: use_build_context_synchronously
                  context.noticeBarError(res, 3);
                }
              }
            } else {
              context.noticeBarError("Lütfen ortak seçiniz.", 3);
            }
          },
          label: _labelSave),
    );
  }

  widgetButtonPrinter(AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    return IconButton(
        onPressed: () async {
          ///tablo boş ise pdf dökme hata veriyor. O yüzden burada verinin dolu kontrol ediliyor.

          if (snapshot.hasData) {
            printPDF(
                _headers, snapshot.data, _blocCapital.getterCalculationRow);
          }
        },
        icon: const Icon(
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
                            alignment: pw.Alignment.center,
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
                                "Toplam Tutar: ${FormatterConvert().currencyShow(footer['totalLend'])}",
                                textAlign: pw.TextAlign.center,
                                style: letterCharacter)),
                        pw.Container(
                            margin: const pw.EdgeInsets.all(2.0),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                "Ödenen Tutar: ${FormatterConvert().currencyShow(footer['totalBorrow'])}",
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
