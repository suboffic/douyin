import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:douyin/config/Config.dart';
import 'package:douyin/model/ConfigModel.dart';
import 'package:douyin/model/DYModelUnit.dart';
import 'package:douyin/model/OtherModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/page/Home/VideoPage_Home.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/PermissionTool.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StartupPageState();
  }
}

class _StartupPageState extends State<StartupPage> {
  ///数据模块
  MainModel _mainModel;

  ///配置模块
  ConfigModel _configModel;

  ///是否获取配置
  bool _isGetOreInfo = false;

  ///计时器_启动页
  Timer _cdTimer_SP;

  ///当前冷却时间_启动页
  num _curCdTime_SP = 3;

  ///总倒计时时间_启动页
  num _countdown_SP = 3;

  ///计时器_广告
  Timer _cdTimer_Ads;

  ///当前冷却时间_广告
  num _curCdTime_Ads = 5;

  ///当前倒计时时间_广告
  num _countdown_Ads = 3;

  ///当前广告页下标
  int _curAdsIndex = -1;

  @override
  void initState() {
    super.initState();

    this.startCountDown_SP();
    this.checkServerUrl();
    this.initMessage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //初始化数据
    //ScreenUtil(width: 1080, height: 1920)..init(context);
    ScreenUtil.init(context,
        designSize: Size(1080, 1920), allowFontScaling: false);
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      _configModel = model.configModel;
      return Container(
        width: ScreenUtil().setWidth(1080),
        height: ScreenUtil().setHeight(1920),
        child: Stack(
          children: <Widget>[
            Image.asset(
              "images/replace/start.jpg",
              fit: BoxFit.fill,
              width: ScreenUtil().setWidth(1080),
              height: ScreenUtil().setHeight(1920),
            ),
            this._curCdTime_SP <= 0 && this._isGetOreInfo
                ? buildAds()
                : Container(),
          ],
        ),
      );
    });
  }

  ///生成广告页
  Widget buildAds() {
    if (this._configModel.adsList == null ||
        this._configModel.adsList.length == 0 ||
        this._curAdsIndex >= this._configModel.adsList.length) {
      return Container();
    }

    AdsConfig tempAdsData = this._configModel.adsList[this._curAdsIndex];
    return Stack(
      children: <Widget>[
        buildAds_Image(tempAdsData),
        Positioned(
          top: ScreenUtil().setHeight(120),
          right: ScreenUtil().setHeight(40),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(180),
                height: ScreenUtil().setWidth(80),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(50)),
                ),
              ),
              Text(
                "${_curCdTime_Ads}s",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(44),
                    color: Colors.white,
                    decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///生成广告页_图片
  Widget buildAds_Image(AdsConfig _data) {
    return Image.network(
      _data.contentUrl,
      fit: BoxFit.fill,
      width: ScreenUtil().setWidth(1080),
      height: ScreenUtil().setHeight(1920),
    );
  }

  ///开始倒计时_启动页
  void startCountDown_SP() {
    if (_cdTimer_SP == null) {
      _curCdTime_SP = _countdown_SP;
      _cdTimer_SP = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_curCdTime_SP > 0) {
          _curCdTime_SP--;
        } else {
          setState(() {
            _cdTimer_SP.cancel();
            _cdTimer_SP = null;

            if (_isGetOreInfo) {
              this.checkAds();
            } else {
              Toast.toast(context,
                  msg: "网络环境较差,请稍后再试!", position: ToastPostion.center);
            }
          });
        }
      });
    }
  }

  //开始倒计时_广告
  void startCountDown_Ads(num _cdTime) {
    if (_cdTimer_Ads == null) {
      _curCdTime_Ads = _cdTime;
      _countdown_Ads = _cdTime;
      _cdTimer_Ads = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_curCdTime_Ads > 0) {
          _curCdTime_Ads--;
          setState(() {});
        } else {
          _cdTimer_Ads.cancel();
          _cdTimer_Ads = null;
          this.checkAds();
        }
      });
    }
  }

  /*
   * 检测广告页面
   * (如果3秒后,已经请求到配置,并且广告页为空,进入首页.)
   * (如果3秒后,请求还未回复,等待...所以接口返回也需要判断)
   * (每次广告播放完毕都要检测)
   */
  void checkAds() {
    if (this._cdTimer_Ads != null) {
      this._cdTimer_Ads.cancel();
      this._cdTimer_Ads = null;
    }
    this._curAdsIndex++;
    if (this._configModel.adsList == null ||
        this._configModel.adsList.length == 0 ||
        this._curAdsIndex >= this._configModel.adsList.length) {
      //iOS下,不需要授权'读写权限'
      if (Platform.isIOS) {
        this.CheckVersionAndStartApp();
      } else {
        //申请授权(涉及版本更新,所以需要优先授权)
        PermissionTool.requestPermission(context, Permission.storage, () {
          this.CheckVersionAndStartApp();
        });
      }
    } else {
      setState(() {});
      this.startCountDown_Ads(
          this._configModel.adsList[this._curAdsIndex].duration);
    }
  }

  ///检测更新/进入App
  void CheckVersionAndStartApp() {
    //版本更新
    DyStyleVariable.keyCurVideoList = null;
    DyStyleVariable.keyCurVideoPage = null;
    DyStyleVariable.keyCurVideoView = null;
    //进入app
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) {
        return ScopedModel<MainModel>(
          model: this._mainModel,
          child: VideoPage_Home(),
        );
      }),
      (Route<dynamic> route) => false,
    );
  }

  ///检测线路
  void checkServerUrl() async {
    ResultData _result = await HttpManager.requestPost(
        context, "/config", {"ver": Config.localVersionName},
        errMsg: "连接服务器失败，正在疯狂重试");
    if (_result.result && this.mounted) {
      if (!this._isGetOreInfo) {
        this._isGetOreInfo = true;
        this._configModel.fromMap(_result.data);
        // 持久化
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool(DyPreferencesKeys.debug, Config.isDebug);
        prefs.setString(DyPreferencesKeys.serverUrl, Config.serverUrl);

        setState(() {});
        //如果已经倒计时3秒结束,主动检测广告.
        if (this._curCdTime_SP <= 0) {
          this.checkAds();
        }
      }
    }
  }

  ///初始化消息
  void initMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tempStr = prefs.getString(DyPreferencesKeys.message);
    List<dynamic> tempList = jsonDecode(tempStr);
    this._mainModel.chatList = DYModelUnit.convertList<ChatModel>(tempList);
  }
}
