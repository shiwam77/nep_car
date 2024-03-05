import 'package:bechdal_app/admin/category/product_by_category_screen.dart';
import 'package:bechdal_app/admin/category/subcategory_screen.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../forms/common_form.dart';
import '../../forms/sell_car_form.dart';
import '../../services/auth.dart';

class CategoryListScreen extends StatelessWidget {
  final bool? isForForm;
  static const String screenId = 'category_list_screen';
  const CategoryListScreen({Key? key, this.isForForm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: blackColor),
        title: Text(
          isForForm == true ? 'Select Category' : 'Categories',
          style: TextStyle(color: blackColor),
        ),
      ),
      body: _body(categoryProvider),
    );
  }

  _body(categoryProvider) {
    Auth authService = Auth();

    return FutureBuilder<QuerySnapshot>(
        future: authService.categories.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: ((context, index) {
                var doc = snapshot.data?.docs[index];
                return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      onTap: () {
                        categoryProvider.setCategory(doc!['category_name']);
                        categoryProvider.setCategorySnapshot(doc);
                        if (doc['category_name'] == 'anonymous') {
                          categoryProvider.setSubCategory('anonymous');
                          Navigator.pushNamed(context, CommonForm.screenId);
                        } else {
                          if (isForForm == true) {
                            if (doc['subcategory'].length == 0) {
                              Navigator.of(context)
                                  .pushNamed(SellCarForm.screenId);
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => SubCategoryScreen(
                                          doc: doc, isForForm: true)));
                            }
                          } else {
                            if (doc['subcategory'].length == 0) {
                              Navigator.of(context)
                                  .pushNamed(ProductByCategory.screenId);
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => SubCategoryScreen(
                                            doc: doc,
                                          )));
                            }
                          }
                        }
                      },
                      leading: Image.network(doc!['img'].toString()),
                      title: Text(
                        doc['category_name'],
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      trailing: doc['subcategory'].length != 0
                          ? const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            )
                          : null,
                    ));
              }));
        });
  }
}
