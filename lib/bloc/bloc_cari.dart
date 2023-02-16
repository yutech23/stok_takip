// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:stok_takip/data/database_helper.dart';

class BlocCari {
  List<Map<String, String>> _allCustomerAndSuppliers = [];
  BlocCari() {
    getAllCustomerAndSuppliers();
  }

  List<Map<String, String>> get getAllCustomerAndSuppliersMap =>
      _allCustomerAndSuppliers;

  getAllCustomerAndSuppliers() async {
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
    print(_allCustomerAndSuppliers);
  }
}

BlocCari blocCari = BlocCari();
