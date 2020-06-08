import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/screens/user_specific_screens/my_created_contests_screen.dart';
import 'package:sports_private_pool/screens/join_contest_screen.dart';

import 'package:sports_private_pool/services/sport_data.dart';
import 'package:sports_private_pool/screens/home_page.dart';

Firestore _firestore = Firestore.instance;

class UserProfileScreen extends StatefulWidget {

  UserProfileScreen({this.loggedInUserData});

  final loggedInUserData;
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  dynamic loggedInUserData;
  int index = 2;

  @override
  void initState() {
    super.initState();
    loggedInUserData = widget.loggedInUserData;
  }
  
  Future<List<Map>> getContestsList(type) async {

    var contests = loggedInUserData['contests${type}'];
    print(loggedInUserData['contests${type}']);
    print(contests);
    List<Map> contests_list = [];
    
    for(var contest_id in contests){
      if(contest_id.substring(0, 3) == 'CMC'){
        
        var contestSnapshot = await _firestore.collection('contests/cricketMatchContest/cricketMatchContestCollection').document(contest_id).get();
        var contest = contestSnapshot.data;
        contests_list.add(contest);
      }
    }
    
    return contests_list;
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SimpleAppBar(
            appBarTitle: 'U S E R   P R O F I L E',
          ),
          Expanded(
            child : ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                ListTile(
                  leading: Text('First Name', style: kUserProfileInfoTextStyle,),
                  title: Text(loggedInUserData['firstName']),
                ),
                ListTile(
                  leading: Text('Last Name', style: kUserProfileInfoTextStyle,),
                  title: Text(loggedInUserData['lastName']),
                ),
                ListTile(
                  leading: Text('username', style: kUserProfileInfoTextStyle,),
                  title: Text(loggedInUserData['username']),
                ),
                ListTile(
                  leading: Text('Email', style: kUserProfileInfoTextStyle,),
                  title: Text(loggedInUserData['email']),
                ),
                ListTile(
                  leading: Text('Wallet', style: kUserProfileInfoTextStyle,),
                  title: Text(loggedInUserData['purse'].toString()),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 10.0,  bottom: 10.0, right: 200),
                  child: Material(
                    elevation: 5.0,
                    color:  Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                    child: MaterialButton(
                      child: Text('My Contests'),
                      onPressed: () async {
                        print("my contests");

                        var userSnapshot = await _firestore.collection('users').document(loggedInUserData['username']).get();
                        loggedInUserData = userSnapshot.data;

                        var contests_list = await getContestsList('Created');

                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return MyCreatedContestsScreen(loggedInUserData: loggedInUserData, contests_list: contests_list, type: 'Created',);
                        }));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 10.0,  bottom: 10.0, right: 200),
                  child: Material(
                    elevation: 5.0,
                    color:  Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                    child: MaterialButton(
                      child: Text('Joined Contests'),
                      onPressed: ()async{
                        print("joined my contests");

                        var userSnapshot = await _firestore.collection('users').document(loggedInUserData['username']).get();
                        loggedInUserData = userSnapshot.data;

                        var contests_list = await getContestsList('Joined');

                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return MyCreatedContestsScreen(loggedInUserData: loggedInUserData, contests_list: contests_list, type: 'Joined',);
                        }));
                      },
                    ),
                  ),
                ),
              ],
            )
          )
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }
}
