import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:ozomall_flutter/main.dart';
import 'package:ozomall_flutter/utils/UserUtils.dart';
import 'package:ozomall_flutter/utils/navigatorUtils.dart';

class Server {
  // 工厂模式
  factory Server() => _getInstance();
  static Server get instance => _getInstance();
  static Server _instance;
  Dio dio;
  BaseOptions options;

  static Server _getInstance() {
    if (_instance == null) {
      _instance = new Server._internal();
    }
    return _instance;
  }

// 初始化
  Server._internal() {
    options = BaseOptions(
      // baseUrl: "http://81.68.211.165:8090", // 生产环境
      baseUrl: "http://192.168.12.5:8090",
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );

    dio = Dio(options);

    //Cookie管理
    // dio.interceptors.add(CookieManager(CookieJar()));

    //添加拦截器
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      print("请求之前");
      return options;
    }, onResponse: (Response response) {
      print("响应之前");
      print(response);
      return response;
    }, onError: (DioError e) {
      print("错误之前");
      if (e.type == DioErrorType.RESPONSE) {
        // 没有权限
        if (e.error.contains("401")) {
          // 跳转登陆页
          navigatorKey.currentState.pushNamed("/login");
        }
      }
      return e; //continue
    }));
  }

  get(path, [params]) async {
    String token = await UserUtils.getToken();
    Response response = await dio.get(path,
        queryParameters: params,
        options: Options(
          headers: {"token": token},
          contentType: Headers.formUrlEncodedContentType,
        ));
    return response.data;
  }

  post(path, [data]) async {
    String token = await UserUtils.getToken();
    Response response = await dio.post(path,
        data: data,
        options: Options(
          headers: {
            "token": token,
          },
        ));
    return response.data;
  }
}
