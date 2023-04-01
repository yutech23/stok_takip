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
    ///açıldığında o günkü yapılan işlemleri getiriyor.
    await getServiceWithRangeDate();
  }

  List<Expense> listExpense = <Expense>[];
  List<Map<String, dynamic>> _listService = [
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

  ///Arama için Dropdown seçilen hizmet atanıyor.
  String? selectedGetServiceDropdownValue;
  bool selectedServiceDropdown = false;
  bool selectedDateTime = false;

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

  ///Tarihe göre verileri getiriyor. Başlangıç olarak o gün gönderiliyor.
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

  ///Hizmet ekleniyor.
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

  ///Hizmet seçimi ve tarih seçimi beraber seçildiğinde verileri getirir.
  getServiceTypeWithDate() async {
    _listService.clear();
    final res = await db.fetchServiceTypeWithRangeDate(
        selectedGetServiceDropdownValue!, _startTime, _endTime);

    for (Map<String, dynamic> element in res) {
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

  getServiceButton() async {
    ///sadece hizmet dropdown seçildiğinde.
    if (selectedServiceDropdown && selectedDateTime == false) {
      await getServiceDropdown(selectedGetServiceDropdownValue!);
    } else if (selectedDateTime && selectedServiceDropdown == false) {
      await getServiceWithRangeDate();
    } else if (selectedServiceDropdown && selectedDateTime) {
      await getServiceTypeWithDate();
    }
  }

  ///Satır silme işlemi.
  Future<String> deleteService(int idService) async {
    String res = await db.deleteService(idService);

    for (Map<String, dynamic> element in _listService) {
      if (element['id'] == idService) {
        _listService.remove(element);
      }
    }

    _expanded = List.generate(_listService.length, (index) => false);
    _streamControllerListService.sink.add(_listService);
    return res;
  }

  ///Güncelleme işlemi
  Future<String> updateService(Expense updateService) async {
    /* print(updateService.id);
    print(updateService.saveTime);
    print(updateService.name);
    print(updateService.description);
    print(updateService.paymentType);
    print(updateService.total); */
    for (var i = 0; i < _listService.length; i++) {
      if (_listService[i]['id'] == updateService.id) {
        _listService.setAll(i, [
          {
            'id': updateService.id,
            'saveTime':
                shareFunc.dateTimeConvertFormatString(updateService.saveTime),
            'name': updateService.name,
            'description': updateService.description,
            'paymentType': updateService.paymentType,
            'total': FormatterConvert().currencyShow(updateService.total)
          }
        ]);

        break;
      }
    }
    _expanded = List.generate(_listService.length, (index) => false);
    _streamControllerListService.add(_listService);
    return await db.updateService(updateService);
  }
}
