import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/screens/post/my_post_screen.dart';
import 'package:bechdal_app/screens/welcome_screen.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'category/category_list_screen.dart';

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
          return Scaffold(
            backgroundColor: Color(0xFFEEEEEE),
            appBar: AppBar(
              title: Text(
                'My Profile',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    loadingDialogBox(context, 'Signing Out');
                    await googleSignIn.signOut();
                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        WelcomeScreen.screenId,
                        (route) => false,
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // Set the background color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.logout,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo,
                      radius: 36,
                      child: Text(
                        value!['name'] == "" ? "" : value!['name'][0],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 40.0),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      value!['name'].toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Adjust the color
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      value!['location'].toString(),
                      style: TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 36,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 24, bottom: 18),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Email:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                            ),
                          ),
                          Text(
                            value!['email'].toString(),
                            style: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.11,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 24, bottom: 18),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Number:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                            ),
                          ),
                          Text(
                            value!['mobile'].toString(),
                            style: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.11,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 24, bottom: 18),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rewards Points:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                            ),
                          ),
                          Text(
                            value!['rewards_point'].toString(),
                            style: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.11,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 24, bottom: 18),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Credit Points:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                            ),
                          ),
                          Text(
                            value!['credit_point'].toString(),
                            style: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.11,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyPostScreen(), // Replace with your product creation screen
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        side: const BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 12.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Products',
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyPostScreen(), // Replace with your product creation screen
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        side: const BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 12.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sold Products',
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: 1.sw,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryListScreen(
                                isForForm: true,
                              ), // Replace with your product creation screen
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFF29A461),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8)) // Set the background color
                            ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: Text(
                            'Add New Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.09,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
