import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sports_private_pool/models/person.dart';

class Firebase {

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseUser _user;

  Future<FirebaseUser> signInWithGoogle() async {
    try {
      GoogleSignInAccount gAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication gAuth = await gAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      AuthResult authResult = await _firebaseAuth.signInWithCredential(
          credential);
      _user = authResult.user;
      print("signed in");
      return _user;
    }
    catch (e) {
      print(e);
      return null;
    }
  }

  Future<Person> getUserDetails() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentSnapshot temp =
    await _firestore
        .collection("email-username")
        .document(user.email)
        .get();
    String username = temp.data['username'];

    DocumentSnapshot userDetails =
    await _firestore
        .collection("users")
        .document(username)
        .get();
    return Person.fromMap(userDetails.data);
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    }
    catch (e) {
      print(e);
    }
  }

  Future<List<Map>> getContests(String type) async {
    var loggedInUserData;
    Person user = await getUserDetails();
    loggedInUserData = user.toMap();
    var contests = loggedInUserData['contests${type}'];
    print(loggedInUserData['contests${type}']);
    //    print(contests);
    List<Map> contests_list = [];

    for(var contest_id in contests){
      if(contest_id.substring(0, 3) == 'CMC'){

        var contestSnapshot = await _firestore
            .collection('contests/cricketMatchContest/cricketMatchContestCollection')
            .document(contest_id)
            .get();
        var contest = contestSnapshot.data;
        contests_list.add(contest);
      }
    }
    return contests_list;
  }

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

}