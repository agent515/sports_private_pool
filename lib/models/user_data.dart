import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  dynamic _user;

  UserData(dynamic user) {
    _user = user;
  }

  dynamic get user => _user;

  void changeUserData(dynamic newUser) {
    _user = newUser;
    notifyListeners();
  }
}