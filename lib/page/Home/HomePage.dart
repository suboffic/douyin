import 'dart:convert';
import 'dart:typed_data';
import 'package:douyin/page/Home/VideoPage_Home.dart';
import 'package:douyin/style/Style.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

/* 主页 */
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  /* 主数据模块 */
  MainModel _mainModel;

  String _imgData;

  Image _myImg2;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 200), () {
      // this.TestbtnEventVideo();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      return Scaffold(
        body: Column(
          children: <Widget>[
            this.buildContent(),
          ],
        ),
      );
    });
  }

  Widget buildContent() {
    return Expanded(
      child: Container(
        color: Colors.yellow,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              child: Text("打开视频"),
              onPressed: () {
                this.TestbtnEventVideo();
              },
            ),
            OutlineButton(
              child: Text("测试接口"),
              onPressed: () {
                this.TestbtnEventHttp();
              },
            ),
            this.buildTestImg(),
            this.buildTestImg2(),
          ],
        ),
      ),
    );
  }

  Widget buildTestImg() {
    return _imgData == null
        ? Container(
            width: 150,
            height: 150,
            color: Colors.red[200],
          )
        : Image.memory(
            base64.decode(this._imgData),
            height: 30, //设置高度
            width: 70, //设置宽度
            fit: BoxFit.fill, //填充
            gaplessPlayback: true, //防止重绘
          );
  }

  Widget buildTestImg2() {
    this._myImg2 = Image.asset("images/icon_message.png");
    return this._myImg2;
  }

  /* 测试按钮事件_视频 */
  void TestbtnEventVideo() {
    DyStyleVariable.keyCurVideoList = null;
    DyStyleVariable.keyCurVideoPage = null;
    DyStyleVariable.keyCurVideoView = null;
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

  /* 测试按钮事件_Http */
  void TestbtnEventHttp() async {

  }
}
