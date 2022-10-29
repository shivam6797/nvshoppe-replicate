import 'dart:developer';

import 'package:active_ecommerce_flutter/custom/CommonFunctoins.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/shop_repository.dart';
import 'package:active_ecommerce_flutter/screens/filter.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal_list.dart';
import 'package:active_ecommerce_flutter/screens/search_city.dart';
import 'package:active_ecommerce_flutter/screens/subcategory_wise_products.dart';
import 'package:active_ecommerce_flutter/screens/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/top_selling_products.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/screens/category_list.dart';
import 'package:active_ecommerce_flutter/ui_elements/list_product_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/mini_product_card.dart';
import 'package:active_ecommerce_flutter/ui_sections/drawer.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:active_ecommerce_flutter/repositories/sliders_repository.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title, this.show_back_button = false, go_back = true})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  bool show_back_button;
  bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _current_slider = 0;
  ScrollController _featuredProductScrollController;
  ScrollController _mainScrollController = ScrollController();
  ScrollController _gridScrollController = ScrollController();

  AnimationController pirated_logo_controller;
  Animation pirated_logo_animation;
  int shopId = 0;
  var _carouselImageList = [];
  var _homeCategoryList = [];
  var _featuredProductList = [];
  bool _isProductInitial = true;
  bool _isCategoryInitial = true;
  bool _isCarouselInitial = true;
  int _totalProductData = 0;
  int _productPage = 1;
  bool _showProductLoadingContainer = false;
  ScrollController _scrollController = ScrollController();

  var _shopDetails = null;

  List<dynamic> _newArrivalProducts = [];
  bool _newArrivalProductInit = false;
  List<dynamic> _topProducts = [];
  bool _topProductInit = false;
  List<dynamic> _featuredProducts = [];
  bool _featuredProductInit = false;
  @override
  void initState() {
    print("app_mobile_language.en${app_mobile_language.$}");
    print("app_language.${app_language.$}");
    print("app_language_rtl${app_language_rtl.$}");
    checkCity();
    super.initState();
    if (AppConfig.purchase_code == "") {
      initPiratedAnimation();
    }

    fetchAll();

    _mainScrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _productPage++;
        });
        _showProductLoadingContainer = true;
        fetchFeaturedProducts();
      }
    });
  }

  var cityId;
  var cityName;
  var user_id;
  checkCity() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      cityId = await prefs.getString("cityId");
      cityName = await prefs.getString("cityName");
      user_id = await prefs.getString("userId");
      log("cITY id nAME => ${cityId.toString() + cityName}");
      log("user id nAME => ${user_id.toString() + user_id}");

    } catch (e) {
      log(e);
    }
  }

  fetchAll() async {
    var prefs = await SharedPreferences.getInstance();
    shopId = await prefs.getInt("shopId");
    fetchCarouselImages();
    fetchHomeCategories();
    fetchFeaturedProducts();
    fetchProductDetails();
    fetchNewArrivalProducts();
    fetchTopProducts();
    // AddonsHelper().setAddonsData();
    // BusinessSettingHelper().setBusinessSettingData();
  }

  fetchCarouselImages() async {
    var carouselResponse = await SlidersRepository().getSliders(shopId);
    carouselResponse.sliders.forEach((slider) {
      _carouselImageList.add(slider.photo);
    });
    _isCarouselInitial = false;
    setState(() {});
  }

  fetchHomeCategories() async {
    var categoryResponse = await CategoryRepository().getTopCategories(shopId);
    _homeCategoryList.addAll(categoryResponse.categories);
    _isCategoryInitial = false;
    setState(() {});
  }

  // fetchFeaturedProducts() async {
  //   var productResponse = await ProductRepository().getFeaturedProducts(
  //     page: _productPage,
  //   );

  //   _featuredProductList.addAll(productResponse.products);
  //   _isProductInitial = false;
  //   _totalProductData = productResponse.meta.total;
  //   _showProductLoadingContainer = false;
  //   setState(() {});
  // }

  fetchProductDetails() async {
    var shopDetailsResponse = await ShopRepository().getShopInfo(id: shopId);

    //print('ss:' + shopDetailsResponse.toString());
    if (shopDetailsResponse.shops.length > 0) {
      _shopDetails = shopDetailsResponse.shops[0];
    }

    if (_shopDetails != null) {
      _shopDetails.sliders.forEach((slider) {
        _carouselImageList.add(slider);
      });
    }

    setState(() {});
  }

  fetchNewArrivalProducts() async {
    var newArrivalProductResponse =
        await ShopRepository().getNewFromThisSellerProducts(id: shopId);
    _newArrivalProducts.addAll(newArrivalProductResponse.products);
    _newArrivalProductInit = true;

    setState(() {});
  }

  fetchTopProducts() async {
    var topProductResponse =
        await ShopRepository().getTopFromThisSellerProducts(id: shopId);
    _topProducts.addAll(topProductResponse.products);
    _topProductInit = true;
  }

  fetchFeaturedProducts() async {
    var featuredProductResponse =
        await ShopRepository().getfeaturedFromThisSellerProducts(id: shopId);
    _featuredProducts.addAll(featuredProductResponse.products);
    _featuredProductInit = true;
  }

  reset() {
    _carouselImageList.clear();
    _homeCategoryList.clear();
    _isCarouselInitial = true;
    _isCategoryInitial = true;

    _shopDetails = null;
    _carouselImageList.clear();
    _newArrivalProducts.clear();
    _topProducts.clear();
    _featuredProducts.clear();
    _topProductInit = false;
    _newArrivalProductInit = false;
    _featuredProductInit = false;
    setState(() {});

    resetProductList();
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  resetProductList() {
    _featuredProductList.clear();
    _isProductInitial = true;
    _totalProductData = 0;
    _productPage = 1;
    _showProductLoadingContainer = false;
    setState(() {});
  }

  initPiratedAnimation() {
    pirated_logo_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    pirated_logo_animation = Tween(begin: 40.0, end: 60.0).animate(
        CurvedAnimation(
            curve: Curves.bounceOut, parent: pirated_logo_controller));

    pirated_logo_controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        pirated_logo_controller.repeat();
      }
    });

    pirated_logo_controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    pirated_logo_controller?.dispose();
    _mainScrollController.dispose();
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  buildCarouselSlider(context) {
    if (_shopDetails != null) {
      return ShimmerHelper().buildBasicShimmer(
        height: 190.0,
      );
    } else if (_carouselImageList.length > 0) {
      return CarouselSlider(
        options: CarouselOptions(
            aspectRatio: 3,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInCubic,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _current_slider = index;
              });
            }),
        items: _carouselImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i ??
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDn_SgavHUMpVMR4OWP7aOXC1gNAHdGu32NA&usqp=CAU",
                            fit: BoxFit.fill,
                          ))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _carouselImageList.map((url) {
                        int index = _carouselImageList.indexOf(url);
                        return Container(
                          width: 7.0,
                          height: 7.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current_slider == index
                                ? MyTheme.white
                                : Color.fromRGBO(112, 112, 112, .3),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      );
    } else {
      return Container();
    }
  }

  buildNewArrivalList() {
    if (_newArrivalProductInit == false && _newArrivalProducts.length == 0) {
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
    } else if (_newArrivalProducts.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          height: 175,
          child: ListView.builder(
            itemCount: _newArrivalProducts.length,
            scrollDirection: Axis.horizontal,
            itemExtent: 120,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: MiniProductCard(
                  id: _newArrivalProducts[index].id,
                  image: _newArrivalProducts[index].thumbnail_image,
                  name: _newArrivalProducts[index].name,
                  main_price: _newArrivalProducts[index].main_price,
                  stroked_price: _newArrivalProducts[index].stroked_price,
                  has_discount: _newArrivalProducts[index].has_discount,
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).seller_details_screen_no_new_arrival,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  buildTopSellingProductList() {
    if (_topProductInit == false && _topProducts.length == 0) {
      return Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
        ],
      );
    } else if (_topProducts.length > 0) {
      return SingleChildScrollView(
        child: GridView.builder(
          itemCount: _topProducts.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              //crossAxisCount: 3,
              maxCrossAxisExtent: 150,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 3 / 5.5),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            // 3
            return Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: ProductCard(
                  id: _topProducts[index].id,
                  image: _topProducts[index].thumbnail_image,
                  name: _topProducts[index].name,
                  main_price: _topProducts[index].main_price,
                  stroked_price: _topProducts[index].stroked_price,
                  has_discount: _topProducts[index].has_discount),
            );
          },
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                  AppLocalizations.of(context)
                      .seller_details_screen_no_top_selling_products,
                  style: TextStyle(color: MyTheme.font_grey))));
    }
  }

  buildfeaturedProductList() {
    if (_featuredProductInit == false && _featuredProducts.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildProductGridShimmer(scontroller: _scrollController));
    } else if (_featuredProducts.length > 0) {
      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: _featuredProducts.length,
        //controller: _scrollController,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 3 / 5.5),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ProductCard(
              id: _featuredProducts[index].id,
              image: _featuredProducts[index].thumbnail_image,
              name: _featuredProducts[index].name,
              main_price: _featuredProducts[index].main_price,
              stroked_price: _featuredProducts[index].stroked_price,
              has_discount: _featuredProducts[index].has_discount);
        },
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                  AppLocalizations.of(context)
                      .seller_details_screen_no_featured_porducts,
                  style: TextStyle(color: MyTheme.font_grey))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //print(MediaQuery.of(context).viewPadding.top);

    return WillPopScope(
      onWillPop: () async {
        CommonFunctions(context).appExitDialog();
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: buildAppBar(statusBarHeight, context),
            drawer: MainDrawer(),
            body: RefreshIndicator(
              color: MyTheme.accent_color,
              backgroundColor: Colors.white,
              onRefresh: _onPageRefresh,
              child: CustomScrollView(
                controller: _mainScrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // crousal
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          16.0,
                          16.0,
                          0.0,
                        ),
                        child: buildCarouselSlider(context),
                      ),
                    ]),
                  ),
                  // category
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          16.0,
                          16.0,
                          0.0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                              .home_screen_top_categories,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          16.0,
                          8.0,
                          0.0,
                        ),
                        child: buildHomeCategories(context),
                      ),
                    ]),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)
                            .seller_details_screen_new_arrivals,
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8.0,
                        8.0,
                        0.0,
                        0.0,
                      ),
                      child: buildNewArrivalList(),
                    ),
                  ])),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          8.0,
                          16.0,
                          0.0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                              .seller_details_screen_no_top_selling_products,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          8.0,
                          16.0,
                          0.0,
                        ),
                        child: buildTopSellingProductList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          8.0,
                          16.0,
                          0.0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                              .seller_details_screen_featured_products,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(
                            8.0,
                            8.0,
                            16.0,
                            0.0,
                          ),
                          child: buildfeaturedProductList())
                    ]),
                  )
                ],
              ),
            )),
      ),
    );
  }

  buildHomeFeaturedProducts(context) {
    if (_isProductInitial && _featuredProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _featuredProductScrollController));
    } else if (_featuredProductList.length > 0) {
      //snapshot.hasData

      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: _featuredProductList.length,
        controller: _featuredProductScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.618),
        padding: EdgeInsets.all(8),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ProductCard(
              id: _featuredProductList[index].id,
              image: _featuredProductList[index].thumbnail_image,
              name: _featuredProductList[index].name,
              main_price: _featuredProductList[index].main_price,
              stroked_price: _featuredProductList[index].stroked_price,
              has_discount: _featuredProductList[index].has_discount);
        },
      );
    } else if (_totalProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
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

  buildHomeMenuRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CategoryList(
                is_top_category: true,
              );
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/top_categories.png"),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppLocalizations.of(context).home_screen_top_categories,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(132, 132, 132, 1),
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Filter(
                selected_filter: "brands",
              );
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/brands.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(AppLocalizations.of(context).home_screen_brands,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TopSellingProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/top_sellers.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        AppLocalizations.of(context).home_screen_top_sellers,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TodaysDealProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/todays_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        AppLocalizations.of(context).home_screen_todays_deal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FlashDealList();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/flash_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        AppLocalizations.of(context).home_screen_flash_deal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        )
      ],
    );
  }

  buildHomeCarouselSlider(context) {
    if (_isCarouselInitial && _carouselImageList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Shimmer.fromColors(
          baseColor: MyTheme.shimmer_base,
          highlightColor: MyTheme.shimmer_highlighted,
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      );
    } else if (_carouselImageList.length > 0) {
      return CarouselSlider(
        options: CarouselOptions(
            aspectRatio: 2.67,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInCubic,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _current_slider = index;
              });
            }),
        items: _carouselImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i,
                            fit: BoxFit.fill,
                          ))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _carouselImageList.map((url) {
                        int index = _carouselImageList.indexOf(url);
                        return Container(
                          width: 7.0,
                          height: 7.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current_slider == index
                                ? MyTheme.white
                                : Color.fromRGBO(112, 112, 112, .3),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      );
    } else if (!_isCarouselInitial && _carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildAppBar(double statusBarHeight, BuildContext context) {
    return PreferredSize(
      preferredSize: Size(10, 130),
      child: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
            child: Container(
              child: Padding(
                padding: app_language_rtl.$
                    ? const EdgeInsets.only(
                        top: 14.0,
                        bottom: 14,
                        left: 12,
                        right: 12,
                      )
                    : const EdgeInsets.only(
                        top: 14.0,
                        bottom: 14,
                        left: 12,
                        right: 12,
                      ),
                // when notification bell will be shown , the right padding will cease to exist.
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Filter();
                        },
                      ),
                    );
                  },
                  child: buildHomeSearchBox(context),
                ),
              ),
            ),
            preferredSize: Size(10, 10)),
        leading: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState.openDrawer();
          },
          child: widget.show_back_button
              ? Builder(
                  builder: (context) => IconButton(
                      icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
                      onPressed: () {
                        if (!widget.go_back) {
                          return;
                        }
                        return Navigator.of(context).pop();
                      }),
                )
              : Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 0.0),
                    child: Container(
                      child: Image.asset(
                        'assets/hamburger.png',
                        height: 16,
                        //color: MyTheme.dark_grey,
                        color: MyTheme.dark_grey,
                      ),
                    ),
                  ),
                ),
        ),
        title: Container(
          // height: kToolbarHeight +
          //     statusBarHeight -
          //     (MediaQuery.of(context).viewPadding.top > 40 ? 16.0 : 16.0),
          //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   "Delivery in 10 minutes",
              //   maxLines: 1,
              //   style: TextStyle(
              //     decorationThickness: 50,
              //     fontSize: 22,
              //     overflow: TextOverflow.ellipsis,
              //     color: Colors.black,
              //     fontWeight: FontWeight.w900,
              //   ),
              // ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SearchCity();
                      }));
                    },
                    child: Container(
                      width: 100,
                      child: Row(
                        children: [
                          Text(
                            cityName != null ? cityName.toString() : "Soory",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.grey,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        elevation: 0.0,
        titleSpacing: 0,
        actions: <Widget>[
          InkWell(
            onTap: () {
              ToastComponent.showDialog(
                  AppLocalizations.of(context).common_coming_soon, context,
                  gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
            },
            child: Visibility(
              visible: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 18.0, horizontal: 12.0),
                child: Image.asset(
                  'assets/bell.png',
                  height: 16,
                  color: MyTheme.dark_grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildHomeSearchBox(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          color: Colors.white,
          boxShadow: [
            new BoxShadow(
              color: Colors.grey,
              blurRadius: 8.0,
            ),
          ]),
      child: TextField(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Filter();
          }));
        },
        autofocus: false,
        decoration: InputDecoration(
            hintText: AppLocalizations.of(context).home_screen_search,
            hintStyle: TextStyle(fontSize: 18.0, color: MyTheme.textfield_grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyTheme.textfield_grey, width: 0.5),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyTheme.textfield_grey, width: 1.0),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.search,
                color: Colors.black,
                size: 22,
              ),
            ),
            contentPadding: EdgeInsets.all(0.0)),
      ),
    );
  }

  Container buildProductLoadingContainer() {
    return Container(
      height: _showProductLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalProductData == _featuredProductList.length
            ? AppLocalizations.of(context).common_no_more_products
            : AppLocalizations.of(context).common_loading_more_products),
      ),
    );
  }
}
