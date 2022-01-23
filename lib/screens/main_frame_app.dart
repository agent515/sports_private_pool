import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sports_private_pool/models/push_notification.dart';
import 'package:sports_private_pool/screens/user_specific_screens/my_contest_details_screen.dart';
import 'package:sports_private_pool/services/constants.dart';
import 'package:sports_private_pool/services/navigation/home_tab_naviagator.dart';
import 'package:sports_private_pool/services/navigation/join_tab_navigator.dart';
import 'package:sports_private_pool/services/navigation/profile_tab_navigator.dart';

const double ICON_SIZE = 20.0;
const Color SELECTED_COLOR = Colors.white;
const Color UNSELECTED_COLOR = Colors.grey;

class MainFrameApp extends StatefulWidget {
  MainFrameApp(
      {this.defaultPage = 0, this.joinCode, this.contestId, this.matchId});

  final int defaultPage;
  final String? joinCode;
  final String? contestId;
  final String? matchId;

  @override
  _MainFrameAppState createState() => _MainFrameAppState();
}

class _MainFrameAppState extends State<MainFrameApp> {
  int? index;
  bool? close;
  TabItem currentTab = TabItem.home;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.join: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>()
  };

  @override
  void initState() {
    super.initState();
    index = widget.defaultPage;
    PushNotification _pushNotification = PushNotification();
    _pushNotification.initializeFCM();
    if (index == 2) {
      navigatorKeys[TabItem.profile]!.currentState!.push(
            MaterialPageRoute(
              builder: (context) => MyCreatedContestDetailsScreen(
                type: 'Created',
                contestId: widget.contestId,
                matchId: widget.matchId,
              ),
            ),
          );
    }
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
        if (!await navigatorKeys[currentTab]!.currentState!.maybePop()) {
          await _showMyDialog();
          print(close);
          return close!;
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: Duration(milliseconds: 400),
                tabBackgroundColor: kNeonBlue.withOpacity(0.7),
                color: Colors.black,
                tabs: [
                  GButton(
                    icon: LineIcons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: LineIcons.plusCircle,
                    text: 'Join',
                  ),
                  GButton(
                    icon: LineIcons.user,
                    text: 'Profile',
                  ),
                ],
                selectedIndex: index!,
                onTabChange: (i) {
                  setState(() {
                    index = i;
                    currentTab = TabItem.values[index!];
                  });
                },
              ),
            ),
          ),
        ),
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
