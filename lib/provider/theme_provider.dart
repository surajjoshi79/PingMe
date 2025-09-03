import 'package:chat_app/common/utils.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{

  void toggleTheme(){
    sharedPreferences.sp.setBool('isDark', !(sharedPreferences.sp.getBool("isDark")??false));
    notifyListeners();
  }

  ThemeData getTheme(){
    if(sharedPreferences.sp.getBool('isDark')??false){
      return darkMode;
    }
    return lightMode;
  }
}