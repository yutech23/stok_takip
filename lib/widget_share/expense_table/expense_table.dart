import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/widget_share/expense_table/expense_table_row.dart';
import '../../bloc/bloc_expense.dart';
import '../../models/expense.dart';
import '../../validations/format_convert_point_comma.dart';

// ignore: must_be_immutable
class WidgetExpansesTable extends StatefulWidget {
  String selectUnitOfCurrencySymbol;
  List<Expense> listProduct;
  BlocExpense blocExprenses;

  WidgetExpansesTable(
      {super.key,
      required this.selectUnitOfCurrencySymbol,
      required this.listProduct,
      required this.blocExprenses});

  @override
  State<WidgetExpansesTable> createState() => _WidgetExpansesTableState();
}

class _WidgetExpansesTableState extends State<WidgetExpansesTable> {
  final double _tableWidth = 1000, _tableHeight = 500;
  final double _shareheight = 40;
  late double _responceWidth;

  @override
  void dispose() {
    widget.listProduct.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getResponseWidth(context);
    return buildProdcutSaleList();
  }

  ///Ürün Ekleme Tablosu
  buildProdcutSaleList() {
    return SingleChildScrollView(
        child: SizedBox(
      width: _tableWidth,
      height: _tableHeight,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widgetColumnHeaderTable(
              "Tarih",
              "Hizmet",
              "Açıklama",
              "Ödeme Türü",
              "Tutar",
              "Güncelleme",
            ),
            Expanded(
                child: StreamBuilder<List<Expense>>(
                    stream: widget.blocExprenses.getStreamListExpense,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && !snapshot.hasError) {
                        return ListView.builder(
                            itemBuilder: (context, index) {
                              return ExpensesTableRow(
                                addExpense: snapshot.data![index],
                                blocExpense: widget.blocExprenses,
                              );
                            },
                            itemCount: snapshot.data!.length);
                      } else {
                        return Container();
                      }
                    })),
          ],
        ),
      ),
    ));
  }

  ///Tablo Başlık Bölümü
  widgetColumnHeaderTable(String dateTime, String service, String explanation,
      String paymentType, String total, String editAndDelete) {
    TextStyle defaultStyle = getWidthScreenSize(context);
    const EdgeInsets paddingAll = EdgeInsets.all(5);
    return Container(
      height: getHighScreenSizeTableHeader(context),
      color: context.extensionDefaultColor,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(dateTime, style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(service, style: defaultStyle)),
          ),
          Expanded(
            flex: 4,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(explanation, style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(paymentType, style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text("$total (₺)", style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(editAndDelete, style: defaultStyle)),
          ),
        ],
      ),
    );
  }

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  widgetTotalPriceSectionHeader1(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.titleMedium!.copyWith(color: Colors.white);
    return Container(
      height: getHighScreenSizeTotalPrice(context),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: styleHeader,
      ),
    );
  }

  /// EK -- Toplam Ödemelerin Gövde Bölümü
  widgetTotalPriceSectionBody1(
      BuildContext context, num? totalSalesWithoutTax) {
    TextStyle styleBody = context.theme.titleMedium!;
    return Container(
      height: getHighScreenSizeTotalPrice(context),
      alignment: Alignment.center,
      child: Text(
        FormatterConvert().currencyShow(totalSalesWithoutTax ?? 0,
            unitOfCurrency: widget.selectUnitOfCurrencySymbol),
        style: styleBody,
      ),
    );
  }

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  widgetTotalPriceSectionHeaderKDV(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.titleMedium!.copyWith(color: Colors.white);
    return Container(
      height: getHighScreenSizeTotalPrice(context),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: styleHeader,
      ),
    );
  }

  /*  /// EK -- Toplam Ödemelerin Gövde Bölümü -- Veriyi Ürünler bilgisinden alındığında
  widgetTotalPriceSectionBodyKDV(
      BuildContext context, num? totalSalesWithoutTax) {
    TextStyle styleBody = context.theme.titleMedium!;
    return Container(
      alignment: Alignment.center,
      child: Text(
        FormatterConvert().currencyShow(totalSalesWithoutTax ?? 0),
        style: styleBody,
      ),
    );
  } */

  getWidthScreenSize(BuildContext context) {
    TextStyle styleHeader;

    if (MediaQuery.of(context).size.width < 500) {
      styleHeader = context.theme.titleMedium!.copyWith(color: Colors.white);
    } else {
      styleHeader = context.theme.headline6!.copyWith(color: Colors.white);
    }
    return styleHeader;
  }

  getHighScreenSizeTableHeader(BuildContext context) {
    double retHeigh =
        MediaQuery.of(context).size.width < 500 ? 60 : _shareheight;
    return retHeigh;
  }

  getHighScreenSizeTotalPrice(BuildContext context) {
    double retHeigh = MediaQuery.of(context).size.width < 500 ? 50 : 30;
    return retHeigh;
  }

  getResponseWidth(BuildContext context) {
    _responceWidth = MediaQuery.of(context).size.width;
  }
}
