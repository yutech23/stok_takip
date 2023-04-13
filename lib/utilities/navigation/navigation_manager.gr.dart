// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i16;
import 'package:flutter/material.dart' as _i17;

import '../../screen/capital.dart' as _i12;
import '../../screen/cari_customer.dart' as _i9;
import '../../screen/cari_supplier.dart' as _i10;
import '../../screen/case_snapshot.dart' as _i11;
import '../../screen/category.dart' as _i5;
import '../../screen/customer_register.dart' as _i6;
import '../../screen/expense.dart' as _i13;
import '../../screen/login.dart' as _i1;
import '../../screen/product_add.dart' as _i4;
import '../../screen/reset_password.dart' as _i2;
import '../../screen/sale.dart' as _i8;
import '../../screen/stock_edit.dart' as _i3;
import '../../screen/test.dart' as _i15;
import '../../screen/user_setting.dart' as _i7;
import '../../screen/users.dart' as _i14;
import 'auth_guard.dart' as _i18;
import 'custom_router_builder.dart' as _i19;

class AppRouter extends _i16.RootStackRouter {
  AppRouter({
    _i17.GlobalKey<_i17.NavigatorState>? navigatorKey,
    required this.authGuard,
  }) : super(navigatorKey);

  final _i18.AuthGuard authGuard;

