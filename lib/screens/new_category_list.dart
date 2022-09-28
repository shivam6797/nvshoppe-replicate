import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/ui_sections/drawer.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'subcategory_wise_products.dart';

class NewCategoryList extends StatefulWidget {
  NewCategoryList(
      {Key key,
      this.parent_category_id = 0,
      this.parent_category_name = "",
      this.is_base_category = false,
      this.is_top_category = false})
      : super(key: key);

  final int parent_category_id;
  final String parent_category_name;
  final bool is_base_category;
  final bool is_top_category;

  @override
  _NewCategoryListState createState() => _NewCategoryListState();
}

class _NewCategoryListState extends State<NewCategoryList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _homeCategoryList = [];
  ScrollController _gridScrollController = ScrollController();

  bool _isCategoryInitial = true;

  fetchHomeCategories() async {
    var categoryResponse = await CategoryRepository().getCategories();
    _homeCategoryList.addAll(categoryResponse.categories);
    _isCategoryInitial = false;
    setState(() {});
  }

  @override
  void initState() {
    fetchHomeCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          key: _scaffoldKey,
          drawer: MainDrawer(),
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: Stack(children: [
            CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      8.0,
                      16.0,
                      8.0,
                      0.0,
                    ),
                    child: buildHomeCategories(context),
                  ),
                  Container(
                    height: widget.is_base_category ? 60 : 90,
                  )
                ]))
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: widget.is_base_category || widget.is_top_category
                  ? Container(
                      height: 0,
                    )
                  : buildBottomContainer(),
            )
          ])),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: widget.is_base_category
          ? GestureDetector(
              onTap: () {
                _scaffoldKey.currentState.openDrawer();
              },
              child: Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 0.0),
                  child: Container(
                    child: Image.asset(
                      'assets/hamburger.png',
                      height: 16,
                      color: MyTheme.dark_grey,
                    ),
                  ),
                ),
              ),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      title: Text(
        getAppBarTitle(),
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  String getAppBarTitle() {
    String name = widget.parent_category_name == ""
        ? (widget.is_top_category
            ? AppLocalizations.of(context).category_list_screen_top_categories
            : AppLocalizations.of(context).category_list_screen_categories)
        : widget.parent_category_name;

    return name;
  }

  buildHomeCategories(context) {
    if (_isCategoryInitial && _homeCategoryList.length == 0) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
        ],
      );
    } else if (_homeCategoryList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
          shrinkWrap: true,
          controller: _gridScrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            // maxCrossAxisExtent: 150,
            childAspectRatio: 0.60,
            crossAxisSpacing: 10,
            crossAxisCount: 4,
            mainAxisSpacing: 10,
          ),
          itemCount: _homeCategoryList.length,
          itemBuilder: (BuildContext ctx, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SubCategoryWiseProduct(
                    category_id: _homeCategoryList[index].id,
                    category_name: _homeCategoryList[index].name,
                  );
                }));
              },
              child: Column(
                children: [
                  Container(
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // color: Colors.amber,
                      borderRadius: BorderRadius.circular(5),
                      // border: Border.all(color: MyTheme.golden),
                      image: DecorationImage(
                        image: NetworkImage(
                          "${_homeCategoryList[index].banner}",
                        ),
                        onError: (exception, stackTrace) => AssetImage(
                          'assets/placeholder.png',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(_homeCategoryList[index].name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        // fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            );
          });
    } else if (!_isCategoryInitial && _homeCategoryList.length == 0) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            AppLocalizations.of(context).home_screen_no_category_found,
            style: TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Container buildBottomContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),

      height: widget.is_base_category ? 0 : 80,
      //color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: (MediaQuery.of(context).size.width - 32),
                height: 40,
                child: FlatButton(
                  minWidth: MediaQuery.of(context).size.width,
                  //height: 50,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0))),
                  child: Text(
                    AppLocalizations.of(context)
                            .category_list_screen_all_products_of +
                        " " +
                        widget.parent_category_name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CategoryProducts(
                        category_id: widget.parent_category_id,
                        category_name: widget.parent_category_name,
                      );
                    }));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
