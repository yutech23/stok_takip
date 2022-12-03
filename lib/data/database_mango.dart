import 'package:hive_flutter/adapters.dart';

class DbHive {
  DbHive._init();
  static final _singlaton = DbHive._init();

  factory DbHive() {
    return _singlaton;
  }

  late Box _box;

  Future<void> initDbHive(String boxName) async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  Future<void> addToBox(String value) async {
    await _box.add(value);
  }

  Future<void> putToBox(String key, String value) async {
    await _box.put(key, value);
  }

  Iterable<String>? getValues(String key) {
    return _box.get(key);
  }

  bool? isNotEmpty(String key) {
    return _box.isNotEmpty;
  }
}

final dbHive = DbHive();
