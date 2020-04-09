import 'package:flutter/material.dart';

class ContestInputField extends StatelessWidget {
  ContestInputField({this.hintText, this.labelText, this.rightMargin, this.textEditingController});

  final double rightMargin;
  final String labelText;
  final String hintText;
  final TextEditingController textEditingController;


  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60.0,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(
            left: 20.0, right: this.rightMargin, top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black87),
          ),
        ),
        child: TextField(
          controller: textEditingController,
          style: TextStyle(
            color: Colors.black54,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: this.labelText,
            labelStyle: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            hintText: this.hintText,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ));
  }
}