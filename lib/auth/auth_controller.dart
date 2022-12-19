import 'package:stok_takip/data/database_helper.dart';
import 'package:stok_takip/data/user_security_storage.dart';

class AuthController {
  AuthController.init();

  static final _singlatonAuthController = AuthController.init();

  factory AuthController() {
    return _singlatonAuthController;
  }

  bool isAuth = true;
  String role = '1';

  setAuthTrue() {
    isAuth = true;
  }

  controllerAuth() async {
    // final user = await db.supabase.auth.currentUser;
    final userSession = await db.supabase.auth.currentSession;

    if (userSession?.accessToken != null) {
      print("session : ${userSession?.accessToken}");
    } else
      print("Session YOKK");
    //Browser Bulunan Local Storage veriler temizleniyor.
    SecurityStorageUser.deleteStorege();
    // Login Sayfasına yönlendiriliyor
  }
}

final authController = AuthController();
