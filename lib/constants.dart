import 'package:flutter/material.dart';


const kTextInputFieldDecoration = InputDecoration(
    hintText: 'enter email',
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black54, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black54, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
    )
);


const kUserProfileInfoTextStyle = TextStyle(fontSize: 18.0, color: Colors.black54);