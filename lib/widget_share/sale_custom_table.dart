import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/widget_share/sale_custom_table_row.dart';
import '../models/product.dart';

// ignore: must_be_immutable
class WidgetSaleTable extends StatefulWidget {
  String selectUnitOfCurrencySymbol;
  // Product? addProduct;
  List<Product> listProduct;

  WidgetSaleTable(
      {super.key,
      required this.selectUnitOfCurrencySymbol,
      //  required this.addProduct,
      required this.listProduct});

  @override
  State<WidgetSaleTable> createState() => _WidgetSaleTableState();
}

class _WidgetSaleTableState extends State<WidgetSaleTable> {
  final double _tableWidth = 570, _tableHeight = 500;
  final double _shareheight = 40;

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
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widgetColumnHeaderTable(
                "Ürün Kodu", "Miktar", "Fiyat", "Tutar", "Sil"),
            Expanded(
                child: StreamBuilder<String>(
                    stream: SaleTableRow.streamControllerIndex.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        widget.listProduct.removeWhere((products) =>
                            products.productCode == snapshot.data);
                      }
                      return ListView.builder(
                          itemBuilder: (context, index) {
                            return SaleTableRow(
                              addProduct: widget.listProduct[index],
                            );
                          },
                          itemCount: widget.listProduct.length);
                    })),
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
}
