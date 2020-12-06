import 'dart:async';
import 'dart:ui';
import 'package:douyin/model/MainModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/page/Home/VideoPage_Home.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/style/DYPhysicalBtnEvtControll.dart';
import 'package:douyin/style/Style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:douyin/widget/Toast.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/page/Home/HomePage.dart';
import 'package:douyin/page/Mine/MinePage.dart';
import 'package:douyin/page/Video/VideoPage.dart';
import 'package:url_launcher/url_launcher.dart';

/* 主页
 * (Tip : 主页和首页不同)
 */
class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

/* 主页状态 */
class _MainPageState extends State<MainPage> {
  /* 主数据模块 */
  MainModel _mainModel;
  /* 上次按返回键时间 */
  DateTime lastPopTime;

  /* 请求个人信息事件 */
  StreamSubscription _reqUserInfoScription;
  /* 前往广告事件 */
  StreamSubscription _gotoAdScription;

  // DateTime _lastPressedAt; //上次点击时间
  int _tabIndex = 0;
  List<dynamic> tabImages;
  /* 存放页面列表，跟fragmentList一样 */
  var _pageList;

  VideoPage_Home _videoPage_Home = VideoPage_Home();
  HomePage _homePage = HomePage();

  MinePage _minePage = MinePage();
  VideoPage _videoPage = VideoPage();

