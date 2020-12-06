import 'dart:convert';

class Config {
  ///是否Debug模式
  static bool isDebug = true;

  ///播放视频
  static bool playVideo = true;

  ///本地版本号
  static int localVersionCode = 100;

  ///本地版本名
  static String localVersionName = "1.0.0";

  ///服务器地址
  static String serverUrl = "http://ceshi.api.cc/";
  static const String serverUrl_Debug = "http://ceshi.api.cc/";
  static const String serverUrl_Release = "http://ceshi.api.cc/";
  static List<String> serverUrlList =
      Config.isDebug ? [Config.serverUrl_Debug] : [Config.serverUrl_Release];

  ///Ws地址
  static String wsUrl = "ws://ceshi.api.cc:8388";

  ///混淆签名Key
  static String confuseSignKey = "j4uj5516vuYl4MFFGtkKNvqq2XqMXBsR";

  ///(客户端)Tokn
  static String token = "";

  ///(客户端)验证id
  static String oauthId = "";
}
