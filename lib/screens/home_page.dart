import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const apiKey = 'itfCIjkbOnb4vW31al0l79I7p992';
const baseUrl = 'https://cricapi.com/api';

class HomePage extends StatefulWidget {
  static const id = 'home_page';

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  List<Text> upcomingMatchesList = [];


  Future<List<Text>> getNextMatches(route) async {
    http.Response response = await http.get(baseUrl + route + '?apikey=' + apiKey);
    dynamic data =  jsonDecode(response.body)['matches'];

    upcomingMatchesList = [];

    for( var match in data) {
      var fixture = match['team-1'] + ' vs ' + match['team-2'] + match['type'];
      Text singleMatch = Text(
          fixture
      );
      upcomingMatchesList.add(singleMatch);
    }
//    print(upcomingMatchesList);
    return upcomingMatchesList;
  }


  Widget buildAppBar() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        height : 50.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 3.0, top: 3.0, right: 3.0, left: 5.0),
              height: 40.0,
              child: Image(
                image: AssetImage('images/logo.png'),
              ),
            ),
            Text(
              'D A S H B O A R D',
              style: TextStyle(
                color: Colors.black54,
                letterSpacing: 1.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: Icon(
                Icons.person,
              ),
            )
          ],
        )
    );
  }

  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          buildAppBar(),
          RaisedButton(
            elevation: 5.0,
            child: Text(
                'Get next matches',
            ),
            onPressed: () async {
              //Get next match fixtures from the API
              await getNextMatches('/matches');
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              scrollDirection: Axis.vertical,
              children: upcomingMatchesList
            ),
          ),
        ],
      ),
    );
  }
}
