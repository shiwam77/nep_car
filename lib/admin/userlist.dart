import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../services/auth.dart';
import 'menu_button.dart';

class UserListing extends StatefulWidget {
  static const String screenId = 'user';

  const UserListing({Key? key}) : super(key: key);

  @override
  State<UserListing> createState() => _UserListingState();
}

class _UserListingState extends State<UserListing> {
  Auth authService = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder(
                stream: authService.users.snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading products..'));
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
                              Column(
                                children: [
                                  Text(
                                    'Watch all the User',
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
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.size,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var data = snapshot.data!.docs[index];

                                      return ListTile(
                                        selectedTileColor: Colors.orange[100],
                                        leading: Icon(Icons.people),
                                        title: Text(data['name']),
                                        trailing: SortMenuEditDelete(
                                          onChange: (value) {
                                            onMenuChange(value, data);
                                          },
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        );
                }),
          ],
        ),
      ),
    );
  }

  onMenuChange(
    MenuItem item,
    data,
  ) {
    switch (item) {
      case MenuItems.delete:
        delete(data);
        break;
    }
  }

  delete(data) async {
    FirebaseFirestore.instance
        .runTransaction((Transaction myTransaction) async {
          myTransaction.delete(data.reference);
        })
        .then((value) {})
        .catchError((error) {
          print(error);
        });
  }
}
