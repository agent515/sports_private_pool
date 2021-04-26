import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:sports_private_pool/screens/join_contest_input_screen.dart';
import 'package:sports_private_pool/services/firebase.dart';

final FirebaseRepository _firebase = FirebaseRepository();

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

  @override
  void initState() {
    super.initState();
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
                            final response =
                                await _firebase.joinContest(joinCode);

                            if (response["message"] ==
                                "You've already entered the contest.") {
                              setState(() {
                                message = response["message"];
                              });
                            } else if (response["message"] ==
                                "You've already entered the contest.") {
                              setState(() {
                                message = response["message"];
                              });
                            } else if (response["message"] == "") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JoinCMCInputScreen(
                                    loggedInUserData: response['userData'],
                                    contest: response['contest'],
                                    matchData: response['matchData'],
                                    squadData: response['squadData'],
                                  ),
                                ),
                              );
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
