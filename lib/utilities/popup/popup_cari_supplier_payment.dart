// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'package:turkish/turkish.dart';
import 'package:stok_takip/modified_lib/responsive_datatable.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/validation.dart';
import '../../modified_lib/datatable_header.dart';
import '../../validations/format_convert_point_comma.dart';

// ignore: must_be_immutable
class PopupCariSupplierPayment extends StatefulWidget {
  Map<String, dynamic> blocCariSupplierPayment;
  Map<String, dynamic> blocCariSupplierInfo;

  PopupCariSupplierPayment(
    this.blocCariSupplierPayment,
    this.blocCariSupplierInfo,
  );

  @override
  State<PopupCariSupplierPayment> createState() => _ScreenCustomerSave();
}

class _ScreenCustomerSave extends State<PopupCariSupplierPayment>
    with Validation {
  final GlobalKey<FormState> _formKeySupplier = GlobalKey<FormState>();

  final String _labelPopupHeader = "Ödeme Detay";
  /*------------------DATATABLE ----------------------------------------*/
  late final List<DatatableHeader> _headers;
  final List<Map<String, dynamic>> _selected = [];
  final double _dataTableWidth = 560;
  final double _dataTableHeight = 300;
  final List<Map<String, dynamic>> _sourceDateTable = [];

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
  final String _labelSeller = "Satış Elemanı : ";
  final double _widthShareRow = 275;
  final String _labelInvoiceNo = "Fatura No";
/*------------------------------------------------------------------------- */

  @override
  void initState() {
    _sourceDateTable.add({
      'productCode': widget.blocCariSupplierPayment['product_fk'],
      'productAmount': widget.blocCariSupplierPayment['amount_of_stock'],
      'productPriceWithoutTax': FormatterConvert().currencyShow(
          widget.blocCariSupplierPayment['buying_price_without_tax']),
      'productTotal': FormatterConvert()
          .currencyShow(widget.blocCariSupplierPayment['total'])
    });

    _headers = [];
    _headers.add(DatatableHeader(
        text: "ÜRÜN KODU",
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
        text: "MALİYET (₺)",
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
      scrollable: true,
      content: Form(
        key: _formKeySupplier,
        child: SingleChildScrollView(
          child: Container(
            padding: context.extensionPadding20(),
            alignment: Alignment.center,
            width: 600,
            child: Column(children: [
              Center(
                child: Text(
                  _labelPopupHeader,
                  style: context.theme.headline5!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: context.extensionWrapSpacing10(),
                children: [widgetSallerInfo(), widgetDataTableNextTime()],
              ),
              widgetDateTable(),
              const Divider(),
              widgetDataTablePaymentInfoAndBalance(),
              // widgetButtonPrint()
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
        border: TableBorder.all(),
        children: [
          TableRow(
              /*  decoration: BoxDecoration(
                color: context.extensionDefaultColor,
              ), */
              children: [
                TableCell(
                    child: Container(
                        decoration: BoxDecoration(
                          color: context.extensionDefaultColor,
                        ),
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
                          widget.blocCariSupplierPayment['seller']
                              .toString()
                              .toUpperCaseTr(),
                          style: context.theme.titleSmall!
                              .copyWith(color: context.extensionDefaultColor),
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
        border: TableBorder.symmetric(
            inside: const BorderSide(color: Colors.white)),
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

                        ///Deger Null Geldiğinde hata vermemesi için "-" eklendi
                        child: Text(
                          widget.blocCariSupplierPayment['repayment_date'] ??
                              'Girilmedi',
                          style: context.theme.titleSmall!
                              .copyWith(color: Colors.white),
                        ))),
              ]),
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
                          _labelInvoiceNo,
                          style: context.theme.titleSmall!
                              .copyWith(color: Colors.white),
                        ))),
                TableCell(
                    child: Container(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,

                        ///Deger Null Geldiğinde hata vermemesi için "-" eklendi
                        child: Text(
                          widget.blocCariSupplierPayment['invoice_code'] ??
                              'Girilmedi',
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
            source: _sourceDateTable,
            selecteds: _selected,
            expanded: [false],
            autoHeight: false,
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

    return Container(
      alignment: Alignment.centerLeft,
      width: _widthShareRow,
      decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(color: context.extensionDefaultColor))),
      child: RichText(
          text: TextSpan(
              text: "${widget.blocCariSupplierInfo['name']}  \n",
              style: letterCharacter,
              children: [
            TextSpan(text: "Adres : ", style: letterCharacterBold, children: [
              TextSpan(text: "${widget.blocCariSupplierInfo['address']}\n")
            ]),
            TextSpan(text: "Tel : ", style: letterCharacterBold, children: [
              TextSpan(text: "${widget.blocCariSupplierInfo['phone']}\n")
            ]),
            TextSpan(
                text:
                    "Vergi Dairesi : ${widget.blocCariSupplierInfo['tax_office']}\n"),
            TextSpan(
                text:
                    "Vergi No : ${widget.blocCariSupplierInfo['tax_number']}\n")
          ])),
    );
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
          height: 100,
          width: _widthShareRow,
          alignment: Alignment.centerRight,
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(140),
              1: FixedColumnWidth(135),
            },
            border:
                TableBorder.symmetric(inside: BorderSide(color: Colors.white)),
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
        FormatterConvert().currencyShow(widget.blocCariSupplierPayment['cash'],
            unitOfCurrency:
                widget.blocCariSupplierPayment['unit_of_currency'])));
    listTableRow.add(buildRowRight(
        _labelCard,
        FormatterConvert().currencyShow(
            widget.blocCariSupplierPayment['bankcard'],
            unitOfCurrency:
                widget.blocCariSupplierPayment['unit_of_currency'])));
    listTableRow.add(buildRowRight(
        _labelEftHavale,
        FormatterConvert().currencyShow(
            widget.blocCariSupplierPayment['eft_havale'],
            unitOfCurrency:
                widget.blocCariSupplierPayment['unit_of_currency'])));

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
                    padding: EdgeInsets.fromLTRB(15, 4, 0, 4),
                    alignment: Alignment.centerLeft,
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

  /*  createPdfInvoice() async {
    await blocInvoice.getCompanyInformation();

    final doc = pw.Document();
    final pngImage = await imageFromAssetBundle('assets/logo.png');
/*     String svgRaw = await rootBundle.loadString('/logo.svg');
    final svgImage = pw.SvgImage(svg: svgRaw); */

    var myFont = await PdfGoogleFonts.poppinsMedium();

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
     
        return pw.RichText(
            text: pw.TextSpan(
                text:
                    "${widget.blocCariSupplierInfo['name'].toString().toUpperCaseTr()}  \n",
                style: letterCharacter,
                children: [
              pw.TextSpan(
                  text: "Adres : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${widget.blocCariSupplierInfo['address'].toString().toUpperCaseTr()}\n")
                  ]),
              pw.TextSpan(
                  text: "Tel : ",
                  style: letterCharacterBold,
                  children: [
                    pw.TextSpan(
                        text:
                            "${widget.blocCariSupplierInfo['phone']}\n")
                  ]),
              pw.TextSpan(
                  text:
                      "Vergi Dairesi : ${widget.blocCariSupplierInfo['tax_office'].toString().toUpperCaseTr()}\n"),
              pw.TextSpan(
                  text:
                      "Vergi No : ${widget.blocCariSupplierInfo['tax_number']}\n")
            ]));
      
    }

    ///Ürünlerin Listeye Eklendiği List.
    List<pw.TableRow> buildRowProductList() {
      List<pw.TableRow> listTableRow = [];

      
        listTableRow.add(buildRowCenter([
          widget.blocCariSupplierPayment['productCode'],
          widget.blocCariSupplierPayment['productAmount'].toString(),
          widget.blocCariSupplierPayment['productPriceWithoutTax'] + " ₺",
          "${widget.blocCariSupplierPayment['productTotal']} ₺",
        ]));
      
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
    DateTime zaman = DateFormat('dd/MM/yyyy HH:mm').parse(
        widget.blocCariSupplierPayment.getterRowCustomerInfo['dateTime']);

    pw.Table pdfWidgetDateTimeAndInvoice(
        pw.TableRow Function(List<String> cells) buildRow) {
      return pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(110),
            1: const pw.FixedColumnWidth(60)
          },
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          children: [
            buildRow([
              'İrsaliye No:',
              widget.blocCariSupplierPayment
                  .getterRowCustomerInfo['invoiceNumber']
                  .toString()
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
                              (FormatterConvert().currencyShow(
                                  widget.blocCariSupplierPayment.getterSaleInfo[
                                      'total_payment_without_tax'],
                                  unitOfCurrency: widget.blocCariSupplierPayment
                                      .getterSaleCurrencySembol))
                            ]),
                            buildRowRight([
                              'Hesaplanan KDV(%${widget.blocCariSupplierPayment.getterSaleInfo['kdv_rate']})',
                              (FormatterConvert().currencyShow(
                                  shareFunc.calculateOnlyKdvValue(
                                      widget.blocCariSupplierPayment
                                              .getterSaleInfo[
                                          'total_payment_without_tax'],
                                      widget.blocCariSupplierPayment
                                          .getterSaleInfo['kdv_rate']),
                                  unitOfCurrency: widget.blocCariSupplierPayment
                                      .getterSaleCurrencySembol))
                            ]),
                            buildRowRight([
                              'Vergiler Dahil Toplam Tutar',
                              "${widget.blocCariSupplierPayment.getterRowCustomerInfo['totalPrice']} ${widget.blocCariSupplierPayment.getterSaleCurrencySembol}"
                            ]),
                            buildRowRight([
                              'Ödenen Tutar',
                              "${widget.blocCariSupplierPayment.getterRowCustomerInfo['payment']} ${widget.blocCariSupplierPayment.getterSaleCurrencySembol}"
                            ]),
                            buildRowRight([
                              'Kalan Borç Tutar',
                              "${widget.blocCariSupplierPayment.getterRowCustomerInfo['balance']} ${widget.blocCariSupplierPayment.getterSaleCurrencySembol}"
                            ]),
                            buildRowRight([
                              'Ödeme Tarihi ',
                              widget.blocCariSupplierPayment
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
  } */

  /* widgetButtonPrint() {
    return ElevatedButton.icon(
        onPressed: () async => createPdfInvoice(),
        icon: Icon(Icons.print),
        label: Text("Yazdır"));
  } */
}
