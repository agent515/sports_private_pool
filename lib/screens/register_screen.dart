import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:sports_private_pool/models/authentication.dart';
import 'package:sports_private_pool/services/firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:sports_private_pool/components/input_box.dart';
import 'package:sports_private_pool/components/rounded_button.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore _firestore = Firestore.instance;
Firebase _firebase = Firebase();

class RegisterScreen extends StatefulWidget {
  static const id = 'register_screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController cpasswordTextController = TextEditingController();

  bool _success;
  String message = '';

  FocusNode fNameNode;
  FocusNode lNameNode;
  FocusNode userNameNode;
  FocusNode emailNode;
  FocusNode passwordNode;
  FocusNode cpasswordNode;

  Person currentUser;
  Box<dynamic> userData;
  SharedPreferences _preferences;

  @override
  void initState() {
    userData = Hive.box('userData');

    //Initialize the focusNodes
    fNameNode = FocusNode();
    lNameNode = FocusNode();
    userNameNode = FocusNode();
    emailNode = FocusNode();
    passwordNode = FocusNode();
    cpasswordNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    //Dispose after done as they are expensive
    fNameNode.dispose();
    lNameNode.dispose();
    userNameNode.dispose();
    emailNode.dispose();
    passwordNode.dispose();
    cpasswordNode.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    String firstName = firstNameTextController.text;
    String lastName = lastNameTextController.text;
    String username = usernameTextController.text;
    String email = emailTextController.text;
    String password = passwordTextController.text;
    String cpassword = cpasswordTextController.text;

    if (firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        username.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        cpassword.isNotEmpty) {
      if (password == cpassword) {
        print('$email $password');
        try {
          final user = await _auth.createUserWithEmailAndPassword(
              email: email, password: password);
          print(user.toString());
          if (user != null) {
            await _firestore
                .collection("email-username")
                .document(user.user.email)
                .setData({
              'username': username,
            });

            await _firestore.collection('users').document(username).setData({
              'username': username,
              'email': email,
              'firstName': firstName,
              'lastName': lastName,
              'contestsCreated': [],
              'contestsJoined': [],
              'purse': 100.0,
            });

            setState(() {
              _success = true;
              message = 'Successfully registered';
            });
          } else {
            setState(() {
              _success = false;
              message = 'Registration failed';
            });
          }
        } on PlatformException catch (e) {
          print(e);
          setState(() {
            _success = false;
            message = 'Email is already in use';
          });
          print("Email is already in use");
        } catch (e) {
          print(e);
          setState(() {
            _success = false;
            message = 'Registration failed';
          });
        }
      } else {
        print("Passwords do not match");
      }
    } else {
      print("Fill all the details.");
    }
    print(_success);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: EdgeInsets.only(
              left: 25.0,
              right: 25.0,
              top: 30.0,
              bottom: bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'HERO',
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        height: 50.0,
                        child: Image.asset('images/logo.png'),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Text(
                      'Create New Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InputBox(
                        hintText: 'First Name',
                        textController: firstNameTextController,
                        fNode: fNameNode,
                        onComplete: () => lNameNode.requestFocus(),
                      ),
                    ),
                    Expanded(
                      child: InputBox(
                        hintText: 'Last Name',
                        textController: lastNameTextController,
                        fNode: lNameNode,
                        onComplete: () => userNameNode.requestFocus(),
                      ),
                    ),
                  ],
                ),
                InputBox(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.perm_identity),
                  paddingTop: 10.0,
                  textController: usernameTextController,
                  fNode: userNameNode,
                  onComplete: () => emailNode.requestFocus(),
                ),
                InputBox(
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email),
                  paddingTop: 10.0,
                  textController: emailTextController,
                  fNode: emailNode,
                  onComplete: () => passwordNode.requestFocus(),
                ),
                InputBox(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.security),
                  paddingTop: 10.0,
                  textController: passwordTextController,
                  obscureText: true,
                  fNode: passwordNode,
                  onComplete: () => cpasswordNode.requestFocus(),
                ),
                InputBox(
                  hintText: 'Re-enter Password',
                  prefixIcon: Icon(Icons.security),
                  paddingTop: 10.0,
                  textController: cpasswordTextController,
                  obscureText: true,
                  fNode: cpasswordNode,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: RoundedButton(
                    color: Colors.lightBlue,
                    text: 'Register',
                    onpressed: () async {
                      //register button is pressed
                      await _register();
                      if (_success) {
                        try {
                          var loggedInUserData;
                          var snapshot = await _firestore
                              .collection('email-username')
                              .document(emailTextController.text)
                              .get();
                          var temp = snapshot.data['username'];
                          var _user = await _firestore
                              .collection('users')
                              .document(temp)
                              .get();

                          loggedInUserData = _user.data;
                          print("data: ${loggedInUserData}");
                          await userData.put('user', loggedInUserData);

                          currentUser = Person.fromMap(loggedInUserData);

                          userData.put('userData', loggedInUserData);
                          userData.put('user', currentUser);

                          _preferences = await SharedPreferences.getInstance();
                          _preferences.setString(
                              'email', emailTextController.text);

                          Provider.of<Authentication>(context, listen: false)
                              .login(currentUser);

                          Navigator.pop(context);
                        } catch (e, stack) {
                          print(e);
                          print(stack);
                        }
                      }
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(message),
                ),
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
                      'OR REGISTER WITH',
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
                    text: 'Sign Up With Google',
                    onpressed: () async {
                      try {
                        final user = await _firebase.signInWithGoogle();

                        print("in");
                        if (user != null) {
                          print("success");

                          DocumentSnapshot documentRef = await _firestore
                              .collection("users")
                              .document(user.email)
                              .get();

                          if (!documentRef.exists) {
                            await _firestore
                                .collection("email-username")
                                .document(user.email)
                                .setData({
                              'username': user.email,
                            });
                            await _firestore
                                .collection("users")
                                .document(user.email)
                                .setData({
                              'firstName': user.displayName.split(' ')[0],
                              'lastName': user.displayName.split(' ')[1],
                              'purse': 100,
                              'username': user.email,
                              'email': user.email,
                              'contestsCreated': [],
                              'contestsJoined': [],
                            });
                          }

                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Login Successful"),
                            ),
                          );

                          var loggedInUserData;
                          var snapshot = await _firestore
                              .collection('email-username')
                              .document(user.email)
                              .get();
                          var temp = snapshot.data['username'];
                          var _user = await _firestore
                              .collection('users')
                              .document(temp)
                              .get();

                          loggedInUserData = _user.data;
                          print("data: ${loggedInUserData}");
                          await userData.put('user', loggedInUserData);

                          currentUser = Person.fromMap(loggedInUserData);

                          userData.put('userData', loggedInUserData);
                          userData.put('user', currentUser);

                          _preferences = await SharedPreferences.getInstance();
                          _preferences.setString(
                              'email', emailTextController.text);

                          Provider.of<Authentication>(context, listen: false)
                              .login(currentUser);

                          Navigator.pop(context);
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
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
