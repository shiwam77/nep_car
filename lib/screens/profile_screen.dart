import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/screens/welcome_screen.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  static const screenId = 'profile_screen';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserService firebaseUser = UserService();
  DocumentSnapshot<Object?>? value;

  Future<DocumentSnapshot<Object?>?>? getUserData() async {
    return firebaseUser.getUserData().then((value) {
      print(value);
      this.value = value;
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  accountName: Text(value!['name'],
                      style: TextStyle(color: Colors.black)),
                  accountEmail: Text(
                    value!['email'],
                    style: TextStyle(color: Colors.black38),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Text(
                      value!['name'][0],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                  onTap: () async {
                    loadingDialogBox(context, 'Signing Out');

                    Navigator.of(context).pop();
                    await googleSignIn.signOut();

                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          WelcomeScreen.screenId, (route) => false);
                    });
                  },
                ),
              ],
            );
          } else {
            return Container();
          }
        });
  }
}
