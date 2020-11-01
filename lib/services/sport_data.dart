import 'package:flutter/material.dart';
import 'package:sports_private_pool/screens/match_details.dart';
import 'package:sports_private_pool/services/networking.dart';
import 'package:sports_private_pool/api.dart';

const baseUrl = 'https://cricapi.com/api';

//https://cricapi.com/api/fantasySquad?apikey=$apiKey&unique_id=1034809
const String apiKey = CricapiKey;

class SportData {
  // Get Squad Information of two teams in a Match with ID: matchId
  Future<dynamic> getSquads(matchId) async {
    NetworkHelper networkHelper = NetworkHelper(
        '$baseUrl/fantasySquad?apikey=$apiKey&unique_id=$matchId');

    var squadData = await networkHelper.getData();
    return squadData;
  }

  // Get all the necessary data related to a Match.
  Future<dynamic> getMatchData(matchId) async {
    NetworkHelper networkHelper =
        NetworkHelper('$baseUrl/matches/?apikey=$apiKey');
    dynamic data = await networkHelper.getData();
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
    NetworkHelper networkHelper = NetworkHelper(
        '$baseUrl/cricketScore?apikey=$apiKey&unique_id=$matchId');
    dynamic data = await networkHelper.getData();
    return data;
  }

  // Get Player Information and his/her stats.
  Future<dynamic> getPlayerInfo(pid) async {
    NetworkHelper networkHelper =
        NetworkHelper('$baseUrl/playerStats?apikey=$apiKey&pid=$pid');
    dynamic data = await networkHelper.getData();
    return data;
  }

  Future<dynamic> getUpcomingMatchesData(route) async {
    NetworkHelper networkHelper =
        NetworkHelper(baseUrl + route + '?apikey=' + apiKey);
    dynamic data = await networkHelper.getData();
    data = data['matches'];
    return data;
  }

  //
  Future<List<Widget>> getNextMatches(route, context) async {
    NetworkHelper networkHelper =
        NetworkHelper(baseUrl + route + '?apikey=' + apiKey);
    dynamic data = await networkHelper.getData();
    data = data['matches'];

    List<Widget> upcomingMatchesList = [];

    for (var match in data) {
      var fixture = match['team-1'] + ' vs ' + match['team-2'];

      List<Widget> team1Text = [];
      for (var word in match['team-1'].split(" ")) {
        var wordWidget = Text(word,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            ));
        team1Text.add(wordWidget);
      }

      List<Widget> team2Text = [];
      for (var word in match['team-2'].split(" ")) {
        var wordWidget = Text(word,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            ));
        team2Text.add(wordWidget);
      }

      Widget singleMatch = GestureDetector(
        onTap: () async {
          SportData sportData = SportData();
          var squadData = await sportData.getSquads(match['unique_id']);
          print(squadData);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MatchDetails(
              matchData: match,
              squadData: squadData,
            );
          }));
        },
        child: Container(
          height: 130.0,
          margin: EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black26,
              width: 1.0,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
//              Flex(
//                direction: Axis.vertical,
//                children: RowComponents,
//              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Flex(
                      direction: Axis.vertical,
                      children: team1Text,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'Vs',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Flex(
                      direction: Axis.vertical,
                      children: team2Text,
                    ),
                  ),
                ],
              ),
              Text(
                match['type'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),
      );

      upcomingMatchesList.add(singleMatch);
    }
//    print(upcomingMatchesList);
    return upcomingMatchesList;
  }
}
