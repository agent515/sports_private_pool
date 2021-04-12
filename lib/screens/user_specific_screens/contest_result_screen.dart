import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';

class ContestResultScreen extends StatelessWidget {
  final dynamic result;

  const ContestResultScreen({Key key, @required this.result}) : super(key: key);

  Widget _winners() {
    final winners = result['winners'];
    List<Widget> winnerTiles = [];

    for (int i = 0; i < winners.length; i++) {
      Widget tile = Text(
        winners[0],
        style: TextStyle(fontSize: 16),
      );
      winnerTiles.add(tile);
    }

    return Column(
      children: [
        Text('Winner(s)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        SizedBox(height: 15),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: winnerTiles,
        )
      ],
    );
  }

  Widget _leaderboard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final kTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: result['leaderboard'].length,
      itemBuilder: (context, index) => Column(children: [
        index == 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: size.width * 0.15,
                      child: Text(
                        'Rank',
                        style: kTextStyle,
                      )),
                  Container(
                      width: size.width * 0.6,
                      child: Text(
                        'Username',
                        style: kTextStyle,
                      )),
                  Container(
                      width: size.width * 0.2,
                      child: Text(
                        'Points',
                        style: kTextStyle,
                      )),
                ],
              )
            : Container(),
        LeaderboardTile(
            rank: (index + 1).toString(),
            username: result['leaderboard'][index]['username'],
            points: result['leaderboard'][index]['points'].toString()),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SimpleAppBar(
                appBarTitle: 'L E A D E R B O A R D',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    _winners(),
                    SizedBox(height: 20.0),
                    _leaderboard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaderboardTile extends StatelessWidget {
  final String rank;
  final String username;
  final String points;

  const LeaderboardTile({
    Key key,
    @required this.rank,
    @required this.username,
    @required this.points,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final kTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w300);

    return Container(
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: size.width * 0.15,
              child: Text(
                rank,
                style: kTextStyle,
              )),
          Container(
              width: size.width * 0.6,
              child: Text(
                username,
                style: kTextStyle,
              )),
          Container(
              width: size.width * 0.2,
              child: Text(
                points,
                style: kTextStyle,
              )),
        ],
      ),
    );
  }
}
