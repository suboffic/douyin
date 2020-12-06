import 'dart:ui';

import 'package:douyin/model/CollectionModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///合集页面
class CollectionPage extends StatefulWidget {
  ///合集id
  final int collectionId;

  //构造函数
  CollectionPage({Key key, this.collectionId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CollectionPageState();
  }
}

class CollectionPageState extends State<CollectionPage> {
  ///主数据模块
  MainModel _mainModel = null;

  ///动态滑动控制器
  ScrollController _scrollController = ScrollController();

  ///当前页码
  int _curPage = 0;

  ///请求状态
  bool _reqState = false;

  ///合集信息数据
  CollectionInfoModel _collectionInfoModel = CollectionInfoModel();

  @override
  void initState() {
    super.initState();

    //初始化'动态滑动控制器'
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent -
              ScreenUtil().setWidth(200)) {
        //如果正在请求中,忽略.
        if (this._reqState) {
          return;
        }
        this._curPage++;
        this.reqAuthorInfo(this._curPage);
      }
    });
    //请求合集信息
    this.reqAuthorInfo(1);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      return Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(top: _statusBarHeight),
          color: AppColors.BgColor,
          child: Column(
            children: <Widget>[
              this.buildTop(),
              this.buildInfo(),
              this.buildListView(),
            ],
          ),
        ),
      );
    });
  }

  ///生成顶部
  Widget buildTop() {
    return Container(
      height: ScreenUtil().setWidth(126),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white38, width: 1)),
      ),
      child: Row(
        children: <Widget>[
          this.buildTopReturn(),
          this.buildTopTitle(),
          this.buildTopShare(),
        ],
      ),
    );
  }

  ///生成顶部_返回
  Widget buildTopReturn() {
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(140),
        height: ScreenUtil().setWidth(126),
        alignment: Alignment.center,
        child: Icon(
          Icons.keyboard_arrow_left,
          size: ScreenUtil().setWidth(80),
          color: Colors.white,
        ),
      ),
      onTap: () {
        this.btnEventReturn();
      },
    );
  }

  ///生成顶部_标题
  Widget buildTopTitle() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          "合集·${this._collectionInfoModel.title}",
          style:
              TextStyle(fontSize: ScreenUtil().setSp(46), color: Colors.white),
        ),
      ),
    );
  }

  ///生成顶部_分享
  Widget buildTopShare() {
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(140),
        height: ScreenUtil().setWidth(126),
        alignment: Alignment.center,
        child: Image.asset(
          "images/video/right_share.png",
          fit: BoxFit.fill,
          width: ScreenUtil().setWidth(60),
        ),
      ),
      onTap: () {
        this.btnEventReturn();
      },
    );
  }

  ///生成信息
  Widget buildInfo() {
    return Container(
      height: ScreenUtil().setWidth(680),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white38, width: 1)),
      ),
      child: Column(
        children: <Widget>[
          this.buildInfo_Main(),
          this.buildInfo_Summary(),
          this.buildInfoCount(),
          this.buildInfo_Btn(),
        ],
      ),
    );
  }

  ///生成简介_主要
  Widget buildInfo_Main() {
    return Container(
      height: ScreenUtil().setWidth(350),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(34),
          ),
          //封面
          ClipRRect(
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10))),
            child: Container(
              width: ScreenUtil().setWidth(320),
              height: ScreenUtil().setWidth(300),
              color: Colors.white,
              child: Image.network(
                this._collectionInfoModel.thumb,
              ),
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(40),
          ),
          //名称等
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: ScreenUtil().setWidth(60),
              ),
              //标题
              Row(
                children: <Widget>[
                  Image.asset("images/video/bottom_compilation.png",
                      width: ScreenUtil().setWidth(50)),
                  Container(
                    width: ScreenUtil().setWidth(20),
                  ),
                  Text(
                    this._collectionInfoModel.title,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(46), color: Colors.white),
                  ),
                ],
              ),
              Container(
                height: ScreenUtil().setWidth(10),
              ),
              //作者
              Row(
                children: <Widget>[
                  Text(
                    "@${this._collectionInfoModel.nickname}",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(38),
                        color: Color(0xffed4f96)),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(16),
                  ),
                  Text(
                    "创建的合集",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(38), color: Colors.white),
                  ),
                ],
              ),
              Container(
                height: ScreenUtil().setWidth(20),
              ),
              //更新
              Text(
                "更新至第${this._collectionInfoModel.quantity}集",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(38), color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///生成简介_介绍
  Widget buildInfo_Summary() {
    String tempStr = Tools.cutString(this._collectionInfoModel.summary, 25);
    return Container(
      height: ScreenUtil().setWidth(80),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
      alignment: Alignment.centerLeft,
      child: Text(
        tempStr,
        style:
            TextStyle(fontSize: ScreenUtil().setSp(38), color: Colors.white54),
      ),
    );
  }

  ///生成简介_数量
  Widget buildInfoCount() {
    String tempPlay =
        Tools.ToString(this._collectionInfoModel.playCount, "w", false);
    String tempCollect =
        Tools.ToString(this._collectionInfoModel.collectCount, "w", false);
    return Container(
      height: ScreenUtil().setWidth(100),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
      child: Row(
        children: <Widget>[
          //播放
          Text(
            "$tempPlay 播放",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(38), color: Colors.white),
          ),
          Container(
            width: ScreenUtil().setWidth(26),
          ),
          //收藏
          Text(
            "$tempCollect 收藏",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(38), color: Colors.white),
          ),
        ],
      ),
    );
  }

  ///生成简介_按钮
  Widget buildInfo_Btn() {
    Gradient _gradient = this._collectionInfoModel.hasCollect
        ? LinearGradient(colors: [Color(0xff352944), Color(0xff352944)])
        : LinearGradient(colors: [Color(0xfffff3196), Color(0xffff9d9c)]);
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(1000),
        height: ScreenUtil().setWidth(104),
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            //背景
            ShaderMask(
              shaderCallback: (bounds) {
                return _gradient.createShader(Offset.zero & bounds.size);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(10)),
                ),
              ),
            ),
            //文字
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  this._collectionInfoModel.hasCollect
                      ? Icons.star_border
                      : Icons.star,
                  size: ScreenUtil().setWidth(50),
                  color: Colors.white,
                ),
                Container(
                  width: ScreenUtil().setWidth(10),
                ),
                Text(
                  this._collectionInfoModel.hasCollect ? "取消收藏" : "收藏",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(38), color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        this.btnEventFollow();
      },
    );
  }

  ///生成列表
  Widget buildListView() {
    List<CollectionModel> tempList =
        this._collectionInfoModel.collectionInfoList;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            controller: this._scrollController,
            itemCount: tempList.length + 1,
            itemBuilder: (BuildContext _context, int _index) {
              if (_index == tempList.length) {
                return buildProgressIndicator();
              } else {
                return this.buildListItem(_index, tempList[_index]);
              }
            }),
      ),
    );
  }

  ///生成Item
  Widget buildListItem(int _index, CollectionModel _collection) {
    String tempCnt = Tools.ToString(_collection.views, "W", false);
    return InkWell(
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(20),
            horizontal: ScreenUtil().setWidth(10)),
        height: ScreenUtil().setWidth(210),
        child: Row(
          children: <Widget>[
            //封面
            ClipRRect(
              borderRadius:
                  BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10))),
              child: Container(
                width: ScreenUtil().setWidth(210),
                height: ScreenUtil().setWidth(210),
                color: Colors.white,
                child: Image.network(
                  _collection.thumbImg,
                ),
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(40),
            ),
            //信息
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //标题
                  this.buildListItemTitle(_index, _collection.content),
                  //播放
                  Row(
                    children: <Widget>[
                      //时间
                      Text(
                        "02:46",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            color: Colors.white54),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(20),
                      ),
                      //播放
                      Text(
                        "$tempCnt 播放",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        this.btnEventItem(_collection.id);
      },
    );
  }

  ///生成列表Item标题
  Widget buildListItemTitle(int _index, String _title) {
    return RichText(
      text: TextSpan(
        text: "第$_index集",
        style:
            TextStyle(fontSize: ScreenUtil().setSp(36), color: Colors.white54),
        children: [
          TextSpan(
            text: " | $_title",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(40), color: Colors.white),
          ),
        ],
      ),
    );
  }

  ///生成加载图标
  Widget buildProgressIndicator() {
    return Container(
      height: ScreenUtil().setHeight(200),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: this._reqState ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_返回
  void btnEventReturn() {
    Navigator.pop(context);
  }

  ///按钮事件_关注(收藏)
  void btnEventFollow() {
    print(">>>>   按钮事件_关注");
    setState(() {
      this._collectionInfoModel.hasCollect =
          !this._collectionInfoModel.hasCollect;
    });
  }

  ///按钮事件_Item
  void btnEventItem(int _id) {
    print(">>>>   按钮事件_Item $_id");
  }

  //========== [ 辅助函数 ] ==========
  ///请求作者信息
  void reqAuthorInfo(int _page) async {
    if (this._reqState) {
      return;
    }

    setState(() {
      this._reqState = true;
    });
    ResultData _result = await HttpManager.requestPost(context,
        "Collection/single", {"id": widget.collectionId, "page": _page});
    if (_result.result) {
      CollectionInfoModel tempModel = CollectionInfoModel();
      List<dynamic> tempDataList = _result.data["data"];
      if (tempDataList == null || tempDataList.isEmpty) {
        //回退页码
        this._curPage--;
        //回退高度是加载图标的高度
        double edge = ScreenUtil().setHeight(200);
        double offsetFromBottom = _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels;
        if (offsetFromBottom < edge) {
          _scrollController.animateTo(
              _scrollController.offset - (edge - offsetFromBottom),
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut);
        }
        //数据为空,不允许恢复请求状态
        this._reqState = true;
      } else {
        //数据不为空,恢复请求状态
        this._reqState = false;
      }
      //添加数据,并且触发渲染.
      tempModel.fromMap(_result.data);
      if (_page == 1) {
        this._collectionInfoModel = tempModel;
      } else {
        this
            ._collectionInfoModel
            .collectionInfoList
            .addAll(tempModel.collectionInfoList);
      }
      setState(() {});
    }
  }
}
