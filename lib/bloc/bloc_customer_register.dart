import 'dart:async';
import 'package:stok_takip/data/database_helper.dart';

class BlocCustomerRegister {
  BlocCustomerRegister() {
    getAllCustomer();
  }

  final StreamController<List<Map<String, dynamic>>>
      _streamControllerAllCustomer =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get getStremAllCustomer =>
      _streamControllerAllCustomer.stream;

  List<bool> _expanded = [false];
  List<bool> get getterDatatableExpanded => _expanded;
  List<Map<String, dynamic>> _allCustomer = [];
  List<Map<String, dynamic>> _searchCustomer = [];

  getAllCustomer() async {
    _allCustomer.clear();
    _allCustomer = await db.fetchAllCustomer();
    _expanded = List.generate(_allCustomer.length, ((index) => false));
    _streamControllerAllCustomer.sink.add(_allCustomer);
  }

  searchList(String searchValue) async {
    _searchCustomer = _allCustomer
        .where((element) => element['name'].contains(searchValue.toUpperCase()))
        .toList();
    _expanded = List.generate(_allCustomer.length, ((index) => false));
    _streamControllerAllCustomer.add(_searchCustomer);
  }

  Future<String> deleteCustomer(Map<String?, dynamic> customerRow) async {
    late String res;
    switch (customerRow['type']) {
      case "Şahıs":
        for (int i = 0; i < _allCustomer.length; i++) {
          if (_allCustomer[i]['type'] == 'Şahıs' &&
              _allCustomer[i]['customer_id'] == customerRow['customer_id']) {
            _allCustomer.removeAt(i);
          }
        }
        _expanded = List.generate(_allCustomer.length, ((index) => false));
        _streamControllerAllCustomer.add(_allCustomer);
        res = await db.deleteCustomerSoleTrader(customerRow['customer_id']);

        break;
      case "Firma":
        for (int i = 0; i < _allCustomer.length; i++) {
          if (_allCustomer[i]['type'] == 'Firma' &&
              _allCustomer[i]['customer_id'] == customerRow['customer_id']) {
            _allCustomer.removeAt(i);
          }
        }
        _expanded = List.generate(_allCustomer.length, ((index) => false));
        _streamControllerAllCustomer.add(_allCustomer);
        res = await db.deleteCustomerCompany(customerRow['customer_id']);
        break;
      case "Tedarikçi":
        for (int i = 0; i < _allCustomer.length; i++) {
          if (_allCustomer[i]['type'] == 'Tedarikçi' &&
              _allCustomer[i]['id'] == customerRow['id']) {
            _allCustomer.removeAt(i);
          }
        }
        _expanded = List.generate(_allCustomer.length, ((index) => false));
        _streamControllerAllCustomer.add(_allCustomer);
        res = await db.deleteCustomerSupplier(customerRow['id']);
        break;
      default:
    }

    return res;
  }
}
