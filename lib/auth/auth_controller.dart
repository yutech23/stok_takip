class AuthController {
  AuthController.init();

  static final _singlatonAuthController = AuthController.init();

  factory AuthController() {
    return _singlatonAuthController;
  }

  bool isAuth = false;
  String role = '';

  loginLocalStorageIsEmpty() {
    isAuth = true;
  }
}

final authController = AuthController();
