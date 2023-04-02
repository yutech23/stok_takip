// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/utilities/share_func.dart';
import '../modified_lib/searchfield.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/cari_get_pay.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import '../data/database_mango.dart';

class BlocCariSuppleirs {
  List<SearchFieldListItem<String>> listSearchFieldListItemForSuppliers = [];
  final List<Map<String, String>> _suppliers = [];
  Map<String, String> _selectedSupplier = {};
  final List<Map<String, dynamic>> _boughtListOrjinal = [
    {
      'dateTime': '',
      'type': '',
      'customerName': '',
      'invoiceNumber': '',
      'totalPrice': '',
      'payment': '',
      'balance': ''
    }
  ];
  final List<Map<String, dynamic>> _boughtListFilter = [];
  List<bool> _expanded = [false];

  DateTime _startTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime _endTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 23, 59, 59);

  CariSupplierPay cariSupplierPay = CariSupplierPay();

  Map<String, num> _calculationRow = {
    'totalPrice': 0,
    'totalPayment': 0,
    'balance': 0
  };

  // ignore: prefer_final_fields
  Map<String, String> _paymentSystem = {
    "cash": "0",
    "bankCard": "0",
    "eftHavale": "0"
  };

  final List<Map<String, dynamic>> _paymentInfo = [];
  List<bool> _expandedSaleDetailList = [false];

  String _saleCurrencySembol = "";
  Map<String?, dynamic> _rowCustomerInfo = {};

  BlocCariSuppleirs() {
    start();
  }
  start() async {
    await getSuppliers();
    await getOnlyUseDateTimeForPaymentList();
  }

  get getterExpandad => _expanded;

  Map<String, String> get getterSelectedSupplier => _selectedSupplier;

  set setterSelectedSupplier(Map<String, String> value) =>
      _selectedSupplier = value;

  final StreamController<List<Map<String, String>>> _streamControllerSuppliers =
      StreamController<List<Map<String, String>>>.broadcast();

  Stream<List<Map<String, String>>> get getStreamSuppliers =>
      _streamControllerSuppliers.stream;

  final StreamController<List<Map<String, dynamic>>> _streamControllerSoldList =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  get getStreamSoldList => _streamControllerSoldList;
  get getterCalculationRow => _calculationRow;
  get getterPaymentSystem => _paymentSystem;

  get getterStartDate => _startTime;
  get getterEndDate => _endTime;
  set setterStartDate(DateTime dateTime) => _startTime = dateTime;
  set setterEndDate(DateTime dateTime) => _endTime = dateTime;

  get getterPaymentInfo => _paymentInfo;
  get getterExpandedSaleDetail => _expandedSaleDetailList;

  get getterSaleCurrencySembol => _saleCurrencySembol;
  get getterRowCustomerInfo => _rowCustomerInfo;

  set setterRowCustomerInfo(Map<String?, dynamic> newValue) {
    _rowCustomerInfo = newValue;
  }

