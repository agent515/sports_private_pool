import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CricketMatchContest {
  final int matchId;
  final dynamic squad;
  final int contestId;
  final Map matchResult;      //1 (team 1) or 2 (team 2)
  final Map MVP;
  final Map MostWickets;
  final Map MostRuns;
  final double prize;
  final String admin;
  final List<String> participants;

  CricketMatchContest(
      {this.matchId,
      this.squad,
      this.contestId,
      this.MVP,
      this.MostWickets,
      this.MostRuns,
      this.prize,
      this.admin,
      this.participants,
      this.matchResult});

  static List<Text> getSquadNames() {

  }

}
