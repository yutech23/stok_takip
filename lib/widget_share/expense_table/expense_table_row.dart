import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stok_takip/bloc/bloc_expense.dart';
import 'package:stok_takip/models/expense.dart';
import 'package:stok_takip/utilities/dimension_font.dart';
import 'package:stok_takip/utilities/share_widgets.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import 'package:stok_takip/validations/format_decimal_limit.dart';
import 'package:stok_takip/validations/validation.dart';

import '../../utilities/custom_dropdown/widget_share_dropdown_string_type.dart';

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

class _ExpensesTableRowState extends State<ExpensesTableRow> with Validation {
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
                  child: Text(widget.addExpense.saveTime.toString()))),
          Expanded(
              flex: 2,
              child: Container(
                  alignment: Alignment.center, child: widgetDropdownService())),
          Expanded(
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const TextField(
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
                    FormatterConvert().currencyShow(widget.addExpense.total))),
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
                    /*   widget.blocExpense
                        .removeFromListProduct(widget.addExpense.id); */
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
        /* 
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
        } */
      },
    );
  }

  final String _labelService = "Hizmet";
  final List<String> _listService = [
    'Bürüt Ücretler',
    'Demirbaş ve Bakım Onarım Giderleri',
    'Elektrik Giderleri',
    'Isınma Giderleri',
    'Su Giderleri',
    'Doğalgaz Giderleri',
    'Haberleşme Giderleri',
    'Kira Giderleri',
    'Temizlik Giderleri',
    'Yemek Giderleri',
    'Yol, OGS, HGS, Ulaşım Giderleri',
    'Nakliye Giderleri',
    'Diğer Giderler'
  ];

  bool _selectedService = false;

  void _getExprense(String value) {
    setState(() {
      print(value);
    });
    _selectedService = true;
  }

  widgetDropdownService() {
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 2),
        width: 120,
        height: 80,
        child: ShareDropdown(
          validator: validateNotEmpty,
          hint: _labelService,
          itemList: _listService,
          getShareDropdownCallbackFunc: _getExprense,
        ));
  }
}
