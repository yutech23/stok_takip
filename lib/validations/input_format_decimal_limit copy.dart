import 'package:flutter/services.dart';
import 'dart:math' as math;

class InputFormatterDecimalLimitOnly extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    int remainder, division, lenghtString;

    String pointCharacter = ".";
    String sonuc = "";
    sonuc = newValue.text.replaceAll(RegExp(r'[.]'), "");
    // print("degişmeyen : $sonuc");
    lenghtString = sonuc.length;
    division = ((lenghtString - 1) / 3).floor();
    remainder = (lenghtString - 1) % 3;
    final _listGroupString = <String>[];
    String ek = "";
    if (lenghtString > 3) {
      for (var i = lenghtString; 0 < i; i = i - 3) {
        if (3 < i) {
          _listGroupString.add(sonuc.substring(i - 3, i));
        } else {
          _listGroupString.add(sonuc.substring(0, i));
        }
      }

      var pointPlusList = "";
      for (var j = 0; j < _listGroupString.length; j++) {
        if (j != (_listGroupString.length - 1)) {
          pointPlusList = pointCharacter + _listGroupString[j] + pointPlusList;
        } else {
          sonuc = _listGroupString[j] + pointPlusList;
        }
      }
      newSelection = newSelection.copyWith(
          baseOffset: sonuc.length, extentOffset: sonuc.length);
    }

    return TextEditingValue(
        selection: newSelection, text: sonuc, composing: TextRange.empty);
  }
}
