import 'package:chat_app/common/utils.dart';
import 'package:chat_app/provider/theme_provider.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'apis/apis.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For sending notification for any message',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  await Permission.microphone.request();
  await sharedPreferences.init();
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PingMe',
      theme: Provider.of<ThemeProvider>(context).getTheme(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> postDelay() async {
    Future.delayed(const Duration(milliseconds: 2200), () {
      if(APIs.auth.currentUser!=null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return HomeScreen();
          },
        ));
      }else{
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ));
      }
    });
  }
  @override
  void initState() {
    postDelay();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            systemNavigationBarColor: Theme.of(context).colorScheme.primary,
            statusBarColor: Theme.of(context).colorScheme.primary
        )
    );
    return Scaffold(
      body:Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.surface,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(seconds: 2),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Image.asset('assets/icon_foreground.png'),
            ),
          ),
        ),
      )
    );
  }
}
