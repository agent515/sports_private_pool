import 'package:flutter/material.dart';
import 'package:sports_private_pool/models/push_notification.dart';
import 'package:sports_private_pool/services/constants.dart';
import 'package:sports_private_pool/services/navigation/home_tab_naviagator.dart';
import 'package:sports_private_pool/services/navigation/join_tab_navigator.dart';
import 'package:sports_private_pool/services/navigation/profile_tab_navigator.dart';

const double ICON_SIZE = 20.0;
const Color SELECTED_COLOR = Colors.white;
const Color UNSELECTED_COLOR = Colors.grey;

class MainFrameApp extends StatefulWidget {
  MainFrameApp({this.defaultPage = 0, this.joinCode});

  final int defaultPage;
  final String joinCode;

  @override
  _MainFrameAppState createState() => _MainFrameAppState();
}

class _MainFrameAppState extends State<MainFrameApp> {
  int index;
  bool close;
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

  Widget _buildBottomAppBarButton(
      {int index_, String label, String imagePath}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 60, minHeight: 60),
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              elevation: MaterialStateProperty.all<double>(0.0)),
          onPressed: () {
            setState(() {
              index = index_;
              currentTab = TabItem.values[index];
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ImageIcon(
                AssetImage(imagePath),
                color: index == index_ ? SELECTED_COLOR : UNSELECTED_COLOR,
              ),
              Text(
                label,
                style: TextStyle(
                    color: index == index_ ? SELECTED_COLOR : UNSELECTED_COLOR),
              ),
              SizedBox(
                height: 8.0,
              )
            ],
          )),
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
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Container(
            height: 70,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  height: 60,
                  color: Colors.black87,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBottomAppBarButton(
                        index_: 0,
                        label: 'Home',
                        imagePath: 'images/icons/icons8-home.png'),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 70, minHeight: 70),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(5.0),
                            shape: MaterialStateProperty.all<CircleBorder>(
                              CircleBorder(
                                side: BorderSide(color: Colors.grey),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.grey)),
                        child: ImageIcon(
                          AssetImage('images/icons/icons8-plus.png'),
                          size: ICON_SIZE + 10,
                          color: SELECTED_COLOR,
                        ),
                        onPressed: () {
                          setState(() {
                            index = 1;
                            currentTab = TabItem.values[index];
                          });
                        },
                      ),
                    ),
                    _buildBottomAppBarButton(
                        index_: 2,
                        label: 'Profile',
                        imagePath: 'images/icons/icons8-user.png'),
                  ],
                ),
              ],
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
