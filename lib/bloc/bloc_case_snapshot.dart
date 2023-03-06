import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/utilities/share_func.dart';

class BlocCaseSnapshot {
  Map<String, double> _collectionDataPaid = {
    'Kasa': 0,
    'Banka': 0,
    'Toplam': 0,
    'Kalan': 0
  };

  Map<String, double> _collectionDataBalance = {'Kalan': 100};

  BlocCaseSnapshot() {
    getCollection();
  }

  Map<String, double> get getterCollectionData => _collectionDataPaid;

  Future<Map<String, double>>? getCollection() async {
    _collectionDataPaid = {'Kasa': 0, 'Banka': 0, 'Toplam': 0, 'Kalan': 0};
    List<dynamic> res = await db.fetchCalculateCollection();
    for (Map<String, dynamic> item in res) {
      print("nakit :${item['cash_payment']}");
      print("nakit :${item['bankcard_payment']}");
      print("nakit :${item['eft_havale_payment']}");

      _collectionDataPaid['Kasa'] =
          _collectionDataPaid['Kasa']! + item['cash_payment'];

      _collectionDataPaid['Banka'] = _collectionDataPaid['Banka']! +
          item['bankcard_payment'] +
          item['eft_havale_payment'];

      if (item.containsKey('total_payment_without_tax')) {
        _collectionDataPaid['Toplam'] = _collectionDataPaid['Toplam']! +
            shareFunc.calculateWithKDV(
                item['total_payment_without_tax'], item['kdv_rate']);

        print(shareFunc.calculateWithKDV(
            item['total_payment_without_tax'], item['kdv_rate']));
        print("*************************************");
      }
    }

    _collectionDataPaid['Kalan'] = _collectionDataPaid['Toplam']! -
        _collectionDataPaid['Kasa']! -
        _collectionDataPaid['Banka']!;

    return Future<Map<String, double>>.value(_collectionDataPaid);
  }
}
