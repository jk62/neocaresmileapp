import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class CustomRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  // Static instance for global access
  static final CustomRouteObserver routeObserver = CustomRouteObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      devtools.log('Pushed route: ${route.settings.name}');
    }
    if (previousRoute is PageRoute) {
      devtools
          .log('Previous route before push: ${previousRoute.settings.name}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute) {
      devtools.log('Popped route: ${route.settings.name}');
    }
    if (previousRoute is PageRoute) {
      devtools
          .log('Returned to route after pop: ${previousRoute.settings.name}');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      devtools.log('Replaced with new route: ${newRoute.settings.name}');
    }
    if (oldRoute is PageRoute) {
      devtools.log('Old route replaced: ${oldRoute.settings.name}');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route is PageRoute) {
      devtools.log('Removed route: ${route.settings.name}');
    }
    if (previousRoute is PageRoute) {
      devtools
          .log('Previous route before removal: ${previousRoute.settings.name}');
    }
  }
}
