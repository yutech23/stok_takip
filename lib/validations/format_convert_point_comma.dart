import 'package:intl/intl.dart';

class FormatterConvert {
  String pointToCommaAndDecimalTwo(num valueDigit, int decimalLenght) {
    return valueDigit.toStringAsFixed(decimalLenght).replaceAll(".", ",");
  }

  double commaToPointDouble(String valueString) {
    if (valueString.isEmpty) {
      valueString = "0";
    }
    return double.parse(valueString.replaceAll(",", "."));
  }

  //Basamak basamak ayırır.
  String currencyShow(dynamic value) {
    var turkishCurrencyFormat =
        NumberFormat.currency(locale: 'tr_TR', decimalDigits: 2, symbol: '');
    return turkishCurrencyFormat.format(value);
  }
}
