import 'package:flutter/services.dart';

class FormatterIbanInput extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    TextSelection newSelection = newValue.selection;
    String replaceNewValue = "";
    int newValueLenght = newValue.text.length;
    List<String> listGroupString = [];
    const separator = " ";

    if (newValue.text.isNotEmpty) {
      if (newValueLenght <= 2 &&
          newValue.text[newValueLenght - 1].contains(RegExp(r'\D'))) {
        replaceNewValue = newValue.text.toUpperCase();
      } else if (newValueLenght > 2 &&
          newValue.text[newValueLenght - 1].contains(RegExp(r'[0-9 ]+'))) {
        replaceNewValue = newValue.text.split(" ").join("");
      } else {
        replaceNewValue = oldValue.text.split(" ").join("");
      }
    }

    /*  print("oldValue : ${oldValue.text}");
    print("newValue : ${newValue.text}");
    print("replace : $replaceNewValue"); */

    if (replaceNewValue.length > 4) {
      /// 4 erli gruplara ayırarak listeye ekliyoruz. Sondan Başlıyor.
      for (var i = 0; i < replaceNewValue.length; i = i + 4) {
        if (i + 4 > replaceNewValue.length) {
          listGroupString
              .add(replaceNewValue.substring(i, replaceNewValue.length));
        } else {
          listGroupString.add(replaceNewValue.substring(i, i + 4));
        }
      }
      var buffer = StringBuffer();
      buffer.writeAll(listGroupString, separator);
      replaceNewValue = buffer.toString();
    }

    newSelection = newSelection.copyWith(
        baseOffset: replaceNewValue.length,
        extentOffset: replaceNewValue.length);

    return TextEditingValue(
        selection: TextSelection.collapsed(offset: replaceNewValue.length),
        text: replaceNewValue,
        composing: TextRange.empty);
  }
}
