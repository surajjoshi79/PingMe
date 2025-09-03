import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils{
  static void showSnackBar(BuildContext context,String msg){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        duration: Duration(seconds: 1),
      )
    );
  }

  static void showProgressBar(BuildContext context){
    showDialog(context: context, builder: (_)=>Center(child: CircularProgressIndicator(color: Colors.purple)));
  }
}

class SharedPref{
  late SharedPreferences sp;
  Future<void> init() async{
    sp=await SharedPreferences.getInstance();
  }
}

final sharedPreferences=SharedPref();