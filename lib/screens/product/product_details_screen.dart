import 'dart:async';

import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/chat/user_chat_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetail extends StatefulWidget {
  static const screenId = 'product_details_screen';
  const ProductDetail({Key? key}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late GoogleMapController _mapController;
  Auth authService = Auth();
  UserService firebaseUser = UserService();
  bool _loading = true;
  int _index = 0;
  bool isLiked = false;
  List fav = [];
  double _userRating = 3.0;
  int _ratingBarMode = 1;
  double _initialRating = 2.0;
  IconData? _selectedIcon;
  Auth auth = Auth();

  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var productProvider = Provider.of<ProductProvider>(context);
    getFavourites(productProvider: productProvider);
    super.didChangeDependencies();
  }

  getFavourites({required ProductProvider productProvider}) {
    authService.products
        .doc(productProvider.productData!.id)
        .get()
        .then((value) {
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

  _mapLauncher(location) async {
    final availableMaps = await launcher.MapLauncher.installedMaps;
    await availableMaps.first.showMarker(
      coords: launcher.Coords(location.latitude, location.longitude),
      title: "Seller Location is here..",
    );
  }

  Future<void> _callLauncher(number) async {
    if (!await launchUrl(number)) {
      throw 'Could not launch $number';
    }
  }

  _createChatRoom(ProductProvider productProvider) {
    Map product = {
      'product_id': productProvider.productData!.id,
      'product_img': productProvider.productData!['images'][0],
      'price': productProvider.productData!['price'],
      'title': productProvider.productData!['title'],
      'seller': productProvider.productData!['seller_uid'],
    };
    List<String> users = [
      productProvider.sellerDetails!['uid'],
      firebaseUser.user!.uid,
    ];
    String chatroomId =
        '${productProvider.sellerDetails!['uid']}.${firebaseUser.user!.uid}${productProvider.productData!.id}';
    Map<String, dynamic> chatData = {
      'users': users,
      'chatroomId': chatroomId,
      'read': false,
      'product': product,
      'lastChat': null,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch,
    };
    firebaseUser.createChatRoom(data: chatData);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => UserChatScreen(
                  chatroomId: chatroomId,
                )));
  }

  _body({
    required DocumentSnapshot<Object?> data,
    required String formattedDate,
    required ProductProvider productProvider,
    required String formattedPrice,
    required GeoPoint location,
    required NumberFormat numberFormat,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 450,
                      color: Colors.transparent,
                      child: _loading
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: secondaryColor,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Loading..',
                                  )
                                ],
                              ),
                            )
                          : Stack(
                              children: [
                                Center(
                                  child: Image.network(
                                    data['images'][_index],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    height: 60,
                                    color: whiteColor,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                          physics: ScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: data['images'].length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _index = index;
                                                });
                                              },
                                              child: Container(
                                                width: 100,
                                                color: whiteColor,
                                                child: Image.network(
                                                    data['images'][index]),
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ),
                    _loading
                        ? Container()
                        : Container(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ratingBar(data),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        data['title'].toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      if (data['category'] == 'Cars')
                                        Text('[${data['year']}]')
                                    ],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    '\u{20b9} ${formattedPrice}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (data['category'] == 'Cars')
                                    Container(
                                      decoration: BoxDecoration(
                                          color: disabledColor.withOpacity(0.3),
                                          border: Border.all(
                                              color:
                                                  blackColor.withOpacity(0.3))),
                                      margin: EdgeInsets.only(top: 10),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.filter_alt_outlined,
                                                      color: blackColor,
                                                      size: 12,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      data['fuel_type'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.av_timer_outlined,
                                                      color: blackColor,
                                                      size: 12,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      '${numberFormat.format(int.parse(data['km_driven']))} Km',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .account_tree_outlined,
                                                      color: blackColor,
                                                      size: 12,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      data['transmission_type'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            Divider(
                                              color: blackColor,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        color: blackColor,
                                                        size: 12,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        '${data['owners']} Owner',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      child: TextButton.icon(
                                                          onPressed: () {},
                                                          icon: Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            size: 12,
                                                            color: blackColor,
                                                          ),
                                                          label: Text(
                                                            productProvider
                                                                        .sellerDetails !=
                                                                    null
                                                                ? productProvider
                                                                        .sellerDetails![
                                                                    'address']
                                                                : '',
                                                            style: TextStyle(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          )),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text('Posted At'),
                                                        Text(formattedDate
                                                            .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(data['description']),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 10,
                                                ),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: disabledColor
                                                    .withOpacity(0.3),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (data['subcategory'] ==
                                                            'Mobile Phones' ||
                                                        data['subcategory'] ==
                                                            null)
                                                      Text(
                                                        'Brand: ${data['brand']}',
                                                        style: TextStyle(
                                                          color: blackColor,
                                                        ),
                                                      ),
                                                    (data['subcategory'] ==
                                                                'Accessories' ||
                                                            data['subcategory'] ==
                                                                'Tablets' ||
                                                            data['subcategory'] ==
                                                                'For Sale: House & Apartments' ||
                                                            data['subcategory'] ==
                                                                'For Rent: House & Apartments')
                                                        ? Text(
                                                            'Type: ${data['type']}',
                                                            style: TextStyle(
                                                              color: blackColor,
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                    (data['subcategory'] ==
                                                                'For Sale: House & Apartments' ||
                                                            data['subcategory'] ==
                                                                'For Rent: House & Apartments')
                                                        ? Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Bedrooms: ${data['bedroom']}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blackColor,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Bathrooms: ${data['bathroom']}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blackColor,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Furnished Type: ${data['furnishing']}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blackColor,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Construction Status: ${data['construction_status']}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blackColor,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Floors: ${data['floors']}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blackColor,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 20),
                                                            ],
                                                          )
                                                        : SizedBox(),
                                                    Text(
                                                      'Posted At: ${formattedDate}',
                                                      style: TextStyle(
                                                        color: blackColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: blackColor,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: primaryColor,
                                        radius: 40,
                                        child: CircleAvatar(
                                          backgroundColor: secondaryColor,
                                          radius: 37,
                                          child: Icon(
                                            CupertinoIcons.person,
                                            color: whiteColor,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            productProvider
                                                .sellerDetails!['name']
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          subtitle: Text(
                                            'View Profile',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: linkColor,
                                            ),
                                          ),
                                          trailing: IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.arrow_forward_ios,
                                                color: linkColor,
                                                size: 12,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Divider(
                                    color: blackColor,
                                  ),
                                  Text(
                                    'Ad Post at:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 200,
                                    color: disabledColor.withOpacity(0.3),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: GoogleMap(
                                            initialCameraPosition:
                                                CameraPosition(
                                              zoom: 15,
                                              target: LatLng(
                                                location.latitude,
                                                location.longitude,
                                              ),
                                            ),
                                            mapType: MapType.normal,
                                            onMapCreated: (GoogleMapController
                                                controller) {
                                              setState(() {
                                                _mapController = controller;
                                              });
                                            },
                                          ),
                                        ),
                                        Center(
                                            child: Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 35,
                                        )),
                                        Center(
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundColor:
                                                blackColor.withOpacity(0.1),
                                          ),
                                        ),
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: Material(
                                            elevation: 4,
                                            shape: Border.all(
                                                color: disabledColor
                                                    .withOpacity(0.2)),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.alt_route_outlined,
                                              ),
                                              onPressed: () async {
                                                await _mapLauncher(location);
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ad Id: ${data['posted_at']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          'REPORT AD',
                                          style: TextStyle(color: linkColor),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 80,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _ratingBar(DocumentSnapshot<Object?> data) {
    return RatingBar.builder(
      initialRating: double.parse(data['rating']),
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      unratedColor: Colors.amber.withAlpha(50),
      itemCount: 5,
      itemSize: 50.0,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          auth.products.doc(data.id).update({'rating': rating.toString()});
        });
      },
      updateOnDrag: true,
    );
  }

  _bottomSheet({required ProductProvider productProvider}) {
    return BottomAppBar(
      child: Padding(
        padding: (productProvider.productData!['seller_uid'] ==
                firebaseUser.user!.uid)
            ? EdgeInsets.zero
            : EdgeInsets.all(16),
        child: (productProvider.productData!['seller_uid'] ==
                firebaseUser.user!.uid)
            ? null
            : Row(children: [
                Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(secondaryColor)),
                      onPressed: () {
                        _createChatRoom(productProvider);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              size: 16,
                              color: whiteColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Chat',
                            )
                          ],
                        ),
                      )),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(secondaryColor)),
                      onPressed: () async {
                        var phoneNo = Uri.parse(
                            'tel:${productProvider.sellerDetails!['mobile']}');
                        await _callLauncher(phoneNo);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.call,
                              size: 16,
                              color: whiteColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Call',
                            )
                          ],
                        ),
                      )),
                )
              ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    final numberFormat = NumberFormat('##,##,##0');
    var data = productProvider.productData;
    var _price = int.parse(data!['price']);
    var formattedPrice = numberFormat.format(_price);
    var date = DateTime.fromMicrosecondsSinceEpoch(data['posted_at']);
    var formattedDate = DateFormat.yMMMd().format(date);
    GeoPoint _location = productProvider.sellerDetails!['location'];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          iconTheme: IconThemeData(color: blackColor),
          title: Text(
            'Product Details',
            style: TextStyle(color: blackColor),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: blackColor,
              ),
              onPressed: () {},
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                  firebaseUser.updateFavourite(
                    context: context,
                    isLiked: isLiked,
                    productId: data.id,
                  );
                },
                color: isLiked ? secondaryColor : disabledColor,
                icon: Icon(
                  isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                ))
          ],
        ),
        body: _body(
            data: data,
            formattedDate: formattedDate,
            productProvider: productProvider,
            formattedPrice: formattedPrice,
            location: _location,
            numberFormat: numberFormat),
        bottomSheet: _loading
            ? SizedBox()
            : _bottomSheet(productProvider: productProvider));
  }
}
