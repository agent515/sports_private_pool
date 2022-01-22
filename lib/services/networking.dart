import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sports_private_pool/api.dart';

class NetworkHelper {
  Future getData(Uri url) async {
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
      print("Error:${response.statusCode}");
    }
  }
}

class NetworkEndpoints {
  String get baseUrl => 'https://cricapi.com';
  String get apiPath => 'api';
  String _apiKey = CricapiKey;

  Uri getSquads(String matchId) => Uri.https(
      baseUrl, '$apiPath/fantasySquad?apikey=$_apiKey&unique_id=$matchId');
  Uri getMatchData() => Uri.https(baseUrl, '$apiPath/matches/?apikey=$_apiKey');
  Uri getScore(String matchId) => Uri.https(
      baseUrl, '$apiPath/cricketScore?apikey=$_apiKey&unique_id=$matchId');
  Uri getPlayerInfo(String pid) =>
      Uri.https(baseUrl, '$apiPath/playerStats?apikey=$_apiKey&pid=$pid');
  Uri getUpcomingMatchesData(String route) =>
      Uri.https(baseUrl, '$apiPath/$route?apikey=$_apiKey');
}
