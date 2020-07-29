import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:hive/hive.dart';
import 'package:sports_private_pool/services/sport_data.dart';

import 'match_details.dart';

class HomePage extends StatefulWidget {
  static const id = 'home_page';

  HomePage(this.upcomingMatchesData);

  dynamic upcomingMatchesData;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic upcomingMatchesData;
  dynamic loggedInUserData;
  int index = 0;

  Box<dynamic> userData;

  @override
  void initState() {
    super.initState();
    userData = Hive.box('userData');
    loggedInUserData = userData.get('user');
    upcomingMatchesData = widget.upcomingMatchesData;
    print(loggedInUserData);
  }

  List<Widget> getUpcomingMatchesList() {
    var data = upcomingMatchesData;

    List<Widget> upcomingMatchesList = [];

    for( var match in data) {
      var fixture = match['team-1'] + ' vs ' + match['team-2'];

      List<Widget> team1Text = [];
      for(var word in match['team-1'].split(" ")){
        var wordWidget = Text(
            word,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            )
        );
        team1Text.add(wordWidget);
      }

      List<Widget> team2Text = [];
      for(var word in match['team-2'].split(" ")){
        var wordWidget = Text(
            word,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            )
        );
        team2Text.add(wordWidget);
      }


      Widget singleMatch = GestureDetector(
        onTap: () async {
          SportData sportData = SportData();
          var squadData = await sportData.getSquads(match['unique_id']);
          print(squadData);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MatchDetails(matchData: match, squadData: squadData,);
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
          padding: const EdgeInsets.symmetric(vertical : 5.0, horizontal: 5.0),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    children: getUpcomingMatchesList()
                ),
              ),
            ],
        ),
    );
  }
}
