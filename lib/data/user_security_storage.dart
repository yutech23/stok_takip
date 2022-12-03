import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityStorageUser {
  static const storage = FlutterSecureStorage();

  static Future setUserName(String userName) async =>
      await storage.write(key: 'name', value: userName);
  static Future setUserLastName(String lastName) async =>
      await storage.write(key: 'lastName', value: lastName);
  static Future setUserRole(String role) async =>
      await storage.write(key: 'role', value: role);
  static Future setUserId(String id) async =>
      await storage.write(key: 'id', value: id);
  static Future setUserAccessToken(String accessToken) async =>
      await storage.write(key: 'accessToken', value: accessToken);
  static Future sertUserRefleshToken(String refleshToken) async =>
      await storage.write(key: 'refleshToken', value: refleshToken);

  static Future<String?> getUserName() async => await storage.read(key: 'name');

  static Future<String?> getUserLastName() async =>
      await storage.read(key: 'lastName');
  static Future<String?> getUserRole() async => await storage.read(key: 'role');
  static Future<String?> getUserToken() async =>
      await storage.read(key: 'accessToken');
  static Future<String?> getUserRefleshToken() async =>
      await storage.read(key: 'refleshToken');

  static Future deleteStorege() async => await storage.deleteAll();
}
