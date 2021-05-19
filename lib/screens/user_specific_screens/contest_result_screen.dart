import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ContestResultScreen extends StatelessWidget {
  final dynamic result;

  const ContestResultScreen({Key key, @required this.result}) : super(key: key);

  Widget _winners() {
    final winners = result['winners'];
    print(winners);
    List<Widget> winnerTiles = [];

    for (int i = 0; i < winners.length; i++) {
      Widget tile = WinnerCard(
        username: result['leaderboard'][i]['username'],
        points: result['leaderboard'][i]['points'].toStringAsFixed(2),
      );
      winnerTiles.add(tile);
    }

    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 2.0,
        enlargeCenterPage: true,
      ),
      items: winnerTiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Column(
            children: [
              Container(
                height: size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff000046),
                      Color(0xff1CB5E0),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        height: 0.1 * size.height,
                        child: Text(
                          'Winner(s)',
                          style: Theme.of(context).textTheme.headline4.copyWith(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Container(
                        height: 0.2 * size.height,
                        width: double.infinity,
                        child: _winners(),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: result['leaderboard'].length,
                  itemBuilder: (context, index) => LeaderboardTile(
                    rank: (index + 1).toString(),
                    username: result['leaderboard'][index]['username'],
                    points: result['leaderboard'][index]['points']
                        .toStringAsFixed(2),
                  ),
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_sharp,
                  color: Colors.white.withOpacity(0.7)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ]),
      ),
    );
  }
}

class WinnerCard extends StatelessWidget {
  final String username;
  final String points;
  const WinnerCard({Key key, @required this.username, @required this.points})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: 0.22 * size.width,
      child: Column(
        children: [
          Container(
            height: 0.11 * size.height,
            width: 0.22 * size.width,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('images/profile.png'),
              ),
            ),
          ),
          Text(
            username,
            style: Theme.of(context).textTheme.headline6.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
          ),
          Text(
            points,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.white),
          ),
        ],
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

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 0.05 * size.width,
                child: Text(
                  '$rank',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Container(
                height: 0.05 * size.height,
                width: 0.1 * size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('images/profile.png'),
                  ),
                ),
              ),
              Container(
                width: 0.5 * size.width,
                child: Text(
                  username,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.black87),
                ),
              ),
              Container(
                width: 0.15 * size.width,
                child: Text(
                  points,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Theme.of(context).accentColor),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            height: 1.0,
            width: double.infinity,
            color: Colors.grey.withOpacity(0.2),
          )
        ],
      ),
    );
  }
}
