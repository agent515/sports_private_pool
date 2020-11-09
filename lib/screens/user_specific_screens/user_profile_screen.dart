import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/screens/user_specific_screens/my_created_contests_screen.dart';
import 'package:hive/hive.dart';
import 'package:sports_private_pool/services/firebase.dart';
import 'package:sports_private_pool/models/person.dart';

Firestore _firestore = Firestore.instance;

class UserProfileScreen extends StatefulWidget {

  UserProfileScreen();

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  dynamic loggedInUserData;
  int index = 2;
  Box<dynamic> userData;
  Box<Person> userBox;
  Firebase _firebase = Firebase();
  Person user;

  @override
  void initState() {
    super.initState();
    userData = Hive.box<dynamic>('userData');
    userBox = Hive.box<Person>('user');
    loggedInUserData = userData.get('userData');
    user = userBox.get('user');
    _getUserDetails();

  }

  Future<void> _getUserDetails() async {
    user = await _firebase.getUserDetails();
    userData.put('userData', user.toMap());
    userBox.put('user', user);
    setState(() {
      loggedInUserData = user.toMap();
      user = user;
    });
  }
  
  Future<List<Map>> getContestsList(type) async {

    var contests = loggedInUserData['contests${type}'];
    print(loggedInUserData['contests${type}']);
//    print(contests);
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
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: <Widget>[
            SimpleAppBar(appBarTitle: 'P R O F I L E',),
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
                          // DB read
                          /*
                          var userSnapshot = await _firestore.collection('users').document(loggedInUserData['username']).get();
                          loggedInUserData = userSnapshot.data;
                          */

                          // HIVE READ but also ensure updated Hive Box

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

                          // DB READ
                          /*
                          var userSnapshot = await _firestore.collection('users').document(loggedInUserData['username']).get();
                          loggedInUserData = userSnapshot.data;
                          */

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
    );
  }
}
