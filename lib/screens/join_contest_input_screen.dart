import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/services/firebase.dart';

enum matchResultEnum { team_1, draw, team_2 }

Firestore _firestore = Firestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseRepository _firebase = FirebaseRepository();

class JoinCMCInputScreen extends StatefulWidget {
  JoinCMCInputScreen(
      {this.loggedInUserData, this.contest, this.matchData, this.squadData});
  final loggedInUserData;
  final contest;
  final matchData;
  final squadData;

  @override
  _JoinCMCInputScreenState createState() => _JoinCMCInputScreenState();
}

class _JoinCMCInputScreenState extends State<JoinCMCInputScreen> {
  dynamic loggedInUserData;
  dynamic contest;
  dynamic matchData;
  dynamic squadData;
  matchResultEnum _matchResult;
  bool _show = false;

  String _message = 'Fill the contest entries..';

  int _currentStep = 0;
  String MVP;
  String mostRuns;
  String mostWickets;
  String matchResult;

  int index = 1;

  @override
  void initState() {
    super.initState();
    loggedInUserData = widget.loggedInUserData;
    contest = widget.contest;
    matchData = widget.matchData;
    squadData = widget.squadData;
    print(contest);
    print(matchData);
    print(squadData);
    matchResult = matchData['team-1'];
    _matchResult = matchResultEnum.team_1;
  }

  String getTeamNames(matchResultEnum value) {
    switch (value) {
      case matchResultEnum.team_1:
        return matchData['team-1'].toString();
      case matchResultEnum.team_2:
        return matchData['team-2'].toString();
      case matchResultEnum.draw:
        return 'Draw';
      default:
        return matchData['team-1'].toString();
    }
  }

  Future<void> joinContest() async {
    FirebaseUser loggedInUser = await _auth.currentUser();
    var loggedInUserData;
    var snapshots = await _firestore.collection('users').getDocuments();

    for (var user in snapshots.documents) {
      if (user.data.containsValue(loggedInUser.email)) {
        loggedInUserData = user.data;
        print(user.data);
        break;
      }
    }
    print("in");
    print(loggedInUser.email);
    print(loggedInUserData);

    var predictions = {
      'MVP': MVP,
      'mostRuns': mostRuns,
      'mostWickets': mostWickets,
      'matchResult': matchResult,
    };

    print(predictions);

    final TransactionHandler joinContestTransactionHandler =
        (Transaction tx) async {
      final contestSnapshot = await tx.get(_firestore
          .collection(
              'contests/cricketMatchContest/cricketMatchContestCollection')
          .document(contest['contestId']));
      List participants = contestSnapshot.data['participants'];
      Map<String, dynamic> contestPredictions =
          contestSnapshot.data['predictions'];

      if (participants.length == contestSnapshot.data['noOfParticipants']) {
        print("Contest is full");
        return {"status": "Contest is full"};
      }
      if (participants.contains(loggedInUserData['username'])) {
        print("Already entered the contest");
        return {"status": "Already entered the contest"};
      }
      participants.add(loggedInUserData['username']);
      contestPredictions['${loggedInUserData["username"]}'] = predictions;
      // Add this contest to the current user's joined contest list
      List userContestsJoined = loggedInUserData['contestsJoined'];
      var tempObj = {
        'contestId': contest['contestId'],
        'matchId': contest['matchId'],
        'admin': contest['admin'],
        'team1': matchData["team-1"],
        'team2': matchData["team-2"]
      };
      userContestsJoined.add(tempObj);

      // Contest Admin user data fetch
      var adminDataSnapshot = await tx
          .get(_firestore.collection('users').document(contest['admin']));
      var adminData = adminDataSnapshot.data;

      // Subtract entry fee from the current user's purse
      await tx.update(
          _firestore.collection('users').document(loggedInUserData['username']),
          {
            'purse': loggedInUserData['purse'] - contest['entryFee'],
            'contestsJoined': userContestsJoined,
          });

      // Add entry fee to the contest admin's purse
      await tx.update(_firestore.collection('users').document(contest['admin']),
          {'purse': adminData['purse'] + contest['entryFee']});

      // Update contest document with updated participants and predictions list
      await tx.update(
          _firestore
              .collection(
                  'contests/cricketMatchContest/cricketMatchContestCollection')
              .document(contest['contestId']),
          {'participants': participants, 'predictions': contestPredictions});
      // await tx.update(
      //     _firestore.collection('users').document(loggedInUserData['username']),
      //     {'contestsJoined': userContestsJoined});

      return {"status": "success"};
    };

    _firestore.runTransaction(joinContestTransactionHandler).then((result) {
      print(result["status"]);
      //* Skip sending notification if the contest creator joins the contest.
      // if (loggedInUserData["username"] != contest["admin"]) {
      _firebase.sendNotification({
        'title': 'Join Contest',
        'body':
            '${loggedInUserData["username"]} joined contest ${contest["contestId"]}',
        'receiverUsername': '${contest["admin"]}',
        'contestId': '${contest["contestId"]}',
        'matchId': '${contest["matchId"]}',
      }, NotificationEnum.userJoinsContest);
      // }
    }).catchError((e) {
      print(e);
    });
  }

