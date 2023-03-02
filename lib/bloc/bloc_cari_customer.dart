// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/cari_get_pay.dart';
import 'package:stok_takip/utilities/share_func.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import '../data/database_mango.dart';
import '../modified_lib/searchfield.dart';

class BlocCariCustomer {
  List<SearchFieldListItem<String>> listSearchFieldListItemForAllCustomer = [];
  final List<Map<String, String>> _allCustomerAndSuppliers = [];
  Map<String, String> _selectedCustomer = {};
  final List<Map<String, dynamic>> _soldListManipulatorByHeader = [
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
  final List<Map<String, dynamic>> _soldListWithFiltre = [];
  List<bool> _expanded = [false];
  int _customerId = -1; //-1 hiç bir id yok

  DateTime _startTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime _endTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 23, 59, 59);

  CariGetPay cariGetPay = CariGetPay();

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

  final List<Map<String, dynamic>> _saleDetailList = [];
  List<bool> _expandedSaleDetailList = [false];
  Map<String, dynamic> _saleInfo = {};
  String _saleCurrencySembol = "";
  Map<String?, dynamic> _rowCustomerInfo = {};

  BlocCariCustomer() {
    getAllCustomerAndSuppliers();
  }

  get getterExpandad => _expanded;

  Map<String, String> get getterSelectedCustomer => _selectedCustomer;
  set setterSelectedCustomer(Map<String, String> value) =>
      _selectedCustomer = value;

  final StreamController<List<Map<String, String>>>
      _streamControllerAllCustomer =
      StreamController<List<Map<String, String>>>.broadcast();

  Stream<List<Map<String, String>>> get getStreamAllCustomer =>
      _streamControllerAllCustomer.stream;

  final StreamController<List<Map<String, dynamic>>> _streamControllerSoldList =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  get getStreamSoldList => _streamControllerSoldList;
  get getterCalculationRow => _calculationRow;
  get getterPaymentSystem => _paymentSystem;

  get getterStartDate => _startTime;
  get getterEndDate => _endTime;
  set setterStartDate(DateTime dateTime) => _startTime = dateTime;
  set setterEndDate(DateTime dateTime) => _endTime = dateTime;

  get getterSaleDetailList => _saleDetailList;
  get getterExpandedSaleDetail => _expandedSaleDetailList;
  get getterSaleInfo => _saleInfo;
  get getterSaleCurrencySembol => _saleCurrencySembol;
  get getterRowCustomerInfo => _rowCustomerInfo;

  set setterRowCustomerInfo(Map<String?, dynamic> newValue) {
    _rowCustomerInfo = newValue;
  }

/*-------------------------ÖDEME SİSTEMİ--------------------------- */

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

  ///Seçilen Müşterinin Id getirir.
  getCustomerId() async {
    _customerId = await db.fetchSelectedCustomerIdForCari(_selectedCustomer);
  }

  ///Müşterileri arama için getirilen veriler(tip,isim,numara)
  Future getAllCustomerAndSuppliers() async {
    final resCustomerSolo = await db.fetchCustomerSolo();

    for (var element in resCustomerSolo) {
      String araDeger = element['name'] +
          " " +
          element['last_name'] +
          " - " +
          element['phone'];
      _allCustomerAndSuppliers.add({'type': element['type'], 'name': araDeger});
    }

    final resCustomerCompany = await db.fetchCustomerCompany();
    for (var element in resCustomerCompany) {
      String araDeger = element['name'] + " - " + element['phone'];
      _allCustomerAndSuppliers.add({'type': element['type'], 'name': araDeger});
    }

    _streamControllerAllCustomer.sink.add(_allCustomerAndSuppliers);
  }

  ///Seçilen Müşterinin carisi getiriliyor
  Future getSoldListOfSelectedCustomer() async {
    _expanded.clear();
    _soldListManipulatorByHeader.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};
    await getCustomerId();

