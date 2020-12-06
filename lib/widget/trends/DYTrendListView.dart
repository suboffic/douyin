import 'dart:async';

import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/widget/DYRefreshIndicator.dart';
import 'package:douyin/widget/trends/DYTrendPageView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:douyin/model/MainModel.dart';
import 'dart:ui';

///动态列表视图
class DYTrendListView extends StatefulWidget {
  final DYTrendListViewState myState = DYTrendListViewState();

  ///视频类型  1为获取关注动态 非1为获取推荐
  final int videoType;

  ///动态数据列表
  final List<TrendsModel> trendsModelList;
  //当前面页码
  final int curPageIndex;

  ///请求更多数据事件
  Function(int, int, bool) reqMoreModelEvent;

  ///是否需要获取数据
  final bool needGetModel;

  ///是否需要检测免费(免费观看次数)
  final bool needCheckFree;

  ///设置拖动状态事件
  Function(bool) setDragStateEvent;

  ///前往作者信息界面
  final Function(String _uuid) gotoAuthorInfoPage;

  //构造函数
  DYTrendListView(
      {Key key,
      this.videoType,
      this.trendsModelList,
      this.curPageIndex,
      this.reqMoreModelEvent,
      this.needGetModel = false,
      this.needCheckFree = true,
      this.gotoAuthorInfoPage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    //this.myState = DYTrendListViewState();
    return this.myState;
  }

  ///添加更多视频数据
  void addMoreVideoModel(int _page, bool _isForce, List<TrendsModel> _list) {
    if (_list.length == 0) {
      return;
    }

    this.trendsModelList.addAll(_list);

    if (this.myState != null) {
      this.myState.addMoreVideoModel(_page, _isForce, _list);
    }
  }

  ///获取视频数据个数
  int getVideoModelCount() {
    return this.trendsModelList.length;
  }

  ///清除视频数据
  void cleanVideoModel() {
    this.trendsModelList.clear();
    if (this.myState != null) {
      this.myState.cleanVideoModel();
    }
  }

  ///播放/暂停视频
  void playOrPauseVideo(bool _isPlay) {
    if (this.myState != null) {
      this.myState.playOrPauseVideo(_isPlay);
    }
  }

  ///注入"设置拖动状态事件"
  void injSetDragStateEvent(Function(bool) _event) {
    this.setDragStateEvent = _event;
  }
}

class DYTrendListViewState extends State<DYTrendListView>
    with AutomaticKeepAliveClientMixin {
  // 解决Tab页重绘问题: 1. 继承 AutomaticKeepAliveClientMixin
  // 解决Tab页重绘问题: 2. 设置 wantKeepAlive 为 true,保证不销毁不重绘. (必须保证不销毁)
  @override
  bool get wantKeepAlive => true;

  ///主数据模块
  MainModel _mainModel;

  ///是否能拖拽
  bool _canDrag = true;

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///动态数据列表
  List<TrendsModel> _trendsModelList = [];

  ///当前页码
  int _curPage = 0;

  ///页面控制器
  PageController _pageController;

  ///动态页面列表
  Map<int, DYTrendPageView> _trendPageList = {};

  ///动态页面Key列表
  Map<int, GlobalKey> _trendPageKeyList = {};

  ///上个页面下标
  int _lastPageIndex = 0;

  ///是否强制刷新
  bool _isForce = false;

  @override
  void initState() {
    super.initState();

    this._trendsModelList = widget.trendsModelList;
    this._curPage = widget.trendsModelList.length > 0 ? 1 : 0;
    this.initEventBus();
    //初始化视图宽度 & 高度
    _viewWidth = ScreenUtil().setWidth(1080);
    double _statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    _viewHeight = ScreenUtil().setHeight(1920) - _statusBarHeight;
    // 监听PageController
    this._curPage = widget.curPageIndex;
    this._pageController = PageController(initialPage: _curPage);
    this._pageController.addListener(() {
      int tempPage = _pageController.page.toInt();
      if (tempPage == _pageController.page && tempPage != this._lastPageIndex) {
        //缓存Key
        DyStyleVariable.keyCurVideoPage = this._trendPageKeyList[tempPage];
        //更新页码
        this.releaseVideo();
        this._lastPageIndex = tempPage;
        this.playOrPauseVideo(true);
        if (widget.videoType == 0) {
          DyStyleVariable.curVideoAuthorId =
              this._trendsModelList[this._lastPageIndex].uuid;
        }
      }
      //预加载
      if (tempPage >= (this._trendsModelList.length - 2)) {
        if (widget.reqMoreModelEvent != null) {
          widget.reqMoreModelEvent(widget.videoType, this._curPage + 1, false);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    //取消订阅
    this.releaseEventBus();
  }

  @override
  Widget build(BuildContext context) {
    // 解决Tab页重绘问题: 3. 要使用 super.build
    super.build(context);
    return Container(
      width: _viewWidth,
      height: _viewHeight,
      color: Colors.transparent,
      child: DYRefreshIndicator(
        child: this._trendsModelList.length > 0
            ? PageView.builder(
                scrollDirection: Axis.vertical,
                physics: this._canDrag
                    ? ClampingScrollPhysics()
                    : NeverScrollableScrollPhysics(),
                controller: this._pageController,
                itemCount: this._trendsModelList.length,
                itemBuilder: (BuildContext _context, int _index) {

                  print("PageView  vertical build");
                  return this.buildVideoView(this._trendsModelList[_index], _index);
                },
              )
            : this.buildNotData(),
        onRefresh: this._refresh,
      ),
    );
  }

  ///生成视频视图
  Widget buildVideoView(TrendsModel _model, int _index) {
    //如果下标超过现有的,认为需要添加...否则为刷新
    if (this._isForce || this._trendPageList[_index] == null) {
      GlobalKey tempKey = GlobalKey();
      DYTrendPageView tempVideoView = DYTrendPageView(
        key: tempKey,
        myVideoListKey: widget.key,
        trendsModel: _model,
        needGetModel: widget.needGetModel,
        needCheckFree: widget.needCheckFree,
        setDragStateEvent: (bool _canDrag) {
          setState(() {
            this._canDrag = _canDrag;
          });
          if (widget.setDragStateEvent != null) {
            widget.setDragStateEvent(_canDrag);
          }
        },
        gotoAuthorInfoPage: widget.gotoAuthorInfoPage,
      );
      this._trendPageList[_index] = tempVideoView;
      this._trendPageKeyList[_index] = tempKey;
    }
    return Container(
      height: _viewHeight,
      child: this._trendPageList[_index],
    );
  }

  ///生成空数据
  Widget buildNotData() {
    return Container(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(400)),
      color: Color(0xff171a23),
      child: Column(
        children: <Widget>[
          //图标
          Image.asset(
            "images/video/icon_maillist.jpg",
            fit: BoxFit.fill,
            width: ScreenUtil().setWidth(800),
            height: ScreenUtil().setWidth(560),
          ),
          Container(
            height: ScreenUtil().setWidth(50),
          ),
          //提示语
          Text(
            "暂无关注人动态",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(50), color: Colors.white),
          ),
        ],
      ),
    );
  }

  ///添加更多视频数据
  void addMoreVideoModel(int _page, bool _isForce, List<TrendsModel> _list) {
    //如果请求数据回复的页面ID,等于当前的,则不需要添加(已经加过)
    if (this._curPage == _page && !_isForce) {
      return;
    }
    this._curPage = _page;
    this._isForce = _isForce;
    if (_curPage == 1) {
      this._trendsModelList = _list;
    } else {
      this._trendsModelList.addAll(_list);
    }
    setState(() {});

    if (widget.videoType == 0) {
      DyStyleVariable.curVideoAuthorId =
          this._trendsModelList[this._lastPageIndex].uuid;
    }
  }

  ///清除视频数据
  void cleanVideoModel() {
    this._trendsModelList.clear();
    this._trendPageList.clear();
    setState(() {});
  }

  ///播放/暂停视频
  void playOrPauseVideo(bool _isPlay) {
    if (this._lastPageIndex >= this._trendPageList.length ||
        this._trendPageList.length == 0) {
      return;
    }
    this._trendPageList[this._lastPageIndex].playOrPauseVideo(_isPlay);
  }

  ///释放播放器
  void releaseVideo() {
    if (this._lastPageIndex >= this._trendPageList.length ||
        this._trendPageList.length == 0) {
      return;
    }
    this._trendPageList[this._lastPageIndex].releaseVideo();
  }

  ///刷新事件
  Future<Null> _refresh() async {
    DyStyleVariable.keyCurVideoList = null;
    DyStyleVariable.keyCurVideoPage = null;
    DyStyleVariable.keyCurVideoView = null;

    if (widget.reqMoreModelEvent != null) {
      widget.reqMoreModelEvent(widget.videoType, 1, true);
    }
  }

  //========== [ 事件总线 ] ==========
  ///视频视图通知列表事件
  StreamSubscription _videoViewToVideoListScription;

  ///关注通知视频视图事件
  StreamSubscription _followToVideoListScription;

  ///初始化事件总线
  void initEventBus() {
    //初始化'视频视图通知列表'事件
    if (_videoViewToVideoListScription == null) {
      _videoViewToVideoListScription =
          DYEventBus.eventBus.on<VideoViewToVideoList>().listen((event) async {
        this.videoViewToListEvent(
            event.listKey, event.eventName, event.eventArg);
      });
    }
    //初始化'关注通知视频视图'事件
    if (_followToVideoListScription == null) {
      _followToVideoListScription =
          DYEventBus.eventBus.on<FollowToVideoList>().listen((event) {
        List<int> tempIndexList =
            this.refreshFollowState(event.uuid, event.state);
        tempIndexList.forEach((_index) {
          if (this._trendPageList[_index] != null) {
            this._trendPageList[_index].setFollowState(event.state);
          }
        });
      });
    }
  }

  ///释放事件总线
  void releaseEventBus() {
    _videoViewToVideoListScription?.cancel();
    _videoViewToVideoListScription = null;
    _followToVideoListScription?.cancel();
    _followToVideoListScription = null;
  }

  ///视频视图通知列表事件
  void videoViewToListEvent(
      GlobalKey _listKye, String _eventName, dynamic _eventArg) {
    if (_listKye != widget.key) {
      return;
    }
    switch (_eventName) {
      case "Follow":
        this.refreshFollowState(_eventArg["uuid"], _eventArg["state"]);
        break;
    }
  }

  ///刷新关注状态
  List<int> refreshFollowState(String _uuid, bool _state) {
    List<int> tempIndexList = [];
    for (int i = 0; i < this._trendsModelList.length; i++) {
      if (this._trendsModelList[i].uuid == _uuid) {
        this._trendsModelList[i].hasFollow = _state;
        tempIndexList.add(i);
      }
    }
    return tempIndexList;
  }
}
