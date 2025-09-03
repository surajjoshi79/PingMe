import 'package:flutter/material.dart';

class LastActiveTimeFormat{
  static String formatTime(BuildContext context,String lastActive){
    final dateTime=DateTime.fromMillisecondsSinceEpoch(int.parse(lastActive));
    if(dateTime.day==DateTime.now().day && dateTime.month==DateTime.now().month && dateTime.year==DateTime.now().year){
      return 'Last seen today at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    }
    if((DateTime.now().difference(dateTime).inHours/24).round()==1){
      return 'Last seen yesterday at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    }
    return 'Last seen ${dateTime.day} ${getMonth(dateTime)} at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
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