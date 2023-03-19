import 'package:stok_takip/data/database_mango.dart';

class ShareFunc {
  double calculateWithKDV(num value, num kdv) {
    return value + (value * (kdv / 100));
  }

  double calculateWithoutKDV(num value, num kdv) {
    return value / ((100 + kdv) / 100);
  }

  double calculateOnlyKdvValue(num valueWithoutKDV, num kdv) {
    return (valueWithoutKDV * kdv) / 100;
  }

  String getCurrentUserId() {
    return dbHive.getValues('uuid');
  }

  String convertAbridgmentToSymbol(String ambridgment) {
    late String symbol;
    if (ambridgment == "TL") {
      symbol = "₺";
    } else if (ambridgment == "USD") {
      symbol = "\$";
    } else if (ambridgment == "EURO") {
      symbol = "€";
    }
    return symbol;
  }
}

final shareFunc = ShareFunc();