  Widget _getTable(choice) {
    List<Widget> team1 = [];
    List<Widget> team2 = [];

    for (var player in squadData['squad'][0]['players']) {
      Widget playerWidget = GestureDetector(
        onTap: () {
          setState(() {
            if (choice == 'MVP') {
              MVP = player['pid'].toString();
            } else if (choice == 'mostRuns') {
              mostRuns = player['pid'].toString();
            } else if (choice == 'mostWickets') {
              mostWickets = player['pid'].toString();
            }
          });
        },
        child: Container(
          height: 25.0,
          margin: EdgeInsets.symmetric(vertical: 2.5),
          decoration: BoxDecoration(
            color: choice == 'MVP'
                ? (MVP == player['pid'].toString()
                    ? Colors.black54
                    : Colors.white)
                : (choice == 'mostRuns'
                    ? (mostRuns == player['pid'].toString()
                        ? Colors.black54
                        : Colors.white)
                    : (mostWickets == player['pid'].toString()
                        ? Colors.black54
                        : Colors.white)),
            border: Border.all(
              color: Colors.black26,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3.0,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
          child: Row(
            children: <Widget>[
              Text(
                player['name'].toString(),
                style: TextStyle(
                    color: choice == 'MVP'
                        ? (MVP == player['pid'].toString()
                            ? Colors.white
                            : Colors.black54)
                        : (choice == 'mostRuns'
                            ? (mostRuns == player['pid'].toString()
                                ? Colors.white
                                : Colors.black54)
                            : (mostWickets == player['pid'].toString()
                                ? Colors.white
                                : Colors.black54)),
                    fontSize: 13.0),
              )
            ],
          ),
        ),
      );

      team1.add(playerWidget);
    }

    for (var player in squadData['squad'][1]['players']) {
      Widget playerWidget = GestureDetector(
        onTap: () {
          setState(() {
            if (choice == 'MVP') {
              MVP = player['pid'].toString();
            } else if (choice == 'mostRuns') {
              mostRuns = player['pid'].toString();
            } else if (choice == 'mostWickets') {
              mostWickets = player['pid'].toString();
            }
          });
        },
        child: Container(
          height: 25.0,
          margin: EdgeInsets.symmetric(vertical: 2.5),
          decoration: BoxDecoration(
            color: choice == 'MVP'
                ? (MVP == player['pid'].toString()
                    ? Colors.black54
                    : Colors.white)
                : (choice == 'mostRuns'
                    ? (mostRuns == player['pid'].toString()
                        ? Colors.black54
                        : Colors.white)
                    : (mostWickets == player['pid'].toString()
                        ? Colors.black54
                        : Colors.white)),
            border: Border.all(
              color: Colors.black26,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3.0,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
          child: Row(
            children: <Widget>[
              Text(
                player['name'].toString(),
                style: TextStyle(
                    color: choice == 'MVP'
                        ? (MVP == player['pid'].toString()
                            ? Colors.white
                            : Colors.black54)
                        : (choice == 'mostRuns'
                            ? (mostRuns == player['pid'].toString()
                                ? Colors.white
                                : Colors.black54)
                            : (mostWickets == player['pid'].toString()
                                ? Colors.white
                                : Colors.black54)),
                    fontSize: 13.0),
              )
            ],
          ),
        ),
      );

      team2.add(playerWidget);
    }

    return Container(
      height: 200.0,
      child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: team1,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: team2,
              ),
            )
          ],
        ),
      ]),
    );
  }

  List<Step> _getSteps() {
    List<Step> _step = [
      Step(
        title: Text('Choose MVP'),
        content: _getTable('MVP'),
        isActive: this._currentStep >= 0,
      ),
      Step(
        title: Text('Choose Most Runs'),
        content: _getTable('mostRuns'),
        isActive: this._currentStep >= 1,
      ),
      Step(
        title: Text('Choose Most Wickets'),
        content: _getTable('mostWickets'),
        isActive: this._currentStep >= 2,
      ),
      Step(
        title: Text('Choose Match Result'),
        content: Column(
          children: <Widget>[
            ListTile(
              title: Text(matchData['team-1'].toString()),
              leading: Radio(
                value: matchResultEnum.team_1,
                groupValue: _matchResult,
                onChanged: (value) {
                  String actualResult = getTeamNames(value);
                  setState(() {
                    _matchResult = value;
                    matchResult = actualResult;
                  });
                  print(matchResult);
                },
              ),
            ),
            ListTile(
              title: Text(matchData['team-2'].toString()),
              leading: Radio(
                value: matchResultEnum.team_2,
                groupValue: _matchResult,
                onChanged: (value) {
                  String actualResult = getTeamNames(value);
                  setState(() {
                    _matchResult = value;
                    matchResult = actualResult;
                  });
                  print(matchResult);
                },
              ),
            ),
            ListTile(
              title: Text('Draw'),
              leading: Radio(
                value: matchResultEnum.draw,
                groupValue: _matchResult,
                onChanged: (value) {
                  String actualResult = getTeamNames(value);
                  setState(() {
                    _matchResult = value;
                    matchResult = actualResult;
                  });
                  print(matchResult);
                },
              ),
            ),
          ],
        ),
        isActive: this._currentStep >= 2,
      ),
    ];
    return _step;
  }

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (_show) {
      Timer(
          Duration(milliseconds: 500),
          () => _controller.animateTo(
                _controller.position.maxScrollExtent,
                duration: Duration(seconds: 500),
                curve: Curves.fastOutSlowIn,
              ));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SimpleAppBar(
            appBarTitle: 'C O N T E S T',
          ),
          Expanded(
            child: ListView(
              controller: _controller,
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(),
              children: [
                Theme(
                  data: ThemeData(
                      primaryColor: Colors.black87,
                      accentColor: Colors.black54),
                  child: Stepper(
                    physics: ClampingScrollPhysics(),
                    steps: _getSteps(),
                    currentStep: this._currentStep,
                    onStepTapped: (index) {
                      if (index <= this._currentStep) {
                        setState(() {
                          this._currentStep = index;
                        });
                      }
                    },
                    onStepContinue: () {
                      if (this._currentStep == 0 && MVP == null) {
                        return;
                      }
                      if (this._currentStep == 1 && mostRuns == null) {
                        return;
                      }
                      if (this._currentStep == 2 && mostWickets == null) {
                        return;
                      }
                      if (this._currentStep < _getSteps().length - 1) {
                        setState(() {
                          this._currentStep += 1;
                        });
                      } else {
                        //complete
                        print('$MVP, $mostRuns, $mostWickets, $matchResult');
                        setState(() {
                          _show = true;
                          print(_show);
                          _message = (contest['entryFee'] <
                                  loggedInUserData['purse'])
                              ? ""
                              : "You don't have enough money in the purse to enter the contest..";
                        });
                      }
                    },
                    onStepCancel: () {
                      if (this._currentStep > 0) {
                        setState(() {
                          this._currentStep -= 1;
                        });
                      }
                    },
                  ),
                ),
                _show
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 0.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Contest created by ',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '${contest["admin"]}',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ]),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Contest entry fee:',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${contest['entryFee']}',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Contest winning prize:',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${contest['prizeMoney']}',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'No. of participants:',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '${contest['noOfParticipants']}',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ]),
                            RoundedButton(
                              color: Colors.black87,
                              text: 'Join',
                              onpressed: (contest['entryFee'] <
                                      loggedInUserData['purse'])
                                  ? () async {
                                      await joinContest();
                                      Navigator.pop(context);
                                    }
                                  : null,
                            )
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 20.0,
                        child: Text(
                          '$_message',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w400),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
