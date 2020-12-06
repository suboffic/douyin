import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/style/DYPhysicalBtnEvtControll.dart';
import 'package:douyin/widget/trends/DYTrendListView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///喜欢列表视图
class LikeListView extends StatefulWidget {
  //用户id
  final String uuid;
  //数据列表
  final List<TrendsModel> trendsModelList;
  //当前页码
  final int curPageIndex;

  //构造函数
  LikeListView({Key key, this.uuid, this.trendsModelList, this.curPageIndex})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LikeListViewState();
  }
}

class LikeListViewState extends State<LikeListView> {
  ///主数据模块
  MainModel _mainModel;

  ///动态列表视图
  DYTrendListView _trendListView;

  ///请求状态
  bool _reqState = false;

  @override
  void initState() {
    super.initState();

    //初始化
    this._trendListView = DYTrendListView(
      videoType: 0,
      trendsModelList: widget.trendsModelList,
      curPageIndex: widget.curPageIndex,
      reqMoreModelEvent: this.reqMoreLikeModelEvent,
      needGetModel: true,
    );
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
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            backgroundColor: Colors.black,
            elevation: 0.0,
            brightness: Brightness.dark,
          ),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            //动态列表视图
            this._trendListView,
            //扩展UI_返回
            this.buildExtendUIReturn(),
            //扩展UI_搜索
            this.buildExtendUISearch(),
          ],
        ),
      );
    });
  }

  //生成扩展UI_返回
  Widget buildExtendUIReturn() {
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

  //生成扩展UI_搜索
  Widget buildExtendUISearch() {
    return Positioned(
      top: ScreenUtil().setWidth(40),
      right: ScreenUtil().setWidth(40),
      child: InkWell(
        child: Icon(
          Icons.search,
          size: ScreenUtil().setWidth(100),
          color: Colors.white,
        ),
        onTap: this.btnEventSearch,
      ),
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_搜索
  void btnEventSearch() {}

  //========== [ 辅助函数 ] ==========
  ///请求更多喜欢数据事件
  void reqMoreLikeModelEvent(int _videoType, int _page, bool _isForce) async {
    if (this._reqState) {
      return;
    }

    this._reqState = true;
    ResultData _result = await HttpManager.requestPost(
        context, "/likes", {"uuid": widget.uuid, "page": _page});
    this._reqState = false;
    if (_result.result) {
      List<TrendsModel> tempTrendsDataList = [];
      if (_result.data["data"] != null) {
        setState(() {
          this._reqState = _result.data["page"] == 0;
        });
        _result.data["data"].forEach((_data) {
          TrendsModel tempTrendsData = TrendsModel();
          tempTrendsData.fromMap(_data);
          tempTrendsDataList.add(tempTrendsData);
        });
      }
      this
          ._trendListView
          .addMoreVideoModel(_page, _isForce, tempTrendsDataList);
    }
  }
}
