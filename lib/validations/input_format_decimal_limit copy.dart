import 'package:flutter/services.dart';
import 'dart:math' as math;

class InputFormatterDecimalLimitOnly extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String pointCharacter = ".";
    String replaceNewValue = "";
    replaceNewValue = newValue.text.replaceAll(RegExp(r'[.]'), "");

    int remainder, division, lenghtReplaceNewValue;

    lenghtReplaceNewValue = replaceNewValue.length;
    division = ((lenghtReplaceNewValue - 1) / 3).floor();
    remainder = (lenghtReplaceNewValue - 1) % 3;
    final _listGroupString = <String>[];
    String ek = "";
    if (lenghtReplaceNewValue > 3) {
      for (var i = lenghtReplaceNewValue; 0 < i; i = i - 3) {
        if (3 < i) {
          _listGroupString.add(replaceNewValue.substring(i - 3, i));
        } else {
          _listGroupString.add(replaceNewValue.substring(0, i));
        }
      }

      var pointPlusList = "";
      for (var j = 0; j < _listGroupString.length; j++) {
        if (j != (_listGroupString.length - 1)) {
          pointPlusList = pointCharacter + _listGroupString[j] + pointPlusList;
        } else {
          replaceNewValue = _listGroupString[j] + pointPlusList;
        }
      }
      newSelection = newSelection.copyWith(
          baseOffset: replaceNewValue.length,
          extentOffset: replaceNewValue.length);
    }

    return TextEditingValue(
        selection: newSelection,
        text: replaceNewValue,
        composing: TextRange.empty);
  }
}
