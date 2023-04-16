import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stok_takip/auth/auth_controller.dart';
import 'package:stok_takip/utilities/dimension_font.dart';

/*  Yönetici = 1
    User = 2
    Tüm kullanıcı durumları(kombinasyon) için CustomeRouterBuilder oluşturuluyor.
    oluşturulan Builderlar sayfaların customerRouterBuilder ekleniyor.
*/

Widget nonPermissionScreen(BuildContext context) {
  return Center(child: Text("İzniniz Yok", style: context.theme.headline1));
}

class RolePermissionCustomRouter {
  static Route<T> customRouteBuilderAdmin<T>(
      BuildContext context, Widget child, page) {
    return PageRouteBuilder(
      fullscreenDialog: page.fullscreenDialog,
      settings: page,
      pageBuilder: (context, animation, secondaryAnimation) {
        if (authController.role == '1') {
          return child;
        } else {
          return nonPermissionScreen(context);
        }
      },
    );
  }

  static Route<T> customRouteBuilderAdminAndUser<T>(
      BuildContext context, Widget child, page) {
    return PageRouteBuilder(
      fullscreenDialog: page.fullscreenDialog,
      settings: page,
      pageBuilder: (context, animation, secondaryAnimation) {
        if (authController.role == '1' || authController.role == '2') {
          return child;
        } else {
          return nonPermissionScreen(context);
        }
      },
    );
  }
}
