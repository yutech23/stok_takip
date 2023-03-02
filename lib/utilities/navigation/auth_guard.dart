import 'package:auto_route/auto_route.dart';
import 'package:stok_takip/auth/auth_controller.dart';

import 'navigation_manager.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (authController.isAuth) {
      resolver.next(true);
    } else {
      router.push(const RouteLogin());
    }
  }
}
