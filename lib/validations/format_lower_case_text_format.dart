//TextField için İçine Sadece Büyük harf girme Sınıfı
import 'package:flutter/services.dart';
import 'package:turkish/turkish.dart';

class FormatterLowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCaseTr(),
      selection: newValue.selection,
    );
  }
}
