import 'package:flutter/material.dart';
import 'package:sports_private_pool/screens/home_page.dart';
import 'package:sports_private_pool/screens/more.dart';
import 'package:sports_private_pool/screens/feed.dart';
import 'package:sports_private_pool/screens/my_matches.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {

  static FirebaseUser loggedInUser;
  static List<Widget> upcomingMatchesList;

  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(loggedInUser, upcomingMatchesList),
    MyMatches(),
    MyFeed(),
    MoreSettings(),
  ];

  void onTappedBar(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: _children[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(

          onTap: onTappedBar,
          currentIndex: _currentIndex,

        items: [ BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: kBottomBarIconColor,
          ),
          title: Text(
            'HOME',
            style: kBottomBarTitleColor,
            )
          ),
          BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: kBottomBarIconColor
            ),
          title: Text(
            'MY MATCHES',
            style: kBottomBarTitleColor,
          )
          ),
          BottomNavigationBarItem(
          icon: Icon(
            Icons.message,
            color: kBottomBarIconColor
            ),
          title: Text(
            'FEED',
            style: kBottomBarTitleColor,
            )
          ),
          BottomNavigationBarItem(
          icon: Icon(
            Icons.more_horiz,
            color: kBottomBarIconColor,
            ),
          title: Text(
            'MORE',
            style: kBottomBarTitleColor,
            )
          )
      ],
      ),
    );
  }
}