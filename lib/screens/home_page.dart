import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/models/person.dart';
import 'package:sports_private_pool/services/sport_data.dart';

import 'match_details.dart';

class HomePage extends StatefulWidget {
  static const id = 'home_page';

  HomePage(this.upcomingMatchesData);

  final dynamic upcomingMatchesData;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic upcomingMatchesData;
  dynamic loggedInUserData;
  int index = 0;
  Person currentUser;

  Box<dynamic> userData;
  Box<Person> userBox;

  @override
  void initState() {
    super.initState();
    getCachedData();
    upcomingMatchesData = widget.upcomingMatchesData;
  }

  Future<void> getCachedData() async {
    userData = await Hive.openBox('userData');
    userBox = await Hive.openBox('user');
    setState(() {
      loggedInUserData = userData.get('userData');
      currentUser = userBox.get('user');
    });
    print("CurrentUser: ${currentUser.firstName} ${currentUser.lastName}");
  }

  List<Widget> getUpcomingMatchesList() {
    var data = upcomingMatchesData;

    List<Widget> upcomingMatchesList = [];

    for (var match in data) {
      List<Widget> team1Text = [];
      for (var word in match['team-1'].split(" ")) {
        var wordWidget = Text(
          word,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        );
        team1Text.add(wordWidget);
      }

      List<Widget> team2Text = [];
      for (var word in match['team-2'].split(" ")) {
        var wordWidget = Text(
          word,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        );
        team2Text.add(wordWidget);
      }

      Widget singleMatch = GestureDetector(
        onTap: () async {
          SportData sportData = SportData();
          var squadData = await sportData.getSquads(match['unique_id']);
          print(squadData);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MatchDetails(
                  matchData: match,
                  squadData: squadData,
                );
              },
            ),
          );
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
            gradient: LinearGradient(
              colors: [
                Color(0xff000046),
                Color(0xff1CB5E0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          child: Stack(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Flex(
                        direction: Axis.vertical,
                        children: team1Text,
                      ),
                    ),
                    Expanded(
                      child: Flex(
                        direction: Axis.vertical,
                        children: team2Text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                match['type'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
            )
          ]),
        ),
      );

      upcomingMatchesList.add(singleMatch);
    }
//    print(upcomingMatchesList);
    return upcomingMatchesList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SimpleAppBar(
              appBarTitle: 'D A S H B O A R D',
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                scrollDirection: Axis.vertical,
                children: getUpcomingMatchesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
