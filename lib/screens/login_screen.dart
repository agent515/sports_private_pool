import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/screens/forgot_password.dart';
import 'package:sports_private_pool/screens/main_frame_app.dart';
import 'package:sports_private_pool/screens/register_screen.dart';
import 'package:sports_private_pool/services/firebase.dart';
import 'package:sports_private_pool/models/person.dart';

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
  Person currentUser;

  SharedPreferences _preferences;

  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();

  Firebase _firebase = Firebase();

  Box<dynamic> userData;
  Box<Person> userBox;

  FocusNode emailNode;
  FocusNode passwordNode;

  @override
  void initState() {
    userData = Hive.box('userData');
    userBox = Hive.box('user');
    print("User Data: $userData");

    //Used to initialize the focus nodes
    emailNode = FocusNode();
    passwordNode = FocusNode();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Builder(
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'HERO',
                  child: Container(
                    height: 100.0,
                    child: Image.asset('images/logo.png'),
                  ),
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
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.bold,
                      ),
                      colors: [
                        Colors.black87,
                        Colors.grey,
                        Colors.white,
                      ],
                      textAlign: TextAlign.center,
                      alignment:
                          AlignmentDirectional.topStart // or Alignment.topLeft
                      ),
                ),
                SizedBox(
                  height: 60.0,
                ),
                TextField(
                  controller: emailTextController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: kTextInputFieldDecoration.copyWith(
                    prefixIcon: Icon(Icons.perm_identity),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 60.0,
                    ),
                  ),
                  onChanged: (value) {
                    email = value;
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: passwordTextController,
                  obscureText: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: kTextInputFieldDecoration.copyWith(
                    hintText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 60.0,
                    ),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        //forgot password is pressed
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPasswordPage()));
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ),
                ),
                RoundedButton(
                  color: Colors.lightBlue,
                  text: 'SIGN IN',
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
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Login Successful"),
                          ),
                        );

                        var loggedInUserData;
                        var snapshot =
                        await _firestore.collection('email-username').document(user.user.email).get();
                        var temp = snapshot.data['username'];
                        var _user = await _firestore.collection('users').document(temp).get();

                        loggedInUserData = _user.data;
                        currentUser = Person.fromMap(loggedInUserData);

                        userData.put('userData', loggedInUserData);
                        userBox.put('user', currentUser);

                        _preferences = await SharedPreferences.getInstance();
                        await _preferences.setString('email', email.toString());

                        print("EMAIL: ${_preferences.getString('email')}");

                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return MainFrameApp();
                        }));
                        passwordTextController.clear();
                      }
                    } catch (e, stack) {
                      print(e);
                      print(stack);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Login Unsuccessful"),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.7,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'OR LOGIN WITH',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.7,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                RoundedButton(
                  color: Colors.deepOrangeAccent,
                  text: 'SIGN IN WITH GOOGLE',
                  onpressed: () async {
                    try {
                      final user = await _firebase.signInWithGoogle();

                      print("in");
                      if (user != null) {
                        print("success");

                        DocumentSnapshot documentRef = await _firestore.collection("users").document(user.email).get();

                        if (!documentRef.exists) {

                          await _firestore.collection("email-username").document(user.email).setData({
                            'username' : user.email,
                          });
                          await _firestore.collection("users").document(user.email).setData(
                              {
                                'firstName' : user.displayName.split(' ')[0],
                                'lastName' : user.displayName.split(' ')[1],
                                'purse' : 100,
                                'username' : user.email,
                                'email' : user.email,
                                'contestsCreated' : [],
                                'contestsJoined' : [],
                              }
                          );
                        }

                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Login Successful"),
                          ),
                        );

                        var loggedInUserData;
                        var snapshot =
                        await _firestore.collection('email-username').document(user.email).get();
                        var temp = snapshot.data['username'];
                        var _user = await _firestore.collection('users').document(temp).get();

                        loggedInUserData = _user.data;
                        print("data: ${loggedInUserData}");
                        await userData.put('user', loggedInUserData);

                        currentUser = Person.fromMap(loggedInUserData);

                        userData.put('userData', loggedInUserData);
                        userBox.put('user', currentUser);

                        _preferences = await SharedPreferences.getInstance();
                        await _preferences.setString('email', email.toString());
                        print("EMAIL: ${_preferences.getString('email')}");

                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                              return MainFrameApp();
                            }));
                        passwordTextController.clear();
                      }
                    } catch (e) {
                      print(e);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Login Unsuccessful"),
                        ),
                      );
                    }

                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        //Sign up is pressed
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RegisterScreen()));
                      },
                      child: Text(
                        'Sign up.',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

    //Dispose focus node
    emailNode.dispose();
    passwordNode.dispose();

    super.dispose();
  }
}
