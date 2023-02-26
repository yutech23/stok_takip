import 'dart:developer';

import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/bloc/bloc_cari.dart';
import 'package:stok_takip/modified_lib/responsive_datatable.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_func.dart';
import 'package:stok_takip/validations/validation.dart';
import '../../bloc/bloc_invoice.dart';
import '../../modified_lib/datatable_header.dart';
import '../../validations/format_convert_point_comma.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:turkish/turkish.dart';

// ignore: must_be_immutable
class PopupSaleDetail extends StatefulWidget {
  BlocCari blocCari;
  PopupSaleDetail(this.blocCari, {super.key});

  @override
  State<PopupSaleDetail> createState() => _ScreenCustomerSave();
}

class _ScreenCustomerSave extends State<PopupSaleDetail> with Validation {
  final GlobalKey<FormState> _formKeySupplier = GlobalKey<FormState>();

  final String _labelPopupHeader = "Fatura Detayları";
  /*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;

  final List<Map<String, dynamic>> _selected = [];
  final double _dataTableWidth = 560;
  final double _dataTableHeight = 400;
/*------------------------------------------------------------------------- */
/*-------------------------------ALINAN ÖDEME BİLGİLERİ-------------------- */
  final String _labelHeaderPayment = "ALINAN ÖDEMELER";
  final String _labelTotal = "MİKTAR";
  final String _labelCash = "Nakit: ";
  final String _labelCard = "Kart: ";
  final String _labelEftHavale = "EFT/Havale: ";
/*------------------------------------------------------------------------- */
/*------------------------------ÖDEME TARİHİ------------------------------- */
  final String _labelNextPaymentTime = "Ödeme Tarihi";
  final String _labelSeller = "Satış Elemanı: ";
  final double _widthShareRow = 275;
/*------------------------------------------------------------------------- */
  @override
  void initState() {
    _headers = [];
    _headers.add(DatatableHeader(
        text: "MAL NO",
        value: "productCode",
        show: true,
        sortable: true,
        flex: 3,
        textAlign: TextAlign.start));
    _headers.add(DatatableHeader(
        text: "MİKTAR",
        value: "productAmount",
        show: true,
        flex: 2,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "FİYAT  (₺)",
        value: "productPriceWithoutTax",
        show: true,
        flex: 2,
        sortable: true,
        textAlign: TextAlign.center));
    _headers.add(DatatableHeader(
        text: "TUTAR (₺)",
        value: "productTotal",
        show: true,
        flex: 2,
        sortable: true,
        textAlign: TextAlign.end));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSaleDetail();
  }

