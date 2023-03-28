import 'dart:async';
import 'package:stok_takip/models/expense.dart';

class BlocExpense {
  List<Expense> listExpense = <Expense>[];

  final StreamController<List<Expense>> _streamControllerListExpense =
      StreamController<List<Expense>>.broadcast();

  Stream<List<Expense>> get getStreamListExpense =>
      _streamControllerListExpense.stream;

  //Listeden ürün siliyor
  void removeFromListProduct(int getId) {
    listExpense.removeWhere((element) => element.id == getId);
    _streamControllerListExpense.add(listExpense);
  }
}
