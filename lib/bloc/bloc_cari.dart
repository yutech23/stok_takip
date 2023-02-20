// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/utilities/share_func.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';
import '../modified_lib/searchfield.dart';

class BlocCari {
  List<SearchFieldListItem<String>> listSearchFieldListItemForAllCustomer = [];
  final List<Map<String, String>> _allCustomerAndSuppliers = [];
  Map<String, String> _selectedCustomer = {};
  final List<Map<String, dynamic>> _soldListManipulatorByHeader = [];
  late List<bool> _expanded = [false];
  Map<String, num> _calculationRow = {
    'totalPrice': 0,
    'totalPayment': 0,
    'balance': 0
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
      _allCustomerAndSuppliers
          .add({'type': element['type'], 'name': element['name']});
    }

    final resSuppliers = await db.fetchSuppliers();
    for (var element in resSuppliers) {
      _allCustomerAndSuppliers
          .add({'type': element['type'], 'name': element['name']});
    }

    _streamControllerAllCustomer.sink.add(_allCustomerAndSuppliers);
  }

  ///Yapılan satışların listesi
  Future getSoldListOfSelectedCustomer() async {
    _expanded.clear();
    _soldListManipulatorByHeader.clear();
    _calculationRow = {'totalPrice': 0, 'totalPayment': 0, 'balance': 0};
    int customerId = await db.fetchSelectedCustomerIdForCari(_selectedCustomer);

    ///veritabanı arasında veri geliyor. bu gelen veri datatable header uyumlu değil
    ///bu yüzden aşağıdaki for döngüsü ile header uyumlu haline geliyor.
    final resSoldList = await db.fetchSoldListOfSelectedCustomerById(
        _selectedCustomer['type']!, customerId);

    for (var element in resSoldList) {
      String dateTime = DateFormat("dd/MM/yyyy HH:mm")
          .format(DateTime.parse(element['sale_date']));

      double totalPayment = element['cash_payment'] +
          element['bankcard_payment'] +
          element['eft_havale_payment'];
      double totalPrice = ShareFunc.calculateWithKDV(
          element['total_payment_without_tax'], element['kdv_rate']);

      _soldListManipulatorByHeader.add({
        'dateTime': dateTime,
        'type': _selectedCustomer['type'],
        'customerName': _selectedCustomer['name'],
        'invoiceNumber': element['invoice_number'],
        'totalPrice': FormatterConvert().currencyShow(totalPrice),
        'payment': FormatterConvert().currencyShow(totalPayment),
        'balance': FormatterConvert().currencyShow(totalPrice - totalPayment)
      });

      _calculationRow['totalPrice'] =
          _calculationRow['totalPrice']! + totalPrice;
      _calculationRow['totalPayment'] =
          _calculationRow['totalPayment']! + totalPayment;
      _calculationRow['balance'] =
          _calculationRow['balance']! + (totalPrice - totalPayment);
    }

    ///Satılan listesinin içinde toplam tutar , ödenen tutar ve kalan tutar
    ///hesaplanıyor.
    for (var item in _soldListManipulatorByHeader) {}

    _expanded =
        List.generate(_soldListManipulatorByHeader.length, (index) => false);
    _streamControllerSoldList.sink.add(_soldListManipulatorByHeader);
  }

  /* fillSearchNameAllCustomerAndSuppliers() {
    for (var element in _allCustomerAndSuppliers) {
      listSearchFieldListItemForAllCustomer
          .add(SearchFieldListItem(element['name']!, item: element['type']));
    }
  } */

}
