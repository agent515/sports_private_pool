import 'package:flutter/material.dart';
import 'file:///C:/Users/kokat/AndroidStudioProjects/sports_private_pool/lib/services/navigation/home_tab_naviagator.dart';
import 'file:///C:/Users/kokat/AndroidStudioProjects/sports_private_pool/lib/services/navigation/join_tab_navigator.dart';
import 'file:///C:/Users/kokat/AndroidStudioProjects/sports_private_pool/lib/services/navigation/profile_tab_navigator.dart';
import 'package:sports_private_pool/services/constants.dart';


class MainFrameApp extends StatefulWidget {
  @override
  _MainFrameAppState createState() => _MainFrameAppState();
}


class _MainFrameAppState extends State<MainFrameApp> {

  int index = 0;
  TabItem currentTab = TabItem.home;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.home : GlobalKey<NavigatorState>(),
    TabItem.join : GlobalKey<NavigatorState>(),
    TabItem.profile : GlobalKey<NavigatorState>()
  };


  Widget _bottomNavigationBar() {
      return BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black87,
        onTap: (int x) {
          setState(() {
            index = x;
            currentTab = TabItem.values[index];
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            title: Text('Join'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin),
              title: Text('Profile'))
        ],
      );
    }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => !await navigatorKeys[currentTab].currentState.maybePop(),

      child: Scaffold(
        body: Stack(
          children: <Widget>[
            _buildOffstageNavigator(TabItem.home),
            _buildOffstageNavigator(TabItem.join),
            _buildOffstageNavigator(TabItem.profile)
          ],
        ),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }


  Widget _buildOffstageNavigator(TabItem tabItem) {
    if (tabItem == TabItem.join) {
      return Offstage(
        offstage: tabItem != currentTab,
        child: JoinTabNavigator(
          navigatorKey: navigatorKeys[tabItem],
          tabItem: tabItem,
        ),
      );
    }
    else if (tabItem == TabItem.profile) {
      return Offstage(
        offstage: tabItem != currentTab,
        child: ProfileTabNavigator(
          navigatorKey: navigatorKeys[tabItem],
          tabItem: tabItem,
        ),
      );
    }
    else {
      return Offstage(
        offstage: tabItem != currentTab,
        child: HomeTabNavigator(
          navigatorKey: navigatorKeys[tabItem],
          tabItem: tabItem,
        ),
      );
    }
  }

}
