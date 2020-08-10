import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputBox extends StatelessWidget {
  InputBox({
    this.hintText,
    this.textController,
    this.keyboardType: TextInputType.text,
    this.prefixIcon,
    this.paddingTop: 3.0,
    this.obscureText: false,
    this.fNode,
    this.onComplete,
  });

  final String hintText;
  final TextEditingController textController;
  final TextInputType keyboardType;
  final Icon prefixIcon;
  final double paddingTop;
  final bool obscureText;
  final FocusNode fNode;
  final Function onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 55.0,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
//          border: Border.all(
//            color: Colors.black87,
//          ),
          color: Color.fromRGBO(240, 240, 240, 1),
          borderRadius: BorderRadius.circular(60.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1.0,
//                            offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          //Used to send the focus to next text field using focus node.
          focusNode: fNode,
          onEditingComplete: onComplete,

          controller: textController,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black54,
          ),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            prefixIconConstraints: BoxConstraints(minWidth: 60.0),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: paddingTop),
            hintText: this.hintText,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ));
  }
}
