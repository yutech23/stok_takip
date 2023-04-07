import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
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

  ///DateTime verisini String çeviriyor.
  String dateTimeConvertFormatString(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  ///Gelen String Tarihleri dateTime dönüştürüyor
  DateTime dateTimeStringConvertToDateTime(String stringDateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').parse(stringDateTime).toLocal();
  }

  ///String gelen dateTime mı Tekrar Formatlamak için
  String dateTimeStringToString(String stringDateTime) {
    return DateFormat('dd/MM/yyyy HH:mm')
        .format(DateTime.parse(stringDateTime));
  }

  ///DateTime zaman hariç verisini String çeviriyor.
  String dateTimeConvertFormatStringWithoutTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  ///Şifrelemek için SHA512 kullanılıyor Stringe dönüştürüyor
  String hashSha512ConvertToString(String password) {
    final bytes = utf8.encode(password);
    final diges = sha512.convert(bytes);
    final hashPass = diges.toString();
    return hashPass;
  }
}

final shareFunc = ShareFunc();
