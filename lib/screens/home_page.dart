import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';


const apiKey = 'itfCIjkbOnb4vW31al0l79I7p992';
const baseUrl = 'https://cricapi.com/api';

FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  static const id = 'home_page';

  HomePage(this.loggedInUser, this.upcomingMatchesList);

  FirebaseUser loggedInUser;
  List<Widget> upcomingMatchesList;

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  List<Widget> upcomingMatchesList;
  FirebaseUser loggedInUser;



  @override
  void initState()
  {
    super.initState();
    loggedInUser = widget.loggedInUser;
    upcomingMatchesList = widget.upcomingMatchesList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SimpleAppBar(appBarTitle: 'D A S H B O A R D',),
//          Container(
//            margin: EdgeInsets.only(bottom: 10.0),
//            child: RaisedButton(
//              elevation: 5.0,
//              child: Text(
//                  'Get next matches',
//              ),
//              onPressed: () async {
//                //Get next match fixtures from the API
//                dynamic returnResult = await getNextMatches('/matches');
//                setState((){
//                  upcomingMatchesList = returnResult;
//                });
//
//              },
//            ),
//          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              scrollDirection: Axis.vertical,
              children: upcomingMatchesList
            ),
          ),
        ],
      ),
    );
  }
}


