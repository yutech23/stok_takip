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

class BlocCari {
  List<SearchFieldListItem<String>> listSearchFieldListItemForAllCustomer = [];
  final List<Map<String, String>> _allCustomerAndSuppliers = [];
  Map<String, String> _selectedCustomer = {};
  final List<Map<String, dynamic>> _soldListManipulatorByHeader = [];
  final List<Map<String, dynamic>> _soldListWithFiltre = [];
  List<bool> _expanded = [false];
  int _customerId = -1; //-1 hiç bir id yok

  DateTime _startTime = DateTime.now();
  DateTime _endTime =
      DateTime.now().add(const Duration(hours: 23, minutes: 59));

  CariGetPay cariGetPay = CariGetPay();

  Map<String, num> _calculationRow = {
    'totalPrice': 0,
    'totalPayment': 0,
    'balance': 0
  };

  Map<String, String> _paymentSystem = {
    "cash": "0",
    "bankCard": "0",
    "eftHavale": "0"
  };

  BlocCari() {
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

  ///Yapılan satışların listesi
  Future getSoldListOfSelectedCustomer() async {
    _expanded.clear();
    _soldListManipulatorByHeader.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};
    await getCustomerId();

    ///veritabanı arasında veri geliyor. bu gelen veri datatable header uyumlu değil
    ///bu yüzden aşağıdaki for döngüsü ile header uyumlu haline geliyor.
    final resSoldList = await db.fetchSoldListOfSelectedCustomerById(
        _selectedCustomer['type']!, _customerId);

    final resCariList = await db.fetchCariPayListOfSelectedCustomerById(
        _selectedCustomer['type']!, _customerId);

    //Sales tablosundan gelen veriler
    for (var element in resSoldList) {
      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['sale_date']));

      double totalPayment = element['cash_payment'] +
          element['bankcard_payment'] +
          element['eft_havale_payment'];
      double totalPrice = ShareFunc.calculateWithKDV(
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
          .format(DateTime.parse(element['payment_date']));

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
        'invoiceNumber': '-',
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

/*----------------------TARİHİ ALMA------------------------------- */

/*---------------------------------------------------------------- */

  ///Zamana Göre Filtre
  filtreSoldListByDateTime() {
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};
    _soldListWithFiltre.clear();

    /// Gelen Tarihde saat olmadığı için ekliyoruz çünkü verilerde zaman geliyor
    /// filtre uygulamada problem çıkıyor.
    DateTimeRange tempAddTime = DateTimeRange(start: _startTime, end: _endTime);

    for (var element in _soldListManipulatorByHeader) {
      DateTime convertTemp =
          DateFormat('dd/MM/yyyy HH:mm').parse(element['dateTime']);

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
    final resSoldList = await db.fetchCariByOnlyDateTime();

    for (var element in resSoldList) {
      DateTime convertTemp = DateTime.parse(element['sale_date']);

      if (convertTemp.compareTo(_startTime) >= 0 &&
          convertTemp.compareTo(_endTime) <= 0) {
        String dateTime = DateFormat("dd/MM/yyyy HH:mm")
            .format(DateTime.parse(element['sale_date']));

        double totalPayment = element['cash_payment'] +
            element['bankcard_payment'] +
            element['eft_havale_payment'];
        double totalPrice = ShareFunc.calculateWithKDV(
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
        _soldListManipulatorByHeader.add(element);
      }
    }
  }
}
