import 'dart:async';

import 'package:douyin/config/Config.dart';
import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/DYImage.dart';
import 'package:douyin/widget/LoadingBall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///简略动态列表视图
class SimpleTrendsListView extends StatefulWidget {
  ///页面状态
  final SimpleTrendsListViewState myState = new SimpleTrendsListViewState();

  ///一行个数
  final int cntOfRow;

  ///类别
  final int category;

  ///当前页码
  final int curPage;

  ///动态数据列表
  final List<TrendsModel> dataList;

  ///请求更多数据函数
  final Function(GlobalKey _key, int _page, int _category) reqMoreDataEvent;

  ///item事件
  final Function(int _category, int _itemId) itemEvent;

  ///拖动事件
  final Function(bool _isLeft, double _value, bool _dragToNext) dragEvent;

  //构造函数
  SimpleTrendsListView(
      {Key key,
      this.cntOfRow = 2,
      this.category,
      this.curPage,
      this.dataList,
      this.reqMoreDataEvent,
      this.itemEvent,
      this.dragEvent})
      : super(key: key);

  ///滑动控制器
  ScrollController scrollController;

  ///滑动控制器限制值
  double scrollControllerLimitValue;

  @override
  State<StatefulWidget> createState() {
    //this.myState = SimpleTrendsListViewState();
    return this.myState;
  }

  ///添加更多数据
  void addMoreData(List<TrendsModel> _dataList) {
    if (this.myState != null) {
      this.myState.addMoreData(_dataList);
    }
  }

  ///清除数据
  void clearData() {
    if (this.myState != null) {
      this.myState.clearData();
    }
  }

  ///注入滑动控制器
  void injScrollController(ScrollController _sc, double _scLimitValue) {
    this.scrollController = _sc;
    this.scrollControllerLimitValue = _scLimitValue;
  }
}

class SimpleTrendsListViewState extends State<SimpleTrendsListView> {
  ///动态数据列表
  List<TrendsModel> _trendsList;

  ///动态滑动控制器
  ScrollController _trendsScrollController = ScrollController();

  ///当前页码
  int _curPage = 0;

  ///请求状态
  bool _reqState = false;

  ///能否请求(如果获取到为空,则不能继续获取)
  bool _isCanReq = true;

  ///滑动值
  double _dragValue = 0;

  ///拖动到下一页
  bool _dragToNext = false;

  ///滑动倒计时器
  Timer _dragTimer;

  @override
  void initState() {
    super.initState();

    //初始化页码
    this._curPage = widget.curPage;
    //初始化动态数据列表
    this._trendsList = widget.dataList;
    //初始化'动态滑动控制器'
    _trendsScrollController.addListener(() {
      //如果滑动控制器不为空,抛出监听
      if (widget.scrollController != null) {
        if (_trendsScrollController.offset <=
            widget.scrollControllerLimitValue) {
          widget.scrollController.jumpTo(_trendsScrollController.offset);
        }
      }

      if (_trendsScrollController.position.pixels >=
              _trendsScrollController.position.maxScrollExtent -
                  ScreenUtil().setWidth(600) &&
          this._isCanReq) {
        //如果正在请求中,忽略.
        if (this._reqState) {
          return;
        }
        this._curPage++;
        if (widget.reqMoreDataEvent != null) {
          setState(() {
            this._reqState = true;
          });
          widget.reqMoreDataEvent(widget.key, this._curPage, widget.category);
        }
      }
    });
  }

