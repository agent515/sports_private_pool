import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomToolTip extends StatelessWidget {
  final String text;

  CustomToolTip({this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Tooltip(
          preferBelow: false,
          message: "Copy",
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
      },
    );
  }
}
