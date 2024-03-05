import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/models/product_model.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/cart_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/search.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MainAppBarWithSearch extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool? byAdmin;
  final bool? cartBtn;
  const MainAppBarWithSearch({
    required this.controller,
    required this.focusNode,
    this.byAdmin = false,
    Key? key,
    this.cartBtn = false,
  }) : super(key: key);

  @override
  State<MainAppBarWithSearch> createState() => _MainAppBarWithSearchState();
}

class _MainAppBarWithSearchState extends State<MainAppBarWithSearch> {
  static List<Products> products = [];
  Auth authService = Auth();
  Search searchService = Search();
  String address = '';
  UserService firebaseUser = UserService();
  DocumentSnapshot? sellerDetails;
  @override
  void initState() {
    authService.products
        .where('by_admin', isEqualTo: widget.byAdmin)
        .get()
        .then(((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        products.add(Products(
            document: doc,
            title: doc['title'],
            description: doc['description'],
            category: doc['category'],
            subcategory: doc['subcategory'],
            price: doc['price'],
            postDate: doc['posted_at']));
        getSellerAddress(doc['seller_uid']);
      });
    }));
    super.initState();
  }

  getSellerAddress(selledId) {
    firebaseUser.getSellerData(selledId).then((value) => {
          setState(() {
            address = value['address'];
            sellerDetails = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    return SafeArea(
      child: Container(
        height: 70,
        color: Colors.transparent,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Shopee",
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 34,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    searchService.searchQueryPage(
                        context: context,
                        products: products,
                        address: address,
                        byAdmin: widget.byAdmin,
                        sellerDetails: sellerDetails,
                        provider: provider);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: EdgeInsets.only(right: 10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: disabledColor.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.search,
                    ),
                  ),
                ),
                if (widget.cartBtn == true)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: disabledColor.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
