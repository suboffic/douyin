import 'dart:ui';

import 'package:douyin/model/UserModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/widget/DotsIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///更多图片界面
class MoreImgPage extends StatefulWidget {
  ///用户id
  final String uuid;

  ///图片列表
  final List<UserPhotoModel> photoList;

  //构造函数
  MoreImgPage({Key key, this.uuid, this.photoList}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MoreImgPageState();
  }
}

class MoreImgPageState extends State<MoreImgPage> {
  ///主数据模块
  MainModel _mainModel;

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///状态栏高度
  double _statusBarHeight = 0;

  ///图片列表
  List<UserPhotoModel> _photoList;

  ///页面控制器(针对图片)
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    //初始化视图宽度 & 高度
    this._statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    _viewWidth = ScreenUtil().setWidth(1080);
    _viewHeight = ScreenUtil().setHeight(1920) - this._statusBarHeight;
    this._photoList = widget.photoList;
    //请求
    // this.reqUserPhoto();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      return Material(
        color: Colors.black,
        //_statusBarHeight
        child: Column(
          children: <Widget>[
            Container(
              height: this._statusBarHeight,
            ),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                this.buildImages(),
                this.buildDotsIndicator(),
                this.buildReturn(),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget buildImages() {
    return Container(
      width: this._viewWidth,
      height: this._viewHeight,
      child: PageView.builder(
        controller: this._pageController,
        itemCount: this._photoList.length,
        itemBuilder: (BuildContext _context, int _index) {
          String tempImg = this._photoList[_index].url;
          return Container(
            child: Image.network(
              tempImg,
            ),
          );
        },
      ),
    );
  }

  ///生成点状指示器
  Widget buildDotsIndicator() {
    return Positioned(
      bottom: ScreenUtil().setWidth(50),
      child: Container(
        height: ScreenUtil().setWidth(60),
        // margin: EdgeInsets.only(top: ScreenUtil().setHeight(25)),
        child: DotsIndicator(
          controller: _pageController,
          itemCount: this._photoList.length,
          colorNoraml: Colors.grey,
          colorSelect: Colors.white,
          onPageSelected: (int page) {
            _pageController.animateToPage(
              page,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
        ),
      ),
    );
  }

  ///生成返回
  Widget buildReturn() {
    return Positioned(
      top: ScreenUtil().setWidth(40),
      left: ScreenUtil().setWidth(40),
      child: InkWell(
        child: Icon(
          Icons.keyboard_arrow_left,
          size: ScreenUtil().setWidth(100),
          color: Colors.white,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  //========== [ 辅助函数 ] ==========
  ///请求用户相册
  void reqUserPhoto() async {
    ResultData _result = await HttpManager.requestPost(
        context, "get_photo", {"uuid": widget.uuid, "page": 1});
    if (_result.result) {
      List<UserPhotoModel> tempPhotoList = [];
      List<dynamic> tempDataList = _result.data["data"] ?? [];
      tempDataList.forEach((_data) {
        UserPhotoModel tempPhoto = UserPhotoModel();
        tempPhoto.fromMap(_data);
        tempPhotoList.add(tempPhoto);
      });
      setState(() {
        this._photoList = tempPhotoList;
      });
    }
  }
}
