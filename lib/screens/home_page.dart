import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/screens/join_contest_screen.dart';
import 'package:sports_private_pool/screens/user_specific_screens/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Firestore _firestore = Firestore.instance;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
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
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: RaisedButton(
                  elevation: 5.0,
                  child: Text(
                    'Profile',
                  ),
                  onPressed: () async {
                    //join contest with join code

                    var userSnapshot = await _firestore.collection('users').document(loggedInUserData['username']).get();
                    loggedInUserData = userSnapshot.data;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          loggedInUserData: loggedInUserData,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
