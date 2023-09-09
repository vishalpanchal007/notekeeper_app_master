import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notekeeper_app_master/pages/Splash_screen.dart';
import 'package:notekeeper_app_master/pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'SplashScreen',
    routes: {
      'SplashScreen': (context) => SplashScreen(),
      'HomePage': (context) => HomePage(),
    },
  ));
}