import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/screens/join_contest_screen.dart';
import 'package:sports_private_pool/screens/user_specific_screens/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_private_pool/services/sport_data.dart';
import 'package:provider/provider.dart';
import 'package:sports_private_pool/models/user_data.dart';

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
  int index = 0;

  @override
  void initState() {
    super.initState();
    loggedInUserData = widget.loggedInUserData;
    upcomingMatchesList = widget.upcomingMatchesList;
    print(loggedInUserData);

  }

  void renderScreen(index) async {
    if (index == 0) {
      var sportData = SportData();
      dynamic returnResult = await sportData.getNextMatches('/matches', context);
      List<Widget> upcomingMatchesList = returnResult;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomePage(loggedInUserData, upcomingMatchesList);
      }));
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinContestScreen(
            loggedInUserData: loggedInUserData,
          ),
        ),
      );
    } else if (index == 2) {
      var userSnapshot = await _firestore
          .collection('users')
          .document(loggedInUserData['username'])
          .get();
      loggedInUserData = userSnapshot.data;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(
            loggedInUserData: loggedInUserData,
          ),
        ),
      );
    }
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: index,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.black87,
      onTap: (int x) {
        setState(() {
          index = x;
        });
        renderScreen(index);
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
            icon: Icon(Icons.person_pin), title: Text('Profile'))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserData>(
      create: (context) => UserData(loggedInUserData),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SimpleAppBar(
              appBarTitle: 'D A S H B O A R D',
            ),
            Expanded(
              child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  scrollDirection: Axis.vertical,
                  children: upcomingMatchesList),
            ),
          ],
        ),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }
}
