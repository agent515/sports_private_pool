import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_private_pool/components/match_card.dart';
import 'package:sports_private_pool/models/authentication.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:sports_private_pool/services/constants.dart';
import 'package:sports_private_pool/services/firebase.dart';
import 'package:sports_private_pool/wallet/wallet.dart';

FirebaseRepository _firebase = FirebaseRepository();

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen();

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late dynamic loggedInUserData;
  int index = 2;
  Box<dynamic>? userData;
  late Box<Person> userBox;
  Person? user;

  List<Widget>? createdContests;
  List<Widget>? joinedContests;

  List<Widget>? matchList = [];

  List<bool> isSelected = [true, false];

  @override
  void initState() {
    print('here in profile page');
    // userData = Hive.box<dynamic>('userData');
    userBox = Hive.box<Person>('user');
    // loggedInUserData = userData.get('userData');
    user = userBox.get('user');
    loggedInUserData = user!.toMap();
    _getUserDetails();
    super.initState();
  }

  Future<void> _getUserDetails() async {
    _firebase.getUserDetails().then(
      (user) {
        // userData.put('userData', user.toMap());
        userBox.put('user', user);
        // print("CONTEST CREATED" + user.contestsCreated.toString());
        setState(() {
          createdContests = getCreatedMatchTiles(user.contestsCreated!);
          joinedContests = getJoinedMatchTiles(user.contestsJoined!);
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
            clipBehavior: Clip.none,
            children: [
              ListView(),
              SingleChildScrollView(
                child: Container(
                  height: 0.4 * screenSize.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xff000046),
                        Color(0xff1CB5E0),
                      ],
                    ),
                  ),
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

                                Provider.of<Authentication>(context,
                                        listen: false)
                                    .logout();
                                print('signedOut');
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                    fontSize: 0.02 * screenSize.height,
                                    color: Colors.white),
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
                        Container(
                          height: 0.1 * screenSize.height,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 0.4 * screenSize.width,
                                child: Column(
                                  children: [
                                    Text(
                                      loggedInUserData['email'],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 0.02 * screenSize.height,
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
                              ),
                              Container(
                                width: 0.2 * screenSize.width,
                                child: Column(
                                  children: [
                                    Text(
                                      '₹ ' +
                                          loggedInUserData['purse']
                                              .toStringAsFixed(2),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 0.022 * screenSize.height,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 0.01 * screenSize.height,
                                    ),
                                    Container(
                                      height: 25,
                                      child: OutlinedButton(
                                        child: Text(
                                          'Wallet',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 0.02 * screenSize.height,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MyWallet(),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: 0.2 * screenSize.width,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 0.025 * screenSize.height,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          selectedColor: Colors.white,
                          fillColor: kDeepBlue,
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
