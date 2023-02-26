import 'package:intl/intl.dart';

class FormatterConvert {
  String pointToCommaAndDecimalTwo(num valueDigit, int decimalLenght) {
    return valueDigit.toStringAsFixed(decimalLenght).replaceAll(".", ",");
  }

  double commaToPointDouble(String valueString) {
    if (valueString.isEmpty) {
      valueString = "0";
    }
    valueString = valueString.replaceAll('.', '');

    return double.parse(valueString.replaceAll(",", "."));
  }

  //Basamak basamak ayırır.
  String currencyShow(dynamic value, {String? unitOfCurrency = null}) {
    String turkishCurrencyString;
    var turkishCurrencyFormat =
        NumberFormat.currency(locale: 'tr_TR', decimalDigits: 2, symbol: '');
    turkishCurrencyString = turkishCurrencyFormat.format(value);
    if (unitOfCurrency != null) {
      turkishCurrencyString = "$turkishCurrencyString $unitOfCurrency";
    }
    return turkishCurrencyString;
  }
}
