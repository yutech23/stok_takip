import 'dart:async';
import 'package:turkish/turkish.dart';

import '../data/database_helper.dart';

class BlocUsers {
  BlocUsers() {
    start();
  }
  start() async {
    await getAllUsers();
  }

  final StreamController<List<Map<String, dynamic>>> _streamControllerAllUsers =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get getStremAllUsers =>
      _streamControllerAllUsers.stream;

  List<bool> _expanded = [false];
  List<bool> get getterDatatableExpanded => _expanded;
  List<Map<String, dynamic>> _allUsers = [];

  getAllUsers() async {
    _allUsers.clear();
    _allUsers = await db.fetchAllUsers();
    for (var user in _allUsers) {
      ///Veritabanından role için gelen 1 ve 2 değeri burada anlamlandırılıyor.
      if (user['role'] == 1) {
        user['role'] = "Yönetici";
      } else if (user['role'] == 2) {
        user['role'] = "Kullanıcı";
      }

      ///Veritabanından ortaklı değeri bool olarak geliyor.
      if (user['partner']) {
        user['partner'] = "Evet";
      } else {
        user['partner'] = "Hayır";
      }

      ///Veritabanından durum değeri bool olarak geliyor.
      if (user['status']) {
        user['status'] = "Evet";
      } else {
        user['status'] = "Hayır";
      }

      ///Veritabanından isim bölümü üyük harfler çeviriliyor..
      user['name'] = user['name'].toString().toUpperCaseTr();
    }
    _expanded = List.generate(_allUsers.length, ((index) => false));
    _streamControllerAllUsers.sink.add(_allUsers);
  }
}
