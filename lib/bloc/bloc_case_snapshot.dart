import 'dart:async';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/utilities/share_func.dart';

class BlocCaseSnapshot {
  DateTime _startTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime _endTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 23, 59, 59);

  Map<String, double> _collectionData = {
    'Nakit': 0,
    'Banka': 0,
    'Toplam': 0,
    'Kalan': 0
  };

  Map<String, double> _paymentData = {
    'Nakit': 0,
    'Banka': 0,
    'Toplam': 0,
    'Kalan': 0
  };

  Map<String, num> _calculateCashBox = {
    'snapshootCash': 0,
    'snapshootBank': 0,
    'snapshootTotal': 0
  };

  Map<String, num> _calculatePaymentDaily = {
    'totalSale': 0,
    'totalCollectionBySale': 0,
    'totalCollectionLate': 0,
    'totalCollection': 0,
    'totalPayment': 0,
    'totalExpense': 0,
    'totalPaymentAndExpense': 0
  };

  Map<String, num> _calculateDailySnapshoot = {
    'totalPay': 0,
    'totalCollectionBySale': 0,
    'totalCollectionLate': 0,
    'totalCollection': 0,
  };

  Map<String, num> _calculateGeneralSituation = {
    'totalStockPrice': 0,
    'totalProfit': 0,
  };

  Map<String, num> _calculateService = {
    'totalCash': 0,
    'totalBank': 0,
  };

  BlocCaseSnapshot() {
    start();
  }

  start() async {
    await getCollection();
    await getPayment();
    await getCalculateDailySnapshoot();
    await calculateCasefunc();
    await calculateStockCapital();
  }

  final StreamController<Map<String, double>> _streamControllerCollection =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get getStreamCollection =>
      _streamControllerCollection.stream;

  final StreamController<Map<String, double>> _streamControllerPayment =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get getStreamPayment =>
      _streamControllerPayment.stream;
  /*-------------------------GÜNLÜK DURUM-------------------------------- */
  ///Tahsilat
  final StreamController<Map<String, num>> _streamControllerCalculateDaily =
      StreamController<Map<String, num>>.broadcast();

  Stream<Map<String, num>> get getStreamCalculateDaily =>
      _streamControllerCalculateDaily.stream;

  ///GENEL DURUM
  final StreamController<Map<String, num>>
      _streamControllerCalculateGeneralSituation =
      StreamController<Map<String, num>>.broadcast();

  Stream<Map<String, num>> get getStreamCalculateGeneralSituation =>
      _streamControllerCalculateGeneralSituation.stream;

  ///Ödeme Stream
  final StreamController<Map<String, num>>
      _streamControllerCalculateCashBoxSnapshoot =
      StreamController<Map<String, num>>.broadcast();

  Stream<Map<String, num>> get getStreamCalculateCashBoxSnapshoot =>
      _streamControllerCalculateCashBoxSnapshoot.stream;
