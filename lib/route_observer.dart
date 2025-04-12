import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class RouteObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    devtools.log('Popped route: ${route.settings.name}');
  }
}

// import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

// class RouteObserverProvider extends InheritedWidget {
//   final RouteObserver<Route<dynamic>> routeObserver;

//   const RouteObserverProvider(
//       {super.key, required super.child, required this.routeObserver});

//   static RouteObserverProvider? of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<RouteObserverProvider>();
//   }

//   @override
//   bool updateShouldNotify(RouteObserverProvider oldWidget) => true;
// }
