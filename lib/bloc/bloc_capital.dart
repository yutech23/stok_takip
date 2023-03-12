import 'dart:async';

import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';

class BlocCapital {
  BlocCapital() {
    start();
  }

  start() async {
    await getCashBox();
  }

  Map<String, dynamic> _cashBox = {};

  String? _selectCashBalance = "+";
  String? _selectBankBalance = "+";

  get getterSelectCashBalance => _selectCashBalance;

  get getterSelectBankBalance => _selectBankBalance;

  set selectCashBalance(String? value) => _selectCashBalance = value;

  set selectBankBalance(String? value) => _selectBankBalance = value;

  final StreamController<Map<String, dynamic>> _streamControllerCashBox =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get getStreamCashBox =>
      _streamControllerCashBox.stream;

  getCashBox() async {
    _cashBox = {'cash': '0', 'bank': '0', 'total': '0'};
    _streamControllerCashBox.sink.add(_cashBox);
    final temp = await db.fetchCashBox();

    ///tablo boş ve sorguda hata çıkarsa

    if (!temp.containsKey('Hata')) {
      num total = temp['cash'] + temp['bank'];

      _cashBox.addAll({
        'cash': FormatterConvert().currencyShow(temp['cash']),
        'bank': FormatterConvert().currencyShow(temp['bank']),
        'total': FormatterConvert().currencyShow(total)
      });
    }
    _streamControllerCashBox.sink.add(_cashBox);
  }

  Future<String> saveCashBox(String? cashValue, String bankValue) async {
    num tempCash = FormatterConvert().commaToPointDouble(cashValue) *
        (getterSelectCashBalance == '-' ? -1 : 1);
    num tempBank = FormatterConvert().commaToPointDouble(bankValue) *
        (getterSelectBankBalance == '-' ? -1 : 1);
    String res = await db.upsertCashBox(tempCash, tempBank);
    print(res);
    getCashBox();
    return res;
  }
}
