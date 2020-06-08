import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_private_pool/screens/join_contest_input_screen.dart';
import 'package:sports_private_pool/services/sport_data.dart';
import 'package:sports_private_pool/screens/user_specific_screens/user_profile_screen.dart';
import 'package:sports_private_pool/screens/home_page.dart';

final _firestore = Firestore.instance;

class JoinContestScreen extends StatefulWidget {
  static const id = 'join_contest_screen';

  JoinContestScreen({this.loggedInUserData});

  final loggedInUserData;

  @override
  _JoinContestScreenState createState() => _JoinContestScreenState();
}

class _JoinContestScreenState extends State<JoinContestScreen> {
  final TextEditingController codeTextController = TextEditingController();
  dynamic loggedInUserData;
  String message = '';
  int index = 1;

  @override
  void initState() {
    super.initState();
    loggedInUserData = widget.loggedInUserData;
  }

  void renderScreen(index) async {
    if (index == 0) {
      var sportData = SportData();
      dynamic returnResult = await sportData.getNextMatches('/matches', context);
      List<Widget> upcomingMatchesList = returnResult;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomePage(loggedInUserData, upcomingMatchesList);
      }));
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SimpleAppBar(
            appBarTitle: 'J O I N   C O N T E S T',
          ),
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
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5.0,
                      onPressed: () async {
                        var joinCode = codeTextController.text;
                        if (joinCode.length == 11) {
                          var type = joinCode.substring(0, 3);

                          if (type == 'CMC') {
                            try {
                              var docSnap = await _firestore
                                  .collection(
                                      'contests/joinCodes/joinCodesCollection')
                                  .document(joinCode)
                                  .get();
                              String contestId = docSnap.data['contestId'];
                              print(docSnap.data);
                              print(contestId);

                              var userSnapshot = await _firestore.collection('users').document(loggedInUserData['username']).get();
                              loggedInUserData = userSnapshot.data;

                              print('${loggedInUserData['contestsJoined'].contains(contestId)}');
                              if(loggedInUserData['contestsJoined'].contains(contestId)){
                                setState(() {
                                  message = "You've already entered the contest";
                                });
                              }
                              else{
                                var contestSnap = await _firestore
                                    .collection(
                                    'contests/cricketMatchContest/cricketMatchContestCollection')
                                    .document(contestId)
                                    .get();
                                var contest = contestSnap.data;

                                SportData sportData = SportData();
                                var matchData = await sportData
                                    .getMatchData(contest['matchId']);

                                var squadData =
                                await sportData.getSquads(contest['matchId']);

                                if(matchData == null){
                                  setState(() {
                                    message = 'The contest has already ended';
                                  });
                                }
                                else{
                                  message = "";
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => JoinCMCInputScreen(
                                            loggedInUserData: widget.loggedInUserData,
                                            contest: contest,
                                            matchData: matchData,
                                            squadData: squadData,
                                          )));
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
                      color: Colors.grey,
                      child: Text('Join',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w300)),
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
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }
}
