import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/custom_tool_tip.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/services/sport_data.dart';

class MyCreatedContestDetailsScreen extends StatefulWidget {
  MyCreatedContestDetailsScreen({this.contest, this.type, this.matchScore});
  final contest;
  final type;
  final matchScore;

  @override
  _MyCreatedContestDetailsScreenState createState() =>
      _MyCreatedContestDetailsScreenState();
}

class _MyCreatedContestDetailsScreenState
    extends State<MyCreatedContestDetailsScreen> {
  dynamic contest;
  dynamic matchScore;
  String type;
  bool _tapped = false;

  dynamic MVP;
  dynamic mostRuns;
  dynamic mostWickets;

  Widget predictionWidget = Icon(Icons.arrow_drop_down);

  @override
  void initState() {
    super.initState();
    contest = widget.contest;
    type = widget.type;
    matchScore = widget.matchScore;
    print(matchScore);
    print(contest);
    print(type);
  }

  Widget _buildJoinedContestDetails() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Column(children: <Widget>[
        ListTile(
          leading: Text('Join Code :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['joinCode']),
        ),
        ListTile(
          leading: Text('Prize :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['prizeMoney'].toString()),
        ),
        ListTile(
          leading: Text('Entry Fee :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['entryFee'].toString()),
        ),
        ListTile(
          leading: Text('No. of participants (currently) :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['participants'].length.toString()),
        ),
        ListTile(
          leading: Text('No. of participants (max) :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['noOfParticipants'].toInt().toString()),
        ),
        Container(
          color: Color(0xFFEEEEEE),
          child: ListTile(
            onTap: () async {
              setState(() {
                _tapped = !_tapped;
              });
              await _updatePlayerData();
            },
            leading: Text('Predictions :', style: kUserProfileInfoTextStyle,),
            title: predictionWidget,

          ),
        ),
      ],),
    );
  }

  Widget _buildCreatedContestDetails() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Column(children: <Widget>[
        ListTile(
          leading: Text('Join Code :', style: kUserProfileInfoTextStyle,),
          title: GestureDetector(
            child: CustomToolTip(text: contest['joinCode'],),
            onTap: () {

            },
          ),
        ),
        ListTile(
          leading: Text('Prize :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['prizeMoney'].toString()),
        ),
        ListTile(
          leading: Text('Entry Fee :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['entryFee'].toString()),
        ),
        ListTile(
          leading: Text('No. of participants (currently) :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['participants'].length.toString()),
        ),
        ListTile(
          leading: Text('No. of participants (max) :', style: kUserProfileInfoTextStyle,),
          title: Text(contest['noOfParticipants'].toInt().toString()),
        ),
        ListTile(
          leading: Text('Particpants :', style: kUserProfileInfoTextStyle,),
          title: Column(
            children: getUserList(),
          ),
        ),
      ],),
    );
  }


  List<Widget> getUserList() {
    var participants = contest['participants'];
    List<Widget> userWidgetsList = [];
    for(var participant in participants){
      Widget userWidget = ListTile(
        title: Text(participant),
      );

      userWidgetsList.add(userWidget);
    }

    return userWidgetsList;
  }

  Future<void> _updatePlayerData() async {

    if(_tapped == false) {
      setState(() {
        predictionWidget = Icon(Icons.arrow_drop_down);
      });
    }
    else {
      var sportData = SportData();

      MVP = await sportData.getPlayerInfo(contest['predictions']['MVP']);
      mostRuns = await sportData.getPlayerInfo(contest['predictions']['mostRuns']);
      mostWickets = await sportData.getPlayerInfo(contest['predictions']['mostWickets']);

      setState(() {
        predictionWidget = Column(
          children: <Widget>[
            ListTile(leading: Text('MVP :'), title: Text('${MVP['name']}')),
            ListTile(leading: Text('Most Runs :'), title: Text('${mostRuns['name']}')),
            ListTile(leading: Text('Most Wickets :'), title: Text('${mostWickets['name']}')),
            ListTile(leading: Text('Match Result :'), title: Text('${contest['predictions']['matchResult']}')),
          ],
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: <Widget>[
        SimpleAppBar(
          appBarTitle: 'C O N T E S T   D E T A I L S',
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Text(
                    '${matchScore['team-1']}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'vs',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${matchScore['team-2']}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Match start: ' + (matchScore['matchStarted'] ? 'Has started' : matchScore['stat']),
                      ),
                    ],
                  ),
                ),
              ),
              type == 'Joined' ? _buildJoinedContestDetails() : _buildCreatedContestDetails(),
            ],
          ),
        ),
      ]),
    );
  }
}
