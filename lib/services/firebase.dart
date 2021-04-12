import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sports_private_pool/core/errors/exceptions.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:instant/instant.dart';
import 'package:sports_private_pool/services/sport_data.dart';

class Firebase {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  CloudFunctions _cloudFunctions = CloudFunctions.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseUser _user;
  SportData _sportData = SportData();

  Firebase() {
    _cloudFunctions.useFunctionsEmulator(origin: "http://10.0.2.2:5001");
  }

  Future<dynamic> getUpcomingMatches() async {
    DateTime currentIndiaTime = curDateTimeByZone(zone: "IST");

    final currentDateString = currentIndiaTime.toString().substring(0, 10);
    try {
      final result = await _firestore
          .collection('upcomingMatches')
          .document(currentDateString)
          .get();
      if (result.exists) {
        print("upcomingMatches data exist.");
        return result.data['data'];
      }
      print("upcomingMatches data updated");

      final data = await _sportData.getUpcomingMatchesData('/matches');
      QuerySnapshot prevRecords =
          await _firestore.collection('upcomingMatches').getDocuments();
      for (var doc in prevRecords.documents) {
        await doc.reference.delete();
      }

      _firestore
          .collection('upcomingMatches')
          .document(currentDateString)
          .setData({'data': data});
      return data;
    } catch (e) {
      print(e);
      return _sportData.getUpcomingMatchesData('/matches');
    }
  }

  Future<FirebaseUser> signInWithGoogle() async {
    try {
      GoogleSignInAccount gAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication gAuth = await gAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      AuthResult authResult =
          await _firebaseAuth.signInWithCredential(credential);
      _user = authResult.user;
      print("signed in");
      return _user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Person> getUserDetails() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentSnapshot temp = await _firestore
        .collection("email-username")
        .document(user.email)
        .get();
    String username = temp.data['username'];

    DocumentSnapshot userDetails =
        await _firestore.collection("users").document(username).get();
    return Person.fromMap(userDetails.data);
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<Map<dynamic, dynamic>> getContestDetails(String contestId) async {
    var temp = await _firestore
        .collection(
            'contests/cricketMatchContest/cricketMatchContestCollection')
        .document(contestId)
        .get();
    var contest = temp.data;
    return contest;
  }

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<Map<dynamic, dynamic>> calculateResult(
      Map<dynamic, dynamic> contest) async {
    HttpsCallable httpsCallable =
        _cloudFunctions.getHttpsCallable(functionName: 'calculate_result');
    final params = <String, dynamic>{
      'matchId': contest['matchId'],
      'contestId': contest['contestId']
    };
    try {
      final result = await httpsCallable.call(params);
      print(result.data);
      if (result.data['error'] != null) throw NotFoundException();
      return result.data['data'];
    } on PlatformException {
      throw ServerException();
    } catch (e) {
      print(e);
      throw NotFoundException();
    }
  }
}
