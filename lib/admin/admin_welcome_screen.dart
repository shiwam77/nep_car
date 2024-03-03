import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'admin_login.dart';
import 'admin_signup.dart';

class AdminWelcomeScreen extends StatelessWidget {
  static const screenId = 'admin_welcome_screen';
  const AdminWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: welcomeBodyWidget(context),
    );
  }

  Widget welcomeBodyWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin DashBoard For NepCar',
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your data from  here',
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Lottie.asset(
                'assets/lottie/welcome_lottie.json',
                width: double.infinity,
                height: 350,
              ),
            )
          ]),
        ),
        _bottomNavigationBar(context),
      ],
    );
  }

  Widget _bottomNavigationBar(context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor: whiteColor,
              borderColor: blackColor,
              textColor: blackColor,
              text: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, AdminLoginScreen.screenId);
              }),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor: secondaryColor,
              text: 'Sign Up',
              textColor: whiteColor,
              onPressed: () {
                Navigator.pushNamed(context, AdminRegisterScreen.screenId);
              }),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}
