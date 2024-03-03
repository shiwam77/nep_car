import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../screens/product/product_details_screen.dart';
import 'menu_button.dart';

class ManageProductListing extends StatefulWidget {
  final bool? isProductByCategory;

  const ManageProductListing({Key? key, this.isProductByCategory})
      : super(key: key);

  @override
  State<ManageProductListing> createState() => _ManageProductListingState();
}

class _ManageProductListingState extends State<ManageProductListing> {
  Auth authService = Auth();

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    var categoryProvider = Provider.of<CategoryProvider>(context);
    final numberFormat = NumberFormat('##,##,##0');
    return StreamBuilder(
        stream: authService.products.orderBy('posted_at').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
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
          return (snapshot.data!.docs.isEmpty)
              ? SizedBox(
                  height: MediaQuery.of(context).size.height - 50,
                  child: const Center(
                    child: Text('No Products Found.'),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (widget.isProductByCategory != null)
                          ? const SizedBox()
                          : Container(
                              child: Column(
                                children: [
                                  Text(
                                    'Manage all the product',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: blackColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                      GridView.builder(
                          physics: const ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 2 / 2.8,
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
                            );
                          }),
                    ],
                  ),
                );
        });
  }
}

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    required this.data,
    required this.formattedPrice,
    required this.numberFormat,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> data;
  final String formattedPrice;
  final NumberFormat numberFormat;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Auth authService = Auth();
  UserService firebaseUser = UserService();

  String address = '';
  DocumentSnapshot? sellerDetails;
  bool isLiked = false;
  List fav = [];
  @override
  void initState() {
    getSellerData();
    getFavourites();
    super.initState();
  }

  getSellerData() {
    firebaseUser.getSellerData(widget.data['seller_uid']).then((value) {
      if (mounted) {
        setState(() {
          address = value['address'];
          sellerDetails = value;
        });
      }
    });
  }

  getFavourites() {
    authService.products.doc(widget.data.id).get().then((value) {
      if (mounted) {
        setState(() {
          fav = value['favourites'];
        });
      }
      if (fav.contains(firebaseUser.user!.uid)) {
        if (mounted) {
          setState(() {
            isLiked = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLiked = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    return InkWell(
      onTap: () {
        productProvider.setSellerDetails(sellerDetails);
        productProvider.setProductDetails(widget.data);
        Navigator.pushNamed(context, ProductDetail.screenId);
      },
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SortMenuEditDelete(
                  onChange: (value) {
                    onMenuChange(value);
                  },
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  height: 120,
                  child: Image.network(
                    widget.data['images'][0],
                    fit: BoxFit.cover,
                  )),
              const SizedBox(
                height: 10,
              ),
              Text(
                '\u{20B9} ${widget.formattedPrice}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.data['title'],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              (widget.data['category'] == 'Cars')
                  ? Text(
                      '${widget.data['year']} - ${widget.numberFormat.format(int.parse(widget.data['km_driven']))} Km')
                  : SizedBox(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_pin,
                    size: 14,
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Flexible(
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  onMenuChange(
    MenuItem item,
  ) {
    switch (item) {
      case MenuItems.delete:
        delete();
        break;
    }
  }

  delete() async {
    FirebaseFirestore.instance
        .runTransaction((Transaction myTransaction) async {
      myTransaction.delete(widget.data.reference);
    }).then((value) {
      setState(() {});
    }).catchError((error) {
      print(error);
    });
  }
}
