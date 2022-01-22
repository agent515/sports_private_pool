import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/custom_loader.dart';
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
  String? message = '';
  int index = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _utilSetState(String? responseMessage) {
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
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 2.0),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.black87),
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                height: 40,
                width: 80,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).accentColor),
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
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              Container(
                child: Text(
                  message!,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            _buildBody(),
            if (isLoading) CustomLoader(message: 'Joining.. Please wait..'),
          ],
        ),
      ),
    );
  }
}
