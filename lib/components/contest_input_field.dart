import 'package:flutter/material.dart';

class ContestInputField extends StatelessWidget {
  ContestInputField(
      {this.hintText,
      this.labelText,
      this.rightMargin,
      this.textEditingController});

  final double rightMargin;
  final String labelText;
  final String hintText;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 100),
      child: TextFormField(
        controller: textEditingController,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(color: Colors.black87),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide:
                BorderSide(color: Theme.of(context).accentColor, width: 1.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          ),
          labelText: this.labelText,
          labelStyle: Theme.of(context).textTheme.bodyText2.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600),
          contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          hintText: this.hintText,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
