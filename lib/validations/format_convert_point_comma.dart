import 'package:intl/intl.dart';

class FormatterConvert {
  String pointToCommaAndDecimalTwo(num valueDigit, int decimalLenght) {
    return valueDigit.toStringAsFixed(decimalLenght).replaceAll(".", ",");
  }

  double commaToPointDouble(String? valueString) {
    if (valueString == "" || valueString == null) {
      valueString = "0";
    }
    valueString = valueString.replaceAll(RegExp(r'[₺$€.]'), '');
    return double.parse(valueString.replaceAll(RegExp(r','), "."));
  }

  //Basamak basamak ayırır.
  String currencyShow(dynamic value, {String? unitOfCurrency = '₺'}) {
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
