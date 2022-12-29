class ConvertStringCurrencyDigitThreeByThree {
  String convertStringToDigit3By3(String value) {
    String pointCharacter = '.';
    final List<String> listPartDigits = [];
    String resultConvert = "";
    for (var i = value.length; 0 < i; i = i - 3) {
      if (i > 2) {
        listPartDigits.add(value.substring(i - 3, i));
      } else {
        listPartDigits.add(value.substring(0, i));
      }
    }

    var pointPlusList = "";
    for (var j = 0; j < listPartDigits.length; j++) {
      if (j != (listPartDigits.length - 1)) {
        pointPlusList = pointCharacter + listPartDigits[j] + pointPlusList;
      } else {
        resultConvert = listPartDigits[j] + pointPlusList;
      }
    }
    return resultConvert;
  }
}

ConvertStringCurrencyDigitThreeByThree
    convertStringToCurrencyDigitThreeByThree =
    ConvertStringCurrencyDigitThreeByThree();
