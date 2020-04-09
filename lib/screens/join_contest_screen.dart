import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_private_pool/screens/join_contest_input_screen.dart';
import 'package:sports_private_pool/services/sport_data.dart';

final _firestore = Firestore.instance;

class JoinContestScreen extends StatelessWidget {
  static const id = 'join_contest_screen';

  JoinContestScreen({this.loggedInUserData});

  final loggedInUserData;

  final TextEditingController codeTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => JoinCMCInputScreen(
                                            loggedInUserData: loggedInUserData,
                                            contest: contest,
                                            matchData: matchData,
                                            squadData: squadData,
                                          )));
                            } catch (e) {
                              print(e);
                            }
                          }
                        } else {
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
                ],
              ))
        ],
      ),
    );
  }
}
