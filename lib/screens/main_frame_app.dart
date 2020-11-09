import 'package:flutter/material.dart';
import 'package:sports_private_pool/services/constants.dart';
import 'package:sports_private_pool/services/navigation/home_tab_naviagator.dart';
import 'package:sports_private_pool/services/navigation/join_tab_navigator.dart';
import 'package:sports_private_pool/services/navigation/profile_tab_navigator.dart';

class MainFrameApp extends StatefulWidget {
  @override
  _MainFrameAppState createState() => _MainFrameAppState();
}

class _MainFrameAppState extends State<MainFrameApp> {
  int index = 0;
  bool close;
  TabItem currentTab = TabItem.home;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.join: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>()
  };

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: index,
      iconSize: 20.0,
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
          icon: ImageIcon(
              AssetImage('images/icons/icons8-home.png')
          ),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
              AssetImage('images/icons/icons8-plus.png')
          ),
          title: Text('Join'),
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('images/icons/icons8-user.png')
          ),
          title: Text('Profile'))
      ],
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Envision'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to exit?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  close = true;
                });
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  close = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!await navigatorKeys[currentTab].currentState.maybePop()) {
          await _showMyDialog();
          print(close);
          return close;
        }
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            _buildOffstageNavigator(TabItem.home),
            _buildOffstageNavigator(TabItem.join),
            _buildOffstageNavigator(TabItem.profile),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          splashColor: Colors.black87,
          child: ImageIcon(
              AssetImage('images/icons/icons8-plus.png')
          ),
          onPressed: () {
            setState(() {
              index = 1;
              currentTab = TabItem.values[index];
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
    } else if (tabItem == TabItem.profile) {
      return Offstage(
        offstage: tabItem != currentTab,
        child: ProfileTabNavigator(
          navigatorKey: navigatorKeys[tabItem],
          tabItem: tabItem,
        ),
      );
    } else {
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
