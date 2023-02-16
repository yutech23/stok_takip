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
import 'package:auto_route/auto_route.dart' as _i12;
import 'package:flutter/material.dart' as _i13;

import '../../screen/cari.dart' as _i11;
import '../../screen/category_edit.dart' as _i6;
import '../../screen/customer_register.dart' as _i7;
import '../../screen/login.dart' as _i2;
import '../../screen/product_add.dart' as _i4;
import '../../screen/sale.dart' as _i10;
import '../../screen/sign_up.dart' as _i5;
import '../../screen/splash.dart' as _i1;
import '../../screen/stock_edit.dart' as _i3;
import '../../screen/test.dart' as _i9;
import '../../screen/user_setting.dart' as _i8;
import 'auth_guard.dart' as _i14;
import 'custom_router_builder.dart' as _i15;

class AppRouter extends _i12.RootStackRouter {
  AppRouter({
    _i13.GlobalKey<_i13.NavigatorState>? navigatorKey,
    required this.authGuard,
  }) : super(navigatorKey);

  final _i14.AuthGuard authGuard;

  @override
  final Map<String, _i12.PageFactory> pagesMap = {
    InitName.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.ScreenSplash(),
      );
    },
    RouteLogin.name: (routeData) {
      return _i12.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.ScreenLogin(),
      );
    },
    RouteStockEdit.name: (routeData) {
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i3.ScreenStockEdit(),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteProductAdd.name: (routeData) {
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i4.ScreenProductAdd(),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdmin,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteSignUp.name: (routeData) {
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i5.ScreenSignUp(),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdmin,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCategoryEdit.name: (routeData) {
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i6.ScreenCategoryEdit(),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdmin,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCustomerRegister.name: (routeData) {
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i7.ScreenCustomerRegister(),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteUserSetting.name: (routeData) {
      final args = routeData.argsAs<RouteUserSettingArgs>(
          orElse: () => const RouteUserSettingArgs());
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: _i8.ScreenUserSetting(key: args.key),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    Test.name: (routeData) {
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i9.Test(),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteSale.name: (routeData) {
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i10.ScreenSale(),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RouteCari.name: (routeData) {
      return _i12.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i11.ScreenCari(),
        customRouteBuilder:
            _i15.RolePermissionCustomRouter.customRouteBuilderAdminAndUser,
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i12.RouteConfig> get routes => [
        _i12.RouteConfig(
          InitName.name,
          path: '/splash',
        ),
        _i12.RouteConfig(
          RouteLogin.name,
          path: '/login',
        ),
        _i12.RouteConfig(
          RouteStockEdit.name,
          path: '/stockEdit',
          guards: [authGuard],
        ),
        _i12.RouteConfig(
          RouteProductAdd.name,
          path: '/productAdd',
          guards: [authGuard],
        ),
        _i12.RouteConfig(
          RouteSignUp.name,
          path: '/signUp',
          guards: [authGuard],
        ),
        _i12.RouteConfig(
          RouteCategoryEdit.name,
          path: '/categoryEdit',
          guards: [authGuard],
        ),
        _i12.RouteConfig(
          RouteCustomerRegister.name,
          path: '/customerRegister',
          guards: [authGuard],
        ),
        _i12.RouteConfig(
          RouteUserSetting.name,
          path: '/userSetting',
          guards: [authGuard],
        ),
        _i12.RouteConfig(
          Test.name,
          path: '/Test',
          guards: [authGuard],
        ),
        _i12.RouteConfig(
          RouteSale.name,
          path: '/sale',
          guards: [authGuard],
        ),
        _i12.RouteConfig(
          RouteCari.name,
          path: '/cari',
          guards: [authGuard],
        ),
      ];
}

/// generated route for
/// [_i1.ScreenSplash]
class InitName extends _i12.PageRouteInfo<void> {
  const InitName()
      : super(
          InitName.name,
          path: '/splash',
        );

  static const String name = 'InitName';
}

/// generated route for
/// [_i2.ScreenLogin]
class RouteLogin extends _i12.PageRouteInfo<void> {
  const RouteLogin()
      : super(
          RouteLogin.name,
          path: '/login',
        );

  static const String name = 'RouteLogin';
}

/// generated route for
/// [_i3.ScreenStockEdit]
class RouteStockEdit extends _i12.PageRouteInfo<void> {
  const RouteStockEdit()
      : super(
          RouteStockEdit.name,
          path: '/stockEdit',
        );

  static const String name = 'RouteStockEdit';
}

/// generated route for
/// [_i4.ScreenProductAdd]
class RouteProductAdd extends _i12.PageRouteInfo<void> {
  const RouteProductAdd()
      : super(
          RouteProductAdd.name,
          path: '/productAdd',
        );

  static const String name = 'RouteProductAdd';
}

/// generated route for
/// [_i5.ScreenSignUp]
class RouteSignUp extends _i12.PageRouteInfo<void> {
  const RouteSignUp()
      : super(
          RouteSignUp.name,
          path: '/signUp',
        );

  static const String name = 'RouteSignUp';
}

/// generated route for
/// [_i6.ScreenCategoryEdit]
class RouteCategoryEdit extends _i12.PageRouteInfo<void> {
  const RouteCategoryEdit()
      : super(
          RouteCategoryEdit.name,
          path: '/categoryEdit',
        );

  static const String name = 'RouteCategoryEdit';
}

/// generated route for
/// [_i7.ScreenCustomerRegister]
class RouteCustomerRegister extends _i12.PageRouteInfo<void> {
  const RouteCustomerRegister()
      : super(
          RouteCustomerRegister.name,
          path: '/customerRegister',
        );

  static const String name = 'RouteCustomerRegister';
}

/// generated route for
/// [_i8.ScreenUserSetting]
class RouteUserSetting extends _i12.PageRouteInfo<RouteUserSettingArgs> {
  RouteUserSetting({_i13.Key? key})
      : super(
          RouteUserSetting.name,
          path: '/userSetting',
          args: RouteUserSettingArgs(key: key),
        );

  static const String name = 'RouteUserSetting';
}

class RouteUserSettingArgs {
  const RouteUserSettingArgs({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return 'RouteUserSettingArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.Test]
class Test extends _i12.PageRouteInfo<void> {
  const Test()
      : super(
          Test.name,
          path: '/Test',
        );

  static const String name = 'Test';
}

/// generated route for
/// [_i10.ScreenSale]
class RouteSale extends _i12.PageRouteInfo<void> {
  const RouteSale()
      : super(
          RouteSale.name,
          path: '/sale',
        );

  static const String name = 'RouteSale';
}

/// generated route for
/// [_i11.ScreenCari]
class RouteCari extends _i12.PageRouteInfo<void> {
  const RouteCari()
      : super(
          RouteCari.name,
          path: '/cari',
        );

  static const String name = 'RouteCari';
}
