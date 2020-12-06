import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/tools/Logger.dart';
import 'package:douyin/widget/Loading.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:douyin/config/Config.dart';
import 'package:douyin/net/Code.dart';
import 'package:douyin/net/ResultData.dart';

//http请求
class HttpManager {
  static final EventBus eventBus = new EventBus();

  static const CONTENT_TYPE_JSON = 'application/json';
  static const CONTENT_TYPE_FORM = 'application/x-www-form-urlencoded';

  static requestPost(
      BuildContext context, String modAndFun, Map<String, dynamic> params,
      {noTip = false, delayTime = 1, errMsg = ""}) async {
    String tempUrl = Config.serverUrl;
    String encParams = changeParams(modAndFun, params);

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return new ResultData(Code.errorHandleFunction(Code.NETWORK_ERROR, ""),
          false, Code.NETWORK_ERROR);
    }
    // 如果存在token,默认每个http请求的header都带上token.
    Map<String, String> tempHeaders = {
      "Content-Type": "application/x-www-form-urlencoded"
    };
    tempHeaders.addAll({"VersionCode": "${Config.localVersionCode}"});
    tempHeaders.addAll({"VersionName": "${Config.localVersionName}"});
    tempHeaders.addAll({"Device": Platform.isAndroid ? "Android" : "iOS"});
    tempHeaders.addAll({"user-agent": "Mozilla/5.0"});
    Map<String, String> headers = new HashMap();
    headers.addAll(tempHeaders);

    Options option = new Options(method: "post");
    option.headers = headers;
    option.receiveTimeout = 5000;
    option.sendTimeout = 5000;
    //option.connectTimeout = 5000;

    //delayTime(单位s): 负数:不显示 0:立马显示 正数:间隔x秒后显示
    Timer _loadTimer;
    if (delayTime > 0) {
      int _loadTime = delayTime;
      _loadTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
        if (_loadTime > 0) {
          _loadTime--;
        } else {
          Loading.start(context);
        }
      });
    } else if (delayTime == 0) {
      Loading.start(context);
    }

    var dio = new Dio();
    Response response;
    try {
      response = await dio.request(tempUrl, data: encParams, options: option);
      if (Config.isDebug) print(response);
    } on DioError catch (err) {
      //清除计时器
      _loadTimer?.cancel();
      _loadTimer = null;
      Loading.End();
      //重构错误信息
      int tempErrCode = -999;
      String tempErrMsg = "";
      if (Config.isDebug) Logger.LogError("请求异常：$modAndFun", value: err);
      //如果服务器有下发状态,使用服务器为准
      if (err.response != null) {
        tempErrCode = err.response.statusCode;
      }

      if (err.type == DioErrorType.CONNECT_TIMEOUT) {
        tempErrCode = Code.NETWORK_TIMEOUT;
        tempErrMsg = "链接超时！";
        // }else if (err.type == DioErrorType.DEFAULT){
      } else {
        if (Config.isDebug) {
          tempErrMsg = modAndFun;
          tempErrMsg += "\n${jsonEncode(params)}";
          tempErrMsg += "\n${err.toString()}";
          if (Config.isDebug) print(">>>  输出http错误:  ${err.toString()}");
        } else {
          tempErrMsg = "服务异常,请稍后再试！";
        }
      }
      //如果接口有要求错误提示
      tempErrMsg = errMsg != "" ? errMsg : tempErrMsg;
      if (!noTip) {
        Toast.toast(context, msg: tempErrMsg, position: ToastPostion.center);
      }

      return new ResultData(tempErrMsg, false, tempErrCode);
    }
    //清除计时器
    _loadTimer?.cancel();
    _loadTimer = null;
    Loading.End();

    try {
      if (option.contentType != null && option.contentType == 'text') {
        return new ResultData(response.data, true, Code.SUCCESS);
      } else {
        if (response.statusCode == 200) {
          var tempResponseData = response.data;

          var tempServerCode = tempResponseData["ret"];
          var tempServerData;
          if (tempServerCode == 200) {
            tempServerData = tempResponseData["data"];
          } else {
            return new ResultData(tempServerData, false, tempServerCode);
          }
          return new ResultData(tempServerData, true, tempServerCode);
        }
      }
    } catch (e) {
      if (Config.isDebug) print('返回参数异常:' + e.toString() + "  url:" + tempUrl);
      return new ResultData(response.data, false, response.statusCode,
          headers: response.headers);
    }
    return new ResultData(Code.errorHandleFunction(response.statusCode, ""),
        false, response.statusCode);
  }

  /// 调整上传参数
  static String changeParams(String _modAndFun, Map<String, dynamic> _params) {
    List<String> tempModAndFun = _modAndFun.split("/");
    Map<String, dynamic> tempParams = {};
    tempParams["t"] = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    tempParams["data"] = {};
    tempParams["data"]["mod"] = tempModAndFun[0];
    tempParams["data"]["fun"] = tempModAndFun[1];
    tempParams["data"]["data"] = _params;

    var content = new Utf8Encoder().convert(json.encode(tempParams["data"]));
    var digest = md5.convert(content);
    String tempSignStr =
        digest.toString() + tempParams["t"].toString() + Config.confuseSignKey;
    content = new Utf8Encoder().convert(tempSignStr);
    tempParams["sign"] = md5.convert(content).toString();

    return json.encode(tempParams);
  }

  /* 请求图片 */
  static requestImg(BuildContext context, String _url,
      {noTip = false, delayTime = 1, errMsg = ""}) async {
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return new ResultData(Code.errorHandleFunction(Code.NETWORK_ERROR, ""),
          false, Code.NETWORK_ERROR);
    }

    Options option = new Options(method: "get");
    option.sendTimeout = 5000;
    option.receiveTimeout = 5000;

    Dio dio = new Dio();
    Response response;
    try {
      response = await dio.request(_url, data: null, options: option);
    } on DioError catch (err) {
      if (Config.isDebug) Logger.LogError("请求异常：$_url", value: err);
      return new ResultData(err.message, false, 999);
    }

    try {
      if (option.contentType != null && option.contentType == 'text') {
        return new ResultData(response.data, true, Code.SUCCESS);
      } else {
        if (response.statusCode == 200 || response.statusCode == 201) {
          return new ResultData(response.data, true, 0);
        }
      }
    } catch (e) {
      if (Config.isDebug) print('返回参数异常:' + e.toString() + "  url:" + _url);
      return new ResultData(response.data, false, response.statusCode,
          headers: response.headers);
    }
    return new ResultData(null, false, response.statusCode);
  }
}