  ///Widget ların oluşturulduğu builder Fonksiyonu
  buildSaleDetail() {
    return AlertDialog(
      title: Text(
        textAlign: TextAlign.center,
        _labelPopupHeader,
        style: context.theme.headline5!.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKeySupplier,
          child: Container(
            padding: context.extensionPadding20(),
            alignment: Alignment.center,
            width: 600,
            child: Column(children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: context.extensionWrapSpacing10(),
                children: [widgetSallerInfo(), widgetDataTableNextTime()],
              ),
              widgetDateTable(),
              Divider(),
              widgetDataTablePaymentInfoAndBalance(),
              widgetButtonPrint()
            ]),
          ),
        ),
      ),
    );
  }

  widgetSallerInfo() {
    return Container(
      width: _widthShareRow,
      alignment: Alignment.centerRight,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(140),
          1: FixedColumnWidth(135),
        },
        border: TableBorder.all(color: Colors.white),
        children: [
          TableRow(
              decoration: BoxDecoration(
                color: context.extensionDefaultColor,
              ),
              children: [
                TableCell(
                    child: Container(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        child: Text(
                          _labelSeller,
                          style: context.theme.titleSmall!
                              .copyWith(color: Colors.white),
                        ))),
                TableCell(
                    child: Container(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        child: Text(
                          widget.blocCari.getterSaleInfo['seller'],
                          style: context.theme.titleSmall!
                              .copyWith(color: Colors.white),
                        ))),
              ])
        ],
      ),
    );
  }

  widgetDataTableNextTime() {
    return Container(
      width: _widthShareRow,
      alignment: Alignment.centerRight,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(140),
          1: FixedColumnWidth(135),
        },
        border: TableBorder.all(color: Colors.white),
        children: [
          TableRow(
              decoration: BoxDecoration(
                color: context.extensionDefaultColor,
              ),
              children: [
                TableCell(
                    child: Container(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        child: Text(
                          _labelNextPaymentTime,
                          style: context.theme.titleSmall!
                              .copyWith(color: Colors.white),
                        ))),
                TableCell(
                    child: Container(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        child: Text(
                          widget.blocCari.getterSaleInfo['payment_next_date'],
                          style: context.theme.titleSmall!
                              .copyWith(color: Colors.white),
                        ))),
              ])
        ],
      ),
    );
  }

  widgetDateTable() {
    return SizedBox(
      width: _dataTableWidth,
      height: _dataTableHeight,
      child: Card(
          margin: const EdgeInsets.only(top: 5),
          elevation: 5,
          shadowColor: Colors.black,
          clipBehavior: Clip.none,
          child: ResponsiveDatatable(
            reponseScreenSizes: const [ScreenSize.xs],
            headers: _headers,
            source: widget.blocCari.getterSaleDetailList,
            selecteds: _selected,
            expanded: widget.blocCari.getterExpandedSaleDetail,
            autoHeight: false,
            footers: [
              Expanded(
                child: Container(
                  decoration:
                      BoxDecoration(color: context.extensionDefaultColor),
                  height:
                      40, //Fotter kısmın yüksekliği bozulmasın diye belirtim
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: RichText(
                    text: TextSpan(
                        text: "Toplam Tutar : ",
                        style: context.theme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white),
                        children: [
                          TextSpan(
                            // ignore: prefer_interpolation_to_compose_strings
                            text: FormatterConvert().currencyShow(
                                    widget.blocCari.getterSaleInfo[
                                        'total_payment_without_tax']) +
                                " ${widget.blocCari.getterSaleCurrencySembol}",
                            style: context.theme.titleSmall!
                                .copyWith(color: Colors.white),
                          ),
                          TextSpan(
                              text: "    KDV : ",
                              style: const TextStyle(
                                  color: Colors.white, letterSpacing: 1),
                              children: [
                                TextSpan(
                                    text: widget
                                        .blocCari.getterSaleInfo['kdv_rate']
                                        .toString(),
                                    style: context.theme.titleSmall!
                                        .copyWith(color: Colors.white))
                              ]),
                          TextSpan(text: "   Toplam Tutar(KDV) : ", children: [
                            TextSpan(
                                // ignore: prefer_interpolation_to_compose_strings
                                text: FormatterConvert().currencyShow(
                                        shareFunc.calculateWithKDV(
                                            widget.blocCari.getterSaleInfo[
                                                'total_payment_without_tax'],
                                            widget.blocCari
                                                .getterSaleInfo['kdv_rate'])) +
                                    " ${widget.blocCari.getterSaleCurrencySembol}",
                                style: context.theme.titleSmall!
                                    .copyWith(color: Colors.white))
                          ]),
                        ]),
                  ),
                ),
              ),
            ],
            headerDecoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                border: const Border(
                    bottom: BorderSide(color: Colors.red, width: 1))),
            selectedDecoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.red, width: 1)),
              color: Colors.green,
            ),
            headerTextStyle:
                context.theme.titleSmall!.copyWith(color: Colors.white),
            rowTextStyle: context.theme.titleSmall,
            selectedTextStyle: const TextStyle(color: Colors.grey),
          )),
    );
  }

  widgetCustomerInfo() {
    TextStyle? letterCharacter =
        context.theme.titleSmall!.copyWith(fontWeight: FontWeight.bold);
    TextStyle? letterCharacterBold =
        context.theme.titleSmall!.copyWith(fontWeight: FontWeight.bold);
    if (widget.blocCari.getterSaleInfo['customer_type'] == "Şahıs") {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.centerLeft,
        width: _widthShareRow,
        decoration: BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(color: context.extensionDefaultColor))),
        child: RichText(
            text: TextSpan(
                text:
                    "${widget.blocCari.getterRowCustomerInfo['customerName']} \n",
                style: letterCharacter,
                children: [
              TextSpan(text: "Adres : ", style: letterCharacter, children: [
                TextSpan(text: "${widget.blocCari.getterSaleInfo['address']}\n")
              ]),
              TextSpan(text: "Tel : ", style: letterCharacter, children: [
                TextSpan(text: "${widget.blocCari.getterSaleInfo['phone']}\n")
              ]),
              TextSpan(
                  text: "TCKN : ${widget.blocCari.getterSaleInfo['tc_no']}\n")
            ])),
      );

      ///Fİrmaların Verisisnin Dolduğu yer
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        width: _widthShareRow,
        decoration: BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(color: context.extensionDefaultColor))),
        child: RichText(
            text: TextSpan(
                text:
                    "${widget.blocCari.getterRowCustomerInfo['customerName']}  \n",
                style: letterCharacter,
                children: [
              TextSpan(text: "Adres : ", style: letterCharacterBold, children: [
                TextSpan(text: "${widget.blocCari.getterSaleInfo['address']}\n")
              ]),
              TextSpan(text: "Tel : ", style: letterCharacterBold, children: [
                TextSpan(text: "${widget.blocCari.getterSaleInfo['phone']}\n")
              ]),
              TextSpan(
                  text:
                      "Vergi Dairesi : ${widget.blocCari.getterSaleInfo['tax_office']}\n"),
              TextSpan(
                  text:
                      "Vergi No : ${widget.blocCari.getterSaleInfo['tax_number']}\n")
            ])),
      );
    }
  }

  widgetDataTablePaymentInfoAndBalance() {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: context.extensionWrapSpacing10(),
      direction: Axis.horizontal,
      children: [
        widgetCustomerInfo(),
        Container(
          width: _widthShareRow,
          alignment: Alignment.centerRight,
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(140),
              1: FixedColumnWidth(135),
            },
            border: TableBorder.all(color: Colors.white),
            children: [
              for (int i = 0; i < buildRowProductList().length; i++)
                buildRowProductList()[i],
            ],
          ),
        ),
      ],
    );
  }

  ///Ürünlerin Listeye Eklendiği List.
  List<TableRow> buildRowProductList() {
    List<TableRow> listTableRow = [];
    listTableRow.add(buildRowHeader(_labelHeaderPayment, _labelTotal));
    listTableRow.add(buildRowRight(
        _labelCash,
        FormatterConvert().currencyShow(
            widget.blocCari.getterSaleInfo['cash_payment'],
            unitOfCurrency: widget.blocCari.getterSaleCurrencySembol)));
    listTableRow.add(buildRowRight(
        _labelCard,
        FormatterConvert().currencyShow(
            widget.blocCari.getterSaleInfo['bankcard_payment'],
            unitOfCurrency: widget.blocCari.getterSaleCurrencySembol)));
    listTableRow.add(buildRowRight(
        _labelEftHavale,
        FormatterConvert().currencyShow(
            widget.blocCari.getterSaleInfo['eft_havale_payment'],
            unitOfCurrency: widget.blocCari.getterSaleCurrencySembol)));

    return listTableRow;
  }

  TableRow buildRowRight(String header, String value) => TableRow(
          decoration: BoxDecoration(
            color: context.extensionDefaultColor,
          ),
          children: [
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.centerRight,
                    child: Text(
                      header,
                      style: context.theme.titleSmall!
                          .copyWith(color: Colors.white),
                    ))),
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(4),
                    child: Text(
                      value,
                      style: context.theme.titleSmall!
                          .copyWith(color: Colors.white),
                    ))),
          ]);

  TableRow buildRowHeader(String header, String value) => TableRow(
          decoration: BoxDecoration(
            color: context.extensionDefaultColor,
          ),
          children: [
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.center,
                    child: Text(
                      header,
                      style: context.theme.titleSmall!
                          .copyWith(color: Colors.white),
                    ))),
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.center,
                    child: Text(
                      value,
                      style: context.theme.titleSmall!
                          .copyWith(color: Colors.white),
                    ))),
          ]);

  createPdfInvoice() async {
    await blocInvoice.getCompanyInformation();

    final doc = pw.Document();
    final pngImage = await imageFromAssetBundle('assets/logo.png');
/*     String svgRaw = await rootBundle.loadString('/logo.svg');
    final svgImage = pw.SvgImage(svg: svgRaw); */

    var myFont = await PdfGoogleFonts.montserratAlternatesBlack();

    final pw.TextStyle letterCharacter =
        pw.TextStyle(font: myFont, fontSize: 9);
    final pw.TextStyle letterCharacterBold =
        pw.TextStyle(font: myFont, fontSize: 9, fontWeight: pw.FontWeight.bold);

    final pw.TextStyle letterCharacterHeader = pw.TextStyle(
        font: myFont, fontSize: 11, fontWeight: pw.FontWeight.bold);

//Tablo Row yapıldı Yer.
    pw.TableRow buildRow(List<String> cells) => pw.TableRow(
            children: cells.map((cell) {
          return pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(4, 2, 0, 2),
              child: pw.Text(
                cell,
                style: letterCharacterBold,
              ));
        }).toList());
    pw.TableRow buildRowRight(List<String> cells) => pw.TableRow(
            children: cells.map((cell) {
          return pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(4, 2, 2, 2),
              child: pw.Text(
                textAlign: pw.TextAlign.right,
                cell,
                style: letterCharacterBold,
              ));
        }).toList());

    pw.TableRow buildRowCenter(List<String> cells) => pw.TableRow(
            children: cells.map((cell) {
          return pw.Center(
              child: pw.Text(
            cell,
            style: letterCharacterBold,
          ));
        }).toList());

    pw.TableRow buildRowHeader(List<String> cells) => pw.TableRow(
            children: cells.map((cell) {
          return pw.Center(
              child: pw.Text(
            cell,
            style: letterCharacterHeader,
          ));
        }).toList());

    ///SATIŞ yapılan Kişi ve Firma Bilgilerin blundu yer.
    pw.RichText buildRichTextCompanyAndSoloInformation() {
      if (widget.blocCari.getterSaleInfo['customer_type'] == "Şahıs") {
        return pw.RichText(
            text: pw.TextSpan(
                text:
                    "${widget.blocCari.getterRowCustomerInfo['customerName'].toString().toUpperCaseTr()} \n",
                style: letterCharacter,
                children: [
              pw.TextSpan(
                  text: "Adres : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${widget.blocCari.getterSaleInfo['address'].toString().toUpperCaseTr()}\n")
                  ]),
              pw.TextSpan(
                  text: "Tel : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text: "${widget.blocCari.getterSaleInfo['phone']}\n")
                  ]),
              pw.TextSpan(
                  text: "TCKN : ${widget.blocCari.getterSaleInfo['tc_no']}\n")
            ]));

        ///Fİrmaların Verisisnin Dolduğu yer
      } else {
        return pw.RichText(
            text: pw.TextSpan(
                text:
                    "${widget.blocCari.getterRowCustomerInfo['customerName'].toString().toUpperCaseTr()}  \n",
                style: letterCharacter,
                children: [
              pw.TextSpan(
                  text: "Adres : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${widget.blocCari.getterSaleInfo['address'].toString().toUpperCaseTr()}\n")
                  ]),
              pw.TextSpan(
                  text: "Tel : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text: "${widget.blocCari.getterSaleInfo['phone']}\n")
                  ]),
              pw.TextSpan(
                  text:
                      "Vergi Dairesi : ${widget.blocCari.getterSaleInfo['tax_office'].toString().toUpperCaseTr()}\n"),
              pw.TextSpan(
                  text:
                      "Vergi No : ${widget.blocCari.getterSaleInfo['tax_number']}\n")
            ]));
      }
    }

    ///Ürünlerin Listeye Eklendiği List.
    List<pw.TableRow> buildRowProductList() {
      List<pw.TableRow> listTableRow = [];

      for (var element in widget.blocCari.getterSaleDetailList) {
        listTableRow.add(buildRowCenter([
          element['productCode'],
          element['productAmount'].toString(),
          element['productPriceWithoutTax'],
          "${element['productTotal']}",
        ]));
      }
      return listTableRow;
    }

    ///Ürünler Listesinin Widget bölümü.
    pw.Table pdfWidgetTableProductList(
        pw.TableRow Function(List<String> cells) buildRowHeader,
        List<pw.TableRow> Function() buildRowProductList) {
      return pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(140),
            1: const pw.FixedColumnWidth(50),
            2: const pw.FixedColumnWidth(80),
            3: const pw.FixedColumnWidth(80)
          },
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          children: [
            buildRowHeader(['MAL NO', 'MİKTAR', 'FİYAT', 'TUTAR']),
            for (int i = 0; i < buildRowProductList().length; i++)
              buildRowProductList()[i],
          ]);
    }

    ///Şirket Bilgilerin Widget Bölümü.
    pw.Container pdfWidgetMyCompanyInfo(
        pw.TextStyle letterCharacter, pw.TextStyle letterCharacterBold) {
      return pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: const pw.BoxDecoration(
              border: pw.Border.symmetric(horizontal: pw.BorderSide(width: 2))),
          width: 180,
          child: pw.RichText(
              text: pw.TextSpan(
                  text: "${blocInvoice.getInvoice!.name.toUpperCaseTr()} \n",
                  style: letterCharacter,
                  children: [
                pw.TextSpan(
                    text: "Adres : ",
                    style: letterCharacterBold,
                    children: [
                      pw.TextSpan(
                          text:
                              "${blocInvoice.getInvoice!.address.toUpperCaseTr()}\n")
                    ]),
                pw.TextSpan(
                    text: "Tel : ",
                    style: letterCharacterBold,
                    children: [
                      pw.TextSpan(
                          text:
                              "${blocInvoice.getInvoice!.phone.toUpperCaseTr()}\n")
                    ]),
                pw.TextSpan(
                    text: "instagram Adresi : ",
                    style: letterCharacterBold,
                    children: [
                      pw.TextSpan(
                          text: "${blocInvoice.getInvoice!.instgramAddress}\n")
                    ])
              ])));
    }

    pw.Divider pdfwidgetDivider({double? height}) =>
        pw.Divider(borderStyle: pw.BorderStyle.none, height: height);
    DateTime zaman = DateFormat('dd/MM/yyyy HH:mm')
        .parse(widget.blocCari.getterRowCustomerInfo['dateTime']);

    pw.Table pdfWidgetDateTimeAndInvoice(
        pw.TableRow Function(List<String> cells) buildRow) {
      return pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(100),
            1: const pw.FixedColumnWidth(60)
          },
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          children: [
            buildRow([
              'İrsaliye No:',
              widget.blocCari.getterRowCustomerInfo['invoiceNumber'].toString()
            ]),
            buildRow(
                ['Düzenlenme Tarihi:', DateFormat('dd/MM/yyyy').format(zaman)]),
            buildRow(['Düzenlenme Zamanı:', DateFormat('HH:mm').format(zaman)]),
          ]);
    }

    ///Dökümanın oluşturlduğu yer.
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Container(
            alignment: pw.Alignment.topCenter,
            child: pw.Column(children: [
              ///İlk Satır
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pdfWidgetMyCompanyInfo(
                        letterCharacter, letterCharacterBold),
                    pw.Container(
                        color: PdfColors.amber,
                        width: 150,
                        height: 100,
                        child: pw.Image(fit: pw.BoxFit.fitWidth, pngImage))
                  ]),
              pdfwidgetDivider(),

              ///ikinci Satır
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        decoration: const pw.BoxDecoration(
                            border: pw.Border.symmetric(
                                horizontal: pw.BorderSide(width: 2))),
                        width: 180,
                        child: buildRichTextCompanyAndSoloInformation()),
                    pdfWidgetDateTimeAndInvoice(buildRow),
                  ]),
              pdfwidgetDivider(height: 20),

              ///Ürün Tablosu
              pdfWidgetTableProductList(buildRowHeader, buildRowProductList),
              pdfwidgetDivider(height: 20),
              pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.SizedBox(
                      width: 220,
                      child: pw.Table(
                          columnWidths: {
                            0: const pw.FixedColumnWidth(130),
                            1: const pw.FixedColumnWidth(90),
                          },
                          border: pw.TableBorder.all(
                              color: PdfColors.black, width: 1),
                          children: [
                            buildRowRight([
                              'Mal Hizmet Toplam Tutarı',
                              "${FormatterConvert().currencyShow(widget.blocCari.getterSaleInfo['total_payment_without_tax'], unitOfCurrency: widget.blocCari.getterSaleCurrencySembol)} "
                            ]),
                            buildRowRight([
                              'Hesaplanan KDV(%${widget.blocCari.getterSaleInfo['kdv_rate']})',
                              (FormatterConvert().currencyShow(
                                  shareFunc.calculateOnlyKdvValue(
                                      widget.blocCari.getterSaleInfo[
                                          'total_payment_without_tax'],
                                      widget
                                          .blocCari.getterSaleInfo['kdv_rate']),
                                  unitOfCurrency:
                                      widget.blocCari.getterSaleCurrencySembol))
                            ]),
                            buildRowRight([
                              'Vergiler Dahil Toplam Tutar',
                              "${widget.blocCari.getterRowCustomerInfo['totalPrice']} ${widget.blocCari.getterSaleCurrencySembol}"
                            ]),
                            buildRowRight([
                              'Ödenen Tutar',
                              "${widget.blocCari.getterRowCustomerInfo['payment']} ${widget.blocCari.getterSaleCurrencySembol}"
                            ]),
                            buildRowRight([
                              'Kalan Borç Tutar',
                              "${widget.blocCari.getterRowCustomerInfo['balance']} ${widget.blocCari.getterSaleCurrencySembol}"
                            ]),
                            buildRowRight([
                              'Ödeme Tarihi ',
                              widget.blocCari
                                      .getterSaleInfo['payment_next_date'] ??
                                  'Girilmedi'
                            ])
                          ])))
            ]));
      },
    ));

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
    );

    /* //Başka uygulamada paylaşmak istersen 
    await Printing.sharePdf(bytes: await doc.save(), filename: 'fatura.pdf');
     */
  }

  widgetButtonPrint() {
    return ElevatedButton.icon(
        onPressed: () async => createPdfInvoice(),
        icon: Icon(Icons.print),
        label: Text("Yazdır"));
  }
}
