import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:sports_private_pool/screens/join_contest_input_screen.dart';
import 'package:sports_private_pool/services/sport_data.dart';

final _firestore = Firestore.instance;

class JoinContestScreen extends StatefulWidget {
  static const id = 'join_contest_screen';

  JoinContestScreen();

  @override
  _JoinContestScreenState createState() => _JoinContestScreenState();
}

class _JoinContestScreenState extends State<JoinContestScreen> {
  final TextEditingController codeTextController = TextEditingController();
  dynamic loggedInUserData;
  String message = '';
  int index = 1;
  Box<dynamic> userData;
  Box<Person> userBox;
  Person currentUser;

  @override
  void initState() {
    super.initState();
    userData = Hive.box<dynamic>('userData');
    userBox = Hive.box<Person>('user');
    loggedInUserData = userData.get('userData');
    currentUser = userBox.get('user');
    print("Current User: ${currentUser.firstName} ${currentUser.lastName}");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            SimpleAppBar(appBarTitle: 'J O I N   C O N T E S T'),
            Container(
                margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 2.0),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextField(
                        controller: codeTextController,
                        decoration: InputDecoration(
                          hintText: 'E n t e r   c o d e',
                          hintStyle: TextStyle(
                            color: Colors.black26,
                          ),
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.grey),
                        ),
                        onPressed: () async {
                          final joinCode = codeTextController.text;
                          if (joinCode.length == 11) {
                            final type = joinCode.substring(0, 3);
                            if (type == 'CMC') {
                              try {
                                final docSnap = await _firestore
                                    .collection(
                                        'contests/joinCodes/joinCodesCollection')
                                    .document(joinCode)
                                    .get();
                                print(docSnap.data);
                                print(docSnap.data['contestId']);
                                String contestId = docSnap.data['contestId'];

                                print("ContestID: $contestId");

                                final userSnapshot = await _firestore
                                    .collection('users')
                                    .document(loggedInUserData['username'])
                                    .get();
                                loggedInUserData = userSnapshot.data;

                                print(
                                    '${loggedInUserData['contestsJoined'].contains(contestId)}');
                                if (loggedInUserData['contestsJoined']
                                    .contains(contestId)) {
                                  setState(() {
                                    message =
                                        "You've already entered the contest";
                                  });
                                } else {
                                  final contestSnap = await _firestore
                                      .collection(
                                          'contests/cricketMatchContest/cricketMatchContestCollection')
                                      .document(contestId)
                                      .get();
                                  final contest = contestSnap.data;

                                  SportData sportData = SportData();
                                  final matchData = await sportData
                                      .getMatchData(contest['matchId']);

                                  final squadData = await sportData
                                      .getSquads(contest['matchId']);

                                  if (matchData == null) {
                                    setState(() {
                                      message = 'The contest has already ended';
                                    });
                                  } else {
                                    setState(() {
                                      message = "";
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JoinCMCInputScreen(
                                          loggedInUserData: loggedInUserData,
                                          contest: contest,
                                          matchData: matchData,
                                          squadData: squadData,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                print(e);
                              }
                            }
                          } else {
                            setState(() {
                              message = "The code is of invalid length";
                            });
                            print("The code is of invalid length");
                          }
                        },
                        child: Text(
                          'Join',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        message,
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
