import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sports_private_pool/components/custom_tool_tip.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/core/errors/exceptions.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:sports_private_pool/screens/user_specific_screens/contest_result_screen.dart';
import 'package:sports_private_pool/services/sport_data.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';
import 'package:sports_private_pool/services/firebase.dart';

class MyCreatedContestDetailsScreen extends StatefulWidget {
  MyCreatedContestDetailsScreen(
      {@required this.contestId, @required this.type, this.matchId});
  final contestId;
  final type;
  final matchId;

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
  Map<dynamic, dynamic> contestResult;
  Person _user;
  Box<Person> userBox;

  // ignore: non_constant_identifier_names
  dynamic MVP;
  dynamic mostRuns;
  dynamic mostWickets;
  FirebaseRepository _firebase = FirebaseRepository();

  TextStyle kUserProfileInfoDetailsTextStyle;

  Widget predictionWidget = Icon(Icons.arrow_drop_down);

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<Person>('user');
    print(userBox.isOpen);
    print(userBox.isEmpty);
    _user = userBox.get('user');
    type = widget.type;

    _getUserDetails();
    print(matchScore);
    print(contest);
    print(type);
  }

  Future<void> _getUserDetails() async {
    _firebase.getUserDetails().then(
      (user) {
        userBox.put('user', user);
        setState(() {
          _user = user;
        });
      },
    );
  }

  Future<void> _createDynamicLink(String joinCode) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://envision.page.link',
      // ignore: todo
      // TODO: App download link here
      link: Uri.parse(
          'https://play.google.com/store/apps/details?id=com.whatsapp&join_code=$joinCode'),
      androidParameters: AndroidParameters(
        packageName: 'com.envision.Envision',
        minimumVersion: 0,
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
            ));
    final Uri shortUrl = shortDynamicLink.shortUrl;
    Share.share("${shortUrl.toString()}\nJoin Code: $joinCode",
        subject: "Envision Join code: $joinCode");
  }

  Widget _buildJoinedContestDetails() {
    kUserProfileInfoDetailsTextStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: Colors.black54, fontWeight: FontWeight.w600);
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Text(
              'Join Code :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(contest['joinCode'],
                style: kUserProfileInfoDetailsTextStyle),
          ),
          ListTile(
            leading: Text(
              'Prize :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(
              contest['prizeMoney'].toString(),
              style: kUserProfileInfoDetailsTextStyle,
            ),
          ),
          ListTile(
            leading: Text(
              'Entry Fee :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(contest['entryFee'].toString(),
                style: kUserProfileInfoDetailsTextStyle),
          ),
          ListTile(
            leading: Text(
              'No. of participants (currently) :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(contest['participants'].length.toString(),
                style: kUserProfileInfoDetailsTextStyle),
          ),
          ListTile(
            leading: Text(
              'No. of participants (max) :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(contest['noOfParticipants'].toInt().toString(),
                style: kUserProfileInfoDetailsTextStyle),
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
              leading: Text(
                'Predictions :',
                style: kUserProfileInfoTextStyle,
              ),
              title: predictionWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedContestDetails() {
    kUserProfileInfoDetailsTextStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: Colors.black54, fontWeight: FontWeight.w600);
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Text(
              'Join Code :',
              style: kUserProfileInfoTextStyle,
            ),
            title: GestureDetector(
              child: CustomToolTip(
                text: contest['joinCode'],
              ),
              onTap: () {},
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.grey[500],
              ),
              onPressed: () async {
                await _createDynamicLink(contest['joinCode']);
              },
            ),
          ),
          ListTile(
            leading: Text(
              'Prize :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(contest['prizeMoney'].toString(),
                style: kUserProfileInfoDetailsTextStyle),
          ),
          ListTile(
            leading: Text(
              'Entry Fee :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(contest['entryFee'].toString(),
                style: kUserProfileInfoDetailsTextStyle),
          ),
          ListTile(
            leading: Text(
              'No. of participants (currently) :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(contest['participants'].length.toString(),
                style: kUserProfileInfoDetailsTextStyle),
          ),
          ListTile(
            leading: Text(
              'No. of participants (max) :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Text(contest['noOfParticipants'].toInt().toString(),
                style: kUserProfileInfoDetailsTextStyle),
          ),
          ListTile(
            leading: Text(
              'Particpants :',
              style: kUserProfileInfoTextStyle,
            ),
            title: Column(
              children: getUserList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getUserList() {
    var participants = contest['participants'];
    List<Widget> userWidgetsList = [];
    for (var participant in participants) {
      Widget userWidget = ListTile(
        title: Text(participant),
      );

      userWidgetsList.add(userWidget);
    }

    return userWidgetsList;
  }

  Future<void> _updatePlayerData() async {
    if (_tapped == false) {
      setState(() {
        predictionWidget = Icon(Icons.arrow_drop_down);
      });
    } else {
      var sportData = SportData();

      MVP = await sportData
          .getPlayerInfo(contest['predictions'][_user.username]['MVP']);
      mostRuns = await sportData
          .getPlayerInfo(contest['predictions'][_user.username]['mostRuns']);
      mostWickets = await sportData
          .getPlayerInfo(contest['predictions'][_user.username]['mostWickets']);

      String placeholder =
          "http://www.londondentalsmiles.co.uk/wp-content/uploads/2017/06/person-dummy.jpg";

      setState(() {
        predictionWidget = Column(
          children: <Widget>[
            ListTile(
              leading: Text('MVP :'),
              title: Text('${MVP['name']}'),
              trailing: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(MVP['imageURL'] ?? placeholder),
              ),
            ),
            ListTile(
              leading: Text('Most Runs :'),
              title: Text('${mostRuns['name']}'),
              trailing: CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(mostRuns['imageURL'] ?? placeholder),
              ),
            ),
            ListTile(
              leading: Text('Most Wickets :'),
              title: Text('${mostWickets['name']}'),
              trailing: CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(mostWickets['imageURL'] ?? placeholder),
              ),
            ),
            ListTile(
                leading: Text('Match Result :'),
                title: Text(
                    '${contest['predictions'][_user.username]['matchResult']}')),
          ],
        );
      });
    }
  }

  Future<void> _showMyDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Envision',
            style: Theme.of(context).textTheme.headline5,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(children: <Widget>[
            SimpleAppBar(
              appBarTitle: 'C O N T E S T   D E T A I L S',
            ),
            Expanded(
              child: FutureBuilder(
                future:
                    SportData().getScore(widget.matchId ?? contest['matchId']),
                builder:
                    (BuildContext context, AsyncSnapshot matchScoreSnapshot) {
                  if (matchScoreSnapshot.hasData) {
                    return FutureBuilder(
                      future: _firebase.getContestDetails(widget.contestId),
                      builder: (BuildContext context,
                          AsyncSnapshot contestSnapshot) {
                        if (contestSnapshot.hasData) {
                          matchScore = matchScoreSnapshot.data;
                          contest = contestSnapshot.data;
                          contestResult = contest['result'];

                          return ListView(
                            scrollDirection: Axis.vertical,
                            children: <Widget>[
                              Flex(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Text(
                                    '${matchScore['team-1']}',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                  Text(
                                    'vs',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Text(
                                    '${matchScore['team-2']}',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Match start: ' +
                                            (matchScore['matchStarted']
                                                ? 'Has started'
                                                : matchScore['stat']),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              type == 'Joined'
                                  ? (contestResult != null
                                          ? contestResult.isNotEmpty
                                          : false)
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 60.0),
                                          child: RoundedButton(
                                            text: 'View Result',
                                            color:
                                                Theme.of(context).accentColor,
                                            onpressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ContestResultScreen(
                                                    result: contestResult,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Container()
                                  : (contest['participants'].length > 0 &&
                                          (contestResult != null
                                              ? contestResult.isEmpty
                                              : true))
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 60.0),
                                          child: RoundedButton(
                                            text: 'Calculate Result',
                                            color:
                                                Theme.of(context).accentColor,
                                            onpressed: () async {
                                              try {
                                                final tempResult =
                                                    await _firebase
                                                        .calculateResult(
                                                            contest);
                                                print(tempResult);
                                                setState(() {
                                                  contestResult = tempResult;
                                                });
                                              } on ServerException {
                                                _showMyDialog(
                                                    "Sever Error: Try again later");
                                                print("Server Excpetion");
                                              } on NotFoundException {
                                                _showMyDialog(
                                                    "Result data not available yet.");
                                                print(
                                                    "Result data not available");
                                              }
                                            },
                                          ),
                                        )
                                      : contest['participants'].length == 0
                                          ? Center(
                                              child: Text(
                                                'Sorry, no one participated',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 60.0),
                                              child: RoundedButton(
                                                text: 'View Result',
                                                color: Theme.of(context)
                                                    .accentColor,
                                                onpressed: () async {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ContestResultScreen(
                                                                result:
                                                                    contestResult,
                                                              )));
                                                },
                                              ),
                                            ),
                              type == 'Joined'
                                  ? _buildJoinedContestDetails()
                                  : _buildCreatedContestDetails(),
                            ],
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ]),
        ));
  }
}