    ///veritabanı arasında veri geliyor. bu gelen veri datatable header uyumlu değil
    ///bu yüzden aşağıdaki for döngüsü ile header uyumlu haline geliyor.
    final resSoldList = await db.fetchSoldListOfSelectedCustomerById(
        _selectedCustomer['type']!, _customerId);

    ///cari tablodan seçilen müşterinin verileri geliyor.Alınan ödemeler
    final resCariList = await db.fetchCariPayListOfSelectedCustomerById(
        _selectedCustomer['type']!, _customerId);

    //Sales tablosundan gelen veriler
    for (var element in resSoldList) {
      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['sale_date']));

      double totalPayment = element['cash_payment'] +
          element['bankcard_payment'] +
          element['eft_havale_payment'];
      double totalPrice = shareFunc.calculateWithKDV(
          element['total_payment_without_tax'], element['kdv_rate']);

      ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
      ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
      ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
      _calculationRow['totalPrice'] =
          _calculationRow['totalPrice']! + totalPrice;
      _calculationRow['totalPayment'] =
          _calculationRow['totalPayment']! + totalPayment;

      _soldListManipulatorByHeader.add({
        'dateTime': dateTime,
        'type': _selectedCustomer['type'],
        'customerName': _selectedCustomer['name'],
        'invoiceNumber': element['invoice_number'],
        'totalPrice': FormatterConvert().currencyShow(totalPrice),
        'payment': FormatterConvert().currencyShow(totalPayment),
        'balance': FormatterConvert().currencyShow(totalPrice - totalPayment)
      });
    }

    //Cari tablosundan gelen Veriler
    for (var element in resCariList) {
      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['payment_date']).toLocal());

      double totalPayment = element['cash_payment'] +
          element['bankcard_payment'] +
          element['eft_havale_payment'];

      ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
      ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
      ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
      _calculationRow['totalPayment'] =
          _calculationRow['totalPayment']! + totalPayment;

      _soldListManipulatorByHeader.add({
        'dateTime': dateTime,
        'type': _selectedCustomer['type'],
        'invoiceNumber': element['cari_id'],
        'customerName': _selectedCustomer['name'],
        'totalPrice': '-',
        'payment': FormatterConvert().currencyShow(totalPayment),
        'balance': "-"
      });
    }

    ///kalan Tutar Burada Hesaplanıyor.
    _calculationRow['balance'] =
        _calculationRow['totalPrice']! - _calculationRow['totalPayment']!;

    ///List Map içinde Sort işlemi yapılıyor Tarih Saate göre (m1 ile m2 yeri değiştiğinde
    ///descending olarak)
    _soldListManipulatorByHeader.sort((m1, m2) => DateFormat('dd/MM/yyyy HH:mm')
        .parse(m2['dateTime'])
        .compareTo(DateFormat('dd/MM/yyyy HH:mm').parse(m1['dateTime'])));

    _expanded =
        List.generate(_soldListManipulatorByHeader.length, (index) => false);
    _streamControllerSoldList.sink.add(_soldListManipulatorByHeader);
  }

  //Elden Alınan ödemeler Kaydediliyor
  Future<Map<String, dynamic>> savePayment(String unitOfCurrency) async {
    await getCustomerId();
    cariGetPay.customerType = _selectedCustomer['type']!;
    cariGetPay.customerFk = _customerId;
    cariGetPay.cashPayment = double.parse(_paymentSystem['cash']!);
    cariGetPay.bankcardPayment = double.parse(_paymentSystem['bankCard']!);
    cariGetPay.eftHavalePayment = double.parse(_paymentSystem['eftHavale']!);
    cariGetPay.unitOfCurrency = unitOfCurrency;
    cariGetPay.sellerId = dbHive.getValues('uuid');

    /*   print(cariGetPay.customerType);
    print(cariGetPay.customerFk);
    print(cariGetPay.cashPayment);
    print(cariGetPay.bankcardPayment);
    print(cariGetPay.eftHavalePayment);
    print(cariGetPay.sellerId); */

    return await db.insertCariBySelectedCustomer(cariGetPay);
  }

  ///Müşteri belli olduktan sonra Zamana Göre Filtre
  filtreSoldListByDateTime() {
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};
    _soldListWithFiltre.clear();

    /// Gelen Tarihde saat olmadığı için ekliyoruz çünkü verilerde zaman geliyor
    /// filtre uygulamada problem çıkıyor.
    DateTimeRange tempAddTime = DateTimeRange(start: _startTime, end: _endTime);

    for (var element in _soldListManipulatorByHeader) {
      DateTime convertTemp =
          DateFormat('dd/MM/yyyy HH:mm').parse(element['dateTime']).toLocal();

      if (convertTemp.compareTo(tempAddTime.start) >= 0 &&
          convertTemp.compareTo(tempAddTime.end) <= 0) {
        _soldListWithFiltre.add(element);

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

    _expanded = List.generate(_soldListWithFiltre.length, (index) => false);
    _streamControllerSoldList.add(_soldListWithFiltre);
  }

  ///Sadece Tarih Seçildiğinde

  getOnlyUseDateTimeForSoldList() async {
    _expanded.clear();
    _soldListManipulatorByHeader.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};

    ///veritabanı arasında veri geliyor. bu gelen veri datatable header uyumlu değil
    ///bu yüzden aşağıdaki for döngüsü ile header uyumlu haline geliyor.
    final resSoldList = await db.fetchCariByOnlyDateTime(_startTime, _endTime);

    for (var element in resSoldList) {
      DateTime convertTemp = DateTime.parse(element['sale_date']);

      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['sale_date']));

      if (element['kdv_rate'] != null) {
        double totalPayment = element['cash_payment'] +
            element['bankcard_payment'] +
            element['eft_havale_payment'];
        double totalPrice = shareFunc.calculateWithKDV(
            element['total_payment_without_tax'], element['kdv_rate']);

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

        _soldListManipulatorByHeader.add({
          'dateTime': dateTime,
          'type': element['customer_type'],
          'customerName': element['name'],
          'invoiceNumber': element['invoice_number'],
          'totalPrice': FormatterConvert().currencyShow(totalPrice),
          'payment': FormatterConvert().currencyShow(totalPayment),
          'balance': FormatterConvert().currencyShow(totalPrice - totalPayment)
        });
      } else {
        double totalPayment = element['cash_payment'] +
            element['bankcard_payment'] +
            element['eft_havale_payment'];

        ///Buradaki sırası önemli çünkü aşağıda yapıldığında sayı olan veriler
        ///string döndürülüyor. TR para birimine göre ". ile ," ters oluyor.
        ///buda double döndürülemiyor özel olarak yazdığım Fonk. kullanılmalı.
        _calculationRow['totalPayment'] =
            _calculationRow['totalPayment']! + totalPayment;

        _soldListManipulatorByHeader.add({
          'dateTime': dateTime,
          'type': element['customer_type'],
          'invoiceNumber': element['cari_id'],
          'customerName': element['name'],
          'totalPrice': '-',
          'payment': FormatterConvert().currencyShow(totalPayment),
          'balance': "-"
        });
      }
    }

    ///List Map içinde Sort işlemi yapılıyor Tarih Saate göre (m1 ile m2 yeri değiştiğinde
    ///descending olarak)
    _soldListManipulatorByHeader.sort((m1, m2) => DateFormat('dd/MM/yyyy HH:mm')
        .parse(m2['dateTime'])
        .compareTo(DateFormat('dd/MM/yyyy HH:mm').parse(m1['dateTime'])));

    _expanded =
        List.generate(_soldListManipulatorByHeader.length, (index) => false);
    _streamControllerSoldList.add(_soldListManipulatorByHeader);
  }

  ///Fatura No ile Cari getirme
  getCariByInvoiceNo(String invoiceNo) async {
    _expanded.clear();
    _soldListManipulatorByHeader.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};

    Map<String, dynamic> resCari = await db.fetchCariByInvoiceNo(invoiceNo);

    String dateTime = DateFormat("dd/MM/yyyy HH:mm")
        .format(DateTime.parse(resCari['sale_date']));

    double totalPayment = resCari['cash_payment'] +
        resCari['bankcard_payment'] +
        resCari['eft_havale_payment'];
    double totalPrice = shareFunc.calculateWithKDV(
        resCari['total_payment_without_tax'], resCari['kdv_rate']);

    _soldListManipulatorByHeader.add({
      'dateTime': dateTime,
      'type': resCari['customer_type'],
      'customerName': resCari['name'],
      'invoiceNumber': resCari['invoice_number'],
      'totalPrice': FormatterConvert().currencyShow(totalPrice),
      'payment': FormatterConvert().currencyShow(totalPayment),
      'balance': FormatterConvert().currencyShow(totalPrice - totalPayment)
    });
    _expanded =
        List.generate(_soldListManipulatorByHeader.length, (index) => false);
    _streamControllerSoldList.add(_soldListManipulatorByHeader);
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
  //Ürün listesini Getiriyor
  getSaleDetail(int invoiceId) async {
    _expandedSaleDetailList.clear();
    _saleDetailList.clear();
    final saleDetailListTemp = await db.fetchsaleDetailByInvoice(invoiceId);
    for (var element in saleDetailListTemp) {
      double tempTotal =
          element['product_amount'] * element['product_price_without_tax'];

      _saleDetailList.add({
        'productCode': element['product_code'],
        'productAmount': element['product_amount'],
        'productPriceWithoutTax': FormatterConvert()
            .currencyShow(element['product_price_without_tax']),
        'productTotal': FormatterConvert().currencyShow(tempTotal)
      });
    }

    _expandedSaleDetailList =
        List.generate(_saleDetailList.length, (index) => false);
  }

  //Faturaya ait diğer bilgiler geliyor. (ödeme tipleri, düzenlem zamanı, kdv)
  getSaleInfo(int invoiceId) async {
    _saleInfo.clear();
    _saleInfo = await db.fetchSaleInfoByInvocice(invoiceId);

    ///Satış parabirimi simge olarak değiştiriliyor
    if (_saleInfo['unit_of_currency'] == "TL") {
      _saleCurrencySembol = "₺";
    } else if (_saleInfo['unit_of_currency'] == "USD") {
      _saleCurrencySembol = "\$";
    } else if (_saleInfo['unit_of_currency'] == "EURO") {
      _saleCurrencySembol = "€";
    }
  }

  ///veri tabanında  Faturanın silindiği yer Orjinal Veri
  deleteInvoiceOrjinalSource(int invoiceNumber, String totalPrice) async {
    if (totalPrice != "-") {
      await db.deleteInvoiceSales(invoiceNumber);
    } else {
      await db.deleteInvoiceCari(invoiceNumber);
    }

    _soldListManipulatorByHeader
        .removeWhere((element) => element['invoiceNumber'] == invoiceNumber);
    calculateRowTotalPaymentBalance(_soldListManipulatorByHeader);
    _streamControllerSoldList.add(_soldListManipulatorByHeader);
  }

  ///veri tabanında Faturanın silindiği yer Filtre
  deleteInvoiceFiltreSource(int invoiceNumber, String totalPrice) async {
    if (totalPrice != "-") {
      await db.deleteInvoiceSales(invoiceNumber);
    } else {
      await db.deleteInvoiceCari(invoiceNumber);
    }

    _soldListWithFiltre
        .removeWhere((element) => element['invoiceNumber'] == invoiceNumber);
    calculateRowTotalPaymentBalance(_soldListWithFiltre);
    _streamControllerSoldList.add(_soldListWithFiltre);
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
