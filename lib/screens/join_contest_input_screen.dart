import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';

class JoinCMCInputScreen extends StatefulWidget {
  JoinCMCInputScreen(
      {this.loggedInUserData, this.contest, this.matchData, this.squadData});
  final loggedInUserData;
  final contest;
  final matchData;
  final squadData;

  @override
  _JoinCMCInputScreenState createState() => _JoinCMCInputScreenState();
}

class _JoinCMCInputScreenState extends State<JoinCMCInputScreen> {
  dynamic loggedInUserData;
  dynamic contest;
  dynamic matchData;
  dynamic squadData;

  int _currentStep = 0;
  int MVP;
  int mostRuns;
  int mostWickets;

  @override
  void initState() {
    super.initState();
    loggedInUserData = widget.loggedInUserData;
    contest = widget.contest;
    matchData = widget.matchData;
    squadData = widget.squadData;
    print(contest);
    print(matchData);
    print(squadData);
  }

  Widget _getTable(choice) {
    List<Widget> team1 = [];
    List<Widget> team2 = [];

    for (var player in squadData['squad'][0]['players']) {
      Widget playerWidget = GestureDetector(
        onTap: () {
          setState(() {
            if (choice == 'MVP') {
              MVP = player['pid'];
            } else if (choice == 'mostRuns') {
              mostRuns = player['pid'];
            } else if (choice == 'mostWickets') {
              mostWickets = player['pid'];
            }
          });
        },
        child: Container(
          height: 25.0,
          margin: EdgeInsets.symmetric(vertical: 2.5),
          decoration: BoxDecoration(
            color: choice == 'MVP'
                ? (MVP == player['pid'] ? Colors.black54 : Colors.white)
                : (choice == 'mostRuns'
                    ? (mostRuns == player['pid']
                        ? Colors.black54
                        : Colors.white)
                    : (mostWickets == player['pid']
                        ? Colors.black54
                        : Colors.white)),
            border: Border.all(
              color: Colors.black26,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3.0,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
          child: Row(
            children: <Widget>[
              Text(
                player['name'].toString(),
                style: TextStyle(
                    color: choice == 'MVP'
                        ? (MVP == player['pid'] ? Colors.white : Colors.black54)
                        : (choice == 'mostRuns'
                            ? (mostRuns == player['pid']
                                ? Colors.white
                                : Colors.black54)
                            : (mostWickets == player['pid']
                                ? Colors.white
                                : Colors.black54)),
                    fontSize: 13.0),
              )
            ],
          ),
        ),
      );

      team1.add(playerWidget);
    }

    for (var player in squadData['squad'][1]['players']) {
      Widget playerWidget = GestureDetector(
        onTap: () {
          setState(() {
            if (choice == 'MVP') {
              MVP = player['pid'];
            } else if (choice == 'mostRuns') {
              mostRuns = player['pid'];
            } else if (choice == 'mostWickets') {
              mostWickets = player['pid'];
            }
          });
        },
        child: Container(
          height: 25.0,
          margin: EdgeInsets.symmetric(vertical: 2.5),
          decoration: BoxDecoration(
            color: choice == 'MVP'
                ? (MVP == player['pid'] ? Colors.black54 : Colors.white)
                : (choice == 'mostRuns'
                    ? (mostRuns == player['pid']
                        ? Colors.black54
                        : Colors.white)
                    : (mostWickets == player['pid']
                        ? Colors.black54
                        : Colors.white)),
            border: Border.all(
              color: Colors.black26,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3.0,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
          child: Row(
            children: <Widget>[
              Text(
                player['name'].toString(),
                style: TextStyle(
                    color: choice == 'MVP'
                        ? (MVP == player['pid'] ? Colors.white : Colors.black54)
                        : (choice == 'mostRuns'
                            ? (mostRuns == player['pid']
                                ? Colors.white
                                : Colors.black54)
                            : (mostWickets == player['pid']
                                ? Colors.white
                                : Colors.black54)),
                    fontSize: 13.0),
              )
            ],
          ),
        ),
      );

      team2.add(playerWidget);
    }

    return Container(
      height: 200.0,
      child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: team1,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: team2,
              ),
            )
          ],
        ),
      ]),
    );
  }

  List<Step> _getSteps() {
    List<Step> _step = [
      Step(
        title: Text('Choose MVP'),
        content: _getTable('MVP'),
        isActive: this._currentStep >= 0,
      ),
      Step(
        title: Text('Choose Most Runs'),
        content: _getTable('mostRuns'),
        isActive: this._currentStep >= 1,
      ),
      Step(
        title: Text('Choose Most Wickets'),
        content: _getTable('mostWickets'),
        isActive: this._currentStep >= 2,
      ),
      Step(
        title: Text('Choose Match Result'),
        content: TextField(),
        isActive: this._currentStep >= 2,
      ),
    ];
    return _step;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SimpleAppBar(
            appBarTitle: 'C O N T E S T',
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                Stepper(
                  steps: _getSteps(),
                  currentStep: this._currentStep,
                  onStepTapped: (index) {
                    setState(() {
                      this._currentStep = index;
                    });
                  },
                  onStepContinue: () {
                    if (this._currentStep < _getSteps().length - 1) {
                      setState(() {
                        this._currentStep += 1;
                      });
                    } else {
                      //complete
                      print('$MVP, $mostRuns, $mostWickets');
                    }
                  },
                  onStepCancel: () {
                    if (this._currentStep > 0) {
                      setState(() {
                        this._currentStep -= 1;
                      });
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
