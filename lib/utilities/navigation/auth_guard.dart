import 'package:auto_route/auto_route.dart';
import 'package:stok_takip/utilities/navigation/navigation_manager.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    bool _isAuth = true;

    if (_isAuth) {
      resolver.next(true);
    } else {
      router.push(const RouteLogin());
    }
  }
}
