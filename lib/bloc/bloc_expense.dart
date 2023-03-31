import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/models/expense.dart';
import 'package:stok_takip/utilities/share_func.dart';
import 'package:stok_takip/validations/format_convert_point_comma.dart';

class BlocExpense {
  BlocExpense() {
    start();
  }

  start() async {
    await getServiceWithRangeDate();
  }

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
/*-------------------------------TARİH BÖLÜMÜ----------------------------- */
  DateTime _startTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime _endTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 23, 59, 59);

  DateTime get getterStartDate => _startTime;
  DateTime get getterEndDate => _endTime;
  set setterStartDate(DateTime dateTime) => _startTime = dateTime;
  set setterEndDate(DateTime dateTime) => _endTime = dateTime;

  ///Zaman Aralığı girme bölümü
  setDateRange(DateTimeRange? dateTimeRange) {
    _startTime = dateTimeRange!.start;
    _endTime = dateTimeRange.end
        .add(const Duration(hours: 23, minutes: 59, seconds: 59));
  }

/*----------------------------------------------------------------------- */
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
        'total': FormatterConvert().currencyShow(element['total'])
      });
    }
    _expanded = List.generate(_listService.length, (index) => false);
    _streamControllerListService.sink.add(_listService);
  }

  ///Müşterileri arama için getirilen veriler(tip,isim,numara)
  Future getServiceWithRangeDate() async {
    _listService.clear();
    final resService = await db.fetchServiceWithRangeDate(_startTime, _endTime);
    for (Map<String, dynamic> element in resService) {
      _listService.add({
        'id': element['id'],
        'saveTime': shareFunc.dateTimeStringToString(element['save_time']),
        'name': element['name'],
        'description': element['description'],
        'paymentType': element['payment_type'],
        'total': FormatterConvert().currencyShow(element['total'])
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

  ///Dropdown seçilen değere göre Listeye doldurur.
  getServiceDropdown(String selectedService) async {
    _listService.clear();
    final resService = await db.fetchServiceByDropdown(selectedService);
    for (Map<String, dynamic> element in resService) {
      _listService.add({
        'id': element['id'],
        'saveTime': shareFunc.dateTimeStringToString(element['save_time']),
        'name': element['name'],
        'description': element['description'],
        'paymentType': element['payment_type'],
        'total': FormatterConvert().currencyShow(element['total'])
      });
    }
    _expanded = List.generate(_listService.length, (index) => false);
    _streamControllerListService.sink.add(_listService);
  }
}
