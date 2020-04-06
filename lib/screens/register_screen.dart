import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/input_box.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_private_pool/screens/home_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

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
  String _userEmail;

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

          if( user != null) {
            setState(() {
              _success = true;
            }
            );
          }
          else {
            setState(() {
              _success = false;
            });
          }
        }
        catch(e) {
          print(e);
          setState(() {
            _success = false;
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
            onpressed: () {
              //register button is pressed
              _register();
              if(_success) {
                try{
                  dynamic user = _auth.signInWithEmailAndPassword(email: emailTextController.text, password: passwordTextController.text);

                  if(user != null) {
                    Navigator.pushNamed(context, HomePage.id);
                  }
                }
                catch(e) {
                  print(e);
                }
              }
            },
          ),
          Container(
            alignment: Alignment.center,
            child: Text(_success == null
                ? ''
                : (_success
                ? 'Successfully registered '
                : 'Registration failed')),
          )
        ],
      ),
    );
  }
}
