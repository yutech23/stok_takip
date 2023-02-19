// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/utilities/share_func.dart';
import '../modified_lib/searchfield.dart';

class BlocCari {
  List<SearchFieldListItem<String>> listSearchFieldListItemForAllCustomer = [];
  final List<Map<String, String>> _allCustomerAndSuppliers = [];
  Map<String, String> _selectedCustomer = {};
  final List<Map<String, dynamic>> _sourceList = [];
  late List<bool>? _expanded;

  BlocCari() {
    getAllCustomerAndSuppliers();
  }

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

  get getStreamSoldList => _streamControllerSoldList.stream;

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
    _sourceList.clear();
    int customerId = await db.fetchSelectedCustomerIdForCari(_selectedCustomer);
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

      _sourceList.add({
        'dateTime': dateTime,
        'type': _selectedCustomer['type'],
        'customerName': _selectedCustomer['name'],
        'invoiceNumber': element['invoice_number'],
        'totalPrice': totalPrice,
        'payment': totalPayment,
        'balance': totalPrice - totalPayment
      });
    }

    _streamControllerSoldList.sink.add(_sourceList);
  }

  /* fillSearchNameAllCustomerAndSuppliers() {
    for (var element in _allCustomerAndSuppliers) {
      listSearchFieldListItemForAllCustomer
          .add(SearchFieldListItem(element['name']!, item: element['type']));
    }
  } */

}
