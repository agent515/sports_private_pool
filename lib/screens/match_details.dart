import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_private_pool/services/networking.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
NetworkHelper networkHelper;

class MatchDetails extends StatefulWidget {

  MatchDetails({this.matchData, this.squadData});

  dynamic matchData;
  dynamic squadData;

  @override
  _MatchDetailsState createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails> {
  int matchId;
  dynamic matchData;
  dynamic dateObject;
  String date;
  dynamic squads;

  @override
  void initState() {
    super.initState();
    matchData = widget.matchData;
    matchId = matchData['unique_id'];
    dateObject = DateTime.parse(matchData['date']).toLocal();
    print(dateObject);
    date = dateObject.toString();
    squads = widget.squadData;
    print(squads);
  }

  Widget getSquad(int index) {
    String teamName = squads['squad'][index]['name'];
    String playerList = "";
    int i = 0;
    int length = 0;
    for(var player in squads['squad'][index]['players'])
      {length++; }
    for(var player in squads['squad'][index]['players']){
      playerList = playerList + player['name'].toString();
      i++;
//      print(squads['squad'][index]['players'])
      if(i != length){
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
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold
            ),
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

  @override
  Widget build(BuildContext context) {
    print(dateObject);
    return Scaffold(
      body: Column(
        children: <Widget>[
          SimpleAppBar(),
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Text(
                '${matchData['team-1']}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'vs',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '${matchData['team-2']}',
                style: TextStyle(
                  fontSize: 18.0,
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
                  Container(
                    margin: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                    height: 400,
                    child: Column(
                      children: <Widget>[
                        getSquad(0),
                        getSquad(1)
                      ],
                    ),
                  )
                ],
              )
            )
        ],
      )
    );
  }
}
