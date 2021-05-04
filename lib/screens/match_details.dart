import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/screens/cricket_match_contest_screen.dart';
import 'package:sports_private_pool/services/networking.dart';

NetworkHelper networkHelper;

class MatchDetails extends StatefulWidget {
  MatchDetails({@required this.matchData, @required this.squadData});

  final dynamic matchData;
  final dynamic squadData;

  @override
  _MatchDetailsState createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails> {
  int matchId;
  dynamic matchData;
  dynamic dateObject;
  String date;
  dynamic squads;
  dynamic loggedInUserData;
  int index = 1;

  @override
  void initState() {
    super.initState();
    matchData = widget.matchData;
    matchId = matchData['unique_id'];
    print(matchId);
    dateObject = DateTime.parse(matchData['date']).toLocal();
    print(dateObject);
    date = dateObject.toString();
    squads = widget.squadData;
    print(squads);
  }

  Widget getSquad(int index) {
    if (!matchData['squad']) {
      var temp = index + 1;
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: <Widget>[
            Text(
              matchData['team-$temp'],
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'squad not available',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }
    String teamName = squads['squad'][index]['name'];
    String playerList = "";
    int i = 0;
    int length = 0;
    // ignore: unused_local_variable
    for (var player in squads['squad'][index]['players']) {
      length++;
    }
    for (var player in squads['squad'][index]['players']) {
      playerList = playerList + player['name'].toString();
      i++;
      if (i != length) {
        playerList += ', ';
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            teamName,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          Text(
            playerList,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }

  Widget createContest() {
    return RoundedButton(
      color: Colors.black87,
      text: 'Create Contest',
      onpressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CricketMatchContestScreen(
                      matchData: matchData,
                      squadData: squads,
                    )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(dateObject);
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        SimpleAppBar(
          appBarTitle: 'M A T C H   D E T A I L S',
        ),
        Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              '${matchData['team-1']}',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'vs',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              '${matchData['team-2']}',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Date  ${date.substring(0, 10)}',
                      ),
                      Text(
                        'Time  ${date.substring(11, 16)}',
                      )
                    ],
                  ),
                ),
                matchData['squad']
                    ? createContest()
                    : Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Cannot create contest without squad details',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                Container(
                  margin: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                  child: Column(
                    children: <Widget>[getSquad(0), getSquad(1)],
                  ),
                )
              ],
            ))
      ],
    );
  }
}
