import 'dart:async';
import 'package:intl/intl.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/expense.dart';
import 'package:stok_takip/utilities/share_func.dart';

class BlocExpense {
  List<Expense> listExpense = <Expense>[];
  final List<Map<String, dynamic>> _listService = [
    {
      'id': '0',
      'saveTime': '',
      'name': '',
      'description': '',
      'paymentType': '',
      'total': '0'
    }
  ];
  List<bool> _expanded = [false];

  BlocExpense() {
    start();
  }

  start() async {
    await getService();
  }

  final StreamController<List<Map<String, dynamic>>>
      _streamControllerListService =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get getStreamListService =>
      _streamControllerListService.stream;

  get getterListExpanded => _expanded;

  ///Müşterileri arama için getirilen veriler(tip,isim,numara)
  Future getService() async {
    _listService.clear();
    final resService = await db.fetchService();
    for (Map<String, dynamic> element in resService) {
      _listService.add({
        'id': element['id'],
        'saveTime': shareFunc.dateTimeStringToString(element['save_time']),
        'name': element['name'],
        'description': element['description'],
        'paymentType': element['payment_type'],
        'total': element['total']
      });
    }
    _expanded = List.generate(_listService.length, (index) => false);
    _streamControllerListService.sink.add(_listService);
  }

  /* //Listeden ürün siliyor
  void removeFromListProduct(int getId) {
    listExpense.removeWhere((element) => element.id == getId);
    _streamControllerListService.add(listExpense);
  } */

  Future<String> serviceAdd(Expense newService) async {
    return await db.saveNewService(newService);
  }
}
