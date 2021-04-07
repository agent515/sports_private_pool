import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:sports_private_pool/screens/user_specific_screens/my_contest_details_screen.dart';
import 'package:sports_private_pool/screens/welcome_screen.dart';
import 'package:sports_private_pool/services/firebase.dart';
import 'package:sports_private_pool/services/sport_data.dart';

Firestore _firestore = Firestore.instance;
Firebase _firebase = Firebase();

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
  Person user;

  List<Widget> createdContests;
  List<Widget> joinedContests;

  List<Widget> matchList = [];

  SharedPreferences _preferences;

  List<bool> isSelected = [true, false];

  @override
  void initState() {
    print('here in profile page');
    userData = Hive.box<dynamic>('userData');
    userBox = Hive.box<Person>('user');
    loggedInUserData = userData.get('userData');
    user = userBox.get('user');
    _getUserDetails();
    super.initState();
  }

  Future<void> _getUserDetails() async {
    await _firebase.getUserDetails().then(
      (user) {
        userData.put('userData', user.toMap());
        userBox.put('user', user);
        // print("CONTEST CREATED" + user.contestsCreated.toString());
        setState(() {
          createdContests = getCreatedMatchTiles(user.contestsCreated);
          joinedContests = getJoinedMatchTiles(user.contestsJoined);
          matchList = isSelected[0] ? createdContests : joinedContests;
          loggedInUserData = user.toMap();
          user = user;
        });
      },
    );
  }

  getCreatedMatchTiles(List<dynamic> contestsCreated) {
    List<Widget> tiles = [];
    Size screenSize = MediaQuery.of(context).size;
//    print(contestsCreated);
    for (var match in contestsCreated) {
//      print(match);
      tiles.add(MatchCard(
        screenSize: screenSize,
        contestMeta: match,
        type: 'Created',
      ));
    }

    return tiles;
  }

  getJoinedMatchTiles(List<dynamic> contestsJoined) {
    List<Widget> tiles = [];
    Size screenSize = MediaQuery.of(context).size;

    for (var match in contestsJoined) {
      print(match);
      tiles.add(
        MatchCard(
          screenSize: screenSize,
          contestMeta: match,
          type: 'Joined',
        ),
      );
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            await _getUserDetails();
          },
          child: Stack(
            overflow: Overflow.visible,
            children: [
              ListView(),
              SingleChildScrollView(
                child: Container(
                  height: 0.4 * screenSize.height,
                  color: Colors.blue[600],
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 0.02 * screenSize.height),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                print('signing out..');
                                await _firebase.signOut();
                                await SharedPreferences.getInstance()
                                    .then((prefs) => prefs.remove('email'));
//                                 Navigator.of(context).pushAndRemoveUntil(
//                                   MaterialPageRoute(
//                                     builder: (context) => WelcomeScreen(),
//                                   ),
//                                   (Route<dynamic> route) => false,
//                                 );
                                Navigator.popUntil(context,
                                    ModalRoute.withName('WelcomeScreen'));
                                print('signedOut');
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 0.02 * screenSize.height,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              height: 0.11 * screenSize.height,
                              width: 0.22 * screenSize.width,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: AssetImage('images/profile.png'),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 0.05 * screenSize.width,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loggedInUserData['firstName'] +
                                      " " +
                                      loggedInUserData['lastName'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 0.04 * screenSize.height,
                                  ),
                                ),
                                SizedBox(
                                  height: 0.01 * screenSize.height,
                                ),
                                Text(
                                  "@" + loggedInUserData['username'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 0.02 * screenSize.height,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 0.05 * screenSize.height,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  loggedInUserData['email'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 0.022 * screenSize.height,
                                  ),
                                ),
                                SizedBox(
                                  height: 0.01 * screenSize.height,
                                ),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 0.02 * screenSize.height,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '₹ ' + loggedInUserData['purse'].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 0.022 * screenSize.height,
                                  ),
                                ),
                                SizedBox(
                                  height: 0.01 * screenSize.height,
                                ),
                                Text(
                                  'Wallet',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 0.02 * screenSize.height,
                                  ),
                                )
                              ],
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 0.025 * screenSize.height,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.35 * screenSize.height),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 0.02 * screenSize.height),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ToggleButtons(
                          children: <Widget>[
                            Text(
                              'My Contests',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Joined Contests',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          constraints: BoxConstraints(
                            minWidth: 0.47 * screenSize.width,
                            minHeight: 0.06 * screenSize.height,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                          isSelected: isSelected,
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < isSelected.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  isSelected[buttonIndex] = true;
                                } else {
                                  isSelected[buttonIndex] = false;
                                }
                              }
                              if (index == 0) {
                                matchList = createdContests;
                              } else {
                                matchList = joinedContests;
                              }
                            });
                          },
                        ),
                        SizedBox(
                          height: 0.01 * screenSize.height,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 0.47 * screenSize.width,
                                minHeight: 0.43 * screenSize.height,
                              ),
                              child: ListView(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                children: matchList ??
                                    [
                                      Center(
                                          child: Text('No contests to show.'))
                                    ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  const MatchCard(
      {Key key,
      @required this.screenSize,
      @required this.contestMeta,
      @required this.type})
      : super(key: key);

  final Size screenSize;
  final dynamic contestMeta;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () async {
          var contest =
              await _firebase.getContestDetails(contestMeta['contestId']);
          SportData sportData = SportData();
          var matchScore = await sportData.getScore(contest['matchId']);
          // print(squadData);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MyCreatedContestDetailsScreen(
                  contest: contest,
                  type: type,
                  matchScore: matchScore,
                );
              },
            ),
          );
        },
        child: Container(
          height: 0.15 * screenSize.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black26,
              width: 1.0,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('images/vs.png'),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            child: Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Flex(
                          direction: Axis.vertical,
                          children: [
                            for (var word in contestMeta['team1'].split(" "))
                              Text(
                                word,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Flex(
                          direction: Axis.vertical,
                          children: [
                            for (var word in contestMeta['team2'].split(" "))
                              Text(
                                word,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      contestMeta['contestId'],
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                          fontSize: 12.0,
                          color: Colors.white),
                    ),
                    Text(
                      contestMeta['admin'],
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                          fontSize: 12.0,
                          color: Colors.white),
                    )
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

// Column(
// children: <Widget>[
// // SimpleAppBar(
// //   appBarTitle: 'P R O F I L E',
// // ),
// Expanded(
// child: ListView(
// scrollDirection: Axis.vertical,
// children: <Widget>[
// ListTile(
// leading: Text(
// 'First Name',
// style: kUserProfileInfoTextStyle,
// ),
// title: Text(loggedInUserData['firstName']),
// ),
// ListTile(
// leading: Text(
// 'Last Name',
// style: kUserProfileInfoTextStyle,
// ),
// title: Text(loggedInUserData['lastName']),
// ),
// ListTile(
// leading: Text(
// 'username',
// style: kUserProfileInfoTextStyle,
// ),
// title: Text(loggedInUserData['username']),
// ),
// ListTile(
// leading: Text(
// 'Email',
// style: kUserProfileInfoTextStyle,
// ),
// title: Text(loggedInUserData['email']),
// ),
// ListTile(
// leading: Text(
// 'Wallet',
// style: kUserProfileInfoTextStyle,
// ),
// title: Text(loggedInUserData['purse'].toString()),
// ),
// Padding(
// padding: EdgeInsets.only(
// left: 20.0, top: 10.0, bottom: 10.0, right: 200),
// child: Material(
// elevation: 5.0,
// color: Colors.grey,
// borderRadius: BorderRadius.circular(10.0),
// child: MaterialButton(
// child: Text('My Contests'),
// onPressed: () async {
// print("my contests");
// // DB read
// /*
//                             var userSnapshot = await _firestore.collection('users').document(loggedInUserData['username']).get();
//                             loggedInUserData = userSnapshot.data;
//                             */
//
// // HIVE READ but also ensure updated Hive Box
//
// var contests_list = await getContestsList('Created');
//
// Navigator.push(context,
// MaterialPageRoute(builder: (context) {
// return MyCreatedContestsScreen(
// loggedInUserData: loggedInUserData,
// contests_list: contests_list,
// type: 'Created',
// );
// }));
// },
// ),
// ),
// ),
// Padding(
// padding: EdgeInsets.only(
// left: 20.0, top: 10.0, bottom: 10.0, right: 200),
// child: Material(
// elevation: 5.0,
// color: Colors.grey,
// borderRadius: BorderRadius.circular(10.0),
// child: MaterialButton(
// child: Text('Joined Contests'),
// onPressed: () async {
// print("joined my contests");
//
// // DB READ
// /*
//                             var userSnapshot = await _firestore.collection('users').document(loggedInUserData['username']).get();
//                             loggedInUserData = userSnapshot.data;
//                             */
//
// var contests_list = await getContestsList('Joined');
//
// Navigator.push(context,
// MaterialPageRoute(builder: (context) {
// return MyCreatedContestsScreen(
// loggedInUserData: loggedInUserData,
// contests_list: contests_list,
// type: 'Joined',
// );
// }));
// },
// ),
// ),
// ),
// ],
// ))
// ],
// ),
