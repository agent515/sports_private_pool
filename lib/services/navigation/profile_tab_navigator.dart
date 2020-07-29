import 'package:flutter/material.dart';
import 'package:sports_private_pool/screens/user_specific_screens/user_profile_screen.dart';
import 'package:sports_private_pool/services/constants.dart';

class ProfileTabNavigatorRoutes {
  static const profile = '/';
}

class ProfileTabNavigator extends StatelessWidget {
  final TabItem tabItem;
  final GlobalKey<NavigatorState> navigatorKey;
  ProfileTabNavigator({this.tabItem, this.navigatorKey});

  Map<String, WidgetBuilder> _routeBuilders(context) {
    return {
      ProfileTabNavigatorRoutes.profile: (context) => UserProfileScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilder = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: ProfileTabNavigatorRoutes.profile,
      onGenerateRoute: (routeSetting){
        return MaterialPageRoute(builder: (context)=> routeBuilder[routeSetting.name](context),);
      },
    );
  }
}
