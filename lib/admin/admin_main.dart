import 'package:bechdal_app/admin/admin_home.dart';
import 'package:bechdal_app/admin/admin_login.dart';
import 'package:bechdal_app/admin/admin_signup.dart';
import 'package:bechdal_app/admin/category/category_list_screen.dart';
import 'package:bechdal_app/admin/category/common_form.dart';
import 'package:bechdal_app/admin/category/subcategory_screen.dart';
import 'package:bechdal_app/admin/category/user_form_review.dart';
import 'package:bechdal_app/admin/userlist.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/auth/email_verify_screen.dart';
import 'package:bechdal_app/screens/location_screen.dart';
import 'package:bechdal_app/screens/marketplace_screen.dart';
import 'package:bechdal_app/screens/product/product_details_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/auth/reset_password_screen.dart';
import 'admin_splash_screen.dart';
import 'admin_welcome_screen.dart';
import 'const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  );

  // FirebaseFirestore _db = FirebaseFirestore.instance;
  // _db.enablePersistence(const PersistenceSettings(synchronizeTabs: true));
  AppConstant.userType = "Admin";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        )
      ],
      child: const Main(),
    ),
  );
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: blackColor,
          backgroundColor: whiteColor,
          fontFamily: 'Oswald',
          scaffoldBackgroundColor: whiteColor,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AdminSplashScreen.screenId,
        routes: {
          AdminSplashScreen.screenId: (context) => const AdminSplashScreen(),
          AdminLoginScreen.screenId: (context) => const AdminLoginScreen(),
          LocationScreen.screenId: (context) => const LocationScreen(),
          HomeScreen.screenId: (context) => const HomeScreen(),
          UserListing.screenId: (context) => const UserListing(),
          AdminWelcomeScreen.screenId: (context) => const AdminWelcomeScreen(),
          AdminHome.screenId: (context) => const AdminHome(),
          ProductDetail.screenId: (context) => const ProductDetail(),
          CategoryListScreen.screenId: (context) => const CategoryListScreen(),
          SubCategoryScreen.screenId: (context) => const SubCategoryScreen(),
          CommonForm.screenId: (context) => const CommonForm(),
          UserFormReview.screenId: (context) => const UserFormReview(),
          AdminRegisterScreen.screenId: (context) =>
              const AdminRegisterScreen(),
          EmailVerifyScreen.screenId: (context) => const EmailVerifyScreen(),
          ResetPasswordScreen.screenId: (context) =>
              const ResetPasswordScreen(),
        });
  }
}