/*-------------------------ÖDEME SİSTEMİ--------------------------- */
  //Hizmet ekleme bölümündeki tarih.
  DateTime selectedSaveDateTime = DateTime.now();

  double paymentTotalValue() {
    double paymentTotal = 0;
    _paymentSystem.forEach((key, value) {
      paymentTotal += FormatterConvert().commaToPointDouble(value);
    });
    return paymentTotal;
  }

  setPaymentCashValue(String cashValue) {
    _paymentSystem['cash'] = cashValue;
  }

  setPaymentBankCardValue(String bankCardValue) {
    _paymentSystem['bankCard'] = bankCardValue;
  }

  setPaymentEftHavaleValue(String eftHavaleValue) {
    _paymentSystem['eftHavale'] = eftHavaleValue;
  }

  resetPaymentsValue() {
    setPaymentEftHavaleValue('0');
    setPaymentCashValue('0');
    setPaymentBankCardValue('0');
  }
  /*---------------------------------------------------------------- */

  ///Müşterileri arama için getirilen veriler(tip,isim,numara)
  Future getSuppliers() async {
    final resCustomerSolo = await db.fetchCariSuppliers();

    for (var element in resCustomerSolo) {
      String araDeger = element['name'] + " - " + element['phone'];
      _suppliers.add({'name': araDeger});
    }

    _streamControllerSuppliers.sink.add(_suppliers);
  }

  ///Seçilen Müşterinin carisi getiriliyor
  Future getPaymentListOfSelectedSupplier() async {
    _expanded.clear();
    _boughtListOrjinal.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};

    ///veritabanı arasında veri geliyor. bu gelen veri datatable header uyumlu değil
    ///bu yüzden aşağıdaki for döngüsü ile header uyumlu haline geliyor.

    List<dynamic> resSoldList =
        await db.fetchPaymentList(_selectedSupplier['name']!);

    //Sales tablosundan gelen veriler
    for (Map element in resSoldList) {
      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['save_date']));

      num totalPayment =
          element['cash'] + element['bankcard'] + element['eft_havale'];
      num totalPrice;

      ///Buraya 2 ayrı tablodan veri geliyor. bir birinin arkasına eklenmiş bir
      ///list yapı olarak. aralarındaki fark olmayan kolonlardan biri olan "total"
      ///üzerinden 2si ayrıştırlıyor.
      if (element.containsKey('payment_id')) {
        totalPrice = element['total'];

        ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
        ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
        ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
        _calculationRow['totalPrice'] =
            _calculationRow['totalPrice']! + totalPrice;
        _calculationRow['totalPayment'] =
            _calculationRow['totalPayment']! + totalPayment;
        _boughtListOrjinal.add({
          'paymentId': element['payment_id'],
          'productName': element['product_fk'],
          'dateTime': dateTime,
          'supplierName': _selectedSupplier['name'],
          'totalPrice': FormatterConvert().currencyShow(totalPrice,
              unitOfCurrency: shareFunc
                  .convertAbridgmentToSymbol(element['unit_of_currency'])),
          'payment': FormatterConvert().currencyShow(totalPayment,
              unitOfCurrency: shareFunc
                  .convertAbridgmentToSymbol(element['unit_of_currency'])),
          'balance': FormatterConvert().currencyShow(totalPrice - totalPayment,
              unitOfCurrency: shareFunc
                  .convertAbridgmentToSymbol(element['unit_of_currency']))
        });
      } else {
        _calculationRow['totalPayment'] =
            _calculationRow['totalPayment']! + totalPayment;
        _boughtListOrjinal.add({
          'cariId': element['cari_supplier_id'],
          'dateTime': dateTime,
          'supplierName': _selectedSupplier['name'],
          'totalPrice': "-",
          'payment': FormatterConvert().currencyShow(totalPayment,
              unitOfCurrency: shareFunc
                  .convertAbridgmentToSymbol(element['unit_of_currency'])),
          'balance': "-"
        });
      }
    }

    ///kalan Tutar Burada Hesaplanıyor.
    _calculationRow['balance'] =
        _calculationRow['totalPrice']! - _calculationRow['totalPayment']!;

    ///List Map içinde Sort işlemi yapılıyor Tarih Saate göre (m1 ile m2 yeri değiştiğinde
    ///descending olarak)
    _boughtListOrjinal.sort((m1, m2) => DateFormat('dd/MM/yyyy HH:mm')
        .parse(m2['dateTime'])
        .compareTo(DateFormat('dd/MM/yyyy HH:mm').parse(m1['dateTime'])));

    _expanded = List.generate(_boughtListOrjinal.length, (index) => false);
    _streamControllerSoldList.sink.add(_boughtListOrjinal);
  }

  ///Müşteri belli olduktan sonra Zamana Göre Filtre BU kod Orjinal Liste Üzerinden
  ///tarihe göre veri çekiyor.
  filtreSoldListByDateTime() {
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};
    _boughtListFilter.clear();

    /// Gelen Tarihde saat olmadığı için ekliyoruz çünkü verilerde zaman geliyor
    /// filtre uygulamada problem çıkıyor.
    DateTimeRange tempAddTime = DateTimeRange(start: _startTime, end: _endTime);

    for (var element in _boughtListOrjinal) {
      DateTime convertTemp =
          DateFormat('dd/MM/yyyy HH:mm').parse(element['dateTime']);

      if (convertTemp.compareTo(tempAddTime.start) >= 0 &&
          convertTemp.compareTo(tempAddTime.end) <= 0) {
        _boughtListFilter.add(element);

        if (element['totalPrice'] != "-") {
          ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
          ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
          ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
          _calculationRow['totalPrice'] = _calculationRow['totalPrice']! +
              FormatterConvert().commaToPointDouble(element['totalPrice']);
        }
        _calculationRow['totalPayment'] = _calculationRow['totalPayment']! +
            FormatterConvert().commaToPointDouble(element['payment']);
      }
    }

    ///kalan Tutar Burada Hesaplanıyor.
    _calculationRow['balance'] =
        _calculationRow['totalPrice']! - _calculationRow['totalPayment']!;

    _expanded = List.generate(_boughtListFilter.length, (index) => false);
    _streamControllerSoldList.add(_boughtListFilter);
  }

  ///Sadece Tarih Seçildiğinde
  getOnlyUseDateTimeForPaymentList() async {
    _expanded.clear();
    _boughtListOrjinal.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};

    ///veritabanı arasında veri geliyor. bu gelen veri datatable header uyumlu değil
    ///bu yüzden aşağıdaki for döngüsü ile header uyumlu haline geliyor.
    final resPaymentList = await db.fetchCariSupplierPaymentListByRangeDateTime(
        _startTime, _endTime);

    for (Map element in resPaymentList) {
      DateTime convertTemp = DateTime.parse(element['save_date']);

      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['save_date']));

      ///
      if (element.containsKey('product_fk')) {
        num totalPayment =
            element['cash'] + element['bankcard'] + element['eft_havale'];
        num totalPrice = element['total'];

        ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
        ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
        ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
        _calculationRow['totalPrice'] =
            _calculationRow['totalPrice']! + totalPrice;
        _calculationRow['totalPayment'] =
            _calculationRow['totalPayment']! + totalPayment;

        ///kalan Tutar Burada Hesaplanıyor.Çünkü sadece sales tablosunda balance
        ///olduğundan.
        _calculationRow['balance'] =
            _calculationRow['balance']! + (totalPrice - totalPayment);

        _boughtListOrjinal.add({
          'paymentId': element['payment_id'],
          'productName': element['product_fk'],
          'dateTime': dateTime,
          'supplierName': element['supplier_fk'],
          'totalPrice': FormatterConvert().currencyShow(totalPrice,
              unitOfCurrency: shareFunc
                  .convertAbridgmentToSymbol(element['unit_of_currency'])),
          'payment': FormatterConvert().currencyShow(totalPayment,
              unitOfCurrency: shareFunc
                  .convertAbridgmentToSymbol(element['unit_of_currency'])),
          'balance': FormatterConvert().currencyShow(totalPrice - totalPayment,
              unitOfCurrency: shareFunc
                  .convertAbridgmentToSymbol(element['unit_of_currency']))
        });
      } else {
        num totalPayment =
            element['cash'] + element['bankcard'] + element['eft_havale'];

        ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
        ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
        ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
        _calculationRow['totalPayment'] =
            _calculationRow['totalPayment']! + totalPayment;

        _boughtListOrjinal.add({
          'cariId': element['cari_supplier_id'],
          'dateTime': dateTime,
          'supplierName': element['supplier_fk'],
          'totalPrice': '-',
          'payment': FormatterConvert().currencyShow(totalPayment),
          'balance': "-"
        });
      }
    }

    ///List Map içinde Sort işlemi yapılıyor Tarih Saate göre (m1 ile m2 yeri değiştiğinde
    ///descending olarak)
    _boughtListOrjinal.sort((m1, m2) => DateFormat('dd/MM/yyyy HH:mm')
        .parse(m2['dateTime'])
        .compareTo(DateFormat('dd/MM/yyyy HH:mm').parse(m1['dateTime'])));

    _expanded = List.generate(_boughtListOrjinal.length, (index) => false);
    _streamControllerSoldList.add(_boughtListOrjinal);
  }

  ///Fatura No ile Cari getirme
  getCariByInvoiceNo(String invoiceNo) async {
    _expanded.clear();
    _boughtListOrjinal.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};

    Map<String, dynamic> resCari = await db.fetchPaymentByInvoice(invoiceNo);

    String dateTime = DateFormat("dd/MM/yyyy HH:mm")
        .format(DateTime.parse(resCari['save_date']));

    num totalPayment =
        resCari['cash'] + resCari['bankcard'] + resCari['eft_havale'];
    num totalPrice = resCari['total'];

    _boughtListOrjinal.add({
      'paymentId': resCari['payment_id'],
      'productName': resCari['product_fk'],
      'dateTime': dateTime,
      'supplierName': resCari['supplier_fk'],
      'totalPrice': FormatterConvert().currencyShow(totalPrice,
          unitOfCurrency:
              shareFunc.convertAbridgmentToSymbol(resCari['unit_of_currency'])),
      'payment': FormatterConvert().currencyShow(totalPayment,
          unitOfCurrency:
              shareFunc.convertAbridgmentToSymbol(resCari['unit_of_currency'])),
      'balance': FormatterConvert().currencyShow(totalPrice - totalPayment,
          unitOfCurrency:
              shareFunc.convertAbridgmentToSymbol(resCari['unit_of_currency']))
    });
    _expanded = List.generate(_boughtListOrjinal.length, (index) => false);
    _streamControllerSoldList.add(_boughtListOrjinal);
  }

  //Elden Alınan ödemeler Kaydediliyor
  Future<Map<String, dynamic>> savePayment(String unitOfCurrency) async {
    cariSupplierPay.customerFk = _selectedSupplier['name']!;
    cariSupplierPay.cashPayment = FormatterConvert().commaToPointDouble(
      _paymentSystem['cash']!,
    );
    cariSupplierPay.bankcardPayment =
        FormatterConvert().commaToPointDouble(_paymentSystem['bankCard']!);
    cariSupplierPay.eftHavalePayment =
        FormatterConvert().commaToPointDouble(_paymentSystem['eftHavale']!);
    cariSupplierPay.unitOfCurrency = unitOfCurrency;
    cariSupplierPay.sellerId = dbHive.getValues('uuid');
    cariSupplierPay.paymentDate = selectedSaveDateTime;

    /*   print(cariGetPay.customerType);
    print(cariGetPay.customerFk);
    print(cariGetPay.cashPayment);
    print(cariGetPay.bankcardPayment);
    print(cariGetPay.eftHavalePayment);
    print(cariGetPay.sellerId); */

    return await db.insertCariSupplierBySelectedCustomer(cariSupplierPay);
  }

  setToday() {
    _startTime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    _endTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 23, 59, 59);
  }

  setDateRange(DateTimeRange? dateTimeRange) {
    _startTime = dateTimeRange!.start;
    _endTime = dateTimeRange.end
        .add(const Duration(hours: 23, minutes: 59, seconds: 59));
  }

  /*---------------------------------DETAY POP-UP--------------------- */

  Future<String> getSaleInfo(String userId) async {
    String sellerName = await db.fetchSellerNameByUuid(userId);
    return sellerName;
  }

  ///veri tabanında  Faturanın silindiği yer Orjinal Veri
  deletePaymentAndCariSupplierOrjinalSource(
      Map<String?, dynamic> rowSelect) async {
    if (rowSelect.containsKey('paymentId')) {
      await db.deletePaymentCariSupplier(rowSelect);

      _boughtListOrjinal.removeWhere(
          (element) => element['paymentId'] == rowSelect['paymentId']);
    } else {
      await db.deletePaymentCariSupplier(rowSelect);
      _boughtListOrjinal
          .removeWhere((element) => element['cariId'] == rowSelect['cariId']);
    }

    calculateRowTotalPaymentBalance(_boughtListOrjinal);
    _streamControllerSoldList.add(_boughtListOrjinal);
  }

  ///veri tabanında Faturanın silindiği yer Filtre
  deletePaymentAndCariSupplierFilterSource(
      Map<String?, dynamic> rowSelect) async {
    if (rowSelect.containsKey('paymentId')) {
      await db.deletePaymentCariSupplier(rowSelect);

      _boughtListFilter.removeWhere(
          (element) => element['paymentId'] == rowSelect['paymentId']);
    } else {
      await db.deletePaymentCariSupplier(rowSelect);
      _boughtListFilter
          .removeWhere((element) => element['cariId'] == rowSelect['cariId']);
    }

    calculateRowTotalPaymentBalance(_boughtListFilter);
    _streamControllerSoldList.add(_boughtListFilter);
  }

  ///Fatura silindikten sonra Row Hesabı yapıyor (Ödemeler olduğunda burayapılıyor)

  calculateRowTotalPaymentBalance(List<Map<String, dynamic>> resSoldList) {
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};
    double totalPayment = 0, totalPrice = 0, totalBalance = 0;

    //Sales tablosundan gelen veriler
    for (var element in resSoldList) {
      if (element['totalPrice'] != "-") {
        totalPayment +=
            FormatterConvert().commaToPointDouble(element['payment']);
        totalPrice +=
            FormatterConvert().commaToPointDouble(element['totalPrice']);
        totalBalance +=
            FormatterConvert().commaToPointDouble(element['balance']);
      } else {
        totalPayment +=
            FormatterConvert().commaToPointDouble(element['payment']);
      }
    }

    _calculationRow['totalPrice'] = totalPrice;
    _calculationRow['totalPayment'] = totalPayment;
    _calculationRow['balance'] = totalPrice - totalPayment;
  }
}
