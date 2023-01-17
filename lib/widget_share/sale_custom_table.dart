import 'package:flutter/material.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/widget_share/sale_custom_table_row.dart';
import '../models/product.dart';

// ignore: must_be_immutable
class WidgetSaleList extends StatefulWidget {
  String selectUnitOfCurrencySymbol;
  Product? addProduct;
  List<Product> listProduct;
  WidgetSaleList(
      {super.key,
      required this.selectUnitOfCurrencySymbol,
      required this.addProduct,
      required this.listProduct});

  @override
  State<WidgetSaleList> createState() => _WidgetSaleListState();
}

class _WidgetSaleListState extends State<WidgetSaleList> {
  ValueNotifier _valueNotifierListRowTable =
      ValueNotifier<List<SaleTableRow>>([]);
  final List<SaleTableRow> _listRowTable = <SaleTableRow>[];

  final double _tableWidth = 570, _tableHeight = 500;
  final double _shareheight = 40;

  @override
  void didUpdateWidget(covariant WidgetSaleList oldWidget) {
    if (oldWidget.addProduct != widget.addProduct) {
      ///Gelen Ürünün özellikleri Liste ekleniyor
      _listRowTable.add(SaleTableRow(
        addProduct: widget.addProduct!,
        listProduct: widget.listProduct,
        listProductRow: _listRowTable,
      ));
    }

    print("asd");
    super.didUpdateWidget(oldWidget);
  }

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
              child: ValueListenableBuilder(
                valueListenable: _valueNotifierListRowTable,
                builder: (context, value, child) {
                  return ListView.builder(
                      itemBuilder: (context, index) {
                        return _listRowTable[index];
                      },
                      itemCount: _listRowTable.length);
                },
              ),
            ),
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
