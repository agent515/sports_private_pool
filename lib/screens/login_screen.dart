import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_private_pool/screens/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_private_pool/screens/main_frame_app.dart';
import 'package:sports_private_pool/services/sport_data.dart';

final _auth = FirebaseAuth.instance;
final _firestore = Firestore.instance;

class LoginScreen extends StatefulWidget {
  static const id = "login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  List<Widget> upcomingMatchesList;


  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();

  Box<dynamic> userData;

  @override
  void initState() {
    userData = Hive.box('userData');
    print("User Data: $userData");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Builder(

        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: <Widget>[
                Container(
                    height: 100.0,
                    child: Image.asset('images/logo.png')
                ),
                SizedBox(
                  width: 250.0,
                  child: ColorizeAnimatedTextKit(
                      speed: Duration(milliseconds: 300),
                      onTap: () {
                        print("Tap Event");
                      },
                      text: [
                        'E N V I S I O N',
                      ],
                      textStyle: TextStyle(
                          fontSize: 18.0,
                          fontFamily: "Horizon",
                          letterSpacing: 3.0
                      ),
                      colors: [
                        Colors.black87,
                        Colors.grey,
                        Colors.white,
                      ],
                      textAlign: TextAlign.center,
                      alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: TextField(
                    controller: emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    decoration: kTextInputFieldDecoration,
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                ),
                TextField(
                  controller: passwordTextController,
                  obscureText: true,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration: kTextInputFieldDecoration.copyWith(
                      hintText: "enter password"
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                RoundedButton(
                  color: Colors.black87,
                  text: 'Login',
                  onpressed: () async {
                    print(emailTextController.text);
                    print(passwordTextController.text);
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: emailTextController.text,
                          password: passwordTextController.text);
                      print("in");
                      if (user != null) {
                        print("success");
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Login Successful"),
                        ),);

                        var loggedInUserData;
                        var snapshots = await _firestore.collection('users').getDocuments();

                        for (var user in snapshots.documents) {
                          if (user.data.containsValue(email)) {
                            loggedInUserData = user.data;
                            userData.put('user', loggedInUserData);
                            break;
                          }
                        }

//                    var sportData = SportData();
//                    dynamic returnResult = await sportData.getNextMatches('/matches', context);
//                    upcomingMatchesList = returnResult;
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return MainFrameApp();
                        }));
                        passwordTextController.clear();
                      }
                    }
                    catch(e) {
                      print(e);
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Login Unsucessful"),
                      ),);
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        //TODO: Forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                            fontSize: 15.0
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
  @override
  void dispose() {
//    Hive.close();
    super.dispose();
  }
}
