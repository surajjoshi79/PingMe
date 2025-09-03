import 'package:flutter/material.dart';

class JoinedOnDateFormat{
  static String getJoinedDate(BuildContext context,String joinedDate){
    final date=DateTime.fromMicrosecondsSinceEpoch(int.parse(joinedDate));
    return '${date.day} ${getMonth(date)} ${date.year}';
  }
  static String getMonth(DateTime dateTime){
    switch(dateTime.month){
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      default:
        return 'Dec';
    }
  }
}