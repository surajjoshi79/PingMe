import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';
import 'package:chat_app/common/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/apis/apis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  onClickLoginButton() {
    Utils.showProgressBar(context);
    signInWithGoogle().then((user) {
      Navigator.of(context).pop();
      if(user!=null) {
        APIs.createUser();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return HomeScreen();
          })
        );
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      await GoogleSignIn.instance.initialize(
        serverClientId: '311589812798-lq904ei2vgho7va1rsm08vgrublraekm.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication? googleAuth = googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth?.idToken);
      return await APIs.auth.signInWithCredential(credential);
    }catch(e){
      print(e.toString());
      Utils.showSnackBar(context, 'Something went wrong');
    }
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Welcome to PingMe'),
      ),
      body: Stack(
        children: [
          Positioned(
            height: size.height * 0.4,
            width: size.width * 0.7,
            top: size.height * 0.05,
            left: size.width * 0.15,
            child: Image.asset('assets/icon_foreground.png')
          ),
          Positioned(
            height: size.height * 0.07,
            width: size.width * 0.9,
            bottom: size.height * 0.1,
            left: size.width * 0.05,
            child: ElevatedButton.icon(
              onPressed: onClickLoginButton,
              icon: Image.asset('assets/search.png',height: size.height * 0.03),
              label: Text(
                "  Login with Google",
                style: TextStyle(
                color:sharedPreferences.sp.getBool('isDark')??false?Colors.purple.shade100:Colors.purple,
                fontSize: size.height * 0.022,
                )
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: sharedPreferences.sp.getBool('isDark')??false?Colors.purple:Colors.purple.shade100,
              ),
            )
          ),
        ],
      ),
    );
  }
}