  @override
  void initState() {
    super.initState();
    //初始化选中和未选中的icon
    tabImages = [
      [
        {"img": "images/icon_main.png", "color": Color(0x96ffffff)},
        {"img": "images/icon_main.png", "color": Color(0xffffffff)}
      ],
      [
        {"img": "images/icon_hot.png", "color": Color(0x96ffffff)},
        {"img": "images/icon_hot.png", "color": Color(0xffffffff)}
      ],
      [
        {"img": "images/icon_video.png", "color": Color(0x00ffffff)},
        {"img": "images/icon_video.png", "color": Color(0x00ffffff)}
      ],
      [
        {"img": "images/icon_message.png", "color": Color(0x96ffffff)},
        {"img": "images/icon_message.png", "color": Color(0xffffffff)}
      ],
      [
        {"img": "images/icon_me.png", "color": Color(0x96ffffff)},
        {"img": "images/icon_me.png", "color": Color(0xffffffff)}
      ]
    ];
    //子界面
    _pageList = [
      this._videoPage_Home,
      Container(),
      this._videoPage,
      Container(),
      this._minePage,
    ];

    //初始化事件总线,重新注册绑定.
    DYEventBus.initDYEventBus();
    if (_reqUserInfoScription == null) {
      _reqUserInfoScription =
          DYEventBus.eventBus.on<ReqUserInfoEvent>().listen((event) async {
        ResultData _result = await HttpManager.requestPost(
            context, "get_current_userinfo", null);
        if (_result.result) {
          event.callback(_result.data);
        }
      });
    }
    if (_gotoAdScription == null) {
      _gotoAdScription = DYEventBus.eventBus.on<GotoAd>().listen((event) {
        this.gotoAdEvent(event.adType, event.adUrl);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    //取消订阅
    _reqUserInfoScription?.cancel();
    _reqUserInfoScription = null;
    _gotoAdScription?.cancel();
    _gotoAdScription = null;
  }

  @override
  Widget build(BuildContext context) {
    //初始化数据
    //ScreenUtil.instance = ScreenUtil(width: 1080, height: 1920)..init(context);
    ScreenUtil.init(context,
        designSize: Size(1080, 1920), allowFontScaling: false);
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      return Stack(children: <Widget>[
        Positioned(
            child: Opacity(
          opacity: 1,
          child: Container(
            width: ScreenUtil().setWidth(1080),
            height: ScreenUtil().setHeight(1920),
            color: AppColors.BgColor,
          ),
        )),
        Positioned(
          child: Opacity(
            opacity: 0,
            child: Image.asset("images/aaa_00.jpg",
                fit: BoxFit.fill,
                width: ScreenUtil().setWidth(1080),
                height: ScreenUtil().setHeight(1920)),
          ),
        ),
        Positioned(
          child: Opacity(
            opacity: 1,
            child: WillPopScope(
              child: buildMainScaffold(),
              onWillPop: () async {
                Function tempFunc =
                    DYPhysicalBtnEvtControll.GetPhysicalBtnEvent();
                if (tempFunc != null) {
                  tempFunc();
                  return false;
                }
                // 点击返回键的操作
                if (lastPopTime == null ||
                    DateTime.now().difference(lastPopTime) >
                        Duration(seconds: 2)) {
                  lastPopTime = DateTime.now();
                  Toast.toast(context,
                      msg: "再按一次退出", position: ToastPostion.bottom);
                } else {
                  lastPopTime = DateTime.now();
                  // 退出app
                  await SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop');
                }
                return true;
              },
            ),
          ),
        ),
      ]);
    });
  }

  Widget buildMainScaffold() {
    var appBarTitles = ["", "", "", "", ""];
    return Scaffold(
      backgroundColor: AppColors.BgColor,
      body: _pageList[_tabIndex],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xff20013a),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: getTabIcon(0), title: getTabTitle(0, appBarTitles[0])),
            BottomNavigationBarItem(
                icon: getTabIcon(1), title: getTabTitle(1, appBarTitles[1])),
            BottomNavigationBarItem(
                icon: getTabIcon(2), title: getTabTitle(2, appBarTitles[2])),
            BottomNavigationBarItem(
                icon: getTabIcon(3), title: getTabTitle(3, appBarTitles[3])),
            BottomNavigationBarItem(
                icon: getTabIcon(4), title: getTabTitle(4, appBarTitles[4])),
          ],
          type: BottomNavigationBarType.fixed,
          //默认选中首页
          currentIndex: _tabIndex,
          //点击事件
          onTap: (index) {
            setState(() {
              _tabIndex = index;
              // _unreadMsgCount = 0;
            });
          }),
    );
  }

  /* 通过类型生成Icon按钮 */
  Widget buildIconBtnByType(String _iconType) {
    String tempIcon = "";
    Color tempIconColor = Colors.black;
    Function _tempFun = () {
      Toast.toast(context, msg: "功能暂未开放!", position: ToastPostion.center);
    };
    switch (_iconType) {
      case "Service":
        tempIcon = "images/mainicon_appbar_service.png";
        tempIconColor = Colors.black;
        _tempFun = () {
          print("点击客服");
          // Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          //   return Browser(
          //     url: this._mainModel.configModel.service_url,
          //     title: "联系客服",
          //   );
          // }));
        };
        break;
      case "Scan":
        tempIcon = "images/mainicon_appbar_scan.png";
        tempIconColor = Colors.black;
        _tempFun = () {
          print("点击扫码");
        };
        break;
      case "Message":
        tempIcon = "images/mainicon_appbar_message.png";
        tempIconColor = Colors.white;
        _tempFun = () {
          print("点击消息");
        };
        break;
      case "More":
        tempIcon = "images/mainicon_appbar_more.png";
        tempIconColor = Colors.white;
        break;
    }

    return IconButton(
      icon: Container(
        width: ScreenUtil().setWidth(50),
        height: ScreenUtil().setWidth(50),
        child: Stack(
          children: <Widget>[
            ImageIcon(
              AssetImage(tempIcon),
              color: tempIconColor,
              size: ScreenUtil().setWidth(50),
            ),
          ],
        ),
      ),
      onPressed: _tempFun,
    );
  }

  /* 根据选择获得对应的normal或是press的icon */
  Widget getTabIcon(int curIndex) {
    dynamic tempImages = tabImages[curIndex][0];
    if (curIndex == this._tabIndex) {
      tempImages = tabImages[curIndex][1];
    }
    Color tempColor = curIndex == 2 ? null : tempImages["color"];
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
      child: Image.asset(
        tempImages["img"],
        width: ScreenUtil().setWidth(90),
        height: ScreenUtil().setWidth(90),
        color: tempColor,
      ),
    );
  }

  /* 获取bottomTab的颜色和文字 */
  Widget getTabTitle(int curIndex, String _title) {
    if (curIndex == this._tabIndex) {
      return Text(_title,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(0), color: const Color(0xff1296db)));
    } else {
      return Text(_title,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(0), color: const Color(0xff515151)));
    }
  }

  ///前往广告
  void gotoAdEvent(int _adType, String _adUrl) {
    //  1打开url  2下载安装apk  3无响应
    switch (_adType) {
      case 1:
        this.openUrl(_adUrl);
        break;
      case 2:
        this.openUrl(_adUrl);
        break;
      case 3:
        break;
    }
  }

  ///打开Url
  void openUrl(String _adUrl) async {
    if (await canLaunch(_adUrl)) {
      //打开外部浏览器
      await launch(_adUrl);
    } else {
      //复制更新链接
      ClipboardData data = ClipboardData(text: _adUrl);
      Clipboard.setData(data);
      Toast.toast(context,
          msg: "链接已复制,打开浏览器即可粘贴.", position: ToastPostion.center);
      throw 'Could not launch $_adUrl';
    }
  }
}
