import 'package:flutter/services.dart';

class UpperCaseCapitalEachWordTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";

  ///Sadece il Harfi büyütüyor.
  ///return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";

  var result = value[0].toUpperCase();
  for (int i = 1; i < value.length; i++) {
    if (value[i - 1] == " ") {
      result = result + value[i].toUpperCase();
    } else {
      result = result + value[i].toLowerCase();
    }
  }
  return result;
}
