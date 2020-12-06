import 'package:douyin/model/MainModel.dart';
import 'package:flutter/material.dart';

class AppColors {
  ///通用背景颜色
  static const Color BgColor = Color(0xff30015a);

  ///通用背景颜色_深色
  static const Color BgColor_Deep = Color(0xff550124);

  ///通用文字颜色
  static const Color TextColor = Color(0xffff3696);

  static const int primaryValue = 0xFF24292E;
  static const int primaryLightValue = 0xFF42464b;
  static const int primaryDarkValue = 0xFF121917;

  static const MaterialColor primarySwatch = const MaterialColor(
    primaryValue,
    const <int, Color>{
      50: const Color(primaryLightValue),
      100: const Color(primaryLightValue),
      200: const Color(primaryLightValue),
      300: const Color(primaryLightValue),
      400: const Color(primaryLightValue),
      500: const Color(primaryValue),
      600: const Color(primaryDarkValue),
      700: const Color(primaryDarkValue),
      800: const Color(primaryDarkValue),
      900: const Color(primaryDarkValue),
    },
  );
}

///DY系统变量
class DyStyleVariable {
  ///临时使用
  static MainModel mainModel;

  ///全局Key_当前视频列表
  static GlobalKey keyCurVideoList;

  ///全局Key_当前视频页面
  static GlobalKey keyCurVideoPage;

  ///全局Key_当前视频视图
  static GlobalKey keyCurVideoView;

  ///当前推荐视频的作者id
  static String curVideoAuthorId = "";

  ///显示弹幕
  static bool showBarrage = true;
}

///DY持久化key
class DyPreferencesKeys {
  static String free = "DYFree";
  static String token = "DYToken";
  static String oauthId = "DYOauthId";
  static String serverUrl = "DYServerUrl";
  static String serverList = "DYServerList";
  static String debug = "DYDebug";

  ///兴趣
  static String interests = "DYInterests";

  ///消息
  static String message = "DYMessage";
}
