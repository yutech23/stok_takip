import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
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

@MaterialAutoRouter(replaceInRouteName: 'Screen,Route', routes: <
    AutoRoute<bool>>[
  AutoRoute(
      page: ScreenSplash, path: RouteConsts.init, name: RouteConsts.initName),
  AutoRoute(
    page: ScreenLogin,
    path: RouteConsts.login,
  ),
  AutoRoute(
      page: ScreenStockEdit, path: RouteConsts.stockEdit, guards: [AuthGuard]),
  CustomRoute(
      page: ScreenProductAdd,
      path: RouteConsts.productAdd,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),

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
    guards: [AuthGuard],
  ),
  CustomRoute(
      page: ScreenUserSetting,
      path: RouteConsts.userSetting,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: Test,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
//  CustomRoute(page: Test, path:RouteConsts.test, customRouteBuilder: customRouter.myCustomRouteBuilder(context, child, page) )
])
class $AppRouter {}
