import 'dart:ui';

import 'package:douyin/style/Style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///视频
class VideoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoPageState();
  }
}

class VideoPageState extends State<VideoPage> {
  ///主数据模块
  //MainModel _mainModel;

  ///视图宽度
  //double _viewWidth = 0;

  ///视图高度
  //double _viewHeight = 0;

  ///状态栏高度
  double _statusBarHeight = 0;

  @override
  void initState() {
    super.initState();

    //初始化视图宽度 & 高度
    //this._viewWidth = ScreenUtil().setWidth(1080);
    this._statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    //this._viewHeight = ScreenUtil().setHeight(1920) - this._statusBarHeight;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      //_mainModel = model;
      return Scaffold(
        backgroundColor: AppColors.BgColor,
        body: Column(
          children: <Widget>[
            Container(
              height: this._statusBarHeight,
            ),
            this.buildTop(),
            Expanded(
              child: this.buildMain(),
            ),
          ],
        ),
      );
    });
  }

  ///生成顶部
  Widget buildTop() {
    return Container(
      height: ScreenUtil().setWidth(120),
      child: Row(
        children: <Widget>[
          this.buildTopReturn(),
          this.buildTopTitle(),
          Container(
            width: ScreenUtil().setWidth(120),
          ),
        ],
      ),
    );
  }

  ///生成顶部_返回
  Widget buildTopReturn() {
    return Container(
      width: ScreenUtil().setWidth(120),
      height: ScreenUtil().setWidth(120),
      alignment: Alignment.center,
      child: InkWell(
        child: Icon(
          Icons.keyboard_arrow_left,
          size: ScreenUtil().setWidth(100),
          color: Colors.white,
        ),
        onTap: this.btnEventReturn,
      ),
    );
  }

  ///生成顶部_标题
  Widget buildTopTitle() {
    return Expanded(
      child: Center(
        child: Text(
          "聊天",
          style:
              TextStyle(fontSize: ScreenUtil().setSp(50), color: Colors.white),
        ),
      ),
    );
  }

  ///生成主要内容
  Widget buildMain() {
    return Column(
      children: <Widget>[],
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_返回
  void btnEventReturn() {
    Navigator.pop(context);
  }
}
