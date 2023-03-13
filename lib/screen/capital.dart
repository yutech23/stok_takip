import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_textfield_autocomplete/flutter_textfield_autocomplete.dart';
import '../modified_lib/searchfield.dart';
import 'package:stok_takip/bloc/bloc_capital.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_3by3_financial.dart';
import '../modified_lib/datatable_header.dart';
import '../modified_lib/responsive_datatable.dart';

import '../utilities/share_widgets.dart';
import '../utilities/widget_appbar_setting.dart';
import '../validations/format_upper_case_text_format.dart';
import 'drawer.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;

class ScreenCapital extends StatefulWidget {
  const ScreenCapital({super.key});

  @override
  State<ScreenCapital> createState() => _ScreenCapitalState();
}

class _ScreenCapitalState extends State<ScreenCapital> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeySupplier = GlobalKey<FormState>();

  late BlocCapital _blocCapital;

  final String _labelCapitalHeader = "Satış Ekranı";
  /*--------------------------KASA--------------------------- */
  final String _labelCashBoxHeader = "KASA";
  final String _labelCash = "Nakit";
  final String _labelBank = "Banka";
  final String _labelCashBoxTotal = "Toplam";
  /*--------------------------------------------------------- */

/*--------------------------FLOAT BUTTON--------------------------- */
  final String _labelAddbalance = "Sermaye Kasa";
  final String _labelCapitalInflow = "Sermaye Girişi";
  final String _labelCapitalOutflow = "Sermaye Çıkışı";
  /*--------------------------------------------------------- */
  /*--------------------------FLOAT BUTTON--------------------------- */
  final String _labelOpenBalanceCash = "Nakit";
  final String _labelOpenBalanceBank = "Banka";
  final String _labelPositiveBalance = "(+) Bakiye";
  final String _labelNegativeBalance = "(-) Bakiye";
  final TextEditingController _controllerOpenCashBox = TextEditingController();
  final TextEditingController _controllerOpenBankBox = TextEditingController();

  final String _labelSave = "Kaydet";
  /*--------------------------------------------------------- */
  /*--------------------------FLOAT BUTTON Sermaye Giriş ve Çıkış--------------------------- */
  final String _labelLeadingAndCreditCash = "Nakit";
  final String _labelLeadingAndCreditBank = "Banka";
  final TextEditingController _controllerLeadingAndCreditCash =
      TextEditingController();
  final TextEditingController _controllerLeadingAndCreditBank =
      TextEditingController();
  final String _labelLeadingAndCreditHeader = "Serma İşlemleri";
  final TextEditingController _controllerSelectedPartnerLeadingAndCredit =
      TextEditingController();
  final FocusNode _focusNodeLeadingAndCredit = FocusNode();

  /*--------------------------------------------------------- */
  /*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  List<Map<String, dynamic>> _selecteds = [];
  final double _dataTableWidth = 745;
  final double _dataTableHeight = 600;
  final TextEditingController _controllerSelectedPartner =
      TextEditingController();
  final double _searchByNameItemHeight = 30;
  final _focusSearchCustomer = FocusNode();
  final String _labelSearchCustomerName = "Ortak Adı";
/*------------------------------------------------------------------------- */

  @override
  void initState() {
    _blocCapital = BlocCapital();
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
        text: "Çalışan İsmi",
        value: "workerName",
        show: true,
        flex: 3,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Borçu Var",
        value: "leadingCash",
        show: true,
        sortable: true,
        flex: 2,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "Alacağı Var",
        value: "creditCash",
        show: true,
        sortable: true,
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
                },
              ),
              row['totalPrice'] != "-"
                  ? Container(
                      child: IconButton(
                        iconSize: 20,
                        padding: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.center,
                        icon: const Icon(Icons.list),
                        onPressed: () async {
                          /*   showDialog(
                              context: context,
                              builder: (context) {
                                return PopupSaleDetail(_blocCari);
                              }); */
                        },
                      ),
                    )
                  : Container(
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 20),
                        child: Icon(Icons.disabled_by_default),
                      ),
                    ),
            ],
          );
        },
        textAlign: TextAlign.center));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            height: 800,
            width: 1200,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              widgetTableCashBox(),
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
      width: 330,
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
              style: context.theme.headline6!.copyWith(color: Colors.white),
            ),
          ),
          StreamBuilder<Map<String, dynamic>>(
              stream: _blocCapital.getStreamCashBox,
              //  initialData: {'cash': '0', 'bank': '0', 'total': '0'},
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  return Table(
                    columnWidths: const {
                      0: FixedColumnWidth(110),
                      1: FixedColumnWidth(110),
                      2: FixedColumnWidth(110),
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
                return CircularProgressIndicator();
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
          return SearchField(
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
            controller: _controllerSelectedPartner,
            suggestions: listSearch,
            focusNode: _focusSearchCustomer,
            searchStyle: const TextStyle(
              fontSize: 14,
              overflow: TextOverflow.fade,
            ),
            onSuggestionTap: (p0) {
              _blocCapital.setterSelectedPartnerId = p0.item;
              _focusSearchCustomer.unfocus();
            },
            maxSuggestionsInViewPort: 6,
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
                reponseScreenSizes: const [ScreenSize.xs],
                headers: _headers,
                source: snapshot.data,
                selecteds: _selecteds,
                expanded: [false],
                autoHeight: false,
                sortColumn: 'dataTime',
                sortAscending: true,
                actions: [
                  Expanded(child: widgetSearchPartner())
                  //  widgetButtonPrinter(snapshot)
                ],
                footerDecoration:
                    BoxDecoration(color: context.extensionDefaultColor),
                /*   footers: [
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
                ], */
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
            widgetPopupLeadingAndCredit(context);
          },
        ),

        ///Sermaye Çıkışı
        SpeedDialChild(
          backgroundColor: context.extensionDefaultColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: _labelCapitalOutflow,
        )
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
              style: context.theme.headline5!
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

  ///popup İçin Arama
  widgetSearchPartnerLeadingAndCredit(BlocCapital blocCapital) {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: blocCapital.getStreamAllPartner,
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
          return SearchField(
            itemHeight: _searchByNameItemHeight,
            searchInputDecoration: InputDecoration(
                isDense: true,
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
                label: Text(_labelLeadingAndCreditHeader),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(),
                )),
            controller: _controllerSelectedPartnerLeadingAndCredit,
            suggestions: listSearch,
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
          );
        });
  }

  ///Sermaya girişi veye çıkışı
  widgetPopupLeadingAndCredit(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          BlocCapital blocCapital = BlocCapital();
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            title: Text(
              textAlign: TextAlign.center,
              _labelLeadingAndCreditHeader,
              style: context.theme.headline5!
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
                    widgetSearchPartnerLeadingAndCredit(blocCapital),
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
                        widgetPopupLeadingAndCredit(context),
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

  widgetButtonPrinter(AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    return IconButton(
        onPressed: () async {
          ///tablo boş ise pdf dökme hata veriyor. O yüzden burada verinin dolu kontrol ediliyor.

          /*   if (snapshot.hasData) {
            printPDF(_headers, snapshot.data, _blocCari.getterCalculationRow);
          } */
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
