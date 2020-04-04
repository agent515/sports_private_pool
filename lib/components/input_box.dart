import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputBox extends StatelessWidget {
  InputBox(
      {this.hintText,
        this.textController,
        this.keyboardType: TextInputType.text,
        this.prefixIcon,
        this.paddingTop : 3.0,
        this.obscureText : false});
  final String hintText;
  final TextEditingController textController;
  final TextInputType keyboardType;
  final Icon prefixIcon;
  final double paddingTop;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60.0,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black87,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
//                            offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: this.textController,
          obscureText: this.obscureText,
          keyboardType: this.keyboardType,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
          ),
          decoration: InputDecoration(
            prefixIcon: this.prefixIcon,
            border: InputBorder.none,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 5.0, vertical: paddingTop),
            hintText: this.hintText,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ));
  }
}