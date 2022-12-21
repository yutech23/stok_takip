class ConvertStringCurrencyDigitThreeByThree {
  String convertStringToDigit3By3(String value) {
    String pointCharacter = '.';
    final List<String> _listPartDigits = [];
    String resultConvert = "";
    for (var i = value.length; 0 < i; i = i - 3) {
      if (i > 2) {
        _listPartDigits.add(value.substring(i - 3, i));
      } else {
        _listPartDigits.add(value.substring(0, i));
      }
    }

    var pointPlusList = "";
    for (var j = 0; j < _listPartDigits.length; j++) {
      if (j != (_listPartDigits.length - 1)) {
        pointPlusList = pointCharacter + _listPartDigits[j] + pointPlusList;
      } else {
        resultConvert = _listPartDigits[j] + pointPlusList;
      }
    }
    return resultConvert;
  }
}

ConvertStringCurrencyDigitThreeByThree
    convertStringToCurrencyDigitThreeByThree =
    ConvertStringCurrencyDigitThreeByThree();
