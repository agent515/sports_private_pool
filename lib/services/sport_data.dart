import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sports_private_pool/services/networking.dart';
import 'package:sports_private_pool/api.dart';

const baseUrl = 'https://cricapi.com/api';

//https://cricapi.com/api/fantasySquad?apikey=$apiKey&unique_id=1034809
const String apiKey = CricapiKey;

class SportData {
  NetworkHelper _networkHelper = NetworkHelper();
  NetworkEndpoints _networkEndpoints = NetworkEndpoints();

  // Get Squad Information of two teams in a Match with ID: matchId
  Future<dynamic> getSquads(matchId) async {
    // final squadData =
    //     await _networkHelper.getData(_networkEndpoints.getSquads(matchId));
    // return squadData;
    String stringData = await rootBundle.loadString('assets/json/squads.json');
    Map<String, dynamic> data = json.decode(stringData);

    return data["$matchId"];
  }

  // Get all the necessary data related to a Match.
  Future<dynamic> getMatchData(matchId) async {
    dynamic data =
        await _networkHelper.getData(_networkEndpoints.getMatchData());
    data = data['matches'];

    dynamic matchData;

    for (var match in data) {
      if (match['unique_id'] == matchId) {
        matchData = match;
        break;
      }
    }
    return matchData;
  }

  // Get Final Score of a match.
  Future<dynamic> getScore(matchId) async {
    // dynamic data =
    //     await _networkHelper.getData(_networkEndpoints.getScore(matchId));
    // return data;
    String stringData = await rootBundle.loadString('assets/json/scores.json');
    Map<String, dynamic> data = json.decode(stringData);

    return data["$matchId"];
  }

  // Get Player Information and his/her stats.
  Future<dynamic> getPlayerInfo(pid) async {
    dynamic data =
        await _networkHelper.getData(_networkEndpoints.getPlayerInfo(pid));
    return data;
  }

  Future<dynamic> getUpcomingMatchesData(route) async {
    // dynamic data = await _networkHelper
    //     .getData(_networkEndpoints.getUpcomingMatchesData(route));
    // data = data['matches'];
    String stringData =
        await rootBundle.loadString('assets/json/upcoming_matches.json');
    List<Map<String, dynamic>> data =
        json.decode(stringData).toList().cast<Map<String, dynamic>>();
    return data;
  }
}
