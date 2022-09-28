import 'dart:convert';
import 'dart:developer';
import 'package:active_ecommerce_flutter/data_model/selectstoremodel.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelectStore extends StatefulWidget {
  final String id;
  final String name;

  const SelectStore({Key key, this.id, this.name}) : super(key: key);

  @override
  State<SelectStore> createState() => _SelectStoreState();
}

class _SelectStoreState extends State<SelectStore> {
  final TextEditingController controller = TextEditingController();
  double screenheight = 0;
  double screenwidth = 0;
  List<SelectStoreModel> selectStoreList = [];
  @override
  Widget build(BuildContext context) {
    screenheight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBar,
      body: Container(
        height: screenheight / 1,
        width: screenwidth,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: selectStoreList.length,
            itemBuilder: (context, index) =>
                selectSoreContainer(selectStoreList[index])),
      ),
    );
  }

  AppBar get appBar => AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Select Store",
          style: TextStyle(color: Colors.black),
        ),
      );
  Widget searchContainer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 40,
        child: TextField(
          controller: controller,
          cursorColor: Colors.grey,
          onChanged: (value) {
            if (controller.text.isNotEmpty) {
              selectStoreApiGet();
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
  }

  Widget selectSoreContainer(SelectStoreModel item) {
    return InkWell(
      onTap: () async {
        var prefs = await SharedPreferences.getInstance();
        prefs.setInt("shopId", item.id);
        prefs.setString("cityId", widget.id.toString());
        prefs.setString("cityName", widget.name.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Main(),
          ),
        );
      },
      child: Card(
        child: ListTile(
            title: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: NetworkImage(item.logo == null
                        ? "https://franchising.bg/public/files/richeditor/articles/obekt-franchajz.jpg"
                        : item.logo),
                    fit: BoxFit.cover),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Text("pmonu@gmail.com"),
                Text(
                  item.id.toString(),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }

  //-------------------------Api----------------//

  Future selectStoreApiGet() async {
    var url = "https://nvshoppe.thedigitalkranti.com/api/v2/shop/search/" +
        widget.id.toString();
    // widget.name.toString();
    log("===>" + url);
    var responce = await http.get(Uri.parse(url));
    var dataResponce = jsonDecode(responce.body);
    log("===>${responce.body}");
    var _datalist = dataResponce["data"] as List;

    setState(() {
      selectStoreList.clear();
      var listdata =
          _datalist.map((e) => SelectStoreModel.fromJson(e)).toList();
      selectStoreList.addAll(listdata);
    });
  }

  @override
  void initState() {
    selectStoreApiGet();
    super.initState();
  }
}
