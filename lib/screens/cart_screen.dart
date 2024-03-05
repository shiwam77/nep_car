import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/screens/product/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/auth.dart';
import '../services/user.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Auth authService = Auth();
  UserService firebaseUser = UserService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('##,##,##0');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        title: Text(
          'Your Cart',
          style: TextStyle(color: blackColor),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: authService.products
              .where('addToCart', arrayContains: firebaseUser.user!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading products..'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: secondaryColor,
                ),
              );
            }
            if (snapshot.data!.docs.length == 0) {
              return Center(
                child: Text(
                  'No Favourites...',
                  style: TextStyle(
                    color: blackColor,
                  ),
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 2 / 2,
                          mainAxisExtent: 250,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: snapshot.data!.size,
                        itemBuilder: (BuildContext context, int index) {
                          var data = snapshot.data!.docs[index];
                          var price = int.parse(data['price']);
                          String formattedPrice = numberFormat.format(price);
                          return ProductCard(
                            data: data,
                            formattedPrice: formattedPrice,
                            numberFormat: numberFormat,
                            byAdmin: true,
                            isDetailPage: true,
                            isAddToCart: true,
                          );
                        }),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
