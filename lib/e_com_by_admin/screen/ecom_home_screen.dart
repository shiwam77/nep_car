import 'package:bechdal_app/components/main_appbar_with_search.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/screens/location_screen.dart';
import 'package:bechdal_app/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../components/product_listing_widget.dart';

class EcomHomeScreen extends StatefulWidget {
  static const String screenId = 'home_screen';
  const EcomHomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<EcomHomeScreen> createState() => _EcomHomeScreenState();
}

class _EcomHomeScreenState extends State<EcomHomeScreen> {
  late TextEditingController searchController;
  late CarouselController _controller;
  int _current = 0;
  late FocusNode searchNode;

  List<String> downloadBannerImageUrlList() {
    List<String> bannerUrlList = [];
    bannerUrlList.add(
        'https://img.freepik.com/premium-vector/super-sale-only-today-3d-banner-template-design-background_416835-439.jpg?size=626&ext=jpg&ga=GA1.1.1090300621.1681291694&semt=ais');
    bannerUrlList.add(
        'https://img.freepik.com/premium-psd/super-sale-d-text-box-with-discount-3d-rendering_220664-478.jpg?size=626&ext=jpg&ga=GA1.1.1090300621.1681291694&semt=ais');
    bannerUrlList.add(
        "https://img.freepik.com/free-psd/super-sale-banner_1393-365.jpg?1&w=996&t=st=1681292000~exp=1681292600~hmac=8f3dcf04f2c6805a460b937fe6db54292224b971074a5eac3cb922ec5627bf65");

    return bannerUrlList;
  }

  @override
  void initState() {
    searchController = TextEditingController();
    searchNode = FocusNode();
    _controller = CarouselController();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: MainAppBarWithSearch(
          cartBtn: true,
          controller: searchController,
          focusNode: searchNode,
          byAdmin: true,
        ),
      ),
      backgroundColor: Color(0xFFEEEEEE),
      body: homeBodyWidget(),
    );
  }

  lcoationAutoFetchBar(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    User? user = FirebaseAuth.instance.currentUser;
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            customSnackBar(context: context, content: "Something went wrong");
          });
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            customSnackBar(context: context, content: "Addrress not selected");
          });
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          if (data['address'] == null) {
            Position? position = data['location'];
            getFetchedAddress(context, position).then((location) {
              return locationTextWidget(
                location: location,
              );
            });
          } else {
            return locationTextWidget(location: data['address']);
          }
          return const locationTextWidget(location: 'Update Location');
        }
        return const locationTextWidget(location: 'Fetching location');
      },
    );
  }

  Widget homeBodyWidget() {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 40,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(LocationScreen.screenId);
                },
                child: Center(child: lcoationAutoFetchBar(context)),
              ),
            ),
            Container(
              child: Column(
                children: [
                  // CategoryWidget(),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CarouselSlider.builder(
                      itemCount: downloadBannerImageUrlList().length,
                      options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1.0,
                      ),
                      itemBuilder: (context, index, realIdx) {
                        return CachedNetworkImage(
                          imageUrl: downloadBannerImageUrlList()[index],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const ProductListing(
              byAdmin: true,
            )
          ],
        ),
      ),
    );
  }
}

class locationTextWidget extends StatelessWidget {
  final String? location;
  const locationTextWidget({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.pin_drop,
          size: 18,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          location ?? '',
          style: TextStyle(
            color: blackColor,
          ),
        ),
      ],
    );
  }
}