  @override
  final Map<String, _i16.PageFactory> pagesMap = {
    RouteLogin.name: (routeData) {
      return _i16.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.ScreenLogin(),
      );
    },
    RouteResetPassword.name: (routeData) {
      return _i16.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.ScreenResetPassword(),
      );
    },
    RouteStockEdit.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i3.ScreenStockEdit(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteProductAdd.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i4.ScreenProductAdd(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdmin,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCategoryEdit.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i5.ScreenCategoryEdit(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdmin,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCustomerRegister.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i6.ScreenCustomerRegister(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteUserSetting.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i7.ScreenUserSetting(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteSale.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i8.ScreenSale(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCariCustomer.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i9.ScreenCariCustomer(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCariSupplier.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i10.ScreenCariSupplier(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCaseSnapshot.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i11.ScreenCaseSnapshot(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdmin,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCapital.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i12.ScreenCapital(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdmin,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteExpenses.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i13.ScreenExpenses(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteUsers.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i14.ScreenUsers(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdmin,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteTest.name: (routeData) {
      return _i16.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i15.ScreenTest(),
        customRouteBuilder:
            _i19.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i16.RouteConfig> get routes => [
        _i16.RouteConfig(
          RouteLogin.name,
          path: '/',
        ),
        _i16.RouteConfig(
          RouteResetPassword.name,
          path: '/resetPassword',
        ),
        _i16.RouteConfig(
          RouteStockEdit.name,
          path: '/stockEdit',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteProductAdd.name,
          path: '/productAdd',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteCategoryEdit.name,
          path: '/categoryEdit',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteCustomerRegister.name,
          path: '/customerRegister',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteUserSetting.name,
          path: '/userSetting',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteSale.name,
          path: '/sale',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteCariCustomer.name,
          path: '/cariCustomer',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteCariSupplier.name,
          path: '/cariSupplier',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteCaseSnapshot.name,
          path: '/caseSnapshot',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteCapital.name,
          path: '/capital',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteExpenses.name,
          path: '/expenses',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteUsers.name,
          path: '/usersEdit',
          guards: [authGuard],
        ),
        _i16.RouteConfig(
          RouteTest.name,
          path: '/screen-test',
          guards: [authGuard],
        ),
      ];
}

/// generated route for
/// [_i1.ScreenLogin]
class RouteLogin extends _i16.PageRouteInfo<void> {
  const RouteLogin()
      : super(
          RouteLogin.name,
          path: '/',
        );

  static const String name = 'RouteLogin';
}

/// generated route for
/// [_i2.ScreenResetPassword]
class RouteResetPassword extends _i16.PageRouteInfo<void> {
  const RouteResetPassword()
      : super(
          RouteResetPassword.name,
          path: '/resetPassword',
        );

  static const String name = 'RouteResetPassword';
}

/// generated route for
/// [_i3.ScreenStockEdit]
class RouteStockEdit extends _i16.PageRouteInfo<void> {
  const RouteStockEdit()
      : super(
          RouteStockEdit.name,
          path: '/stockEdit',
        );

  static const String name = 'RouteStockEdit';
}

/// generated route for
/// [_i4.ScreenProductAdd]
class RouteProductAdd extends _i16.PageRouteInfo<void> {
  const RouteProductAdd()
      : super(
          RouteProductAdd.name,
          path: '/productAdd',
        );

  static const String name = 'RouteProductAdd';
}

/// generated route for
/// [_i5.ScreenCategoryEdit]
class RouteCategoryEdit extends _i16.PageRouteInfo<void> {
  const RouteCategoryEdit()
      : super(
          RouteCategoryEdit.name,
          path: '/categoryEdit',
        );

  static const String name = 'RouteCategoryEdit';
}

/// generated route for
/// [_i6.ScreenCustomerRegister]
class RouteCustomerRegister extends _i16.PageRouteInfo<void> {
  const RouteCustomerRegister()
      : super(
          RouteCustomerRegister.name,
          path: '/customerRegister',
        );

  static const String name = 'RouteCustomerRegister';
}

/// generated route for
/// [_i7.ScreenUserSetting]
class RouteUserSetting extends _i16.PageRouteInfo<void> {
  const RouteUserSetting()
      : super(
          RouteUserSetting.name,
          path: '/userSetting',
        );

  static const String name = 'RouteUserSetting';
}

/// generated route for
/// [_i8.ScreenSale]
class RouteSale extends _i16.PageRouteInfo<void> {
  const RouteSale()
      : super(
          RouteSale.name,
          path: '/sale',
        );

  static const String name = 'RouteSale';
}

/// generated route for
/// [_i9.ScreenCariCustomer]
class RouteCariCustomer extends _i16.PageRouteInfo<void> {
  const RouteCariCustomer()
      : super(
          RouteCariCustomer.name,
          path: '/cariCustomer',
        );

  static const String name = 'RouteCariCustomer';
}

/// generated route for
/// [_i10.ScreenCariSupplier]
class RouteCariSupplier extends _i16.PageRouteInfo<void> {
  const RouteCariSupplier()
      : super(
          RouteCariSupplier.name,
          path: '/cariSupplier',
        );

  static const String name = 'RouteCariSupplier';
}

/// generated route for
/// [_i11.ScreenCaseSnapshot]
class RouteCaseSnapshot extends _i16.PageRouteInfo<void> {
  const RouteCaseSnapshot()
      : super(
          RouteCaseSnapshot.name,
          path: '/caseSnapshot',
        );

  static const String name = 'RouteCaseSnapshot';
}

/// generated route for
/// [_i12.ScreenCapital]
class RouteCapital extends _i16.PageRouteInfo<void> {
  const RouteCapital()
      : super(
          RouteCapital.name,
          path: '/capital',
        );

  static const String name = 'RouteCapital';
}

/// generated route for
/// [_i13.ScreenExpenses]
class RouteExpenses extends _i16.PageRouteInfo<void> {
  const RouteExpenses()
      : super(
          RouteExpenses.name,
          path: '/expenses',
        );

  static const String name = 'RouteExpenses';
}

/// generated route for
/// [_i14.ScreenUsers]
class RouteUsers extends _i16.PageRouteInfo<void> {
  const RouteUsers()
      : super(
          RouteUsers.name,
          path: '/usersEdit',
        );

  static const String name = 'RouteUsers';
}

/// generated route for
/// [_i15.ScreenTest]
class RouteTest extends _i16.PageRouteInfo<void> {
  const RouteTest()
      : super(
          RouteTest.name,
          path: '/screen-test',
        );

  static const String name = 'RouteTest';
}
