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
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/material.dart' as _i11;

import '../../screen/category_edit.dart' as _i6;
import '../../screen/customer_register.dart' as _i7;
import '../../screen/login.dart' as _i2;
import '../../screen/product_add.dart' as _i4;
import '../../screen/sign_up.dart' as _i5;
import '../../screen/splash.dart' as _i1;
import '../../screen/stock_edit.dart' as _i3;
import '../../screen/test.dart' as _i9;
import '../../screen/user_setting.dart' as _i8;
import 'auth_guard.dart' as _i12;

class AppRouter extends _i10.RootStackRouter {
  AppRouter({
    _i11.GlobalKey<_i11.NavigatorState>? navigatorKey,
    required this.authGuard,
  }) : super(navigatorKey);

  final _i12.AuthGuard authGuard;

  @override
  final Map<String, _i10.PageFactory> pagesMap = {
    RouteSplash.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.ScreenSplash(),
      );
    },
    RouteLogin.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i2.ScreenLogin(),
      );
    },
    RouteStockEdit.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i3.ScreenStockEdit(),
      );
    },
    RouteProductAdd.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.ScreenProductAdd(),
      );
    },
    RouteSignUp.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.ScreenSignUp(),
      );
    },
    RouteCategoryEdit.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.ScreenCategoryEdit(),
      );
    },
    RouteCustomerRegister.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.ScreenCustomerRegister(),
      );
    },
    RouteUserSetting.name: (routeData) {
      final args = routeData.argsAs<RouteUserSettingArgs>(
          orElse: () => const RouteUserSettingArgs());
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i8.ScreenUserSetting(key: args.key),
      );
    },
    Test.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i9.Test(),
      );
    },
  };

  @override
  List<_i10.RouteConfig> get routes => [
        _i10.RouteConfig(
          RouteSplash.name,
          path: '/',
        ),
        _i10.RouteConfig(
          RouteLogin.name,
          path: '/login',
        ),
        _i10.RouteConfig(
          RouteStockEdit.name,
          path: '/stockEdit',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          RouteProductAdd.name,
          path: '/productAdd',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          RouteSignUp.name,
          path: '/signUp',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          RouteCategoryEdit.name,
          path: '/categoryEdit',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          RouteCustomerRegister.name,
          path: '/customerRegister',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          RouteUserSetting.name,
          path: '/userSetting',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          Test.name,
          path: '/test',
        ),
      ];
}

/// generated route for
/// [_i1.ScreenSplash]
class RouteSplash extends _i10.PageRouteInfo<void> {
  const RouteSplash()
      : super(
          RouteSplash.name,
          path: '/',
        );

  static const String name = 'RouteSplash';
}

/// generated route for
/// [_i2.ScreenLogin]
class RouteLogin extends _i10.PageRouteInfo<void> {
  const RouteLogin()
      : super(
          RouteLogin.name,
          path: '/login',
        );

  static const String name = 'RouteLogin';
}

/// generated route for
/// [_i3.ScreenStockEdit]
class RouteStockEdit extends _i10.PageRouteInfo<void> {
  const RouteStockEdit()
      : super(
          RouteStockEdit.name,
          path: '/stockEdit',
        );

  static const String name = 'RouteStockEdit';
}

/// generated route for
/// [_i4.ScreenProductAdd]
class RouteProductAdd extends _i10.PageRouteInfo<void> {
  const RouteProductAdd()
      : super(
          RouteProductAdd.name,
          path: '/productAdd',
        );

  static const String name = 'RouteProductAdd';
}

/// generated route for
/// [_i5.ScreenSignUp]
class RouteSignUp extends _i10.PageRouteInfo<void> {
  const RouteSignUp()
      : super(
          RouteSignUp.name,
          path: '/signUp',
        );

  static const String name = 'RouteSignUp';
}

/// generated route for
/// [_i6.ScreenCategoryEdit]
class RouteCategoryEdit extends _i10.PageRouteInfo<void> {
  const RouteCategoryEdit()
      : super(
          RouteCategoryEdit.name,
          path: '/categoryEdit',
        );

  static const String name = 'RouteCategoryEdit';
}

/// generated route for
/// [_i7.ScreenCustomerRegister]
class RouteCustomerRegister extends _i10.PageRouteInfo<void> {
  const RouteCustomerRegister()
      : super(
          RouteCustomerRegister.name,
          path: '/customerRegister',
        );

  static const String name = 'RouteCustomerRegister';
}

/// generated route for
/// [_i8.ScreenUserSetting]
class RouteUserSetting extends _i10.PageRouteInfo<RouteUserSettingArgs> {
  RouteUserSetting({_i11.Key? key})
      : super(
          RouteUserSetting.name,
          path: '/userSetting',
          args: RouteUserSettingArgs(key: key),
        );

  static const String name = 'RouteUserSetting';
}

class RouteUserSettingArgs {
  const RouteUserSettingArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'RouteUserSettingArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.Test]
class Test extends _i10.PageRouteInfo<void> {
  const Test()
      : super(
          Test.name,
          path: '/test',
        );

  static const String name = 'Test';
}
