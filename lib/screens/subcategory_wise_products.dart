import 'dart:developer';

import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';

import 'category_list.dart';
import 'category_products.dart';

class SubCategoryWiseProduct extends StatefulWidget {
  SubCategoryWiseProduct({Key key, this.category_name, this.category_id})
      : super(key: key);
  final String category_name;
  final int category_id;

  @override
  _SubCategoryWiseProductState createState() => _SubCategoryWiseProductState();
}

class _SubCategoryWiseProductState extends State<SubCategoryWiseProduct> {
  ScrollController _scrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  List<dynamic> _productList = [];
  bool _isInitial = true;
  int _page = 1;
  String _searchKey = "";
  int _totalData = 0;
  bool _showLoadingContainer = false;
  var selectedId;
  var selectedName;
  funt() async {
    var future =
        await CategoryRepository().getCategories(parent_id: widget.category_id);
    setState(() {
      selectedId = future.categories.first.id.toString();
      selectedName = future.categories.first.name.toString();
      fetchData();
    });
  }

  @override
  void initState() {
    funt();
    // TODO: implement initState
    super.initState();

    // fetchData();

    // _xcrollController.addListener(() {
    //   //print("position: " + _xcrollController.position.pixels.toString());
    //   //print("max: " + _xcrollController.position.maxScrollExtent.toString());

    //   if (_xcrollController.position.pixels ==
    //       _xcrollController.position.maxScrollExtent) {
    //     setState(() {
    //       _page++;
    //     });
    //     _showLoadingContainer = true;
    //     fetchData();
    //   }
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  fetchData() async {
    var productResponse = await ProductRepository().getCategoryProducts(
        id: int.parse(selectedId.toString()), page: _page, name: _searchKey);
    _productList.addAll(productResponse.products);
    _isInitial = false;
    _totalData = productResponse.meta.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  reset() {
    _productList.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: MediaQuery.of(context).size.width / 4.50,
                height: MediaQuery.of(context).size.height,
                child: buildCategoryList()),
            buildProductList(),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: buildLoadingContainer(),
            // )
          ],
        ));
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _productList.length
            ? AppLocalizations.of(context).common_no_more_products
            : AppLocalizations.of(context).common_loading_more_products),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 75,
      /*bottom: PreferredSize(
          child: Container(
            color: MyTheme.textfield_grey,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(4.0)),*/
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "${AppLocalizations.of(context).category_products_screen_search_products_from} : " +
            widget.category_name,
        style: TextStyle(
          color: MyTheme.dark_grey,
          fontSize: 14,
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildProductList() {
    if (_isInitial && _productList.length == 0) {
      return Container(
        width: MediaQuery.of(context).size.width / 1.30,
        child: SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
            scontroller: _scrollController,
          ),
        ),
      );
    } else if (_productList.length > 0) {
      return Container(
        width: MediaQuery.of(context).size.width / 1.30,
        child: GridView.builder(
          // 2
          //addAutomaticKeepAlives: true,
          itemCount: _productList.length,
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // maxCrossAxisExtent: 150,
              crossAxisCount: 2,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              childAspectRatio: 3 / 5.5),
          // padding: EdgeInsets.all(16),
          physics: BouncingScrollPhysics(),
          // shrinkWrap: true,
          itemBuilder: (context, index) {
            return ProductCard(
              id: _productList[index].id,
              image: _productList[index].thumbnail_image,
              name: _productList[index].name,
              main_price: _productList[index].main_price,
              stroked_price: _productList[index].stroked_price,
              has_discount: _productList[index].has_discount,
            );
          },
        ),
      );
    } else if (_totalData == 0) {
      return Center(
        child: Text(
          AppLocalizations.of(context).common_no_data_available,
        ),
      );
    } else {
      return Container(); // should never be happening
    }
  }

  buildCategoryList() {
    var future =
        CategoryRepository().getCategories(parent_id: widget.category_id);

    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            //snapshot.hasError
            print("category list error");
            print(snapshot.error.toString());
            return Container(
              height: 10,
            );
          } else if (snapshot.hasData) {
            //snapshot.hasData
            var categoryResponse = snapshot.data;
            // selectedId = categoryResponse.categories.first.id.toString();
            // selectedName = categoryResponse.categories.first.name.toString();

            return SingleChildScrollView(
              child: ListView.builder(
                itemCount: categoryResponse.categories.length,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedId =
                            categoryResponse.categories[index].id.toString();
                        selectedName =
                            categoryResponse.categories[index].name.toString();
                        _onRefresh();

                        log(selectedId);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            width: 3,
                            color: selectedId.toString() ==
                                    categoryResponse.categories[index].id
                                        .toString()
                                ? MyTheme.accent_color
                                : MyTheme.white,
                          ),
                        ),

                        // color: selectedId.toString() ==
                        //         categoryResponse.categories[index].id.toString()
                        //     ? MyTheme.accent_color.withOpacity(0.30)
                        //     : MyTheme.white,
                        // borderRadius: BorderRadius.all(
                        //   Radius.circular(
                        //     5,
                        //   ),
                        // ),
                      ),
                      child: Column(
                        children: [
                          FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder.png',
                            image: categoryResponse.categories[index].banner,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            categoryResponse.categories[index].name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: selectedId.toString() ==
                                      categoryResponse.categories[index].id
                                          .toString()
                                  ? Colors.black
                                  : MyTheme.dark_grey,
                              fontWeight: selectedId.toString() ==
                                      categoryResponse.categories[index].id
                                          .toString()
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return SingleChildScrollView(
              child: ListView.builder(
                itemCount: 10,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    child: Shimmer.fromColors(
                      baseColor: MyTheme.shimmer_base,
                      highlightColor: MyTheme.shimmer_highlighted,
                      child: Container(
                        height: 100,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            );
          }
        });
  }
}
