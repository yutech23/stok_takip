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

@MaterialAutoRouter(replaceInRouteName: 'Screen,Route', routes: <AutoRoute>[
  AutoRoute(
      page: ScreenSplash, path: RouteConsts.init, name: RouteConsts.initName),
  AutoRoute(
    page: ScreenLogin,
    path: RouteConsts.login,
  ),
  CustomRoute(
      page: ScreenStockEdit,
      path: RouteConsts.stockEdit,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: ScreenProductAdd,
      path: RouteConsts.productAdd,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
  CustomRoute(
      page: ScreenSignUp,
      path: RouteConsts.signUp,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
  CustomRoute(
      page: ScreenCategoryEdit,
      path: RouteConsts.categoryEdit,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
  CustomRoute(
      page: ScreenCustomerRegister,
      path: RouteConsts.customerRegister,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
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
])
class $AppRouter {}
