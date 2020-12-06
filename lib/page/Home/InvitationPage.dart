import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:douyin/model/ConfigModel.dart';
import 'package:douyin/tools/Logger.dart';
import 'package:douyin/tools/PermissionTool.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///邀请界面
class InvitationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InvitationPageState();
  }
}

class InvitationPageState extends State<InvitationPage> {
  ///主数据模块
  MainModel _mainModel;

  ///截图对象key
  GlobalKey _rootWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      String tempCode = _mainModel.userModel.inviteCode;
      String tempUrl = "${_mainModel.configModel.inviteUrl}$tempCode";
      return Scaffold(
        body: Stack(
          children: <Widget>[],
        ),
      );
    });
  }

  ///生成顶部
  Widget buildTop() {
    return Container(
      height: ScreenUtil().setWidth(80),
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.only(right: ScreenUtil().setWidth(40)),
      alignment: Alignment.centerRight,
      child: InkWell(),
    );
  }

  ///生成二维码
  Widget buildQrCode(String _shareUrl, String _code) {
    return RepaintBoundary(
      key: this._rootWidgetKey,
      child: Container(),
    );
  }

  ///生成二维码提示
  Widget buildQrCodeTip() {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(20))
    );
  }

  ///生成按钮
  Widget buildBtns(String _shareUrl) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(40)),
      child: Column(),
    );
  }

  ///生成按钮_按钮
  Widget buildBtnsBtn(String btnstr, Function _btnEvent) {
    return SizedBox(
      width: ScreenUtil().setWidth(700),
      child: IconButton(
        padding: EdgeInsets.all(0),
        icon: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset(
              "images/video/share_btnbg.png",
              fit: BoxFit.fill,
            ),
            Text(
              btnstr,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(32), color: Colors.white),
            )
          ],
        ),
        onPressed: _btnEvent,
      ),
    );
  }

  ///生成空白占位容器
  Widget buildContainer() {
    return Container(
      height: ScreenUtil().setWidth(50),
    );
  }

  ///生成分享配置
  Widget buildShareConfig() {
    List<ShareConfig> tempShareConfig = this._mainModel.configModel.shareConfig;
    return Expanded(
      child: Container(),
    );
  }

  ///生成分享配置
  Widget buildShareItem(int _index, ShareConfig _config) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(_index != 0 ? 60 : 0)),
      child: Column(),
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_保存图片
  void btnEventRecord() {

  }

  ///按钮事件_保存图片
  void btnEventSaveImg() async {

  }

  ///按钮事件_复制Url
  void btnEventCopyUrl(String _url) {

  }

  //========== [ 辅助函数 ] ==========
  ///保存图片
  void saveImg() async {

  }
}
