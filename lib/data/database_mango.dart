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

    /*  final encryptionKey = await SecurityStorageUser.getkey();
    dynamic key;
    if (encryptionKey == null) {
      key = Hive.generateSecureKey();
      await SecurityStorageUser.setKey(key);
    } else {
      key = base64Url.decode(encryptionKey);
    }
    _box = await Hive.openBox(boxName, encryptionCipher: HiveAesCipher(key)); */
  }

  Future<void> addToBox(String value) async {
    await _box.add(value);
  }

  Future<void> putToBox(String key, String value) async {
    await _box.put(key, value);
  }

  delete(String key) async {
    await _box.delete(key);
  }

  getValues(String key) {
    return _box.get(key);
  }

  bool? isNotEmpty(String key) {
    return _box.isNotEmpty;
  }
}

final dbHive = DbHive();
