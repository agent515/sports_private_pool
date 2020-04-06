import 'package:flutter/material.dart';
import 'package:sports_private_pool/services/networking.dart';

const apiKey = 'itfCIjkbOnb4vW31al0l79I7p992';
const baseUrl = 'https://cricapi.com/api';

//https://cricapi.com/api/fantasySquad?apikey=itfCIjkbOnb4vW31al0l79I7p992&unique_id=1034809

class SportData {

  Future<dynamic> getSquads(matchId) async {
    NetworkHelper networkHelper = NetworkHelper('$baseUrl/fantasySquad?apikey=$apiKey&unique_id=$matchId');

    var squadData = await networkHelper.getData();
    return squadData;
  }

}