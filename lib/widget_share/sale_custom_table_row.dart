import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/bloc/bloc_sale.dart';
import 'package:stok_takip/models/product.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_limit.dart';
import '../utilities/dimension_font.dart';

// ignore: must_be_immutable
class SaleTableRow extends StatefulWidget {
  Product addProduct;

  static StreamController<String> streamControllerIndex =
      StreamController<String>.broadcast();

  String? ad;
  SaleTableRow({
    Key? key,
    required this.addProduct,
  }) : super(key: key);

  @override
  State<SaleTableRow> createState() => _SaleTableRowState();
}

class _SaleTableRowState extends State<SaleTableRow> {
  final TextEditingController _controllerAmount = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();

  @override
  void initState() {
    _controllerAmount.text = widget.addProduct.sallingAmount.toString();
    _controllerPrice.text = FormatterConvert().pointToCommaAndDecimalTwo(
        widget.addProduct.currentSallingPriceWithoutTax!, 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widgetListRowTable();
  }

  ///Ek-Ürün Ekleme Tablo Satır Sayısı
  widgetListRowTable() {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1.5))),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: IconButton(
                  focusNode: FocusNode(skipTraversal: true),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    blocSale
                        .removeFromListProduct(widget.addProduct.productCode);
                    blocSale.getTotalPriceSection();
                    blocSale.balance();
                  },
                ),
              )),
          Expanded(
              flex: 4,
              child: Container(
                  alignment: Alignment.center,
                  child: Text(widget.addProduct.productCode))),
          Expanded(
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: rowListviewTextFormFieldAmount(_controllerAmount))),
          Expanded(
            flex: 2,
            child: Container(
                child: rowListviewTextFormFieldPrice(_controllerPrice)),
          ),
          Expanded(
            flex: 2,
            child: Container(
                alignment: Alignment.center,
                child: Text(
                    FormatterConvert().currencyShow(widget.addProduct.total!))),
          ),
        ],
      ),
    );
  }

//Ek- Ürün Ekleme Tablosu Miktar TextField
  TextFormField rowListviewTextFormFieldAmount(
      TextEditingController controllerAmount) {
    return TextFormField(
      controller: controllerAmount,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLines: 1,
      maxLength: 3,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          border: OutlineInputBorder()),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      onChanged: (value) {
        ///değiştirlen miktar Product nesnesinin içindeki değere atanıyor.
        ///eğer value boş gelirse tryParse sorunçıkıyor bu yüzden gelen verinin içi boş ise çalışmayacak.
        if (value.isNotEmpty) {
          if (int.parse(value) >= widget.addProduct.currentAmountOfStock) {
            context.noticeBarCustom(
                "BİLDİRİM",
                "Stok miktarını aştınız.\n Stok : ${widget.addProduct.currentAmountOfStock}",
                5,
                Colors.amber.shade600);
          }

          widget.addProduct.sallingAmount = int.tryParse(value)!;
          setState(() {
            widget.addProduct.total = double.parse(value) *
                widget.addProduct.currentSallingPriceWithoutTax!;
          });
          blocSale.getTotalPriceSection();
          blocSale.balance();
        } else {
          widget.addProduct.sallingAmount = 0;
          setState(() {
            widget.addProduct.total = 0;
          });
          blocSale.getTotalPriceSection();
          blocSale.balance();
        }
      },
    );
  }

//Ek- Ürün Ekleme Tablosu Fİyat TextField
  TextFormField rowListviewTextFormFieldPrice(
      TextEditingController controllerAmount) {
    return TextFormField(
      controller: controllerAmount,
      textAlign: TextAlign.left,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLines: 1,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.only(left: 3),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          border: OutlineInputBorder()),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
        FormatterDecimalLimit(decimalRange: 2)
      ],
      onChanged: (value) {
        ///Maliyet altında fiyat girildiğinde bildirim veriyor.
        if (FormatterConvert().commaToPointDouble(value) <=
            widget.addProduct.currentBuyingPriceWithoutTax!) {
          context.noticeBarCustom(
              "BİLDİRİM",
              "Maliyetin altına düştünüz.\n Birim Maliyet : ${FormatterConvert().pointToCommaAndDecimalTwo(widget.addProduct.currentBuyingPriceWithoutTax!, 2)}",
              5,
              Colors.amber.shade600);
        }

        ///Girilen Değer Boş olduğunda sorun çıkmasını engelliyor.
        if (value.isNotEmpty) {
          widget.addProduct.currentSallingPriceWithoutTax =
              FormatterConvert().commaToPointDouble(value);
          setState(() {
            widget.addProduct.total =
                FormatterConvert().commaToPointDouble(value) *
                    widget.addProduct.sallingAmount;
          });
          blocSale.getTotalPriceSection();
          blocSale.balance();
        } else {
          widget.addProduct.currentSallingPriceWithoutTax = 0;
          setState(() {
            widget.addProduct.total = 0;
          });
          blocSale.getTotalPriceSection();
          blocSale.balance();
        }
      },
    );
  }
}
