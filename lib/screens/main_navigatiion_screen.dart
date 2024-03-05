import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/screens/chat/chat_screen.dart';
import 'package:bechdal_app/screens/marketplace_screen.dart';
import 'package:bechdal_app/screens/profile_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../e_com_by_admin/screen/ecom_home_screen.dart';
import 'order_product/order_product.dart';

class MainNavigationScreen extends StatefulWidget {
  static const screenId = 'main_nav_screen';
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  List pages = [
    const EcomHomeScreen(),
    // const CategoryListScreen(isForForm: true),
    // const MyPostScreen(),
    const OrderProductScreen(),
    const HomeScreen(),
    const ChatScreen(),

    const ProfileScreen(),
  ];
  PageController controller = PageController();
  int _index = 0;

  _bottomNavigationBar() {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: DotNavigationBar(
        backgroundColor: Colors.white,
        margin: EdgeInsets.zero,
        paddingR: EdgeInsets.zero,
        selectedItemColor: secondaryColor,
        currentIndex: _index,
        dotIndicatorColor: Colors.transparent,
        unselectedItemColor: disabledColor,
        enablePaddingAnimation: true,
        enableFloatingNavBar: false,
        onTap: (index) {
          setState(() {
            _index = index;
          });
          controller.jumpToPage(index);
        },
        items: [
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                  color: _index == 0 ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(40)),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Icon(
                Icons.home,
                color: _index == 0 ? Colors.white : Colors.black,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                  color: _index == 1 ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(40)),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/claim.png',
                color: _index == 1 ? Colors.white : Colors.black,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                  color: _index == 2 ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(40)),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/market_fill.png',
                width: 20,
                height: 20,
                color: _index == 2 ? Colors.white : Colors.black,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                  color: _index == 3 ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(40)),
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.chat,
                color: _index == 3 ? Colors.white : Colors.black,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                  color: _index == 4 ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(40)),
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.person,
                color: _index == 4 ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: PageView.builder(
            itemCount: pages.length,
            controller: controller,
            onPageChanged: (page) {
              setState(() {
                _index = page;
              });
            },
            itemBuilder: (context, position) {
              return pages[position];
            }),
        bottomNavigationBar: _bottomNavigationBar());
  }
}
