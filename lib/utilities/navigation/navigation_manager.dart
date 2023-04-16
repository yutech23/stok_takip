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

part 'navigation_manager.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class NavigationManager extends _$NavigationManager {
  @override
  RouteType get defaultRouteType => const RouteType.material();
  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      page: RouteLogin.page,
      path: ConstRoute.login,
    ),
    AutoRoute(
      page: RouteResetPassword.page,
      path: ConstRoute.resetPassword,
    ),
    // RedirectRoute(path: '*', redirectTo: ConstRoute.login),
    CustomRoute(
        page: RouteStockEdit.page,
        path: ConstRoute.stockEdit,
        guards: [AuthGuard()],
        customRouteBuilder:
            RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
    CustomRoute(
        page: RouteProductAdd.page,
        path: ConstRoute.productAdd,
        guards: [AuthGuard()],
        customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
    CustomRoute(
        page: RouteCategoryEdit.page,
        path: ConstRoute.categoryEdit,
        guards: [AuthGuard()],
        customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
    CustomRoute(
        page: RouteCustomerRegister.page,
        path: ConstRoute.customerRegister,
        guards: [AuthGuard()],
        customRouteBuilder:
            RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
    CustomRoute(
        page: RouteUserSetting.page,
        path: ConstRoute.userSetting,
        guards: [AuthGuard()],
        customRouteBuilder:
            RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
    CustomRoute(
        page: RouteTest.page,
        guards: [AuthGuard()],
        customRouteBuilder:
            RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
    CustomRoute(
        page: RouteSale.page,
        path: ConstRoute.sale,
        guards: [AuthGuard()],
        customRouteBuilder:
            RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
    CustomRoute(
        page: RouteCariCustomer.page,
        path: ConstRoute.cariCustomer,
        guards: [AuthGuard()],
        customRouteBuilder:
            RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
    CustomRoute(
        page: RouteCariSupplier.page,
        path: ConstRoute.cariSupplier,
        guards: [AuthGuard()],
        customRouteBuilder:
            RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
    CustomRoute(
        page: RouteCaseSnapshot.page,
        path: ConstRoute.caseSnapshot,
        guards: [AuthGuard()],
        customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
    CustomRoute(
        page: RouteCapital.page,
        path: ConstRoute.capital,
        guards: [AuthGuard()],
        customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
    CustomRoute(
        page: RouteExpenses.page,
        path: ConstRoute.expenses,
        guards: [AuthGuard()],
        customRouteBuilder:
            RolePermissionCustomRouter.customRouteBuilderAdminAndUser),
    CustomRoute(
        page: RouteUsers.page,
        path: ConstRoute.users,
        guards: [AuthGuard()],
        customRouteBuilder: RolePermissionCustomRouter.customRouteBuilderAdmin),
  ];
}
