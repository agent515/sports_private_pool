import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {

  RoundedButton({this.color, this.text, this.onpressed});

  final Color color;
  final String text;
  final Function onpressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical : 16.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(25.0),
        color: this.color,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42,
          child: Text(
            this.text,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: this.onpressed,
        ),
      ),
    );
  }
}
