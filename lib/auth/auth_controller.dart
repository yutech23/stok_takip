import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/database_helper.dart';
import '../data/user_security_storage.dart';

class AuthController {
  AuthController.init();

  static final _singlatonAuthController = AuthController.init();

  factory AuthController() {
    return _singlatonAuthController;
  }
  bool isAuth = false;
  String role = '';

  /* bool isAuth = true;
  String role = '1'; */

  setAuthTrue() {
    isAuth = true;
  }

  controllerAuth() async {
    // final user = await db.supabase.auth.currentUser;
    final Session? userSession = await db.supabase.auth.currentSession;

    if (userSession?.accessToken != null) {
      isAuth = true;
      role = (await SecurityStorageUser.getUserRole())!;

      // print("sesion burada durumu : ${userSession!.user.email}");
      await db.supabase.auth.setSession(userSession!.refreshToken!);
      //  print("session : ${userSession!.accessToken}");
    } else {
      print("Session YOKK");
      //Browser Bulunan Local Storage veriler temizleniyor.
      SecurityStorageUser.deleteStorege();
    }

    // Login Sayfasına yönlendiriliyor
  }
}

final authController = AuthController();
