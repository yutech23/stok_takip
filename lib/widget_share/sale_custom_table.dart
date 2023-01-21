import 'package:flutter/material.dart';
import 'package:stok_takip/bloc/bloc_sale.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/widget_share/sale_custom_table_row.dart';
import '../models/product.dart';
import '../validations/format_convert_point_comma.dart';

// ignore: must_be_immutable
class WidgetSaleTable extends StatefulWidget {
  String selectUnitOfCurrencySymbol;

  List<Product> listProduct;

  WidgetSaleTable(
      {super.key,
      required this.selectUnitOfCurrencySymbol,
      required this.listProduct});

  @override
  State<WidgetSaleTable> createState() => _WidgetSaleTableState();
}

class _WidgetSaleTableState extends State<WidgetSaleTable> {
  final double _tableWidth = 570, _tableHeight = 463;
  final double _shareheight = 40;
  /*-------------------BAŞLANGIÇ TOPLAM TUTAR BÖLMÜ-------------------- */
  final String _labelTotalprice = "Toplam Tutar";
  final String _labelTaxRate = "KDV %";
  final String _labelGeneralTotal = "Genel Toplam";

  /*????????????????????????????? SON ???????????????????????????????*/

  @override
  Widget build(BuildContext context) {
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
                "Ürün Kodu", "Miktar", "Fiyat", "Tutar", "Sil"),
            Expanded(
                child: StreamBuilder<List<Product>>(
                    stream: blocSale.getStreamListProduct,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemBuilder: (context, index) {
                              return SaleTableRow(
                                addProduct: snapshot.data![index],
                              );
                            },
                            itemCount: snapshot.data!.length);
                      } else {
                        return Container();
                      }
                    })),
            widgetTableTotalPrice()
          ],
        ),
      ),
    ));
  }

  ///Tablo Başlık Bölümü
  widgetColumnHeaderTable(String productName, String amount, String price,
      String total, String delete) {
    TextStyle defaultStyle =
        context.theme.headline6!.copyWith(color: Colors.white);
    const EdgeInsets paddingAll = EdgeInsets.all(5);
    return Container(
      height: _shareheight,
      color: context.extensionDefaultColor,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(delete, style: defaultStyle)),
          ),
          Expanded(
            flex: 4,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(productName, style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text(amount, style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text("$price (${widget.selectUnitOfCurrencySymbol})",
                    style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text("$total (${widget.selectUnitOfCurrencySymbol})",
                    style: defaultStyle)),
          ),
        ],
      ),
    );
  }

  ///Toplam Tutar, Kdv Ve Genel toplam tutarı Tablosu
  widgetTableTotalPrice() {
    return SizedBox(
      child: StreamBuilder<Map<String, num>>(
          stream: blocSale.getStreamTotalPrice,
          initialData: const {
            'total_without_tax': 0,
            'kdv': 0,
            'total_with_tax': 0
          },
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(2),
                  5: FlexColumnWidth(2),
                },
                children: [
                  partOfWidgetTotalTableRow(
                      snapshot.data!['total_without_tax']!,
                      snapshot.data!['kdv']!,
                      snapshot.data!['total_with_tax']!)
                ],
              );
            }
            return Container();
          }),
    );
  }

  /// Toplam Tutar, Kdv Ve Genel toplam tutarı Satır
  partOfWidgetTotalTableRow(
      num totalPriceWithoutTax, num kdv, num totalPriceWithTax) {
    return TableRow(children: [
      widgetTotalPriceSectionHeader1(
          context, _labelTotalprice, context.extensionDefaultColor),
      widgetTotalPriceSectionBody1(context, totalPriceWithoutTax),
      widgetTotalPriceSectionHeaderKDV(
          context, _labelTaxRate, context.extensionDefaultColor),
      widgetTotalPriceSectionBodyKDV(context, kdv),
      widgetTotalPriceSectionHeader1(
          context, _labelGeneralTotal, context.extensionDefaultColor),
      widgetTotalPriceSectionBody1(context, totalPriceWithTax),
    ]);
  }

  ///EK -- Toplam Ödemelerin Başlık Bölümü
  widgetTotalPriceSectionHeader1(
      BuildContext context, String label, Color backgroundColor) {
    TextStyle styleHeader =
        context.theme.titleMedium!.copyWith(color: Colors.white);
    return Container(
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
      alignment: Alignment.center,
      child: Text(
        FormatterConvert().currencyShow(totalSalesWithoutTax ?? 0),
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
  }
}
