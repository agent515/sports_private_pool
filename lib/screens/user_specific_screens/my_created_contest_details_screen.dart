import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/custom_tool_tip.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/services/sport_data.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';
import 'package:sports_private_pool/services/firebase.dart';


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
  Firebase _firebase = Firebase();

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

  Future<void> _createDynamicLink(String joinCode) async {
    final DynamicLinkParameters parameters =
    DynamicLinkParameters(
      uriPrefix: 'https://envision.page.link',
      // TODO: App download link here
      link: Uri.parse('https://play.google.com/store/apps/details?id=com.whatsapp&join_code=$joinCode'),
      androidParameters: AndroidParameters(
        packageName: 'com.envision.Envision',
        minimumVersion:0,
      ),

//      iosParameters: IosParameters(
//        bundleId: 'com.example',
//        minimumVersion: '1.0.1',
//        appStoreId: '1405860595',
//      )
    );
    final Uri uri = await parameters.buildUrl();
    final ShortDynamicLink shortDynamicLink =
    await DynamicLinkParameters.shortenUrl(
        uri,
        DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
        )
    );
    final Uri shortUrl = shortDynamicLink.shortUrl;
    Share.share("${shortUrl.toString()}\nJoin Code: $joinCode", subject: "Envision Join code: $joinCode");
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
          trailing: IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              await _createDynamicLink(contest['joinCode']);
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0),
                child: RoundedButton(
                  text: 'Calculate Result',
                  color: Colors.pink,
                  onpressed: () => {_firebase.calculateResult(contest)},
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
