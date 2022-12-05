import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:stok_takip/auth/auth_controller.dart';
import 'package:stok_takip/screen/test.dart';

import '../../data/user_security_storage.dart';

class CustomRouter {
  static Route<T> myCustomRouteBuilder<T>(
      BuildContext context, Widget child, CustomPage page) {
    return PageRouteBuilder(
      fullscreenDialog: page.fullscreenDialog,
      settings: page,
      pageBuilder: (context, animation, secondaryAnimation) {
        print("role degeri : ${authController.role}");
        if (authController.role == '1') {
          return Test();
        } else {
          return Container(
            child: Text("Role 1 degil"),
          );
        }
      },
    );
  }
}

final customRouter = CustomRouter();