  @override
  void dispose() {
    //释放计时器
    this.endDragTimer();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          //列表
          _trendsList.length > 0 ? this.buildListView() : this.buildTip(),
          //手势
          this.buildGestureDetector(),
        ],
      ),
    );
  }

  ///生成列表视图
  Widget buildListView() {
    return GridView.builder(
      physics: BouncingScrollPhysics(),
      controller: _trendsScrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: ScreenUtil().setWidth(20),
        crossAxisSpacing: ScreenUtil().setWidth(20),
        childAspectRatio: 0.895,
      ),
      itemCount: _trendsList.length,
      itemBuilder: (BuildContext _context, int _index) {
        return this.buildListItem(_index, _trendsList[_index]);
      },
    );
  }

  ///生成列表Item
  Widget buildListItem(int _index, TrendsModel _trendsModel) {
    String tempFollow = Tools.ToString(_trendsModel.likes, "W", false);
    Color tempColor = _index == 0
        ? Color(0xfffad142)
        : _index == 1 ? Color(0xfffa7241) : Color(0xffb941fb);
    return GestureDetector(
      child: ClipRRect(
        //圆角
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10))),
        child: Container(
          width: ScreenUtil().setWidth(500),
          height: ScreenUtil().setWidth(580),
          color: Colors.black54,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              //视频封面
              Container(
                width: ScreenUtil().setWidth(510),
                child: _trendsModel.thumbImg == null || !Config.playVideo
                    ? Image.asset(
                        "images/replace/share_videobg.jpg",
                        fit: BoxFit.fitWidth,
                      )
                    : DYImage(
                        imageUrl: _trendsModel.thumbImg,
                        dyImgFit: Enum_DYImgFit.fitWidth,
                      ),
              ),
              //黑色遮罩
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(10)),
                  gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black26,
                        Colors.black12,
                      ]),
                ),
              ),
              //置顶
              _index < 3
                  ? Positioned(
                      top: 0,
                      left: 0,
                      child: Image.asset(
                        "images/video/mark_icon_rank.png",
                        color: tempColor,
                        width: ScreenUtil().setWidth(140),
                      ),
                    )
                  : Container(),
              _index < 10
                  ? Positioned(
                      top: ScreenUtil().setWidth(6),
                      left: ScreenUtil().setWidth(12),
                      child: Text(
                        "NO.${_index + 1}",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),
                            color: Colors.white),
                      ),
                    )
                  : Container(),
              //描述
              Positioned(
                bottom: ScreenUtil().setWidth(10),
                left: ScreenUtil().setWidth(10),
                child: Container(
                  width: ScreenUtil().setWidth(360),
                  child: Text(
                    _trendsModel.content,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(30),
                        color: Colors.white,
                        height: 1.2),
                  ),
                ),
              ),
              //点赞
              Positioned(
                bottom: ScreenUtil().setWidth(15),
                right: ScreenUtil().setWidth(15),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      "images/video/right_like_00.png",
                      width: ScreenUtil().setWidth(34),
                      color: Colors.white,
                    ),
                    Container(
                      width: ScreenUtil().setWidth(4),
                    ),
                    Text(tempFollow,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            color: Colors.white)),
                  ],
                ),
              ),
              //播放图标
              Positioned(
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white54,
                  size: ScreenUtil().setWidth(150),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        this.btnEventPlayVideo(_trendsModel.id);
      },
    );
  }

  ///生成提示
  Widget buildTip() {
    return this._reqState
        ? LoadingBall()
        : Container(
            child: Text(
              "暂无数据",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(50), color: Colors.white),
            ),
          );
  }

  ///生成手势
  Widget buildGestureDetector() {
    return widget.dragEvent != null
        ? Container(
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(400)),
            child: GestureDetector(
              onHorizontalDragStart: (_d) {
                this.startDragTimer();
              },
              onHorizontalDragUpdate: (_d) {
                double tempDragValue = _d.delta.dx;
                if (tempDragValue.abs() >= ScreenUtil().setWidth(1080 ~/ 40)) {
                  this._dragToNext = true;
                }
                this._dragValue += tempDragValue;
              },
              onHorizontalDragEnd: (_d) {
                this.endDragTimer();
                this.onHorizontalDragEnd();
              },
            ),
          )
        : Container();
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_播放视频
  void btnEventPlayVideo(int _id) {
    if (widget.itemEvent != null) {
      widget.itemEvent(widget.category, _id);
    }
  }

  //========== [ 辅助函数 ] ==========
  ///添加更多数据
  void addMoreData(List<TrendsModel> _dataList) {
    if (!this.mounted) {
      return;
    }

    if (_dataList.length == 0) {
      setState(() {
        this._reqState = false;
        this._isCanReq = false;
      });
      return;
    }
    setState(() {
      this._reqState = false;
      this._trendsList.addAll(_dataList);
    });
  }

  ///清除数据
  void clearData() {
    if (!this.mounted) {
      return;
    }

    setState(() {
      this._trendsList = [];
    });
  }

  ///开始滑动计时器
  void startDragTimer() {
    if (_dragTimer != null) {
      return;
    }
    _dragTimer = Timer.periodic(Duration(milliseconds: 2), (timer) {
      if (widget.dragEvent != null) {
        widget.dragEvent(this._dragValue >= 0, this._dragValue, false);
      }
    });
  }

  ///关闭滑动计时器
  void endDragTimer() {
    _dragTimer?.cancel();
    _dragTimer = null;
  }

  void onHorizontalDragEnd() {
    double tempValue = this._dragValue;
    bool tempLeft = tempValue >= 0;
    bool tempToNex = this._dragToNext;

    if (this.mounted) {
      setState(() {
        this._dragValue = 0;
        this._dragToNext = false;
      });
    }

    if (widget.dragEvent != null) {
      widget.dragEvent(tempLeft, tempValue, tempToNex);
    }
  }
}
