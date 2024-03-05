import 'dart:async';

import 'package:bechdal_app/e_com_by_admin/screen/ecom_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esewa_flutter/esewa_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/widgets.dart';
import '../../provider/product_provider.dart';
import '../../screens/location_screen.dart';
import '../../services/auth.dart';
import '../../services/user.dart';
import '../../utils.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

lcoationAutoFetchBar(BuildContext context) {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  User? user = FirebaseAuth.instance.currentUser;
  return FutureBuilder<DocumentSnapshot>(
    future: users.doc(user!.uid).get(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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

class _PaymentScreenState extends State<PaymentScreen> {
  Auth authService = Auth();
  UserService firebaseUser = UserService();
  int creditPoint = 0;
  double rewards = 0.0;
  String selectedPaymentOption = '';
  bool isPaymentSelected = false; // Added bool variable
  DocumentSnapshot<Object?>? value;
  bool isRedeem = false;
  double getPrice = 0.0;
  double subRewards = 0.0;

  Future<DocumentSnapshot<Object?>?>? getUserData() async {
    return firebaseUser.getUserData().then((value) {
      this.value = value;
      creditPoint = value['credit_point'];
      rewards = value['rewards_point'];
      subRewards = rewards;
      return value;
    });
  }

  @override
  void initState() {
    var productProvider = Provider.of<ProductProvider>(context, listen: false);
    var data = productProvider.productData;
    getPrice = double.parse(data!['price'].toString());
    getUserData();
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context, listen: false);
    final numberFormat = NumberFormat('##,##,##0');
    var data = productProvider.productData;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          iconTheme: IconThemeData(color: blackColor),
          title: Text(
            'Payment',
            style: TextStyle(color: blackColor),
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.93),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 1.sw,
                height: 118,
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF9B9B9B),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                          height: 0.11,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Rs $getPrice',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                          height: 0.04,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$rewards reward points',
                            style: TextStyle(
                              color: Color(0xFF008815),
                              fontSize: 13,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.13,
                            ),
                          ),
                          Text(
                            '$creditPoint credit point',
                            style: TextStyle(
                              color: Color(0xFFB20000),
                              fontSize: 13,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.13,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              Text(
                'Delivery Address And Contact',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w600,
                  height: 0.09,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                width: 1.sw,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Default Delivery Address',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(LocationScreen.screenId);
                            },
                            child: Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w600,
                                height: 0.08,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(LocationScreen.screenId);
                          },
                          child: Center(child: lcoationAutoFetchBar(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                width: 1.sw,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Default Contact Number',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {},
                            child: Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w600,
                                height: 0.08,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 22),
                      Text(
                        '99812312121312',
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
              ),
              SizedBox(
                height: 32,
              ),
              Text(
                'Select Payment Method',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w600,
                  height: 0.09,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RadioListTile(
                title: Text(
                  'Cash On Delivery',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w600,
                    height: 0.08,
                  ),
                ),
                value: 'Cash',
                groupValue: selectedPaymentOption as String,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentOption = value as String;
                    isPaymentSelected =
                        true; // Set bool to true when payment selected
                  });
                },
              ),
              RadioListTile(
                title: Text(
                  'esewa Digital Payment',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w600,
                    height: 0.08,
                  ),
                ),
                value: 'eSewa',
                groupValue: selectedPaymentOption as String,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentOption = value as String;
                    isPaymentSelected =
                        true; // Set bool to true when payment selected
                  });
                },
              ),
              // Text(
              //   'Selected Payment Option: $selectedPaymentOption',
              //   style: TextStyle(fontSize: 16),
              // ),
              // SizedBox(height: 20),
              // Text(
              //   'Total Price: $getPrice',
              //   style: TextStyle(fontSize: 16),
              // ),
              // SizedBox(height: 20),
              Spacer(),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (endsWithZero(creditPoint)) {
                          setState(() {
                            isRedeem = !isRedeem;
                            if (isRedeem) {
                              getPrice = getPrice - rewards;
                              rewards = 0;
                            } else {
                              getPrice = getPrice + subRewards;
                              rewards = subRewards;
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9D9D9D),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              'Redeem ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w600,
                                height: 0.09,
                              ),
                            ),
                          ),
                          Spacer(),
                          if (isRedeem) Icon(Icons.check_box),
                          if (!isRedeem) Icon(Icons.check_box_outline_blank)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF29A461),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: () async {
                          if (selectedPaymentOption == "eSewa") {
                            //if(point == 100){
                            // convert point into money}
                            //then substract money from total amount i.e double.parse(data!['price'].toString())
                            if (isRedeem) {
                              getPrice = getPrice - rewards;
                            }
                            final result = await Esewa.i.init(
                                context: context,
                                eSewaConfig: ESewaConfig.dev(
                                  su: 'https://www.marvel.com/hello',
                                  // amt: double.parse(data!['price'].toString()),
                                  amt: 100,
                                  fu: 'https://www.marvel.com/hello',
                                  pid: DateTime.now().toIso8601String(),
                                ),
                                walletPageContent: EsewaPageContent(
                                  appBar: AppBar(
                                      systemOverlayStyle:
                                          const SystemUiOverlayStyle(
                                        statusBarColor: Colors.transparent,
                                        statusBarIconBrightness: Brightness
                                            .dark, // For Android (dark icons)
                                        statusBarBrightness: Brightness
                                            .light, // For iOS (dark icons)
                                      ),
                                      elevation: 1,
                                      leading: Builder(builder: (context) {
                                        return IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(
                                              Icons.arrow_back_ios_new,
                                              color: Colors.white,
                                            ));
                                      }),
                                      title: Text(
                                        data!['title'].toString(),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      iconTheme:
                                          IconThemeData(color: Colors.green)),
                                  progressLoader: CircularProgressIndicator(),
                                ));

                            if (result.data != null && result.error == null) {
                              if (mounted) {
                                creditPoint = creditPoint + 1;

                                double getRewards = (getPrice / 100) * 5.0;
                                rewards = rewards + getRewards;
                                print(getRewards);
                                firebaseUser.updateCreditPoint(
                                  context,
                                  {
                                    'credit_point': creditPoint,
                                    'rewards_point': rewards,
                                  },
                                ).then((value) {
                                  setState(() {});
                                });
                              }
                            }
                          } else {
                            if (mounted) {
                              creditPoint = creditPoint + 1;

                              double getRewards = (getPrice / 100) * 5.0;
                              rewards = rewards + getRewards;
                              print(getRewards);
                              firebaseUser.updateCreditPoint(
                                context,
                                {
                                  'credit_point': creditPoint,
                                  'rewards_point': rewards,
                                },
                              ).then((value) {
                                setState(() {});
                                Navigator.pop(context);
                              });
                            }
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'Proceed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              height: 0.09,
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool endsWithZero(int number) {
  return number % 10 == 0;
}
