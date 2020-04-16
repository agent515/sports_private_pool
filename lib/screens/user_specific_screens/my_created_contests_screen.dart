import 'package:flutter/material.dart';
import 'package:sports_private_pool/components/simple_app_bar.dart';
import 'package:sports_private_pool/screens/user_specific_screens/my_created_contest_details_screen.dart';
import 'package:sports_private_pool/services/sport_data.dart';

class MyCreatedContestsScreen extends StatefulWidget {

  MyCreatedContestsScreen({this.loggedInUserData, this.contests_list, this.type});

  final loggedInUserData;
  final contests_list;
  final type;

  @override
  _MyCreatedContestsScreenState createState() => _MyCreatedContestsScreenState();
}

class _MyCreatedContestsScreenState extends State<MyCreatedContestsScreen> {

  dynamic loggedInUserData;
  List contests_list;
  String type;

  @override
  void initState() {
    super.initState();
    loggedInUserData = widget.loggedInUserData;
    contests_list = widget.contests_list;
    type = widget.type;
    print(contests_list);
  }


  List<Widget> _buildContestWidgetsList () {

    List<Widget> contestWidgetList = [];
    for(var contest in contests_list){
      var contestWidget = GestureDetector(
        onTap: () async {
          var sportData = SportData();
          var response = await sportData.getScore(contest['matchId']);
          var matchScore = response;
//          print(matchScore);
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return MyCreatedContestDetailsScreen(contest: contest, type: type, matchScore: matchScore,);
          }));
        },
        child: Padding(
          padding: EdgeInsets.only(left: 20.0, top: 10.0,  bottom: 10.0, right: 20),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black26,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0
                )
              ],
              color:  Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      direction: Axis.vertical,
                      children : <Widget>[Text( contest['match'].toString() ,style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),),]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text( contest['contestId'] ,style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                      ),),
                      Text( contest['admin'] ,style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                      ),),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );

      contestWidgetList.add(contestWidget);
    }
    return contestWidgetList;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SimpleAppBar(
            appBarTitle: type == 'Created' ? 'M Y   C O N T E S T S' : 'J O I N E D   C O N T E S T S',
          ),
          Expanded(
              child : ListView(
                scrollDirection: Axis.vertical,
                children: _buildContestWidgetsList(),
              )
          )
        ],
      ),
    );
  }
}
