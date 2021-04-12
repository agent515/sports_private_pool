import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/components/contest_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_private_pool/components/custom_tool_tip.dart';

import 'package:random_string/random_string.dart';
import 'package:sports_private_pool/services/firebase.dart';
import 'package:sports_private_pool/models/person.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
Firestore _firestore = Firestore.instance;
Firebase _firebase = Firebase();

class CricketMatchContestScreen extends StatefulWidget {
  CricketMatchContestScreen({this.matchData, this.squadData});

  dynamic matchData;
  dynamic squadData;

  @override
  _CricketMatchContestScreenState createState() =>
      _CricketMatchContestScreenState();
}

class _CricketMatchContestScreenState extends State<CricketMatchContestScreen> {
  dynamic matchData;
  dynamic squadData;
  String joinCode;
  bool _success;
  bool _error;
  String _errorMessage = '';

  TextEditingController prizeMoneyTextController = TextEditingController();
  TextEditingController entryFeeTextController = TextEditingController();
  TextEditingController noOfParticipantsTextController =
      TextEditingController();

  Future<void> createContestTransaction() async {
    var loggedInUserData;
    try {
      Person loggedInUser = await _firebase.getUserDetails();
      loggedInUserData = loggedInUser.toMap();

      final double prizeMoneyValue =
          double.parse(prizeMoneyTextController.text);
      final double entryFeeValue = double.parse(entryFeeTextController.text);
      final int noOfParticipants =
          int.parse(noOfParticipantsTextController.text);

      if (prizeMoneyValue < 0 || entryFeeValue < 0 || noOfParticipants < 2) {
        setState(() {
          _error = true;
          _errorMessage =
              'Monetary values cannot be negative and no. of participants should be at least 2';
        });
        return;
      } else if (prizeMoneyValue > loggedInUserData['purse']) {
        setState(() {
          _error = true;
          _errorMessage =
              'Prize money value cannot be greater than the value in your purse! ';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessage = 'The input values are invalid..';
      });
    }

    final type = 'CMC';

    // Unique join code check
    bool duplicate = true;

    while (duplicate) {
      joinCode = type + randomAlphaNumeric(8);
      DocumentSnapshot joinCodeSnapshot = await _firestore
          .collection('contest/joinCodes/joinCodesCollection/')
          .document(joinCode)
          .get();
      if (!joinCodeSnapshot.exists) duplicate = false;
    }

    final int matchId = matchData['unique_id'];

    final TransactionHandler createContestTransaction = (Transaction tx) async {
      final countSnapshot = await tx.get(_firestore
          .collection('contests/cricketMatchContest/noOfContests')
          .document('noOfContests'));
      int count = countSnapshot.data['count'];

      count++;
      String countStr;

      if (count % 10 == count) {
        countStr = "0000000" + count.toString();
      } else if (count % 100 == count) {
        countStr = "000000" + count.toString();
      } else if (count % 1000 == count) {
        countStr = "00000" + count.toString();
      } else if (count % 10000 == count) {
        countStr = "0000" + count.toString();
      } else if (count % 100000 == count) {
        countStr = "000" + count.toString();
      } else if (count % 1000000 == count) {
        countStr = "00" + count.toString();
      } else if (count % 10000000 == count) {
        countStr = "0" + count.toString();
      } else {
        countStr = count.toString();
      }

      final contestId = type + countStr;

      Map<String, dynamic> contest = {
        'admin': loggedInUserData['username'],
        'type': type,
        'contestId': type + countStr,
        'matchId': matchId,
        'match': '${matchData['team-1']} Vs ${matchData['team-2']}',
        'joinCode': joinCode,
        'prizeMoney': double.parse(prizeMoneyTextController.text),
        'entryFee': double.parse(entryFeeTextController.text),
        'noOfParticipants': double.parse(noOfParticipantsTextController.text),
        'participants': [],
        'predictions': {},
        'result': {}
      };

      List<dynamic> contestsCreated = loggedInUserData['contestsCreated'];

      await tx.set(
          _firestore
              .collection(
                  'contests/cricketMatchContest/cricketMatchContestCollection')
              .document(contestId),
          contest);
      await tx.update(
          _firestore
              .collection('contests/cricketMatchContest/noOfContests')
              .document('noOfContests'),
          {'count': FieldValue.increment(1)});
      await tx.set(
          _firestore
              .collection('contests/joinCodes/joinCodesCollection')
              .document(joinCode),
          {'contestId': contestId, 'createdAt': FieldValue.serverTimestamp()});
      await tx.update(
          _firestore.collection('users').document(loggedInUserData['username']),
          {'purse': loggedInUserData['purse'] - contest['prizeMoney']});
      var tempObj = {
        'contestId': contestId,
        'admin': loggedInUserData['username'],
        'team1': matchData['team-1'],
        'team2': matchData['team-2']
      };
      contestsCreated.add(tempObj);
      await tx.update(
          _firestore.collection('users').document(loggedInUserData['username']),
          {'contestsCreated': contestsCreated});
      return contest;
    };

    _firestore.runTransaction(createContestTransaction).then((contest) {
      print(
          "Contest created successfully.. Here is the code to join the contest: ${contest['joinCode']}");
      setState(() {
        _success = true;
        _error = null;
        _errorMessage = '';
      });
    }).catchError((e) {
      print(e);
      _success = false;
      _error = true;
      _errorMessage = e.toString();
    });
  }

  @override
  void initState() {
    matchData = widget.matchData;
    squadData = widget.squadData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SimpleAppBar(appBarTitle: 'C O N T E S T'),
            Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Text(
                  '${matchData['team-1']}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'vs',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${matchData['team-2']}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Create a contest by entering the prize money, entry fee and maximum participants',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            ContestInputField(
              hintText: 'Rs. 10',
              labelText: 'Prize money',
              rightMargin: 200.0,
              textEditingController: prizeMoneyTextController,
            ),
            ContestInputField(
              hintText: 'Rs. 10',
              labelText: 'Entry fee',
              rightMargin: 200.0,
              textEditingController: entryFeeTextController,
            ),
            ContestInputField(
              hintText: 'max 100',
              labelText: 'No. of participants',
              rightMargin: 200.0,
              textEditingController: noOfParticipantsTextController,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              child: RoundedButton(
                color: Colors.black54,
                text: 'Create',
                onpressed: () async {
                  //Create contest and make the sharable invitation link
                  await createContestTransaction();
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  _error == true
                      ? Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.purple,
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    child: _success == null
                        ? Text('')
                        : (_success
                            ? Column(children: <Widget>[
                                Text(
                                    'Contest created.. Here is the the code to join the contest: '),
                                GestureDetector(
                                  child: CustomToolTip(text: joinCode),
                                  onTap: () {},
                                )
                              ])
                            : Text('Registration failed')),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
