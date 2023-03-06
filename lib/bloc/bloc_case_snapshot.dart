import 'package:stok_takip/data/database_helper.dart';

class BlocCaseSnapshot {
  Map<String, double> _collectionData = {'Kasa': 0, 'Banka': 0};

  BlocCaseSnapshot() {
    getCollection();
  }

  Map<String, double> get getterCollectionData => _collectionData;

  getCollection() async {
    List<dynamic> res = await db.fetchCalculateCollection();
    for (Map item in res) {
      _collectionData['Kasa'] = _collectionData['Kasa']! + item['cash_payment'];
      _collectionData['Banka'] =
          (_collectionData['Banka']! + item['bankcard_payment']);
      _collectionData['Banka'] =
          _collectionData['Banka']! + item['eft_havale_payment'];
    }
  }
}

BlocCaseSnapshot blocCaseSnapshot = BlocCaseSnapshot();
