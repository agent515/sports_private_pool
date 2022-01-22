import 'package:flutter/material.dart';
import 'package:sports_private_pool/screens/join_contest_screen.dart';
import 'package:sports_private_pool/services/constants.dart';

class JoinTabNavigatorRoutes {
  static const join = '/';
}

class JoinTabNavigator extends StatelessWidget {
  final TabItem? tabItem;
  final GlobalKey<NavigatorState>? navigatorKey;
  JoinTabNavigator({this.tabItem, this.navigatorKey});

  Map<String, WidgetBuilder> _routeBuilders(context) {
    return {
      JoinTabNavigatorRoutes.join: (context) => JoinContestScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilder = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: JoinTabNavigatorRoutes.join,
      onGenerateRoute: (routeSetting){
        return MaterialPageRoute(builder: (context)=> routeBuilder[routeSetting.name!]!(context),);
      },
    );
  }
}