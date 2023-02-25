import 'package:adaptivex/adaptivex.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/bloc/bloc_cari.dart';
import 'package:stok_takip/modified_lib/responsive_datatable.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_func.dart';
import 'package:stok_takip/validations/validation.dart';
import '../../modified_lib/datatable_header.dart';
import '../../validations/format_convert_point_comma.dart';

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
    return buildCustomerRegister();
  }

  ///Widget ların oluşturulduğu builder Fonksiyonu
  buildCustomerRegister() {
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
              const Divider(),
              widgetDateTable(),
              Divider(),
              widgetDataTablePaymentInfoAndBalance()
            ]),
          ),
        ),
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

  widgetDataTablePaymentInfoAndBalance() {
    return Table(
      columnWidths: {
        0: const FixedColumnWidth(160),
        1: const FixedColumnWidth(100),
      },
      border: TableBorder.all(color: context.extensionDefaultColor),
      children: [
        for (int i = 0; i < buildRowProductList().length; i++)
          buildRowProductList()[i],
      ],
    );
  }

  ///Ürünlerin Listeye Eklendiği List.
  List<TableRow> buildRowProductList() {
    List<TableRow> listTableRow = [];

    listTableRow.add(buildRowRight('Nakit ile ödeme :',
        widget.blocCari.getterSaleInfo['cash_payment'].toString()));
    listTableRow.add(buildRowCenter([
      'Kart ile ödeme :',
      widget.blocCari.getterSaleInfo['bankcard_payment'].toString()
    ]));
    listTableRow.add(buildRowCenter([
      'EFT/Havale ile ödeme :',
      widget.blocCari.getterSaleInfo['eft_havale_payment'].toString()
    ]));

    return listTableRow;
  }

  TableRow buildRowRight(String header, String value) => TableRow(
          decoration: BoxDecoration(
            color: Colors.amber,
          ),
          children: [
            TableCell(
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    color: context.extensionDefaultColor,
                    child: Text(
                      header,
                      style: context.theme.titleMedium!
                          .copyWith(color: Colors.white),
                    ))),
            Text(value)
          ]);

  TableRow buildRowCenter(List<String> cells) => TableRow(
          children: cells.map((cell) {
        return Center(
            child: Text(
          cell,
          style: context.theme.titleSmall,
        ));
      }).toList());

  TableRow buildRowHeader(List<String> cells) => TableRow(
          children: cells.map((cell) {
        return Center(
            child: Text(
          cell,
        ));
      }).toList());
}
