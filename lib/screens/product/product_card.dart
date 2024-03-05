import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/product/product_details_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatefulWidget {
  const ProductCard(
      {Key? key,
      required this.data,
      required this.formattedPrice,
      required this.numberFormat,
      this.FromMyProduct = false,
      this.isDetailPage = false,
      this.byAdmin = false,
      this.isAddToCart = false})
      : super(key: key);

  final QueryDocumentSnapshot<Object?> data;
  final String formattedPrice;
  final NumberFormat numberFormat;
  final bool? FromMyProduct;
  final bool? byAdmin;
  final bool? isDetailPage;
  final bool? isAddToCart;

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
    getAddToCart();
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

  getAddToCart() {
    authService.products.doc(widget.data.id).get().then((value) {
      if (mounted) {
        setState(() {
          fav = value['addToCart'];
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetail(
                      byAdmin: widget.byAdmin,
                      isDetailPage: widget.isDetailPage,
                    )));
      },
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
          child: Stack(
            children: [
              if (widget.FromMyProduct == true)
                Align(
                  alignment: Alignment.topRight,
                  child: SortMenuEditDelete(
                    onChange: (value) {
                      print(value);
                      onMenuChange(value);
                    },
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        child: SizedBox(
                          width: 50,
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.byAdmin == false)
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });

                          if (widget.byAdmin == true) {
                            firebaseUser.updateCart(
                              context: context,
                              isAddToCart: isLiked,
                              productId: widget.data.id,
                            );
                          } else {
                            firebaseUser.updateFavourite(
                              context: context,
                              isLiked: isLiked,
                              productId: widget.data.id,
                            );
                          }
                        },
                        color: isLiked ? secondaryColor : disabledColor,
                        icon: widget.byAdmin == true
                            ? Icon(
                                isLiked
                                    ? CupertinoIcons.cart_fill
                                    : CupertinoIcons.cart,
                              )
                            : Icon(
                                isLiked
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                              ))),
              if (widget.isAddToCart == true)
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });

                          if (widget.byAdmin == true) {
                            firebaseUser.updateCart(
                              context: context,
                              isAddToCart: isLiked,
                              productId: widget.data.id,
                            );
                          } else {
                            firebaseUser.updateFavourite(
                              context: context,
                              isLiked: isLiked,
                              productId: widget.data.id,
                            );
                          }
                        },
                        color: isLiked ? secondaryColor : disabledColor,
                        icon: widget.byAdmin == true
                            ? Icon(
                                isLiked
                                    ? CupertinoIcons.cart_fill
                                    : CupertinoIcons.cart,
                              )
                            : Icon(
                                isLiked
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                              ))),
            ],
          ),
        ),
      ),
    );
  }

  onMenuChange(
    MenuItemB item,
  ) {
    switch (item) {
      case MenuItems.delete:
        delete();
        break;
      case MenuItems.sold:
        update();
        break;
    }
  }

  update() {
    setState(() {
      widget.data.reference.update({"status": "Sold"});
    });
  }

  delete() async {
    FirebaseFirestore.instance
        .runTransaction((Transaction myTransaction) async {
          myTransaction.delete(widget.data.reference);
        })
        .then((value) {})
        .catchError((error) {
          print(error);
        });
  }
}

class SortMenuEditDelete extends StatefulWidget {
  Function? onChange;
  SortMenuEditDelete({Key? key, this.onChange}) : super(key: key);

  @override
  State<SortMenuEditDelete> createState() => _CustomSortMenuTwo();
}

class _CustomSortMenuTwo extends State<SortMenuEditDelete> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        customButton: const Icon(
          Icons.more_vert,
          size: 20,
          color: Color(0xFF424242),
        ),
        items: [
          ...MenuItems.firstItems.map(
            (item) => DropdownMenuItem<MenuItemB>(
              value: item,
              child: MenuItems.buildItem(item),
            ),
          ),
        ],
        buttonStyleData: ButtonStyleData(
          height: 50,
          width: 160,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black26,
            ),
            color: Colors.transparent,
          ),
          elevation: 2,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 150,
          padding: null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Color(0xFF828282),
          ),
          elevation: 8,
          offset: const Offset(-20, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(10),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
        onChanged: (value) {
          widget.onChange!(value);
        },
      ),
    );
  }
}

class MenuItemB {
  final String text;
  final IconData icon;

  const MenuItemB({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  static const List<MenuItemB> firstItems = [delete, sold];

  static const delete = MenuItemB(text: 'delete', icon: Icons.delete);
  static const sold = MenuItemB(text: 'sold', icon: Icons.sell);

  static Widget buildItem(MenuItemB item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItemB item) {
    switch (item) {
      case MenuItems.delete:
        break;

      case MenuItems.sold:
        break;
    }
  }
}
