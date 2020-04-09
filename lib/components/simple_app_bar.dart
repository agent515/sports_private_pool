import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_private_pool/screens/login_screen.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class SimpleAppBar extends StatelessWidget {
  SimpleAppBar({this.appBarTitle});
  final String appBarTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        height : 50.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 3.0, top: 3.0, right: 3.0, left: 5.0),
              height: 40.0,
              child: Image(
                image: AssetImage('images/logo.png'),
              ),
            ),
            Text(
              appBarTitle,
              style: TextStyle(
                color: Colors.black54,
                letterSpacing: 1.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: GestureDetector(
                onTap: () {
                  print('signing out..');
                  _auth.signOut();
                  Navigator.popUntil(context, ModalRoute.withName(LoginScreen.id));
                  print('signedOut');
                },
                child: Icon(
                  Icons.person,
                ),
              ),
            )
          ],
        )
    );
  }
}