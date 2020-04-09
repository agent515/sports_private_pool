import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/screens/join_contest_screen.dart';

class HomePage extends StatefulWidget {
  static const id = 'home_page';

  HomePage(this.loggedInUserData, this.upcomingMatchesList);

  final loggedInUserData;
  List<Widget> upcomingMatchesList;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> upcomingMatchesList;
  dynamic loggedInUserData;

  @override
  void initState() {
    super.initState();
    loggedInUserData = widget.loggedInUserData;
    upcomingMatchesList = widget.upcomingMatchesList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SimpleAppBar(
            appBarTitle: 'D A S H B O A R D',
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            child: RaisedButton(
              elevation: 5.0,
              child: Text(
                'Join Contest',
              ),
              onPressed: () {
                //join contest with join code
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinContestScreen(
                      loggedInUserData: loggedInUserData,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                scrollDirection: Axis.vertical,
                children: upcomingMatchesList),
          ),
        ],
      ),
    );
  }
}
