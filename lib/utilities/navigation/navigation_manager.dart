import 'package:auto_route/annotations.dart';
import 'package:stok_takip/screen/login.dart';
import 'package:stok_takip/screen/product_add.dart';
import 'package:stok_takip/screen/splash.dart';
import 'package:stok_takip/screen/stock_edit.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/navigation/auth_guard.dart';
import 'package:stok_takip/utilities/navigation/custom_router_builder.dart';
import '../../screen/category_edit.dart';
import '../../screen/customer_register.dart';
import '../../screen/sign_up.dart';
import '../../screen/test.dart';
import '../../screen/user_setting.dart';

@MaterialAutoRouter(replaceInRouteName: 'Screen,Route', routes: <AutoRoute>[
  AutoRoute(
      page: ScreenSplash, path: RouteConsts.init, name: RouteConsts.initName),
  AutoRoute(
    page: ScreenLogin,
    path: RouteConsts.login,
  ),
  AutoRoute(
      page: ScreenStockEdit, path: RouteConsts.stockEdit, guards: [AuthGuard]),
  AutoRoute(
      page: ScreenProductAdd,
      path: RouteConsts.productAdd,
      guards: [AuthGuard]),
  AutoRoute(page: ScreenSignUp, path: RouteConsts.signUp, guards: [AuthGuard]),
  AutoRoute(
      page: ScreenCategoryEdit,
      path: RouteConsts.categoryEdit,
      guards: [AuthGuard]),
  AutoRoute(
      page: ScreenCustomerRegister,
      path: RouteConsts.customerRegister,
      guards: [AuthGuard]),
  AutoRoute(
      page: ScreenUserSetting,
      path: RouteConsts.userSetting,
      guards: [AuthGuard]),
  // AutoRoute(page: Test, path: RouteConsts.test),
  CustomRoute(
      page: Test, customRouteBuilder: CustomRouter.myCustomRouteBuilder),
//  CustomRoute(page: Test, path:RouteConsts.test, customRouteBuilder: customRouter.myCustomRouteBuilder(context, child, page) )
])
class $AppRouter {}
