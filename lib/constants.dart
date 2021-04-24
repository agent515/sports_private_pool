import 'package:flutter/material.dart';

const kTextInputFieldDecoration = InputDecoration(
    hintText: 'Username',
    hintStyle: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
    ),
    fillColor: Color.fromRGBO(240, 240, 240, 1),
    filled: true,
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
    ));

const kUserProfileInfoTextStyle =
    TextStyle(fontSize: 18.0, color: Colors.black54);

enum NotificationEnum {
  userJoinsContest,
}
