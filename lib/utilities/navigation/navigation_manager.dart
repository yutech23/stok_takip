import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:stok_takip/screen/capital.dart';
import 'package:stok_takip/screen/cari_supplier.dart';
import 'package:stok_takip/screen/case_snapshot.dart';
import 'package:stok_takip/screen/expense.dart';
import 'package:stok_takip/screen/login.dart';
import 'package:stok_takip/screen/product_add.dart';
import 'package:stok_takip/screen/sale.dart';
import 'package:stok_takip/screen/stock_edit.dart';
import 'package:stok_takip/screen/users.dart';
import 'package:stok_takip/utilities/constants.dart';
import 'package:stok_takip/utilities/navigation/custom_router_builder.dart';
import '../../screen/cari_customer.dart';
import '../../screen/category.dart';
import '../../screen/customer_register.dart';
import '../../screen/reset_password.dart';

import '../../screen/test.dart';
import '../../screen/user_setting.dart';
import 'auth_guard.dart';

@MaterialAutoRouter(replaceInRouteName: 'Screen,Route', routes: <AutoRoute>[
  // AutoRoute(page: ScreenSplash, path: ConstRoute.splash),
  AutoRoute(
    page: ScreenLogin,
    path: ConstRoute.login,
  ),

  AutoRoute(
    page: ScreenResetPassword,
    path: ConstRoute.resetPassword,
  ),
  CustomRoute(
      page: ScreenStockEdit,
      path: ConstRoute.stockEdit,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: ScreenProductAdd,
      path: ConstRoute.productAdd,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
  CustomRoute(
      page: ScreenCategoryEdit,
      path: ConstRoute.categoryEdit,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
  CustomRoute(
      page: ScreenCustomerRegister,
      path: ConstRoute.customerRegister,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: ScreenUserSetting,
      path: ConstRoute.userSetting,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: ScreenSale,
      path: ConstRoute.sale,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: ScreenCariCustomer,
      path: ConstRoute.cariCustomer,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: ScreenCariSupplier,
      path: ConstRoute.cariSupplier,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: ScreenCaseSnapshot,
      path: ConstRoute.caseSnapshot,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
  CustomRoute(
      page: ScreenCapital,
      path: ConstRoute.capital,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
  CustomRoute(
      page: ScreenExpenses,
      path: ConstRoute.expenses,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
  CustomRoute(
      page: ScreenUsers,
      path: ConstRoute.users,
      guards: [AuthGuard],
      customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),

  CustomRoute(
      page: ScreenTest,
      guards: [AuthGuard],
      customRouteBuilder:
          RolePermissionCustomRouter.customRouteBuilderAdminAndUser),

  RedirectRoute(path: '*', redirectTo: ConstRoute.login)
])
class $AppRouter {}
