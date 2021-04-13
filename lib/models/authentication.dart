import 'package:flutter/foundation.dart';
import 'package:sports_private_pool/core/errors/exceptions.dart';
import 'package:sports_private_pool/models/person.dart';

class Authentication extends ChangeNotifier {
  bool _loggedIn = false;
  Person _user;

  bool get loggedIn => _loggedIn;

  Person get user => _loggedIn ? _user : throw NotFoundException();

  void login(Person user) {
    _loggedIn = true;
    _user = user;
    print("user logged in....");
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    print("user logged out...");
    notifyListeners();
  }
}
