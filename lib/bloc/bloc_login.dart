import '../data/database_helper.dart';

class BlocLogin {
  Future<String> resetPassword(String email) async {
    return db.resetPasswordByEmail(email);
  }
}
