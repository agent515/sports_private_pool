import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_private_pool/components/custom_loader.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/models/authentication.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:sports_private_pool/screens/forgot_password.dart';
import 'package:sports_private_pool/screens/register_screen.dart';
import 'package:sports_private_pool/services/firebase.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class LoginScreen extends StatefulWidget {
  static const id = "login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email;
  String? password;
  List<Widget>? upcomingMatchesList;
  Person? currentUser;
  bool _isLoading = false;

  late SharedPreferences _preferences;

  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();

  FirebaseRepository _firebase = FirebaseRepository();

  late Box<dynamic> userData;
  late Box<Person?> userBox;

  late FocusNode emailNode;
  late FocusNode passwordNode;

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

  Future<void> _signinHelper(context, User user) async {
    try {
      var loggedInUserData;
      var snapshot =
          await _firestore.collection('email-username').doc(user.email).get();
      var temp = snapshot.data()!['username'];
      var _user = await _firestore.collection('users').doc(temp).get();

      loggedInUserData = _user.data;
      currentUser = Person.fromMap(loggedInUserData);

      userData.put('userData', loggedInUserData);
      userBox.put('user', currentUser);

      _preferences = await SharedPreferences.getInstance();
      await _preferences.setString('email', email.toString());

      print("EMAIL: ${_preferences.getString('email')}");

      Provider.of<Authentication>(context, listen: false).login(currentUser);

      Navigator.pop(context);
    } catch (e, stack) {
      print(e);
      print(stack);
      throw Exception();
    }
  }

  Widget _buildBody() {
    return Builder(
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
                ),
              ),
              SizedBox(
                height: 60.0,
              ),
              TextField(
                controller: emailTextController,
                keyboardType: TextInputType.emailAddress,
                decoration: kTextInputFieldDecoration.copyWith(
                  prefixIcon: Icon(
                    Icons.perm_identity,
                    color: Theme.of(context).primaryColor,
                  ),
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
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Theme.of(context).primaryColor,
                  ),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()));
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
              ),
              RoundedButton(
                color: Theme.of(context).primaryColor,
                text: 'SIGN IN',
                onpressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  print(emailTextController.text);
                  print(passwordTextController.text);
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: emailTextController.text,
                        password: passwordTextController.text);

                    if (user != null) {
                      print("success");
                      await _signinHelper(context, user.user!);
                      passwordTextController.clear();
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  } catch (e, stack) {
                    print(e);
                    print(stack);
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
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
                    'OR',
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
                color: Theme.of(context).accentColor,
                text: 'SIGN IN WITH GOOGLE',
                onpressed: () async {
                  try {
                    setState(() {
                      _isLoading = true;
                    });

                    final user = await _firebase.signInWithGoogle();

                    if (user != null) {
                      print("success");

                      await _signinHelper(context, user);
                      passwordTextController.clear();
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  } catch (e) {
                    print(e);
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
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
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()));
                    },
                    child: Text(
                      ' Sign up.',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBody(),
          if (_isLoading) CustomLoader(message: 'Logging in.. Please wait..'),
        ],
      ),
    );
  }

  @override
  void dispose() {
//    Hive.close();

    //Dispose focus node
    emailNode.dispose();
    passwordNode.dispose();

    emailTextController.dispose();
    passwordTextController.dispose();

    super.dispose();
  }
}
