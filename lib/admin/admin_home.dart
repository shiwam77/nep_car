import 'package:bechdal_app/admin/category/category_list_screen.dart';
import 'package:bechdal_app/admin/manage_product.dart';
import 'package:bechdal_app/admin/userlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../services/user.dart';
import 'admin_welcome_screen.dart';

class AdminHome extends StatefulWidget {
  static const String screenId = 'admin_home';

  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  UserService firebaseUser = UserService();
  DocumentSnapshot<Object?>? value;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<DocumentSnapshot<Object?>?>? getUserData() async {
    return firebaseUser.getUserData().then((value) {
      print(value);
      this.value = value;
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DashBoard")),
      drawer: Drawer(
        child: ListView(
          children: [
            FutureBuilder(
                future: getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Container();
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: secondaryColor,
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return UserAccountsDrawerHeader(
                      accountName: Text(value!['name']),
                      accountEmail: Text(value!['email']),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(
                          value!['name'][0],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 40.0),
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: secondaryColor,
                      ),
                    );
                  }
                }),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Manage Product"),
              onTap: () {
                Navigator.pushReplacementNamed(context, AdminHome.screenId);
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text("Create Product"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryListScreen(
                      isForForm: true,
                    ), // Replace with your product creation screen
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text("Manage User"),
              onTap: () {
                Navigator.pushReplacementNamed(context, UserListing.screenId);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      AdminWelcomeScreen.screenId, (route) => false);
                });
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: const ManageProductListing(),
      ),
    );
  }
}
