import 'package:flutter/material.dart';

class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  SimpleAppBar({this.appBarTitle});
  final String? appBarTitle;

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
          color: Theme.of(context).accentColor,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Center(
        child: Stack(
          children: [
            Center(
              child: Text(
                appBarTitle!,
                style: TextStyle(
                  color: Colors.black,
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
