import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sports_private_pool/components/input_box.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_private_pool/screens/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_private_pool/screens/main_frame_app.dart';
import 'package:sports_private_pool/services/sport_data.dart';
import 'package:hive/hive.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore _firestore = Firestore.instance;

class RegisterScreen extends StatefulWidget {
  static const id = 'register_screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController firstNameTextController =  TextEditingController();
  final TextEditingController lastNameTextController =  TextEditingController();
  final TextEditingController usernameTextController =  TextEditingController();
  final TextEditingController emailTextController =  TextEditingController();
  final TextEditingController passwordTextController =  TextEditingController();
  final TextEditingController cpasswordTextController =  TextEditingController();

  bool _success;
  String message = '';

  Box<dynamic> userData;

  @override
  void initState() {
    userData = Hive.box('userData');
    super.initState();
  }

  void _register() async {
    String firstName = firstNameTextController.text;
    String lastName = lastNameTextController.text;
    String username = usernameTextController.text;
    String email = emailTextController.text;
    String password = passwordTextController.text;
    String cpassword = cpasswordTextController.text;

    if(!firstName.isEmpty && !lastName.isEmpty && !username.isEmpty && !email.isEmpty && !password.isEmpty && !cpassword.isEmpty ) {

      if(password == cpassword) {
        print('$email $password');
        try{
          final user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          print(user.toString());
          if( user != null) {

            await _firestore.collection('users').document(username).setData({
              'username' : username,
              'email' : email,
              'firstName' : firstName,
              'lastName' : lastName,
              'contestsCreated' : [],
              'contestsJoined' : [],
              'purse' : 100,
            });

            setState(() {
              _success = true;
              message = 'Successfully registered';
            }
            );
          }
          else {
            setState(() {
              _success = false;
              message = 'Registration failed';
            });
          }
        }
        on PlatformException catch(e) {
          print(e);
          setState(() {
            _success = false;
            message = 'Email is already in use';
          });
          print("Email is already in use");
        }
        catch(e) {
          print(e);
          setState(() {
            _success = false;
            message = 'Registration failed';
          });
        }
      }
      else {
        print("Passwords do not match");
      }
    }
    else {
      print("Fill all the details.");
    }
    print(_success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            height: 50.0,
            child: Image.asset('images/logo.png'),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: InputBox(
                  hintText: 'First Name',
                  textController: firstNameTextController,
                ),
              ),
              Expanded(
                  child: InputBox(
                hintText: 'Last Name',
                textController: lastNameTextController,
              )),
            ],
          ),
          InputBox(
            hintText: 'username',
            prefixIcon: Icon(Icons.perm_identity, color: Colors.black87),
            paddingTop: 10.0,
            textController: usernameTextController ,
          ),
          InputBox(
            hintText: 'email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email, color: Colors.black87),
            paddingTop: 10.0,
            textController: emailTextController,
          ),
          InputBox(
            hintText: 'password',
            prefixIcon: Icon(Icons.security, color: Colors.black87),
            paddingTop: 10.0,
            textController: passwordTextController,
            obscureText: true,
          ),
          InputBox(
            hintText: 'confirm password',
            prefixIcon: Icon(Icons.security, color: Colors.black87),
            paddingTop: 10.0,
            textController: cpasswordTextController,
            obscureText: true,
          ),
          RoundedButton(
            color: Colors.black54,
            text: 'Register',
            onpressed: () async{
              //register button is pressed
              await _register();
              if(_success) {
                try{
                  dynamic user = _auth.signInWithEmailAndPassword(email: emailTextController.text, password: passwordTextController.text);

                var loggedInUserData;
                var snapshots = await _firestore.collection('users').getDocuments();

                for (var user in snapshots.documents) {
                if (user.data.containsValue(emailTextController.text)) {
                  loggedInUserData = user.data;
                  userData.put('user', loggedInUserData);
                  break;
                }
                }

                Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MainFrameApp();
                }));
                  }
                catch(e) {
                  print(e);
                }
              }
            },
          ),
          Container(
            alignment: Alignment.center,
            child: Text(message),
          )
        ],
      ),
    );
  }
}
