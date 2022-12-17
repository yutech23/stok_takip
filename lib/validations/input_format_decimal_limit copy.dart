import 'package:flutter/services.dart';
import 'dart:math' as math;

class InputFormatterDecimalLimitOnly extends TextInputFormatter {
  InputFormatterDecimalLimitOnly({required this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      print("trunenc $truncated");
      print("value : $value");
      print("old : ${oldValue.text}");

      if (value.length % 3 == 0 && value.isNotEmpty) {
        value = value.replaceRange(value.length, null, ".");
        print(value);
      }

      /* if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      } */

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
