import 'package:flutter/material.dart';

class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  SimpleAppBar({this.appBarTitle});
  final String appBarTitle;

  @override
  Size get preferredSize {
    return Size.fromHeight(50.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      height: 50.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Center(
        child: Stack(
          children: [
            Center(
              child: Text(
                appBarTitle,
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 3.0,
              left: 15.0,
              child: Image(
                height: 40.0,
                image: AssetImage('images/logo.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Row(
// mainAxisAlignment: MainAxisAlignment.start,
// crossAxisAlignment: CrossAxisAlignment.center,
// children: <Widget>[
// Container(
// padding: EdgeInsets.only(left: 15.0),
// height: 40.0,
// child: Image(
// image: AssetImage('images/logo.png'),
// ),
// ),
// Spacer(),
// Text(
// appBarTitle,
// style: TextStyle(
// color: Colors.black54,
// letterSpacing: 1.5,
// fontWeight: FontWeight.bold,
// ),
// ),
// Spacer(),
// // Padding(
// //   padding: EdgeInsets.only(right: 5.0),
// //   child: GestureDetector(
// //     onTap: () async {
// //       print('signing out..');
// //       await _firebase.signOut();
// //       _preferences = await SharedPreferences.getInstance();
// //       _preferences.remove('email');
// //       Navigator.popUntil(
// //           context, ModalRoute.withName('WelcomeScreen'));
// //       print('signedOut');
// //     },
// //     child: Icon(
// //       Icons.exit_to_app,
// //     ),
// //   ),
// // )
// ],
// ),
