import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/bloc/bloc_sale.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/widget_share/sale_custom_table_row.dart';
import '../models/product.dart';
import '../validations/format_convert_point_comma.dart';

// ignore: must_be_immutable
class WidgetSaleTable extends StatefulWidget {
  WidgetSaleTable(
      {super.key,
      required this.selectUnitOfCurrencySymbol,
      required this.listProduct,
      required this.blocSale,
      required this.tableWidth});

  String selectUnitOfCurrencySymbol;
  List<Product> listProduct;
  BlocSale blocSale;
  double tableWidth;

  @override
  State<WidgetSaleTable> createState() => _WidgetSaleTableState();
}

class _WidgetSaleTableState extends State<WidgetSaleTable> {
  final double _tableHeight = 570;
  final double _shareheight = 40;
  late double _responceWidth;

  /*-------------------BAŞLANGIÇ TOPLAM TUTAR BÖLMÜ-------------------- */
  final String _labelTotalprice = "Toplam Tutar";
  final String _labelTaxRate = "KDV %";
  final String _labelGeneralTotal = "KDV'li Tutar";
  // TextEditingController _controllerKDV = TextEditingController();
  /*????????????????????????????? SON ???????????????????????????????*/

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
      width: widget.tableWidth,
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
                    stream: widget.blocSale.getStreamListProduct,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && !snapshot.hasError) {
                        return ListView.builder(
                            itemBuilder: (context, index) {
                              return SaleTableRow(
                                addProduct: snapshot.data![index],
                                selectUnitOfCurrencySymbol:
                                    widget.selectUnitOfCurrencySymbol,
                                blocSale: widget.blocSale,
                              );
                            },
                            itemCount: snapshot.data!.length);
                      } else {
                        return Container();
                      }
                    })),
            widgetTableTotalPriceSection()
          ],
        ),
      ),
    ));
  }

  ///Tablo Başlık Bölümü
  widgetColumnHeaderTable(String productName, String amount, String price,
      String total, String delete) {
    TextStyle defaultStyle = getWidthScreenSize(context);
    const EdgeInsets paddingAll = EdgeInsets.all(5);
    return Container(
      height: getHighScreenSizeTableHeader(context),
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
                child: Text("$price (₺)", style: defaultStyle)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: paddingAll,
                alignment: Alignment.center,
                child: Text("$total (₺)", style: defaultStyle)),
          ),
        ],
      ),
    );
  }

  ///Toplam Tutar, Kdv Ve Genel toplam tutarı Tablosu
  widgetTableTotalPriceSection() {
    return SizedBox(
      // color: Colors.amber,
      height: _responceWidth <= 500 ? 60 : 35,
      child: StreamBuilder<Map<String, num>>(
          stream: widget.blocSale.getStreamTotalPriceSection,
          initialData: const {
            'total_without_tax': 0,
            'kdv': 0, //Başlangıçtaki değer ataması veri gelmediğinde
            'total_with_tax': 0
          },
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Table(
                border: _responceWidth <= 500
                    ? TableBorder.symmetric(
                        outside:
                            BorderSide(color: context.extensionDefaultColor))
                    : null,
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

  /// EK -- Toplam Ödemelerin Gövde Bölümü
  widgetTotalPriceSectionBodyKDV(BuildContext context, num? KDV) {
    //_controllerKDV.text = KDV.toString();
    TextStyle styleBody = context.theme.titleSmall!;
    return Container(
        height: getHighScreenSizeTotalPrice(context),
        alignment: Alignment.center,
        child: TextFormField(
          initialValue: KDV.toString(),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLines: 1,
          maxLength: 3,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
              isCollapsed: false,
              counterText: "",
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              border: OutlineInputBorder()),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
          ],
          //  controller: _controllerKDV,
          onChanged: (value) {
            ///değiştirlen miktar Product nesnesinin içindeki değere atanıyor.
            ///eğer value boş gelirse tryParse sorunçıkıyor bu yüzden gelen verinin içi boş ise çalışmayacak.
            if (value.isNotEmpty) {
              widget.blocSale.setKdv = value;

              widget.blocSale
                  .getTotalPriceSection(widget.selectUnitOfCurrencySymbol);
              widget.blocSale.balance();
            } else
              widget.blocSale.setKdv = "0";
            widget.blocSale
                .getTotalPriceSection(widget.selectUnitOfCurrencySymbol);
            widget.blocSale.balance();
          },
        ));
  }

  getWidthScreenSize(BuildContext context) {
    TextStyle styleHeader;

    if (MediaQuery.of(context).size.width < 500) {
      styleHeader = context.theme.titleMedium!.copyWith(color: Colors.white);
    } else {
      styleHeader = context.theme.titleLarge!.copyWith(color: Colors.white);
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
