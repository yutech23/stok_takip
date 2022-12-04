import 'package:auto_route/auto_route.dart';
import 'package:stok_takip/auth/auth_controller.dart';
import 'package:stok_takip/utilities/navigation/navigation_manager.gr.dart';

class AuthGuardRole extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (authController.role == '1') {
      resolver.next(true);
    } else {
      resolver.next(false);
    }
  }
}
