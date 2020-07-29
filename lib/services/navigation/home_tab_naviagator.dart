import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/custom_progress_indicator.dart';
import 'package:sports_private_pool/screens/home_page.dart';
import 'package:sports_private_pool/services/constants.dart';
import 'package:sports_private_pool/services/sport_data.dart';

class HomeTabNavigatorRoutes {
  static const home = '/';
//  static const mathchDetails = 'matchDetails';
}


class HomeTabNavigator extends StatelessWidget {
  final TabItem tabItem;
  final GlobalKey<NavigatorState> navigatorKey;

  HomeTabNavigator({this.tabItem, this.navigatorKey});

  Map<String, WidgetBuilder> _routeBuilder(context, upcomingMatchesData) {
    return {
      HomeTabNavigatorRoutes.home : (context) => HomePage(upcomingMatchesData),
//      HomeTabNavigatorRoutes.mathchDetails : (context) => MatchDetails(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SportData().getUpcomingMatchesData('/matches'),
      builder: (context, snapshot) {
        Map<String, WidgetBuilder> routeBuilder = _routeBuilder(context, snapshot.data);

        if (snapshot.connectionState == ConnectionState.done) {
          return Navigator(
            key: navigatorKey,
            initialRoute: HomeTabNavigatorRoutes.home,
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (context) => routeBuilder[routeSettings.name](context)
              );
            },
          );
        }
        else {
          return CustomProgressIndicator();
        }
      }
    );
  }
}
