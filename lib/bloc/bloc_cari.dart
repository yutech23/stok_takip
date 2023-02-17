// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:stok_takip/data/database_helper.dart';

import '../modified_lib/searchfield.dart';

class BlocCari {
  List<Map<String, String>> _allCustomerAndSuppliers = [];
  List<SearchFieldListItem<String>> listSearchFieldListItemForAllCustomer = [];

  BlocCari() {
    getAllCustomerAndSuppliers();
  }

  Future<List<Map<String, String>>> get getAllCustomerAndSuppliersMap =>
      Future.value(_allCustomerAndSuppliers);

  Future<List<Map<String, String>>> getAllCustomerAndSuppliers() async {
    final resCustomerSolo = await db.fetchCustomerSolo();
    for (var element in resCustomerSolo) {
      String araDeger = element['name'] + " " + element['last_name'];
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
    return _allCustomerAndSuppliers;
  }

  fillSearchNameAllCustomerAndSuppliers() {
    for (var element in _allCustomerAndSuppliers) {
      listSearchFieldListItemForAllCustomer
          .add(SearchFieldListItem(element['name']!, item: element['type']));
    }
  }
}

BlocCari blocCari = BlocCari();
