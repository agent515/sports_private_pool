import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _utilSetState(String responseMessage) {
    setState(() {
      message = responseMessage;
      isLoading = false;
    });
  }

  Widget _buildBody() {
    return Column(
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
                    setState(() {
                      isLoading = true;
                    });
                    final joinCode = codeTextController.text;
                    if (joinCode.length == 11) {
                      final response = await _firebase.joinContest(joinCode);
                      print("response: $response");

                      if (response["message"] ==
                          "You've already entered the contest.") {
                        _utilSetState(response["message"]);
                      } else if (response["message"] ==
                          "You've already entered the contest.") {
                        _utilSetState(response["message"]);
                      } else if (response["message"] ==
                          "The contest has already ended.") {
                        _utilSetState(response["message"]);
                      } else if (response["message"] == "") {
                        _utilSetState(response["message"]);
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
                      _utilSetState("The code is of invalid length");
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
          ),
        )
      ],
    );
  }

  Widget _buildLoader() {
    return SizedBox.expand(
      child: Container(
        color: Colors.black87.withOpacity(0.2),
        child: Center(
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Joining.. Please wait..',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            _buildBody(),
            if (isLoading) _buildLoader(),
          ],
        ),
      ),
    );
  }
}
