// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:stok_takip/data/database_helper.dart';
import '../modified_lib/searchfield.dart';

class BlocCari {
  List<Map<String, String>> _allCustomerAndSuppliers = [];
  List<SearchFieldListItem<String>> listSearchFieldListItemForAllCustomer = [];
  List<Map<String, dynamic>> _cariDataTable = [];

  Map<String, String> _selectedCustomer = {};

  Map<String, String> get getterSelectedCustomer => _selectedCustomer;
  set setterSelectedCustomer(Map<String, String> value) =>
      _selectedCustomer = value;

  BlocCari() {
    getAllCustomerAndSuppliers();
  }

  final StreamController<List<Map<String, String>>>
      _streamControllerAllCustomer =
      StreamController<List<Map<String, String>>>.broadcast();

  Stream<List<Map<String, String>>> get getStreamAllCustomer =>
      _streamControllerAllCustomer.stream;

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

  Future<int> getCustomerId(Map<String, String> customerTypeAndValue) async {
    final int customerId =
        await db.fetchCustomerIdForCari(customerTypeAndValue);
    return customerId;
  }

  /* fillSearchNameAllCustomerAndSuppliers() {
    for (var element in _allCustomerAndSuppliers) {
      listSearchFieldListItemForAllCustomer
          .add(SearchFieldListItem(element['name']!, item: element['type']));
    }
  } */

}
