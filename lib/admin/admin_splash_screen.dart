import 'dart:async';

import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'admin_home.dart';
import 'admin_welcome_screen.dart';

class AdminSplashScreen extends StatefulWidget {
  static const String screenId = 'admin_splash_screen';
  const AdminSplashScreen({Key? key}) : super(key: key);

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen> {
  Auth authService = Auth();
  @override
  void initState() {
    permissionBasedNavigationFunc();
    super.initState();
  }

  permissionBasedNavigationFunc() {
    Timer(const Duration(seconds: 5), () async {
      if (mounted) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user == null) {
            Navigator.pushReplacementNamed(
                context, AdminWelcomeScreen.screenId);
          } else {
            Navigator.pushReplacementNamed(context, AdminHome.screenId);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(top: 250),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Shopee',
                  style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
                Text(
                  'Sell your un-needs products here !',
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            height: MediaQuery.of(context).size.height,
            child: Lottie.asset(
              "assets/lottie/splash_lottie.json",
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }
}
