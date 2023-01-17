// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stok_takip/models/product.dart';

import '../validations/format_decimal_3by3.dart';

// ignore: must_be_immutable
class SaleTableRow extends StatefulWidget {
  Product addProduct;
  List<Product> listProduct;
  List<SaleTableRow> listProductRow;
  SaleTableRow(
      {Key? key,
      required this.addProduct,
      required this.listProduct,
      required this.listProductRow})
      : super(key: key);

  @override
  State<SaleTableRow> createState() => _SaleTableRowState();
}

class _SaleTableRowState extends State<SaleTableRow> {
  final TextEditingController _controllerAmount = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();

  @override
  void initState() {
    _controllerAmount.text = widget.addProduct.sallingAmount.toString();
    _controllerPrice.text =
        widget.addProduct.currentSallingPriceWith!.toStringAsFixed(2);
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
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    int index = widget.listProduct.indexOf(widget.addProduct);

                    widget.listProduct.removeAt(index);
                    widget.listProductRow.removeAt(index);
                    print("index : $index");
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
                child: Text(widget.addProduct.total!.toStringAsFixed(2))),
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
      decoration: const InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          border: OutlineInputBorder()),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      onChanged: (value) {
        //değiştirlen miktar Product nesnesinin içindeki değere atanıyor
        widget.addProduct.sallingAmount = int.parse(value);
        setState(() {
          widget.addProduct.total =
              double.parse(value) * widget.addProduct.currentSallingPriceWith!;
        });
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
      maxLines: 1,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.only(left: 3),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          border: OutlineInputBorder()),
      inputFormatters: [FormatterDecimalThreeByThree()],
      onChanged: (value) {
        widget.addProduct.currentSallingPriceWith = double.tryParse(value);
        setState(() {
          widget.addProduct.total =
              double.parse(value) * widget.addProduct.sallingAmount;
        });
      },
    );
  }
}
