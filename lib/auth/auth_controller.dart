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
}

final authController = AuthController();
