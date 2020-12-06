import 'dart:ui';

import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/widget/DotsIndicator.dart';
import 'package:douyin/widget/trends/DYTrendView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///动态页面视图
class DYTrendPageView extends StatefulWidget {
  ///页面状态
  DYTrendPageViewState myState;

  ///视频列表Key
  final GlobalKey myVideoListKey;

  ///视频数据
  final TrendsModel trendsModel;

  ///是否需要获取数据
  final bool needGetModel;

  ///是否需要检测免费(免费观看次数)
  final bool needCheckFree;

  ///设置拖动状态事件
  final Function(bool) setDragStateEvent;

  ///前往作者信息界面
  final Function(String _uuid) gotoAuthorInfoPage;

  //构造函数
  DYTrendPageView(
      {Key key,
      this.myVideoListKey,
      this.trendsModel,
      this.needGetModel = false,
      this.needCheckFree = true,
      this.setDragStateEvent,
      this.gotoAuthorInfoPage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    this.myState = new DYTrendPageViewState();
    return this.myState;
  }

  ///播放/暂停视频
  void playOrPauseVideo(bool _isPlay) {
    if (this.myState != null) {
      this.myState.playOrPauseVideo(_isPlay);
    }
  }

  ///释放播放器
  void releaseVideo() {
    this.myState.releaseVideo();
  }

  ///设置关注状态
  void setFollowState(bool _state) {
    if (this.myState != null) {
      this.myState.setFollowState(_state);
    }
  }
}

class DYTrendPageViewState extends State<DYTrendPageView> {
  ///主数据模块
  MainModel _mainModel;

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///是否页面
  bool _isPage = false;

  ///是否能拖拽
  bool _canDrag = true;

  ///页面控制器
  PageController _pageController = PageController();

  ///动态视图列表
  List<DYTrendView> _trendViewList = [];

  ///动态视图Key列表
  List<GlobalKey> _trendViewKeyList = [];

  ///上个页面下标
  int _lastPageIndex = 0;

  @override
  void initState() {
    super.initState();

    //初始化视图宽度 & 高度
    _viewWidth = ScreenUtil().setWidth(1080);
    double _statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    _viewHeight = ScreenUtil().setHeight(1920) - _statusBarHeight;
    //
    this._isPage = widget.trendsModel.play.length > 1;
    // 监听PageController
    this._pageController.addListener(() {
      int tempPage = _pageController.page.toInt();
      if (tempPage == _pageController.page && tempPage != this._lastPageIndex) {
        //缓存Key
        DyStyleVariable.keyCurVideoView = this._trendViewKeyList[tempPage];
        //更新页码
        this._lastPageIndex = tempPage;
        this.playOrPauseVideo(true);
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      return Stack(
        children: <Widget>[
          _isPage ? this.buildVideoList() : this.buildVideoView(),
          this.buildDotsIndicator(),
        ],
      );
    });
  }

  ///生成视频列表
  Widget buildVideoList() {
    return Container(
      width: _viewWidth,
      height: _viewHeight,
      color: Colors.transparent,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        physics: this._canDrag
            ? ClampingScrollPhysics()
            : NeverScrollableScrollPhysics(),
        controller: this._pageController,
        itemCount: widget.trendsModel.play.length,
        itemBuilder: (BuildContext _context, int _index) {
          return this.buildVideoItem(widget.trendsModel.play[_index], _index);
        },
      ),
    );
  }

  ///生成视频Item
  Widget buildVideoItem(PlayData _playData, int _index) {
    //如果下标超过现有的,认为需要添加...否则为刷新
    if (_index > (this._trendViewList.length - 1)) {
      GlobalKey tempKey = GlobalKey();
      TrendsModel tempTrendModel = TrendsModel();
      tempTrendModel = widget.trendsModel;
      tempTrendModel.play = [_playData];
      DYTrendView tempTrendView = DYTrendView(
        key: tempKey,
        myVideoListKey: widget.myVideoListKey,
        myVideoPageKey: widget.key,
        trendsModel: tempTrendModel,
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
      this._trendViewList.add(tempTrendView);
      this._trendViewKeyList.add(tempKey);
    }
    return Container(
      height: _viewHeight,
      child: this._trendViewList[_index],
    );
  }

  ///生成视频视图
  Widget buildVideoView() {
    GlobalKey tempKey = GlobalKey();
    TrendsModel tempTrendModel = TrendsModel();
    tempTrendModel = widget.trendsModel;
    DYTrendView tempTrendView = DYTrendView(
      key: tempKey,
      myVideoListKey: widget.myVideoListKey,
      myVideoPageKey: widget.key,
      trendsModel: tempTrendModel,
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
    this._trendViewList.add(tempTrendView);
    this._trendViewKeyList.add(tempKey);
    tempTrendView.injSetDragStateEvent((bool _canDrag) {
      setState(() {
        this._canDrag = _canDrag;
      });
      if (widget.setDragStateEvent != null) {
        widget.setDragStateEvent(_canDrag);
      }
    });
    return Container(
      height: _viewHeight,
      child: this._trendViewList[0],
    );
  }

  ///生成点状指示器
  Widget buildDotsIndicator() {
    return this._isPage
        ? Positioned(
            bottom: ScreenUtil().setWidth(100),
            child: Container(
              height: ScreenUtil().setWidth(60),
              // margin: EdgeInsets.only(top: ScreenUtil().setHeight(25)),
              child: DotsIndicator(
                controller: this._pageController,
                itemCount: widget.trendsModel.play.length,
                colorNoraml: Colors.grey,
                colorSelect: Colors.white,
                onPageSelected: (int page) {
                  this._pageController.animateToPage(
                        page,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                },
              ),
            ),
          )
        : Container();
  }

  ///播放/暂停视频
  void playOrPauseVideo(bool _isPlay) {
    if (this._lastPageIndex >= this._trendViewList.length ||
        this._trendViewList.length == 0) {
      return;
    }
    if (!this.mounted) {
      return;
    }
    this._trendViewList[this._lastPageIndex].playOrPauseVideo(_isPlay);
    //清空当前图片页码
    setState(() {
      this._lastPageIndex = 0;
    });
  }

  ///释放播放器
  void releaseVideo() {
    if (this._lastPageIndex >= this._trendViewList.length ||
        this._trendViewList.length == 0) {
      return;
    }
    this._trendViewList[this._lastPageIndex].releaseVideo();
  }

  ///设置关注状态
  void setFollowState(bool _state) {
    if (this._lastPageIndex >= this._trendViewList.length ||
        this._trendViewList.length == 0) {
      return;
    }
    this._trendViewList[this._lastPageIndex].setFollowState(_state);
  }
}
