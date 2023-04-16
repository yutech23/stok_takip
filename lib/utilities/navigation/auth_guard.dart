import 'package:auto_route/auto_route.dart';
import 'package:stok_takip/auth/auth_controller.dart';
import 'package:stok_takip/utilities/navigation/navigation_manager.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (authController.isAuth) {
      return resolver.next(true);
    } else {
      router.push(const RouteLogin());
    }
  }
}
