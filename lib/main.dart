import 'dart:convert';
import 'dart:io';

import 'package:douyin/config/Config.dart';
import 'package:douyin/page/LoginPage.dart';
import 'package:douyin/page/StartupPage.dart';
import 'package:douyin/platform/DYPlatform.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'style/Style.dart';
import 'translations/translations.dart';
import 'translations/application.dart';
import 'model/MainModel.dart';

void main() {
  realRunApp();
}

void realRunApp() async {
  //升级Flutter后,需要执行.
  WidgetsFlutterBinding.ensureInitialized();

  //初始化平台
  DYPlatform.initDYPlatform();
  //获取持久化数据,并且转换
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String tempStr = prefs.getString(DyPreferencesKeys.free);
  Map<String, dynamic> tempPrefs = tempStr == null ? null : jsonDecode(tempStr);
  if (tempPrefs != null) {
    //校验时间,如果不是当天的,要进行清空.
    String tempDateStr = Tools.GetDateTime_YMD();
    if (tempPrefs["date"] != tempDateStr) {
      prefs.remove(DyPreferencesKeys.free);
    }
  }
  //Debug模式,服务器地址
  // Config.isDebug = prefs.getBool(DyPreferencesKeys.debug) ?? false;
  // Config.serverUrl = prefs.getString(DyPreferencesKeys.serverUrl) ?? Config.serverUrl;
  Config.token = prefs.getString(DyPreferencesKeys.token) ?? "";
  Config.oauthId = prefs.getString(DyPreferencesKeys.oauthId) ?? "";
  if (prefs.getString(DyPreferencesKeys.serverList) != null) {
    List<dynamic> tempServerUrlList =
        json.decode(prefs.getString(DyPreferencesKeys.serverList));
    if (tempServerUrlList.length > 0) {
      tempServerUrlList.forEach((_url) {
        Config.serverUrlList.add(_url);
      });
    }
  }
  //强制竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());
  //透明标题栏
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }
}

///App主入口
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //创建顶层状态
  final MainModel mainModel = MainModel();
  //语言
  SpecificLocalizationDelegate _localeOverrideDelegate;

  /* 前往登陆事件 */
  var _gotoLoginEvent;
  /* 检测更新事件 */
  var _checkVersionEvent;

  @override
  void initState() {
    super.initState();

    // todo : 临时做法
    DyStyleVariable.mainModel = this.mainModel;

    if (_gotoLoginEvent == null) {
      _gotoLoginEvent =
          DYEventBus.loginEventBus.on<GotoLoginEvent>().listen((event) {
        _showDialogGotoLogin(event.context, event.title, event.force);
      });
    }
    if (_checkVersionEvent == null) {
      _checkVersionEvent =
          DYEventBus.loginEventBus.on<CheckVersion>().listen((event) {
        // getOreInfo(event.context);
      });
    }
    //初始化一个新的Localization Delegate，有了它，当用户选择一种新的工作语言时，可以强制初始化一个新的Translations
    _localeOverrideDelegate = new SpecificLocalizationDelegate(null);
    //保存这个方法的指针，当用户改变语言时，我们可以调用applic.onLocaleChanged(new Locale('en',''));，通过SetState()我们可以强制App整个刷新
    applic.onLocaleChanged = onLocaleChange;
  }

  //改变语言时的应用刷新核心，每次选择一种新的语言时，都会创造一个新的SpecificLocalizationDelegate实例，强制Translations类刷新。
  onLocaleChange(Locale locale) {
    setState(() {
      _localeOverrideDelegate = new SpecificLocalizationDelegate(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "夜来香",
      debugShowCheckedModeBanner: false,
      //showPerformanceOverlay: true, //显示性能图表
      theme: ThemeData(
        primaryColorLight: AppColors.primarySwatch,
      ),
      localizationsDelegates: [
        // 提供地区数据和默认的文字布局
        _localeOverrideDelegate, // 注册一个新的delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        const TranslationsDelegate(), // 指向默认的处理翻译逻辑的库
        const FallbackCupertinoLocalisationsDelegate(),
      ],
      // supportedLocales: applic.supportedLocales(),
      supportedLocales: [
        Locale('en', ''),
        Locale('zh', 'CN'),
      ],
      locale: Locale('zh', 'CN'),
      home: ScopedModel<MainModel>(
        model: mainModel,
        child: new StartupPage(),
      ),
    );
  }

  /*
   * 显示弹窗_前往登陆
   * (_force : 是否强制登陆)
   */
  void _showDialogGotoLogin(BuildContext _context, String _title, bool _force) {
    showCupertinoDialog(
        context: _context,
        builder: (_context) {
          return CupertinoAlertDialog(
            title: Text(
              _title,
              style: TextStyle(fontSize: ScreenUtil().setSp(40)),
            ),
            actions: _force
                ? <Widget>[
                    CupertinoDialogAction(
                      onPressed: () async {
                        //清空持久化
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.remove(DyPreferencesKeys.token);
                        // 跳转界面
                        Navigator.pushAndRemoveUntil(
                          _context,
                          MaterialPageRoute(builder: (context) {
                            return ScopedModel<MainModel>(
                              model: mainModel,
                              child: new LoginPage(),
                            );
                          }),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text('确定'),
                    ),
                  ]
                : <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop(_context);
                      },
                      child: Text('取消'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () async {
                        //清空持久化
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.remove(DyPreferencesKeys.token);
                        // 跳转界面
                        Navigator.pushAndRemoveUntil(
                          _context,
                          MaterialPageRoute(builder: (context) {
                            return ScopedModel<MainModel>(
                              model: mainModel,
                              child: new LoginPage(),
                            );
                          }),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text('确定'),
                    ),
                  ],
          );
        });
  }

  /* 获取配置 */
  void getOreInfo(BuildContext _context) async {}
}

class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}
