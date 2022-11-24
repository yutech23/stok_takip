

import 'package:stok_takip/models/user_model.dart';

class Mock {
  static Stream<List<UserModel>> getUserStream() {
    return Stream.value(UserModel.userList);
  }
}