import 'package:flutter/material.dart';
import 'package:sports_private_pool/screens/user_specific_screens/my_contest_details_screen.dart';

class MatchCard extends StatelessWidget {
  const MatchCard(
      {Key key,
      @required this.screenSize,
      @required this.contestMeta,
      @required this.type})
      : super(key: key);

  final Size screenSize;
  final dynamic contestMeta;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () async {
          // print(squadData);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MyCreatedContestDetailsScreen(
                  contestId: contestMeta['contestId'],
                  type: type,
                  matchId: contestMeta['matchId'],
                );
              },
            ),
          );
        },
        child: Container(
          height: 0.15 * screenSize.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black26,
              width: 1.0,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('images/vs.png'),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            child: Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Flex(
                          direction: Axis.vertical,
                          children: [
                            for (var word in contestMeta['team1'].split(" "))
                              Text(
                                word ?? "",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Flex(
                          direction: Axis.vertical,
                          children: [
                            for (var word in contestMeta['team2'].split(" "))
                              Text(
                                word ?? "",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      contestMeta['contestId'] ?? "",
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                          fontSize: 12.0,
                          color: Colors.white),
                    ),
                    Text(
                      contestMeta['admin'] ?? "",
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                          fontSize: 12.0,
                          color: Colors.white),
                    )
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
