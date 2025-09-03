import 'package:flutter/material.dart';

class ReadTimeFormat{
  static String formatTime({required BuildContext context,required String time}){
    final date=DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }
  static String formatTimeForCard({required BuildContext context,required String time}){
    final date=DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    if(date.day==DateTime.now().day && date.month==DateTime.now().month && date.year==DateTime.now().year){
      return TimeOfDay.fromDateTime(date).format(context);
    }
    if((DateTime.now().difference(date).inHours/24).round()==1){
      return 'yesterday';
    }
    return 'date.day+${getMonth(date)}';
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