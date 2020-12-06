import 'dart:ui';

import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/page/Other/MarkListView.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/trends/SimpleTrendsListView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///标签页面
class MarkPage extends StatefulWidget {
  ///标签
  final String mark;

  //构造函数
  MarkPage({Key key, this.mark}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MarkPageState();
  }
}

class MarkPageState extends State<MarkPage>
    with SingleTickerProviderStateMixin {
  ///主数据模块
  MainModel _mainModel;

  ///视频简介
  String _summary = "";

  ///动态数据列表_最新
  List<TrendsModel> _trendsDataListNew = [];

  ///动态数据列表_火热
  List<TrendsModel> _trendsDataListHot = [];

  ///没有数据_最新
  bool _notDate_New = false;

  ///没有数据_火热
  bool _notDate_Hot = false;

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///页面控制器
  TabController _tabController;

  ///上个页面下标
  int _lastTabIndex = 0;

  ///动态列表视图列表
  List<SimpleTrendsListView> _trendsListViewList = [null, null];

  ///key列表
  List<GlobalKey> _keyList = [];

  @override
  void initState() {
    super.initState();

    //初始化key列表
    this._keyList = [GlobalKey(), GlobalKey()];

    //初始化视图宽度 & 高度
    _viewWidth = ScreenUtil().setWidth(1080);
    double _statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    _viewHeight = ScreenUtil().setHeight(1920) - _statusBarHeight;
    //初始化Tab控制器
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _tabController.addListener(() {
      if (this._lastTabIndex == _tabController.index) {
        return;
      }
      setState(() {
        this._lastTabIndex = _tabController.index;
      });
      if (this._lastTabIndex == 0 && this._trendsDataListHot.length == 0) {
        this.reqMoreTrendsData(this._keyList[0], 1, 1);
      }
      if (this._lastTabIndex == 1 && this._trendsDataListNew.length == 0) {
        this.reqMoreTrendsData(this._keyList[1], 1, 1);
      }
    });

    //请求数据
    this.reqMoreTrendsData(this._keyList[0], 1, 1);
    this.reqMoreTrendsData(this._keyList[1], 1, 2);
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
        backgroundColor: AppColors.BgColor,
        body: Column(
          children: <Widget>[
            this.buildTop(),
            this.buildText(),
            this.buildTabBtnList(),
            this.buildTabView(),
          ],
        ),
      );
    });
  }

  ///生成顶部
  Widget buildTop() {
    return Container(
      height: ScreenUtil().setWidth(170),
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(80)),
      child: Row(
        children: <Widget>[
          //返回按钮
          GestureDetector(
            child: Container(
              width: ScreenUtil().setWidth(120),
              height: ScreenUtil().setWidth(120),
              child: Icon(
                Icons.keyboard_arrow_left,
                size: ScreenUtil().setWidth(100),
                color: Colors.white,
              ),
            ),
            onTap: () {
              this.btnEventReturn();
            },
          ),
          //标题
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "#${widget.mark}",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(50), color: Colors.white),
              ),
            ),
          ),
          //空出和左边一样宽度
          Container(
            width: ScreenUtil().setWidth(120),
          ),
        ],
      ),
    );
  }

  ///生成文本
  Widget buildText() {
    return Container(
      height: ScreenUtil().setWidth(230),
      child: Column(
        children: <Widget>[
          //人数
          // this.buildTextPlayerCnt(),
          //描述
          this.buildTextDescribe(),
        ],
      ),
    );
  }

  ///生成文本_人数
  Widget buildTextPlayerCnt() {
    String tempCntStr = Tools.ToString(0, "W", false);
    return Container(
      height: ScreenUtil().setWidth(80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //图标
          Image.asset(
            "images/video/mark_icon_fire.png",
            fit: BoxFit.fill,
            width: ScreenUtil().setWidth(34),
            height: ScreenUtil().setWidth(40),
          ),
          //文本
          Text(
            "  ${tempCntStr}人参与",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(38), color: Colors.white),
          )
        ],
      ),
    );
  }

  ///生成文本_描述
  Widget buildTextDescribe() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
        alignment: Alignment.center,
        child: Text(this._summary,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(38),
                color: Colors.white,
                height: 1.2)),
      ),
    );
  }

  ///生成翻页按钮列表
  Widget buildTabBtnList() {
    return Container(
      width: this._viewWidth,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(255)),
      decoration: BoxDecoration(
        color: Color(0xff1a1023),
        border: Border(bottom: BorderSide(color: Colors.black54, width: 1)),
      ),
      child: Container(
        width: ScreenUtil().setWidth(570),
        height: ScreenUtil().setWidth(120),
        child: TabBar(
          controller: this._tabController,
          isScrollable: false,
          labelColor: Color(0xffff3a97),
          unselectedLabelColor: Color(0xffb541f8),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Color(0xffff3a97),
          labelStyle: TextStyle(fontSize: ScreenUtil().setSp(36)),
          tabs: <Widget>[
            Tab(
              child: this.buildTabBtnText(0, "热门"),
            ),
            Tab(
              child: this.buildTabBtnText(1, "最新"),
            ),
          ],
          onTap: (int _index) {},
        ),
      ),
    );
  }

  ///生成翻页按钮文本
  Widget buildTabBtnText(int _index, String _str) {
    return Text(
      _str,
      style: TextStyle(fontSize: ScreenUtil().setSp(40)),
    );
  }

  ///生成Tab视图
  Widget buildTabView() {
    return Expanded(
      child: Container(
        color: Color(0xff1a1023),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            this.buildTabView_Content(0, 1, 1, _trendsDataListHot),
            this.buildTabView_Content(1, 2, 1, _trendsDataListNew),
          ],
        ),
      ),
    );
  }

  ///生成Tab视图_内容
  Widget buildTabView_Content(
      int _index, int _category, int _curPage, List<TrendsModel> _trendsList) {
    if (this._trendsListViewList[_index] == null) {
      this._trendsListViewList[_index] = SimpleTrendsListView(
        key: _keyList[_index],
        category: _category,
        curPage: _curPage,
        dataList: _trendsList,
        reqMoreDataEvent: this.reqMoreTrendsData,
        itemEvent: this.videoItemEvent,
      );
    }
    return this._trendsListViewList[_index];
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_返回
  void btnEventReturn() {
    DyStyleVariable.keyCurVideoList = null;
    DyStyleVariable.keyCurVideoPage = null;
    DyStyleVariable.keyCurVideoView = null;
    Navigator.pop(context);
  }

  //========== [ 辅助函数 ] ==========
  ///请求更多动态数据
  void reqMoreTrendsData(GlobalKey _key, int _page, int _category) async {
    if (_page == 1) {
      if (_key == this._keyList[0]) {
        this._trendsListViewList[0]?.clearData();
        this._trendsDataListHot = [];
      } else if (_key == this._keyList[1]) {
        this._trendsListViewList[1]?.clearData();
        this._trendsDataListNew = [];
      }
    }

    List<TrendsModel> tempDataList = await this.getTrendsList(_page, _category);

    if (_key == this._keyList[0]) {
      this._trendsListViewList[0].addMoreData(tempDataList);
      this._trendsDataListHot.addAll(tempDataList);
    } else if (_key == this._keyList[1]) {
      this._trendsListViewList[1].addMoreData(tempDataList);
      this._trendsDataListNew.addAll(tempDataList);
    }
  }

  ///视频Item事件
  void videoItemEvent(int _category, int _id) async {
    List<TrendsModel> tempTrendModelList =
        _category == 1 ? _trendsDataListHot : _trendsDataListNew;
    int tempPgaeIndex = 0;
    for (int i = 0; i < tempTrendModelList.length; i++) {
      if (tempTrendModelList[i].id == _id) {
        tempPgaeIndex = i;
        break;
      }
    }

    //
    DyStyleVariable.keyCurVideoList = null;
    DyStyleVariable.keyCurVideoPage = null;
    DyStyleVariable.keyCurVideoView = null;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ScopedModel<MainModel>(
          model: this._mainModel,
          child: MarkListView(
            mark: widget.mark,
            category: _category,
            trendsModelList: tempTrendModelList,
            curPageIndex: tempPgaeIndex,
          ),
        );
      }),
    );
  }

  ///获取视频列表
  ///"category" : 获取类型 1热门 2最新 默认热门
  ///"range" : 获取范围 1为视频 2为全部
  Future<List<TrendsModel>> getTrendsList(int _page, int _category) async {
    if (_category == 1 && this._notDate_Hot) {
      return [];
    }
    if (_category == 2 && this._notDate_New) {
      return [];
    }

    List<TrendsModel> tempDataList = [];
    ResultData _result =
        await HttpManager.requestPost(context, "Tags/get_trends_list", {
      "tag": widget.mark,
      "page": _page,
      "category": _category,
      "range": 1,
    });
    if (_result.result) {
      this._summary = _result.data["summary"] ?? "暂无简介";
      if (_category == 1) {
        setState(() {
          this._notDate_Hot = _result.data["page"] == 0;
        });
      } else {
        setState(() {
          this._notDate_New = _result.data["page"] == 0;
        });
      }
      List<dynamic> tempServerList = _result.data["data"] ?? [];
      tempServerList.forEach((_data) {
        TrendsModel tempData = TrendsModel();
        tempData.fromMap(_data);
        tempDataList.add(tempData);
      });
    }
    return tempDataList;
  }
}
