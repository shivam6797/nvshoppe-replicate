import 'dart:developer';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:active_ecommerce_flutter/data_model/order_mini_response.dart';
import 'package:active_ecommerce_flutter/data_model/order_detail_response.dart';
import 'package:active_ecommerce_flutter/data_model/order_item_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

class OrderRepository {
  Future<OrderMiniResponse> getOrderList(
      {page = 1, payment_status = "", delivery_status = ""}) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/purchase-historys" +
        "?page=${page}&payment_status=${payment_status}&delivery_status=${delivery_status}");
    log("url:" + url.toString());
    log("token:" + access_token.$);
    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
    });

    log("res:${response.body}");
    return orderMiniResponseFromJson(response.body);
  }

  Future<OrderDetailResponse> getOrderDetails({@required int id = 0}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/purchase-historys-details/" + id.toString());

    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
    });
    log("url:" + url.toString());
    log("token:" + access_token.$);
    log(response.body);
    return orderDetailResponseFromJson(response.body);
  }

  Future<OrderItemResponse> getOrderItems({@required int id = 0}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/purchase-historys-items/" + id.toString());
    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
    });
    log("url:" + url.toString());
    log("token:" + access_token.$);
    log(response.body);
    return orderItemlResponseFromJson(response.body);
  }
}
