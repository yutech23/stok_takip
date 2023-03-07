import 'dart:async';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/utilities/share_func.dart';

class BlocCaseSnapshot {
  Map<String, double> _collectionData = {
    'Kasa': 0,
    'Banka': 0,
    'Toplam': 0,
    'Kalan': 0
  };

  Map<String, double> _paymentData = {
    'Kasa': 0,
    'Banka': 0,
    'Toplam': 0,
    'Kalan': 0
  };

  Map<String, double> calculateCase = {
    'Kar': 0,
    'Anlık Kasa': 0,
    'Anlık Banka': 0
  };

  BlocCaseSnapshot() {
    start();
  }

  start() async {
    await getCollection();
    await getPayment();
    await calculateCasefunc();
  }

  final StreamController<Map<String, double>> _streamControllerCollection =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get getStreamCollection =>
      _streamControllerCollection.stream;

  final StreamController<Map<String, double>> _streamControllerPayment =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get getStreamPayment =>
      _streamControllerPayment.stream;

  final StreamController<Map<String, double>> _streamControllerCalculateDaily =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get getStreamCalculateDaily =>
      _streamControllerCalculateDaily.stream;

  getCollection() async {
    print("collecition");
    _collectionData = {'Kasa': 0, 'Banka': 0, 'Toplam': 0, 'Kalan': 0};
    List<dynamic> res = await db.fetchCalculateCollection();
    // print(res);
    for (Map<String, dynamic> item in res) {
      /*  print("nakit :${item['cash_payment']}");
      print("kart :${item['bankcard_payment']}");
      print("eft_havale :${item['eft_havale_payment']}"); */

      _collectionData['Kasa'] = _collectionData['Kasa']! + item['cash_payment'];

      _collectionData['Banka'] = _collectionData['Banka']! +
          item['bankcard_payment'] +
          item['eft_havale_payment'];

      if (item.containsKey('total_payment_without_tax')) {
        _collectionData['Toplam'] = _collectionData['Toplam']! +
            shareFunc.calculateWithKDV(
                item['total_payment_without_tax'], item['kdv_rate']);

        /*    print(shareFunc.calculateWithKDV(
            item['total_payment_without_tax'], item['kdv_rate'])); */

      }
    }

    _collectionData['Kalan'] = _collectionData['Toplam']! -
        _collectionData['Kasa']! -
        _collectionData['Banka']!;

    _streamControllerCollection.sink.add(_collectionData);
  }

  getPayment() async {
    print("payment");
    _paymentData = {'Kasa': 0, 'Banka': 0, 'Toplam': 0, 'Kalan': 0};
    List<dynamic> res = await db.fetchCalculatePayment();

    for (Map<String, dynamic> item in res) {
      _paymentData['Kasa'] = _paymentData['Kasa']! + item['cash'];

      _paymentData['Banka'] =
          _paymentData['Banka']! + item['bankcard'] + item['eft_havale'];

      if (item.containsKey('total')) {
        _paymentData['Toplam'] = _paymentData['Toplam']! + item['total'];

        /*    print(shareFunc.calculateWithKDV(
            item['total_payment_without_tax'], item['kdv_rate'])); */

      }
    }

    _paymentData['Kalan'] = _paymentData['Toplam']! -
        _paymentData['Kasa']! -
        _paymentData['Banka']!;

    _streamControllerPayment.sink.add(_paymentData);
  }

  calculateCasefunc() async {
    print("hesaplama");
    // calculateCase = {'Kar': 0, 'Anlık Kasa': 0, 'Anlık Banka': 0};

    calculateCase['Kar'] = _collectionData['Toplam']! - _paymentData['Toplam']!;
    calculateCase['Anlık Kasa'] =
        _collectionData['Kasa']! - _paymentData['Kasa']!;
    calculateCase['Anlık Banka'] =
        _collectionData['Banka']! - _paymentData['Banka']!;
    print(calculateCase['Kar']);
    print(calculateCase['Anlık Kasa']);
    print(calculateCase['Anlık Banka']);

    _streamControllerCalculateDaily.sink.add(calculateCase);
  }
}
