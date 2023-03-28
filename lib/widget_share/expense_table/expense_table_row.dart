import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/bloc/bloc_expense.dart';
import 'package:stok_takip/models/expense.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_limit.dart';

// ignore: must_be_immutable
class ExpensesTableRow extends StatefulWidget {
  Expense addExpense;
  BlocExpense blocExpense;

  String? ad;
  ExpensesTableRow(
      {Key? key, required this.addExpense, required this.blocExpense})
      : super(key: key);

  @override
  State<ExpensesTableRow> createState() => _ExpensesTableRowState();
}

class _ExpensesTableRowState extends State<ExpensesTableRow> {
  final TextEditingController _controllerAmount = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();

  @override
  void initState() {
    _controllerAmount.clear();
    _controllerPrice.clear();
    /*  _controllerAmount.text = widget.addProduct.sallingAmount.toString();
    _controllerPrice.text = FormatterConvert().pointToCommaAndDecimalTwo(
        widget.addProduct.currentSallingPriceWithoutTax!, 2); */
    super.initState();
  }

  @override
  void dispose() {
    _controllerAmount.dispose();
    _controllerPrice.dispose();
    super.dispose();
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
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(widget.addExpense.dateTime.toString()))),
          Expanded(
              flex: 2,
              child: Container(
                  alignment: Alignment.center,
                  child: Text(widget.addExpense.service))),
          Expanded(
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    decoration: InputDecoration(),
                    maxLines: null,
                    expands: true,
                  ))),
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
                    FormatterConvert().currencyShow(widget.addExpense.total!))),
          ),
          Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: IconButton(
                  focusNode: FocusNode(skipTraversal: true),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    widget.blocExpense
                        .removeFromListProduct(widget.addExpense.productCode);
                  },
                ),
              )),
        ],
      ),
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
            widget.addExpense.currentBuyingPriceWithoutTax!) {
          context.noticeBarCustom(
              "BİLDİRİM",
              "Maliyetin altına düştünüz.\n Birim Maliyet : ${FormatterConvert().pointToCommaAndDecimalTwo(widget.addExpense.currentBuyingPriceWithoutTax!, 2)}",
              5,
              Colors.amber.shade600);
        }

        ///Girilen Değer Boş olduğunda sorun çıkmasını engelliyor.
        if (value.isNotEmpty) {
          widget.addExpense.currentSallingPriceWithoutTax =
              FormatterConvert().commaToPointDouble(value);
          setState(() {
            widget.addExpense.total =
                FormatterConvert().commaToPointDouble(value) *
                    widget.addExpense.sallingAmount;
          });
        } else {
          widget.addExpense.currentSallingPriceWithoutTax = 0;
          setState(() {
            widget.addExpense.total = 0;
          });
        }
      },
    );
  }
}
