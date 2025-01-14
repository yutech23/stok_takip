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

  ///Bu değer resetPassword Bölümüne deeplink gelmeyenler
  ///olursa diye buttonu disable yapmak için
  bool resetPasswordButtonActive = false;

  ///isAuth degeri otamatik sayfa yönlendirme için kullanılıyor.
/*   bool isAuth = true;
  String role = '1'; */

  setAuthTrue() {
    isAuth = true;
  }

  getRole() async {
    role = await SecurityStorageUser.getUserRole() ?? '';
    // print("role func içi : $role");
  }

  controllerAuth() async {
    await getRole();
    db.supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      //   print("Auth durumu : $event");
      if (AuthChangeEvent.signedIn == event) {
        isAuth = true;

        //     print("role nedir : $role");
      } else if (AuthChangeEvent.tokenRefreshed == event) {
        //   Session? userSession = data.session;
        // db.supabase.auth.setSession(userSession!.refreshToken!);
        isAuth = true;
      } else if (AuthChangeEvent.passwordRecovery == event) {
        resetPasswordButtonActive = true;
      } else if (AuthChangeEvent.signedOut == event) {
        SecurityStorageUser.deleteStorege();
      }
    });
  }
}

final authController = AuthController();
