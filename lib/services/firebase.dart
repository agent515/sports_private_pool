import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/core/errors/exceptions.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:instant/instant.dart';
import 'package:sports_private_pool/services/sport_data.dart';

/// Utility class for doing all the firebase related work
class FirebaseRepository {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  CloudFunctions _cloudFunctions = CloudFunctions.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseUser _user;
  SportData _sportData = SportData();
  Person person;

  FirebaseRepository() {
    _cloudFunctions.useFunctionsEmulator(origin: "http://10.0.2.2:5001");
  }

  /// This function returns upcoming matches data from the cloud firestore (for today's date).
  /// If the data is not present in the firestore it calls API and then stores
  /// the returned response-data to the firestore after deleting stale upcoming matches data
  /// in firestore.
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

  /// Wrappper function to do Google Sign In
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
      if (_user != null) {
        DocumentSnapshot documentRef =
            await _firestore.collection("users").document(_user.email).get();

        if (!documentRef.exists) {
          await _firestore
              .collection("email-username")
              .document(_user.email)
              .setData({
            'username': _user.email,
          });
          await _firestore.collection("users").document(_user.email).setData({
            'firstName': _user.displayName.split(' ')[0],
            'lastName': _user.displayName.split(' ')[1],
            'purse': 100.0,
            'username': _user.email,
            'email': _user.email,
            'contestsCreated': [],
            'contestsJoined': [],
          });
        }
      }
      return _user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Returns Person object of the Signed in user
  Future<Person> getUserDetails() async {
    _user = await _firebaseAuth.currentUser();

    DocumentSnapshot temp = await _firestore
        .collection("email-username")
        .document(_user.email)
        .get();
    String username = temp.data['username'];

    DocumentSnapshot userDetails =
        await _firestore.collection("users").document(username).get();
    person = Person.fromMap(userDetails.data);
    return Person.fromMap(userDetails.data);
  }

  /// Wrapper function to do GoogleSignOut and FireAuth SignOut
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
    }
  }

  /// Fetch ContestData from the firestore for given contestId
  Future<Map<dynamic, dynamic>> getContestDetails(String contestId) async {
    var temp = await _firestore
        .collection(
            'contests/cricketMatchContest/cricketMatchContestCollection')
        .document(contestId)
        .get();
    var contest = temp.data;
    return contest;
  }

  /// Send Password Reset mail to given Email-Id
  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Calculate result of the contest by calling Firebase Cloud Function calculate_result
  /// Function returns resul (LinkedHashMap) or throws two Exceptions ServerException and NotFoundException
  /// ServerException: Funtion took more amount of time than usual possibly due to POOR_INTERNET_CONNECTION.
  /// NotFoundException: Match Result data from the API is absent or Inefficient to calculate result of the
  /// contest.
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

  Future<void> saveDeviceToken(String token) async {
    try {
      _user = await _firebaseAuth.currentUser();
      DocumentSnapshot temp = await _firestore
          .collection("email-username")
          .document(_user.email)
          .get();
      String username = temp.data['username'];
      print(username);
      await _firestore
          .collection("users")
          .document(username)
          .updateData({'currentToken': token});
      print("Token: $token saved.");
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendNotification(
      Map<String, dynamic> payload, NotificationEnum type) async {
    HttpsCallable httpsCallable;
    if (type == NotificationEnum.userJoinsContest) {
      httpsCallable =
          _cloudFunctions.getHttpsCallable(functionName: 'userJoinsContest');
      try {
        await httpsCallable.call(payload);
      } catch (e) {
        print(e);
      }
    }
  }

  Future<Map<String, dynamic>> joinContest(String joinCode) async {
    final type = joinCode.substring(0, 3);
    if (type == 'CMC') {
      try {
        final docSnap = await _firestore
            .collection('contests/joinCodes/joinCodesCollection')
            .document(joinCode)
            .get();

        String contestId = docSnap.data['contestId'];

        print("ContestID: $contestId");

        person = await getUserDetails();

        bool alreadyJoined = false;

        for (var contest in person.contestsJoined) {
          if (contest['contestId'] == contestId) {
            alreadyJoined = true;
            break;
          }
        }

        if (alreadyJoined) {
          return {"message": "You've already entered the contest."};
        } else {
          final contestSnap = await _firestore
              .collection(
                  'contests/cricketMatchContest/cricketMatchContestCollection')
              .document(contestId)
              .get();
          final contest = contestSnap.data;

          SportData sportData = SportData();
          final matchData = await sportData.getMatchData(contest['matchId']);

          final squadData = await sportData.getSquads(contest['matchId']);

          if (matchData == null) {
            return {"message": "The contest has already ended."};
          } else {
            return {
              "message": "",
              "userData": person.toMap(),
              "contest": contest,
              "squadData": squadData,
              "matchData": matchData,
            };
          }
        }
      } catch (e) {
        print(e);
      }
    }
    assert(type == "CMC");
    return {};
  }
}
