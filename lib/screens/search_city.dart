import 'dart:convert';
import 'dart:developer';

import 'package:active_ecommerce_flutter/data_model/search_model.dart';
import 'package:active_ecommerce_flutter/screens/select_store.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchCity extends StatefulWidget {
  const SearchCity({Key key}) : super(key: key);

  @override
  State<SearchCity> createState() => _SearchCityState();
}

class _SearchCityState extends State<SearchCity> {
  final TextEditingController controller = TextEditingController();
  double screenheight = 0;
  double screenwidth = 0;
  List<SearchModel> searchList = [];

  @override
  Widget build(BuildContext context) {
    screenheight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBar,
      body: ListView(
        children: [
          controller.text.isNotEmpty
              ? Container(
                  height: screenheight / 1,
                  width: screenwidth,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: searchList.length,
                      itemBuilder: (context, index) =>
                          searchCityContainer(searchList[index])),
                )
              : Container(
                  height: screenheight / 1,
                  width: screenwidth,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: searchList.length,
                      itemBuilder: (context, index) =>
                          searchListData(searchList[index])),
                ),
        ],
      ),
    );
  }

  AppBar get appBar => AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(),
        title: Container(
          height: 40,
          child: TextField(
            controller: controller,
            cursorColor: Colors.grey,
            onChanged: (value) {
              if (controller.text.isNotEmpty) {
                searchApiGet();
                print("===>changing");
              } else {}
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.grey),
              ),
              labelText: 'Search city',
              labelStyle: TextStyle(color: Colors.grey),
              suffixIcon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
  Widget searchCityContainer(SearchModel item) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectStore(
                          id: item.id.toString(),
                          name: item.name.toString(),
                        )));
          },
          child: Container(
            height: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchListData(SearchModel item) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Card(
        child: InkWell(
          onTap: () {
            log('gfhfg---->>  ${item.id}');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectStore(
                          id: item.id.toString(),
                          name: item.name.toString(),
                        )));
          },
          child: Container(
            height: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //-------------------------Api----------------------//
  Future searchApiGet() async {
    var url = "https://nvshoppe.thedigitalkranti.com/api/v2/cities?keyword=" +
        controller.text;

    var responce = await http.get(Uri.parse(url));
    var dataResponce = jsonDecode(responce.body);

    log('---->>>    ${responce.body}');
    var _datalist = dataResponce["data"] as List;

    setState(() {
      searchList.clear();
      var listdata = _datalist.map((e) => SearchModel.fromJson(e)).toList();
      searchList.addAll(listdata);
    });
  }

  @override
  void initState() {
    searchApiGet();
    super.initState();
  }
}