/*-----------------------------------------------------------------------*/

  ///TAHSİLAT BÖLÜMÜ
  getCollection() async {
    _collectionData = {'Nakit': 0, 'Banka': 0, 'Toplam': 0, 'Kalan': 0};
    List<dynamic> res = await db.fetchCalculateCollection();
    // print(res);
    for (Map<String, dynamic> item in res) {
      /*  print("nakit :${item['cash_payment']}");
      print("kart :${item['bankcard_payment']}");
      print("eft_havale :${item['eft_havale_payment']}"); */

      _collectionData['Nakit'] =
          _collectionData['Nakit']! + item['cash_payment'];

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
        _collectionData['Nakit']! -
        _collectionData['Banka']!;

    _streamControllerCollection.sink.add(_collectionData);
  }

  ///ÖDEMELER BÖLÜMÜ
  getPayment() async {
    _paymentData = {'Nakit': 0, 'Banka': 0, 'Toplam': 0, 'Kalan': 0};
    List<dynamic> res = await db.fetchCalculatePayment();

    for (Map<String, dynamic> item in res) {
      _paymentData['Nakit'] = _paymentData['Nakit']! + item['cash'];

      _paymentData['Banka'] =
          _paymentData['Banka']! + item['bankcard'] + item['eft_havale'];

      if (item.containsKey('total')) {
        _paymentData['Toplam'] = _paymentData['Toplam']! + item['total'];

        /*    print(shareFunc.calculateWithKDV(
            item['total_payment_without_tax'], item['kdv_rate'])); */

      }
    }

    _paymentData['Kalan'] = _paymentData['Toplam']! -
        _paymentData['Nakit']! -
        _paymentData['Banka']!;

    _streamControllerPayment.sink.add(_paymentData);
  }

  ///KASANIN HESAPLANMASI
  calculateCasefunc() async {
    // calculateCase = {'Kar': 0, 'Anlık Kasa': 0, 'Anlık Banka': 0};
    final resCashBox = await db.fetchCashBox();
    final resCariCapital = await db.fetchCariCapital();
    final resService = await db.fetchServiceOnlyTotal();

    /*  await getCollection();
    await getPayment(); */
    _calculateCashBox['snapshootCash'] =
        _calculateCashBox['snapshootCash']! + resCashBox['cash'];
    _calculateCashBox['snapshootBank'] =
        _calculateCashBox['snapshootBank']! + resCashBox['bank'];
    num cashCapital = 0;
    num bankCapital = 0;

    for (var element in resCariCapital) {
      cashCapital += element['lend_cash'] - element['borrow_cash'];
      bankCapital += element['lend_bank'] - element['borrow_bank'];
    }

    ///Hizmet nakit ve banka hesaplama
    for (var element in resService) {
      if (element['payment_type'] == 'Nakit') {
        _calculateService['totalCash'] =
            _calculateService['totalCash']! + element['total'];
      }
      if (element['payment_type'] == 'Banka') {
        _calculateService['totalBank'] =
            _calculateService['totalBank']! + element['total'];
      }
    }

    _calculateCashBox['snapshootCash'] = _calculateCashBox['snapshootCash']! +
        cashCapital +
        _collectionData['Nakit']! -
        _paymentData['Nakit']! -
        _calculateService['totalCash']!;

    _calculateCashBox['snapshootBank'] = _calculateCashBox['snapshootBank']! +
        bankCapital +
        _collectionData['Banka']! -
        _paymentData['Banka']! -
        _calculateService['totalBank']!;

    _calculateCashBox['snapshootTotal'] = _calculateCashBox['snapshootCash']! +
        _calculateCashBox['snapshootBank']!;

/*     print("gelen veri ${_collectionData['Nakit']!}");

    print("kasa nakit : ${_calculateCashBox['snapshootCash']}");
    print("kasa banka : ${_calculateCashBox['snapshootBank']}"); */

    _streamControllerCalculateCashBoxSnapshoot.sink.add(_calculateCashBox);
  }

  ///Bulunduğu günün Günlük Satış ve Alınan ödemeleri yapıyor.
  getCalculateDailySnapshoot() async {
    /* Map<String, num> _calculateDailySnapshoot = {
      'cashCollection': 0,
      'bankCollection': 0,
      'totalSale': 0,
    }; */
    final resSoldDaily =
        await db.calculateCollectionDailySnapshoot(_startTime, _endTime);
    final resCariCustomerDaily =
        await db.fetchCariCustomerDaily(_startTime, _endTime);
    final resExpense =
        await db.fetchServiceOnlyTotalDaily(_startTime, _endTime);

    await getCalculateDailyPayment();

    ///Satışlar tablosundaki veriler alınıyor
    for (Map<String, dynamic> element in resSoldDaily) {
      _calculatePaymentDaily['totalCollectionBySale'] =
          _calculatePaymentDaily['totalCollectionBySale']! +
              element['cash_payment'] +
              element['bankcard_payment'] +
              element['eft_havale_payment'];

      _calculatePaymentDaily['totalSale'] =
          _calculatePaymentDaily['totalSale']! +
              shareFunc.calculateWithKDV(
                  element['total_payment_without_tax']!, element['kdv_rate']);
    }

    ///Müşteri cari tablosundaki veriler alınıyor. O gün yapılan tahsilatları topluyor.
    for (Map<String, dynamic> element in resCariCustomerDaily) {
      _calculatePaymentDaily['totalCollectionLate'] =
          _calculatePaymentDaily['totalCollectionLate']! +
              element['cash_payment']! +
              element['bankcard_payment']! +
              element['eft_havale_payment']!;
    }

    ///Giderlerin Tutarlarını topluyoruz.
    for (Map<String, dynamic> element in resExpense) {
      _calculatePaymentDaily['totalExpense'] =
          _calculatePaymentDaily['totalExpense']! + element['total'];
    }

    _calculatePaymentDaily['totalCollection'] =
        _calculatePaymentDaily['totalCollectionBySale']! +
            _calculatePaymentDaily['totalCollectionLate']!;

    _calculatePaymentDaily['totalPaymentAndExpense'] =
        _calculatePaymentDaily['totalPayment']! +
            _calculatePaymentDaily['totalExpense']!;
    /*  print(_calculateDailySnapshoot['cashCollection']);
    print(_calculateDailySnapshoot['bankCollection']);
    print(_calculateDailySnapshoot['totalSale']); */

    _streamControllerCalculateDaily.sink.add(_calculatePaymentDaily);
  }

  ///O günkü Ödemeleri getiriyor.
  getCalculateDailyPayment() async {
    final resPayment = await db.calculatePaymentDailySnapshoot();
    final resCariPaymentDaily = await db.fetchCariPaymentDaily();

    for (Map<String, dynamic> element in resPayment) {
      _calculatePaymentDaily['totalPayment'] =
          _calculatePaymentDaily['totalPayment']! +
              element['cash'] +
              element['bankcard'] +
              element['eft_havale'];
    }

    for (Map<String, dynamic> element in resCariPaymentDaily) {
      _calculatePaymentDaily['totalPayment'] =
          _calculatePaymentDaily['totalPayment']! +
              element['cash'] +
              element['bankcard'] +
              element['eft_havale'];
    }
  }

  ///Kar Hesaplanıyor
  calculateProfit() async {
    final resPayment = await db.calculateProfit();
    num total = 0;
    for (var element in resPayment) {
      total += ((element['product_selling_price_without_tax'] -
              element['product_buying_price_without_tax']) *
          element['product_amount']);
    }
    _calculateGeneralSituation['totalProfit'] = total;
  }

  /// Depodaki ürünlerin Maliyeti hesaplar
  calculateStockCapital() async {
    await calculateProfit();
    final resPayment = await db.calculateStockCapitalPrice();
    num total = 0;
    for (var element in resPayment) {
      total += element['current_buying_price_without_tax'] *
          element['current_amount_of_stock'];
    }
    _calculateGeneralSituation['totalStockPrice'] = total;
    _streamControllerCalculateGeneralSituation.sink
        .add(_calculateGeneralSituation);
  }
}
