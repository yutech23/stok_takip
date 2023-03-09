import 'package:flutter/services.dart';

class FormatterDecimalThreeByThreeFinancial extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String pointCharacter = ".";
    String replaceNewValue = "";
    // print("newValue : ${newValue.text}");
    //Gelen Dğerin içindeki '.' temizleniyor
    String? partDecimal;
    int? indexComma;

    if (newValue.text.contains(',')) {
      indexComma = newValue.text.indexOf(',');

      partDecimal = newValue.text.substring(indexComma);

      if (partDecimal.length >= 2) {
        partDecimal =
            ',${partDecimal.substring(1).replaceAll(RegExp(r'[\D]'), "")}';
      }

      if (partDecimal.length >= 3) {
        partDecimal = partDecimal.substring(0, 3);
      }
    } else {
      replaceNewValue = newValue.text.replaceAll(RegExp(r'[a-zA-Z.]'), "");
    }

    replaceNewValue = newValue.text
        .substring(0, indexComma)
        .replaceAll(RegExp(r'[a-zA-Z.]'), "");

    ///Gelen String 3'er 3'er bölümlere ayırıp bu listenin elemanları haline geliyor
    ///Sondan başlıyarak listeye ekleniyor. Yane İlk önce son 3 basamak listeye ekleniyor
    final listGroupString = <String>[];
    int lenghtReplaceNewValue;

    lenghtReplaceNewValue = replaceNewValue.length;

    /*   print("ReplaceNewValue : $replaceNewValue");
    print("replaceLenght $lenghtReplaceNewValue"); */

    ///ilk 3 terimde nokta olmadığı için 3'ten büyük yapıldı.
    if (lenghtReplaceNewValue > 3) {
      /// 3 erli gruplara ayırarak listeye ekliyoruz. Sondan Başlıyor.
      for (var i = lenghtReplaceNewValue; 0 < i; i = i - 3) {
        if (3 < i) {
          listGroupString.add(replaceNewValue.substring(i - 3, i));
        } else {
          ///sayının başını ayrı alıyoruz  çünkü başına '.' eklenmemesi için.
          listGroupString.add(replaceNewValue.substring(0, i));
        }
      }

      // print("liste : $listGroupString");

      ///Burada '.' olarak Sayıyı oluşturuyoruz. Ara değer gerekiyor.
      var pointPlusList = "";
      for (var j = 0; j < listGroupString.length; j++) {
        if (j != (listGroupString.length - 1)) {
          pointPlusList = pointCharacter + listGroupString[j] + pointPlusList;
        } else {
          replaceNewValue = listGroupString[j] + pointPlusList;
        }
      }
    }

    if (partDecimal != null) {
      replaceNewValue += partDecimal;
    }

    ///imleçi Sayını Sonuna atıyor
    newSelection = newSelection.copyWith(
        baseOffset: replaceNewValue.length,
        extentOffset: replaceNewValue.length);

    return TextEditingValue(
        selection: newSelection,
        text: replaceNewValue,
        composing: TextRange.empty);
  }
}
