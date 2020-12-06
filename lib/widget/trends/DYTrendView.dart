import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:douyin/config/Config.dart';
import 'package:douyin/model/CommentModel.dart';
import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/model/UserModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/page/Home/MarkPage.dart';
import 'package:douyin/page/Home/SharePage.dart';
import 'package:douyin/page/Mine/MinePage.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/style/DYPhysicalBtnEvtControll.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/DYImage.dart';
import 'package:douyin/widget/HeadWidget.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:douyin/widget/trends/DYTrendGift.dart';
import 'package:douyin/widget/trends/DYTrendLikePage.dart';
import 'package:douyin/widget/trends/TrendBarragePage.dart';
import 'package:douyin/widget/trends/TrendGiftPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:douyin/model/MainModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

///动态视图
class DYTrendView extends StatefulWidget {
  ///页面状态
  final DYTrendViewState myState = new DYTrendViewState();

  ///视频列表Key
  final GlobalKey myVideoListKey;

  ///视频页面Key
  final GlobalKey myVideoPageKey;

  ///视频数据
  final TrendsModel trendsModel;

  ///是否需要获取数据
  final bool needGetModel;

  ///是否需要检测免费(免费观看次数)
  final bool needCheckFree;

  ///设置拖动状态事件
  Function(bool) setDragStateEvent;

  ///前往作者信息界面
  final Function(String _uuid) gotoAuthorInfoPage;

  //构造函数
  DYTrendView(
      {Key key,
      this.myVideoListKey,
      this.myVideoPageKey,
      this.trendsModel,
      this.needGetModel = false,
      this.needCheckFree = true,
      this.setDragStateEvent,
      this.gotoAuthorInfoPage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return this.myState;
  }

  ///播放/暂停视频
  void playOrPauseVideo(bool _isPlay) {
    this.myState.playOrPauseVideo(_isPlay);
  }

  ///释放播放器
  void releaseVideo() {
    this.myState.releaseVideo();
  }

  ///设置关注状态
  void setFollowState(bool _state) {
    this.trendsModel.hasFollow = _state;
    if (this.myState != null && this.myState.mounted) {
      this.myState.setState(() {
        print("setState" + StackTrace.current.toString());
        this.myState._showFollowBtn = !_state;
        this.myState._animcontrolFollowBtn.reset();
        this.myState._followBtnValue = _state ? 1 : 0;
      });
    }
  }

  ///注入"设置拖动状态事件"
  void injSetDragStateEvent(Function(bool) _event) {
    this.setDragStateEvent = _event;
  }
}

class DYTrendViewState extends State<DYTrendView>
    with TickerProviderStateMixin {
  ///主数据模块
  MainModel _mainModel;

  ///用户数据
  UserModel _userModel;

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///是否播放过广告(如果播放过,不重复播放)
  bool _isPlayAds = false;

  ///显示弹幕
  bool _showBarrage = false;

  ///视频播放器控制器
  VideoPlayerController _controller;

  ///是否有数据(完整的)
  bool _haveData = false;

  ///是否播放视频
  bool _isPlayVideo = false;

  ///是否初始化视频
  bool _isInitVideo = false;

  ///视频尺寸(适配后)
  Size _videoSize = Size(0, 0);

  ///(视频)空白高度
  double _blankHeight = 0;

  ///(视频)点击位置
  Offset _onPanOffset;

  ///最大播放时间(整个视频时长/预览时长)
  int _maxPlaySeconds = 0;

  ///动画控制器_阻断(页面缩放)
  AnimationController _animControllerPrevent;

  ///总秒数
  int _totalSeconds = 0;

  ///当前秒数
  int _curSeconds = 0;

  ///滑块值
  double _sliderValue = 0;

  ///是否显示时间
  bool _isShowTime = false;

  ///是否扩大(时间)滑块
  bool _isExpandSlider = false;

  ///是否感兴趣(防止重复记录)
  bool _isInterest = false;

  ///动画_播放按钮
  Animation<double> _animtionPlayIcon;

  ///动画控制器_播放按钮
  AnimationController _animcontrolPlayIcon;

  ///动态弹幕界面
  TrendBarragePage _trendBarragePage;

  ///分享界面
  SharePage _sharePage;

  ///点赞界面
  DYTrendLikePage _likePage;

  ///点赞UI的key
  GlobalKey _likeKey = GlobalKey();

  ///广告计时器(单位s)
  Timer _adTimer;

  ///功能按钮计时器(用于两侧功能按钮的动画)
  Timer _funcBtnTimer;

  ///动画_功能按钮
  Animation<double> _animtionFuncBtn;

  ///动画控制器_功能按钮
  AnimationController _animcontrolFuncBtn;

  ///功能按钮的动画值
  double _funcBtnValue = 0;

  ///显示功能UI
  bool _showFuncUI = true;

  ///动画_关注按钮
  Animation<double> _animtionFollowBtn;

  ///动画控制器_关注按钮
  AnimationController _animcontrolFollowBtn;

  ///动画按钮的动画值
  double _followBtnValue = 0;

  ///显示关注按钮
  bool _showFollowBtn = true;

  ///评论控制器
  TextEditingController _commentController = TextEditingController();

  ///评论焦点
  FocusNode _commentFocusNode = FocusNode();

  var _setVideoState;

  var _setUILeftState;

  var _setBuildVideoViewState;

  Future _controllerLoad;

  var _setUIRightState;

  @override
  void initState() {
    this._controller =
        VideoPlayerController.network(widget.trendsModel.play[0].play_url);
    this._controllerLoad = _controller.initialize();
    this._showBarrage = DyStyleVariable.showBarrage;
    //初始化视图宽度 & 高度
    _viewWidth = ScreenUtil().setWidth(1080);
    double _statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    _viewHeight = ScreenUtil().setHeight(1920) - _statusBarHeight;

    this._videoSize = Size(_viewWidth, _viewHeight);
    //todo 临时做法
    this._mainModel = DyStyleVariable.mainModel;
    this._userModel = this._mainModel.userModel;

    this._haveData = widget.needGetModel ? false : true;

    //初始化一个动画控制器 定义好动画的执行时长
    _animControllerPrevent = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    //初始化“播放按钮”动画控制器
    _animcontrolPlayIcon = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _animtionPlayIcon =
            Tween(begin: 0.0, end: 1.0.toDouble()).animate(_animcontrolPlayIcon)
        /*..addListener(() {
            if (_controller == null) {
              return;
            }
            if (this.mounted) {
              setState((){
                print("setState"+StackTrace.current.toString());
              });
            }
          })*/
        ;
    _animcontrolPlayIcon.reset();
    //初始化“功能按钮”动画控制器
    _animcontrolFuncBtn = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _animtionFuncBtn =
        Tween(begin: 0.0, end: 1.0.toDouble()).animate(_animcontrolFuncBtn)
          ..addListener(() {
            if (this.mounted) {
              this._funcBtnValue = this._animtionFuncBtn.value;
              //print("_funcBtnValue : " + _funcBtnValue.toString());
              if (_setUILeftState != null) _setUILeftState(() {});
              if (_setUIRightState != null) _setUIRightState(() {});
            }
          });
    _animcontrolFuncBtn.reset();
    //初始化“关注按钮”动画控制器
    _animcontrolFollowBtn = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    _animtionFollowBtn = Tween(begin: 0.0, end: 1.0.toDouble())
            .animate(_animcontrolFollowBtn)
        /*..addListener(() {
            if (this.mounted) {
              setState((){
                print("setState"+StackTrace.current.toString());
                this._followBtnValue = this._animtionFollowBtn.value;
              });
            }
          })*/
        ;
    _animcontrolFollowBtn.reset();
    this._followBtnValue = widget.trendsModel.hasFollow ? 1 : 0;
    this._showFollowBtn = widget.trendsModel.uuid == this._userModel.uuid
        ? false
        : !widget.trendsModel.hasFollow;
    //开始功能按钮计时器
    //this.startFuncTimer();
    //如果需要获取整份数据
    if (widget.needGetModel) {
      this.getSingleTrendModel(widget.trendsModel.id);
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;

    this.endAdTimer();
    this.endFuncTimer();

    this._animcontrolPlayIcon.dispose();
    this._animcontrolFuncBtn.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!Navigator.of(context).canPop()) {
      if (this.mounted) {
        //刷新关注状态
        setState(() {
          print("setState" + StackTrace.current.toString());
          this._showFollowBtn = !widget.trendsModel.hasFollow;
        });
      }
      if (!widget.trendsModel.hasFollow) {
        this._followBtnValue = 0;
        this._animcontrolFollowBtn.reset();
      }

      void tempFunc(bool _state, GlobalKey _key) {
        if (_state && _key == widget.myVideoListKey) {
          if (this._isInitVideo) {
            this.playOrPauseVideo(true); //开始播放
          } else {
            this.checkCanPlay();
          }
        }
      }

      DYEventBus.eventBus.fire(CheckVideoPlayState_V2H(tempFunc));
    } else {
      if (this._isInitVideo) {
        this.playOrPauseVideo(false); //暂停播放
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('build');
    if (!this._haveData) {
      return Container();
    }

    return ClipRRect(
      //视频圆角
      borderRadius:
          BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20))),
      child: Container(
        width: this._viewWidth,
        height: this._viewHeight,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            this.buildVideoView(),
            this.buildPlayIcon(),
            //点赞界面
            this.buildLikePage(),
            this.buildClickVideo(),
            this.buildUI(),
            this.buildVideo(),
            //礼物界面
            this.buildTrendGiftPage(),
            //分享界面
            this.buildSharePage(),
          ],
        ),
      ),
    );
  }

  Widget buildVideo() {
    return StatefulBuilder(builder: (context, _setState) {
      _setVideoState = _setState;

      return Stack(alignment: Alignment.center, children: [
        //进度条(为了实现效果,单独一层)
        this.buildProgress(),
        ////阻断界面
        this.buildPreventPage(),
        ////弹幕界面
        this.buildTrendBarragePage(),
      ]);
    });
  }

  ///生成视频视图
  Widget buildVideoView() {
    return StatefulBuilder(
      builder: (context, _setState) {
        if (_controller != null && _controller.value.initialized) {
          //适配视频尺寸
          this.adaptationVideoSize(_controller.value.size);
        }
        _setBuildVideoViewState = _setState;

        return Container(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              //视频
              Config.playVideo
                  ? Positioned(
                      top: this._blankHeight,
                      child:
                          _controller == null || !_controller.value.initialized
                              ? Container()
                              : Container(
                                  width: this._videoSize.width,
                                  height: this._videoSize.height,
                                  child: StatefulBuilder(
                                      builder: (context, _setState) {
                                    //_setVideoState = _setState;
                                    return VideoPlayer(_controller);
                                  })),
                    )
                  : Container(
                      width: this._viewWidth,
                      height: this._viewHeight,
                      color: Colors.black,
                    ),
              //封面
              widget.trendsModel.thumbImg == null || !Config.playVideo
                  ? Container(
                      width: this._videoSize.width,
                      height: this._videoSize.height,
                      child: Image.asset(
                        "images/replace/videocover.jpg",
                        fit: BoxFit.fill,
                      ),
                    )
                  : Container(
                      width: this._viewWidth,
                      child: DYImage(
                        imageUrl: widget.trendsModel.thumbImg,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  ///生成图片视图
  Widget buildImageView() {
    return Container(
      child: Image.network(widget.trendsModel.play[0].play_url),
    );
  }

  ///生成点击_视频
  Widget buildClickVideo() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black26,
                Colors.transparent,
                Colors.black26,
              ]),
        ),
      ),
      onTap: () {
        if (this._showFuncUI) {
          this.endFuncTimer();
          this.playOrPauseVideo(!this._isPlayVideo);
          if (this._isPlayVideo) {
            this._trendBarragePage.playAnim();
          } else {
            this._trendBarragePage.stopAnim();
          }
        } else {
          this._animcontrolFuncBtn.reverse();
          this.startFuncTimer();
          if (this.mounted) {
            setState(() {
              print("setState" + StackTrace.current.toString());
              this._showFuncUI = true;
              this._trendBarragePage.fadeOut();
            });
          }
        }
        //收回评论输入键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onPanDown: (_d) {
        this._onPanOffset = _d.localPosition;
      },
      onDoubleTap: () {
        this._likePage.doubleTapToLike(this._onPanOffset);
        if (!widget.trendsModel.has_like) {
          this.btnEventRightLike();
        }
      },
    );
  }

  ///生成点击_图片
  Widget buildClickImage() {
    return GestureDetector(
      onTap: () {
        if (this._showFuncUI) {
          this._animcontrolFuncBtn.forward();
          this.endFuncTimer();
          if (this.mounted) {
            setState(() {
              print("setState" + StackTrace.current.toString());
              this._showFuncUI = false;
              this._trendBarragePage.fadeIn();
            });
          }
        } else {
          this._animcontrolFuncBtn.reverse();
          this.startFuncTimer();
          if (this.mounted) {
            setState(() {
              print("setState" + StackTrace.current.toString());
              this._showFuncUI = true;
              this._trendBarragePage.fadeOut();
            });
          }
        }
        //收回评论输入键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onPanDown: (_d) {
        this._onPanOffset = _d.localPosition;
      },
      onDoubleTap: () {
        this._likePage.doubleTapToLike(this._onPanOffset);
        if (!widget.trendsModel.has_like) {
          this.btnEventRightLike();
        }
      },
    );
  }

  ///生成播放按钮
  Widget buildPlayIcon() {
    return StatefulBuilder(
      builder: (context, _setState) {
        print("buildPlayIcon");
        _animtionPlayIcon.addListener(() {
          if (_controller == null) {
            return;
          }
          _setState(() {});
        });
        double tempValue = this._animtionPlayIcon.value;
        int tempWidth = (200 * (tempValue - 2)).abs().toInt();
        return Positioned(
          child: Opacity(
            opacity: tempValue,
            child: Image.asset(
              "images/video/icon_play.png",
              color: Colors.white30,
              fit: BoxFit.fill,
              width: ScreenUtil().setWidth(tempWidth),
            ),
          ),
        );
      },
    );
  }

  ///生成UI
  Widget buildUI() {
    bool tempShowUI = !this._isShowTime && this._showFuncUI;
    return Positioned(
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: this._viewWidth,
            height: this._viewHeight -
                ScreenUtil().setWidth(80) -
                (tempShowUI ? ScreenUtil().setWidth(70) : 0),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                this.buildUILeft(),
                this.buildUIRight(),
              ],
            ),
          ),
          tempShowUI ? this.buildUIBtn() : Container(),
          Container(),
          //空白位置为了排列进度条
          Container(
            height: ScreenUtil().setWidth(78),
          ),
        ],
      ),
    );
  }

  ///生成UI_左侧
  Widget buildUILeft() {
    //print('buildUILeft');
    return StatefulBuilder(builder: (context, _setUILeftState) {
      this._setUILeftState = _setUILeftState;
      return this._funcBtnValue * -1 > -1
          ? Positioned(
              left: this._funcBtnValue * -1 * ScreenUtil().setWidth(1080),
              child: Container(
                width: ScreenUtil().setWidth(1080),
                child: Column(
                  children: <Widget>[
                    this.buildUILeftGotoUser(),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(25)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          this.buildUILeftMarkList(),
                          this.buildUILeftUserInfo(),
                          this.buildUILeftDescribe(),
                          this.buildUILeftAdsBtn(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container();
    });
  }

  ///生成UI_左侧_前往个人中心
  Widget buildUILeftGotoUser() {
    return Container();
  }

  ///生成UI_左侧_标签列表
  Widget buildUILeftMarkList() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      width: ScreenUtil().setWidth(680),
      child: Wrap(
        spacing: ScreenUtil().setWidth(28), //主轴上子控件的间距
        runSpacing: ScreenUtil().setWidth(28), //交叉轴上子控件之间的间距
        //要显示的子控件集合
        children: List.generate(widget.trendsModel.tags.length, (_index) {
          return this
              .buildUILeftMarkItem(_index, widget.trendsModel.tags[_index]);
        }),
      ),
    );
  }

  ///生成UI_左侧_标签Item
  Widget buildUILeftMarkItem(int _index, String _mark) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(25),
            vertical: ScreenUtil().setWidth(10)),
        height: ScreenUtil().setWidth(80),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text("#$_mark",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(40), color: Colors.white)),
      ),
      onTap: () {
        this.btnEventLeftMarkItem(_mark);
      },
    );
  }

  ///生成UI_左侧_用户信息
  Widget buildUILeftUserInfo() {
    String tempNickName = Tools.cutString(
        widget.trendsModel.nickname, this._showFollowBtn ? 6 : 8);
    return InkWell(
      child: Container(
        height: ScreenUtil().setWidth(130),
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            //信息背景
            Container(
              width: ScreenUtil().setWidth(_showFollowBtn ? 540 : 520),
              height: ScreenUtil().setWidth(100),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(140),
                  ),
                  //昵称
                  Text(
                    tempNickName,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(40), color: Colors.white),
                  ),
                  //关注
                  this.buildUILeftUserInfoFollow(),
                  Container(
                    width: ScreenUtil().setWidth(10),
                  ),
                ],
              ),
            ),
            //头像
            Container(
              width: ScreenUtil().setWidth(130),
              height: ScreenUtil().setWidth(130),
              child: HeadWidget(
                headSize: Size(
                  ScreenUtil().setWidth(130),
                  ScreenUtil().setWidth(130),
                ),
                avatarUrl: widget.trendsModel.avatarUrl,
                level: widget.trendsModel.vipLevel,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        this.btnEventLeftUserInfo();
      },
    );
  }

  ///生成UI_左侧_用户信息_关注
  Widget buildUILeftUserInfoFollow() {
    return StatefulBuilder(
      builder: (context, _setState) {
        _animtionFollowBtn.addListener(() => _setState(() {
              this._followBtnValue = this._animtionFollowBtn.value;
            }));

        double tempOp = (1 - this._followBtnValue) * 2;
        double tempWidth = this._showFollowBtn ? ScreenUtil().setWidth(76) : 0;
        tempOp = tempOp > 1 ? 1 : tempOp;

        return InkWell(
          child: Container(
            width: tempWidth,
            height: tempWidth,
            child: Stack(
              children: <Widget>[
                //关注_底
                Image.asset("images/video/icon_follow_01.png"),
                //关注_顶(动画)
                Opacity(
                  opacity: tempOp,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..rotateZ(pi * this._followBtnValue),
                    origin: Offset(
                        ScreenUtil().setWidth(38), ScreenUtil().setWidth(38)),
                    child: Image.asset("images/video/icon_follow_00.png"),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            widget.trendsModel.hasFollow = !widget.trendsModel.hasFollow;
            this.btnEventLeftFollow(widget.trendsModel.hasFollow);
          },
        );
      },
    );
  }

  ///生成UI_左侧_描述
  Widget buildUILeftDescribe() {
    return Container(
      width: ScreenUtil().setWidth(700),
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      child: Text(widget.trendsModel.content,
          style:
              TextStyle(fontSize: ScreenUtil().setSp(40), color: Colors.white)),
    );
  }

  ///生成UI_左侧_广告按钮
  Widget buildUILeftAdsBtn() {
    double tempWidth = ScreenUtil().setWidth(700);
    double tempHeight = ScreenUtil().setWidth(88);
    return widget.trendsModel.ads == null
        ? Container()
        : Container(
            width: tempWidth,
            height: tempHeight,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
            child: FlatButton(
              padding: EdgeInsets.all(0),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset(
                    "images/video/btn_goto_00.png",
                    fit: BoxFit.fill,
                    width: tempWidth,
                    height: tempHeight,
                  ),
                  Text(
                    "立即前往 >",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(40), color: Colors.white),
                  ),
                ],
              ),
              onPressed: () {
                this.btnEventLeftAd();
              },
            ));
  }

  ///生成UI_右侧
  Widget buildUIRight() {
    //print('buildUIRight');
    //return Container();

    return StatefulBuilder(builder: (context, _setUIRightState) {
      this._setUIRightState = _setUIRightState;
      return this._funcBtnValue * -1 > -1
          ? Positioned(
              right: this._funcBtnValue * -1 * ScreenUtil().setWidth(1080),
              child: Stack(
                children: <Widget>[
                  this.buildUIRightGift(),
                  Container(
                    width: ScreenUtil().setWidth(1080),
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        this.buildUIRightLike(),
                        this.buildUIRightComment(),
                        this.buildUIRightShare(),
                        //礼物占位
                        Container(
                          margin: EdgeInsets.only(
                              bottom: ScreenUtil().setWidth(30)),
                          width: ScreenUtil().setWidth(130),
                          height: ScreenUtil().setWidth(130),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container();
    });
  }

  ///生成UI_右侧_点赞
  Widget buildUIRightLike() {
    String tempLikeCnt = Tools.ToString(widget.trendsModel.likes, "W", true);
    String tempImgStr = widget.trendsModel.has_like
        ? "images/video/right_like_01.png"
        : "images/video/right_like_00.png";
    return GestureDetector(
      child: Container(
        key: this._likeKey,
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(25)),
        width: ScreenUtil().setWidth(170),
        height: ScreenUtil().setWidth(170),
        child: Column(
          children: <Widget>[
            Image.asset(
              tempImgStr,
              fit: BoxFit.fill,
              width: ScreenUtil().setWidth(110),
              height: ScreenUtil().setWidth(110),
            ),
            Container(
              height: ScreenUtil().setWidth(10),
            ),
            Text(
              tempLikeCnt,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(34), color: Colors.white),
            ),
          ],
        ),
      ),
      onTap: () {
        if (!widget.trendsModel.has_like) {
          RenderBox tempLikeRB =
              this._likeKey.currentContext.findRenderObject();
          Offset tempOffset =
              tempLikeRB.localToGlobal(Offset(ScreenUtil().setWidth(80), 0));
          this._likePage.doubleTapToLike(tempOffset);
        }
        this.btnEventRightLike();
      },
    );
  }

  ///生成UI_右侧_评论
  Widget buildUIRightComment() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
        width: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(100),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: this._showBarrage ? Color(0xffff3196) : Colors.grey,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        ),
        child: Text("弹",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(46), color: Colors.white)),
      ),
      onTap: () {
        this.btnEventRightComment();
      },
    );
  }

  ///生成UI_右侧_分享
  Widget buildUIRightShare() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30)),
        width: ScreenUtil().setWidth(150),
        height: ScreenUtil().setWidth(150),
        child: Column(
          children: <Widget>[
            Image.asset(
              "images/video/right_share.png",
              fit: BoxFit.fill,
              width: ScreenUtil().setWidth(100),
              height: ScreenUtil().setWidth(80),
            ),
            Container(
              height: ScreenUtil().setWidth(10),
            ),
          ],
        ),
      ),
      onTap: () {
        this.btnEventRightShare();
      },
    );
  }

  ///生成UI_右侧_礼物
  Widget buildUIRightGift() {
    //return Container();
    return Positioned(
      right: 0,
      bottom: 0,
      child: GestureDetector(
        child: Container(
          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30)),
          width: ScreenUtil().setWidth(1080),
          height: ScreenUtil().setWidth(1920),
          alignment: Alignment.bottomRight,
          child: DYTrendGift(),
        ),
        onTap: () {
          this.btnEventRightGift();
        },
      ),
    );
  }

  ///生成UI_底部 (合集 / 火热 / 空)
  Widget buildUIBtn() {
    if (widget.trendsModel.ranking != null) {
      return this.buildUIHotBtn(widget.trendsModel.ranking);
    } else if (widget.trendsModel.collection != null) {
      return this.buildUICompilationBtn(widget.trendsModel.collection);
    } else {
      return Container();
    }
  }

  ///生成UI_底部_火热
  Widget buildUIHotBtn(TrendRanking _hot) {
    TextStyle tempTextStyle =
        TextStyle(fontSize: ScreenUtil().setSp(36), color: Color(0xfffdd705));
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(1080),
        height: ScreenUtil().setWidth(70),
        color: Colors.black26,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        child: Row(
          children: <Widget>[
            Image.asset(
              "images/video/bottom_hot.png",
              width: ScreenUtil().setWidth(45),
              height: ScreenUtil().setWidth(67),
            ),
            Container(
              width: ScreenUtil().setWidth(25),
            ),
            Text("${_hot.title}", style: tempTextStyle),
            Expanded(
              child: Container(),
            ),
            Icon(Icons.keyboard_arrow_right,
                size: ScreenUtil().setSp(50), color: Color(0xfffdd705)),
          ],
        ),
      ),
      onTap: () {
        print(">>>  点击火热: id:${_hot.type}");
      },
    );
  }

  ///生成UI_底部_合集
  Widget buildUICompilationBtn(TrendCollection _compilation) {
    TextStyle tempTextStyle =
        TextStyle(fontSize: ScreenUtil().setSp(36), color: Colors.white);
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(1080),
        height: ScreenUtil().setWidth(70),
        color: Colors.black26,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        child: Row(
          children: <Widget>[
            Image.asset(
              "images/video/bottom_compilation.png",
              width: ScreenUtil().setWidth(58),
              height: ScreenUtil().setWidth(56),
            ),
            Container(
              width: ScreenUtil().setWidth(25),
            ),
            Text("${_compilation.title}", style: tempTextStyle),
            Expanded(
              child: Container(),
            ),
            Icon(Icons.keyboard_arrow_right,
                size: ScreenUtil().setSp(50), color: Colors.white),
          ],
        ),
      ),
      onTap: () {
        print(">>>  点击合集: id:${_compilation.id}");
      },
    );
  }

  ///生成UI_评论
  Widget buildUIComment() {
    return Container(
      width: ScreenUtil().setWidth(1080),
      height: ScreenUtil().setWidth(100),
      color: Colors.black87,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          this.buildUICommentInput(),
          //发送按钮
          InkWell(
            child: Icon(
              Icons.near_me,
              size: ScreenUtil().setWidth(80),
              color: Colors.white,
            ),
            onTap: () {
              this.btnEventComment();
            },
          ),
        ],
      ),
    );
  }

  ///生成底部_输入框
  Widget buildUICommentInput() {
    return Expanded(
      child: TextField(
        controller: _commentController,
        focusNode: _commentFocusNode,
        style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(48)),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 0),
          border: InputBorder.none,
          hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(48),
              color: Colors.grey,
              textBaseline: TextBaseline.alphabetic),
          hintText: "留下你的精彩评论吧",
        ),
        onChanged: (_str) {},
      ),
    );
  }

  ///生成阻断界面
  Widget buildPreventPage() {
    if (!this._showPrevent) {
      return Container();
    }
    if (this._playType == Enum_PlayType.normal) {
      return Container();
    }

    Widget tempChild;
    if (this._playType == Enum_PlayType.buy) {
      tempChild = this.buildPreventBuy();
    } else if (this._playType == Enum_PlayType.vip ||
        this._playType == Enum_PlayType.complete) {
      tempChild = this.buildPreventVip("完整版只针对VIP会员开放");
    } else if (this._playType == Enum_PlayType.nofree) {
      tempChild = this.buildPreventCount();
    }
    if (this._showPreventAtComment) {
      tempChild = this.buildPreventVip("开通会员，即可发送精彩弹幕！");
    }
    return InkWell(
      child: Container(
        color: Colors.black38,
        alignment: Alignment.center,
        child: ScaleTransition(
          alignment: Alignment.center,
          scale: this._animControllerPrevent,
          child: Container(
            width: ScreenUtil().setWidth(900),
            height: ScreenUtil().setWidth(600),
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
            decoration: BoxDecoration(
              color: AppColors.BgColor,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: tempChild,
          ),
        ),
      ),
      onTap: this.closePreventPage,
    );
  }

  ///生成阻断界面_Vip
  Widget buildPreventVip(String _title) {
    return Column(
      children: <Widget>[
        Container(height: ScreenUtil().setWidth(50)),
        //关闭
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              child: Icon(
                Icons.close,
                size: ScreenUtil().setWidth(80),
                color: Colors.white70,
              ),
              onTap: this.closePreventPage,
            ),
          ],
        ),
        Container(height: ScreenUtil().setWidth(50)),
        //文本
        Text(
          _title,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(50), color: Colors.white70),
        ),
        Container(height: ScreenUtil().setWidth(100)),
        //按钮
        InkWell(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              this.buildPreventBtnBg(
                  ScreenUtil().setWidth(500), ScreenUtil().setWidth(100)),
              Text(
                "充值VIP",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(50), color: Colors.white),
              ),
            ],
          ),
          onTap: this.btnEventPreventBuyVip,
        ),
      ],
    );
  }

  ///生成阻断界面_购买
  Widget buildPreventBuy() {
    String tempNick = Tools.cutString(widget.trendsModel.nickname, 10);
    return Column(
      children: <Widget>[
        Container(
          height: ScreenUtil().setWidth(50),
        ),
        //关闭
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(80),
            ),
            Text(
              "确认支付",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(56), color: Colors.white70),
            ),
            InkWell(
              child: Icon(
                Icons.close,
                size: ScreenUtil().setWidth(80),
                color: Colors.white70,
              ),
              onTap: this.closePreventPage,
            ),
          ],
        ),
        Container(
          height: ScreenUtil().setWidth(40),
        ),
        //文本
        Text(
          "该视频由【$tempNick】上传,并设置观看价格为",
          style: TextStyle(
              fontSize: ScreenUtil().setSp(46), color: Colors.white70),
        ),
        Container(
          height: ScreenUtil().setWidth(20),
        ),
        //价格
        Text(
          "10钻石",
          style: TextStyle(
              fontSize: ScreenUtil().setSp(60),
              color: Color(0xfffff3196),
              height: 1),
        ),
        Container(height: ScreenUtil().setWidth(40)),
        //按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkWell(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  this.buildPreventBtnBg(
                      ScreenUtil().setWidth(350), ScreenUtil().setWidth(100)),
                  Text(
                    "上传视频",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(46), color: Colors.white),
                  ),
                ],
              ),
              onTap: this.btnEventPreventUpload,
            ),
            InkWell(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  this.buildPreventBtnBg(
                      ScreenUtil().setWidth(350), ScreenUtil().setWidth(100)),
                  Text(
                    "确认支付",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(46), color: Colors.white),
                  ),
                ],
              ),
              onTap: this.btnEventPreventBuyVideo,
            ),
          ],
        ),
      ],
    );
  }

  ///生成阻断界面_次数
  Widget buildPreventCount() {
    bool tempBind = this._userModel.mobile != "";
    Widget tempBtn = tempBind
        ? InkWell(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                this.buildPreventBtnBg(
                    ScreenUtil().setWidth(350), ScreenUtil().setWidth(100)),
                Text(
                  "充值会员",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(46), color: Colors.white),
                ),
              ],
            ),
          )
        : InkWell(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                this.buildPreventBtnBg(
                    ScreenUtil().setWidth(350), ScreenUtil().setWidth(100)),
                Text(
                  "绑定手机",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(46), color: Colors.white),
                ),
              ],
            ),
            onTap: this.btnEventPreventBindPhone,
          );

    return Column(
      children: <Widget>[
        Container(height: ScreenUtil().setWidth(100)),
        Container(height: ScreenUtil().setWidth(60)),
        //按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkWell(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  this.buildPreventBtnBg(
                      ScreenUtil().setWidth(350), ScreenUtil().setWidth(100)),
                  Text(
                    "分享视频",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(46), color: Colors.white),
                  ),
                ],
              ),
              onTap: () {
                this.btnEventRightShare();
              },
            ),
            tempBtn,
          ],
        ),
      ],
    );
  }

  ///生成阻断界面_按钮背景
  Widget buildPreventBtnBg(double _width, double _height) {
    Gradient _gradient =
        LinearGradient(colors: [Color(0xfffff3196), Color(0xffff9d9c)]);
    return ShaderMask(
      shaderCallback: (bounds) {
        return _gradient.createShader(Offset.zero & bounds.size);
      },
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(100)),
        ),
      ),
    );
  }

  ///生成进度条
  Widget buildProgress() {
    //整体的底部进度条占用高度
    return Positioned(
      bottom: 0,
      child: Container(
        width: ScreenUtil().setWidth(1080),
        height: ScreenUtil().setHeight(1920),
        child: Stack(
          children: <Widget>[
            //底部进度条,盖上黑色.
            Positioned(
              bottom: 0,
              child: Container(
                width: ScreenUtil().setWidth(1080),
                height: ScreenUtil().setWidth(78),
                color: Colors.black,
              ),
            ),
            //真实进度条
            Positioned(
              bottom: ScreenUtil().setWidth(50),
              child: this.buildProgressSlider(),
            ),
            //时间
            this._isShowTime
                ? Positioned(
                    bottom: ScreenUtil().setWidth(250),
                    child: this.buildProgressText(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  ///生成进度条_滑块
  Widget buildProgressSlider() {
    return this._userModel.vipExpires == null
        ? Container(
            width: ScreenUtil().setWidth(1080),
            height: ScreenUtil().setWidth(50),
          )
        : Container(
            width: ScreenUtil().setWidth(1080),
            height: ScreenUtil().setWidth(50),
            // color: Colors.green[200],
            alignment: Alignment.topCenter,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white, //进度条滑块左边颜色
                inactiveTrackColor: Colors.white54, //进度条滑块右边颜色
                thumbColor: Colors.white, //滑块颜色
                overlayColor: Colors.white, //滑块拖拽时外圈的颜色
                overlayShape: RoundSliderOverlayShape(
                  //可继承SliderComponentShape自定义形状
                  overlayRadius: ScreenUtil().setWidth(10), //滑块外圈大小
                ),
                thumbShape: RoundSliderThumbShape(
                  //可继承SliderComponentShape自定义形状
                  disabledThumbRadius: ScreenUtil().setWidth(10), //禁用是滑块大小
                  enabledThumbRadius: ScreenUtil()
                      .setWidth(this._isExpandSlider ? 10 : 0), //滑块大小
                ),
                inactiveTickMarkColor: Colors.black,
              ),
              child: Slider(
                min: 0,
                max: 1,
                value: _sliderValue,
                onChanged: (_v) {
                  if (this.mounted) {
                    setState(() {
                      print("setState" + StackTrace.current.toString());
                      _sliderValue = _v;
                      this._curSeconds =
                          (this._totalSeconds * _sliderValue).toInt();
                      if (this._curSeconds > this._maxPlaySeconds) {
                        this._curSeconds = this._maxPlaySeconds;
                      } else {
                        //跳转视频进度.
                        _controller.seekTo(Duration(seconds: this._curSeconds));
                        this.playOrPauseVideo(true);
                      }
                    });
                  }
                },
                onChangeStart: (_v) {
                  if (this.mounted) {
                    setState(() {
                      print("setState" + StackTrace.current.toString());
                      this._isShowTime = true;
                      this._isExpandSlider = true;
                      _controller.pause();
                    });
                  }
                },
                onChangeEnd: (_v) {
                  if (this.mounted) {
                    setState(() {
                      print("setState" + StackTrace.current.toString());
                      this._isShowTime = false;
                      this._curSeconds =
                          (this._totalSeconds * _sliderValue).toInt();
                      if (this._curSeconds > this._maxPlaySeconds) {
                        this._curSeconds = this._maxPlaySeconds;
                      } else {
                        //跳转视频进度
                        _controller.seekTo(Duration(seconds: this._curSeconds));
                        _controller.play();
                      }
                    });
                  }
                  Future.delayed(Duration(seconds: 2), () {
                    if (this.mounted) {
                      setState(() {
                        print("setState" + StackTrace.current.toString());
                        this._isExpandSlider = false;
                      });
                    }
                  });
                },
              ),
            ),
          );
  }

  ///生成进度条_文本
  Widget buildProgressText() {
    int tempCurSeconds = (this._totalSeconds * this._sliderValue).toInt();
    return Container(
      width: ScreenUtil().setWidth(1080),
      height: ScreenUtil().setWidth(100),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            this.changeDurationToStr(tempCurSeconds),
            style: TextStyle(
                fontSize: ScreenUtil().setSp(70), color: Colors.white),
          ),
          Text(
            " / ",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(40), color: Colors.white),
          ),
          Text(
            this.changeDurationToStr(this._totalSeconds),
            style: TextStyle(
                fontSize: ScreenUtil().setSp(70), color: Colors.white54),
          ),
        ],
      ),
    );
  }

  ///生成动态弹幕界面
  Widget buildTrendBarragePage() {
    if (this._trendBarragePage == null) {
      this._trendBarragePage = TrendBarragePage(
        trendsId: widget.trendsModel.id,
        showBarrage: this._showBarrage,
        gotoAuthorInfoPage: widget.gotoAuthorInfoPage,
      );
    } else {
      if (DyStyleVariable.showBarrage != this._showBarrage) {
        this._showBarrage = DyStyleVariable.showBarrage;
        if (this._showBarrage) {
          this._trendBarragePage.setShowState(true);
          this._trendBarragePage.playAnim();
        } else {
          this._trendBarragePage.stopAnim();
          this._trendBarragePage.setShowState(false);
        }
      }
    }
    return this._trendBarragePage;
  }

  ///生成动态礼物界面
  Widget buildTrendGiftPage() {
    if (this._trendGiftPage == null) {
      this._trendGiftPage = TrendGiftPage(
        trendsId: widget.trendsModel.id,
      );
    }
    return this._trendGiftPage;
  }

  ///生成分享界面
  Widget buildSharePage() {
    if (this._sharePage == null) {
      this._sharePage = SharePage(
        avatarUrl: widget.trendsModel.avatarUrl,
        level: widget.trendsModel.vipLevel,
        thumbImg: widget.trendsModel.thumbImg,
        affTitle: this._mainModel.configModel.affTitle,
        affCode: this._userModel.inviteCode,
        affUrl: this._mainModel.configModel.inviteUrl,
        extendValue: "&v=${widget.trendsModel.id}",
      );
    }
    return this._sharePage;
  }

  ///生成点赞界面
  Widget buildLikePage() {
    if (this._likePage == null) {
      this._likePage = DYTrendLikePage();
    }
    return this._likePage;
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_左侧_前往个人中心
  void btnEventLeftGotoUserCenter() {
    //暂停视频
    this.playOrPauseVideo(false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ScopedModel<MainModel>(
          model: this._mainModel,
          child: MinePage(
            popPageCallBack: () {
              this.playOrPauseVideo(true);
            },
          ),
        );
      }),
    );
  }

  ///按钮事件_左侧_标签Item
  void btnEventLeftMarkItem(String _mark) async {
    //暂停视频
    this.playOrPauseVideo(false);

    //跳转'标签界面'
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ScopedModel<MainModel>(
          model: this._mainModel,
          child: MarkPage(mark: _mark),
        );
      }),
    );
  }

  ///按钮事件_左侧_用户信息
  void btnEventLeftUserInfo() {
    if (widget.gotoAuthorInfoPage != null) {
      widget.gotoAuthorInfoPage(widget.trendsModel.uuid);
    }
  }

  ///按钮事件_左侧_关注
  void btnEventLeftFollow(bool _state) async {
    if (_state) {
      this._animcontrolFollowBtn.forward();
      Future.delayed(Duration(milliseconds: 800), () {
        setState(() {
          print("setState" + StackTrace.current.toString());
          this._showFollowBtn = false;
        });
      });
    } else {
      this._animcontrolFollowBtn.reset();
    }

    ResultData _result = await HttpManager.requestPost(context, "followings",
        {"target_id": widget.trendsModel.uuid, "type": _state ? "1" : "2"});
    if (_result.result) {
      DYEventBus.eventBus.fire(VideoViewToVideoList(widget.myVideoListKey,
          "Follow", {"uuid": widget.trendsModel.uuid, "state": _state}));
    } else {
      widget.trendsModel.hasFollow = !_state;
      setState(() {
        print("setState" + StackTrace.current.toString());
      });
    }
  }

  ///按钮事件_左侧_广告
  void btnEventLeftAd() {
    VideoAdsConfig tempAd = widget.trendsModel.ads;
    if (tempAd != null) {
      DYEventBus.eventBus.fire(GotoAd(tempAd.action_type, tempAd.action_url));
    }
  }

  ///按钮事件_右侧_点赞
  void btnEventRightLike() async {
    widget.trendsModel.has_like = !widget.trendsModel.has_like;
    widget.trendsModel.likes += widget.trendsModel.has_like ? 1 : -1;
    setState(() {
      print("setState" + StackTrace.current.toString());
    });

    ResultData _result = await HttpManager.requestPost(context, "/setLike", {
      "id": widget.trendsModel.id,
      "type": widget.trendsModel.has_like ? "1" : "2"
    });
    if (!_result.result) {
      widget.trendsModel.has_like = !widget.trendsModel.has_like;
      widget.trendsModel.likes += widget.trendsModel.has_like ? -1 : 1;
      setState(() {
        print("setState" + StackTrace.current.toString());
      });
    }
  }

  ///按钮事件_右侧_评论
  void btnEventRightComment() {
    setState(() {
      print("setState" + StackTrace.current.toString());
      DyStyleVariable.showBarrage = !this._showBarrage;
    });
  }

  ///按钮事件_右侧_分享
  void btnEventRightShare() {
    this.playOrPauseVideo(false);
    this._sharePage.playPageAnim(true);
    //添加返回按钮事件
    DYPhysicalBtnEvtControll.AddPhysicalBtnEvent(() {
      this._sharePage.playPageAnim(false);
      this.playOrPauseVideo(true);
    });
  }

  ///按钮事件_右侧_礼物
  void btnEventRightGift() {
    this._trendGiftPage.playPageAnim(true);
  }

  ///按钮事件_评论
  void btnEventComment() async {}

  ///按钮事件_阻断_绑定手机
  void btnEventPreventBindPhone() {}

  //========== [ 辅助函数 ] ==========
  ///获取单条动态数据
  void getSingleTrendModel(int _id) async {
    ResultData _result =
        await HttpManager.requestPost(context, "/single", {"id": _id});
    if (_result.result) {
      if (this.mounted) {
        setState(() {
          print("setState" + StackTrace.current.toString());
          this._haveData = true;
          widget.trendsModel.fromMap(_result.data);
          //检测是否能播放
          this.checkCanPlay();
        });
      }
    }
  }

  ///开始广告计时器
  void startAdTimer() {
    if (widget.trendsModel.ads != null && !this._isPlayAds) {
      //如果是广告,禁止滑动,直到广告结束.
      if (widget.setDragStateEvent != null) {
        widget.setDragStateEvent(false);
      }
      this._adTimer =
          Timer(Duration(seconds: widget.trendsModel.ads.duration), () {
        this.endAdTimer();
        if (widget.setDragStateEvent != null) {
          widget.setDragStateEvent(true);
        }
      });
      this._isPlayAds = true;
    }
  }

  ///关闭广告计时器
  void endAdTimer() {
    _adTimer?.cancel();
    _adTimer = null;
  }

  ///转换时间为文本格式
  String changeDurationToStr(int _second) {
    String tempStr = "";
    int allSeconds = _second;
    int tempH = allSeconds ~/ 3600;
    allSeconds -= tempH * 3600;
    int tempM = allSeconds ~/ 60;
    allSeconds -= tempM * 60;
    int tempS = allSeconds;
    tempStr =
        "${this.getStandardTimeStr(tempM)}:${this.getStandardTimeStr(tempS)}";
    return tempStr;
  }

  ///获取标准时间字符串
  String getStandardTimeStr(int _int) {
    String tempStr = "000$_int";
    return tempStr.substring(tempStr.length - 2);
  }

  ///适配视频尺寸
  void adaptationVideoSize(Size _videoSize) {
    double tempRatioStandard = this._viewWidth / this._viewHeight;
    double tempRatioVideo = _videoSize.width / _videoSize.height;
    if (tempRatioVideo > tempRatioStandard && tempRatioVideo <= 0.6) {
      //按高适配
      this._videoSize = Size(
          this._viewHeight / _videoSize.height * _videoSize.width,
          this._viewHeight);
      this._blankHeight = 10;
    } else {
      //按宽适配
      this._videoSize = Size(this._viewWidth,
          this._viewWidth / _videoSize.width * _videoSize.height);
      this._blankHeight = (this._viewHeight - this._videoSize.height) / 2;
      this._blankHeight = this._blankHeight < 0 ? 0 : this._blankHeight;
    }
  }

  ///播放/暂停视频
  void playOrPauseVideo(bool _isPlay) {
    //根据目标状态，设置视频播放器。
    this._isPlayVideo = _isPlay;
    if (this._isPlayVideo) {
      if (_controller != null) {
        DyStyleVariable.keyCurVideoList = widget.myVideoListKey;
        DyStyleVariable.keyCurVideoView = widget.key;
        _controller.play();
        //开启广告计时器
        this.startAdTimer();
        //开始功能按钮计时器
        this.startFuncTimer();
      }
    } else {
      if (_controller != null) {
        _controller.pause();
      }
    }
    //播放按钮动画
    if (!this._isPlayVideo) {
      this._animcontrolPlayIcon.forward();
    } else {
      this._animcontrolPlayIcon.reset();
    }
  }

  ///释放播放器
  void releaseVideo() {
    _controller?.dispose();
    _controller = null;
  }

  ///开始功能计时器
  void startFuncTimer() {
    if (_funcBtnTimer != null) {
      return;
    }
    _funcBtnTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      this._animcontrolFuncBtn.forward();
      this._showFuncUI = false;
      //this._trendBarragePage.fadeIn();
      this.endFuncTimer();
    });
  }

  ///关闭功能计时器
  void endFuncTimer() {
    _funcBtnTimer?.cancel();
    _funcBtnTimer = null;
  }

  ///设置评论焦点
  void setCommentFocus(bool _isFocus) {
    if (_isFocus) {
      FocusScope.of(context).requestFocus(this._commentFocusNode);
    } else {
      this._commentFocusNode.unfocus();
    }
  }

  ///检测是否能播放
  void checkCanPlay() async {
    if (this._isImage) {
      return;
    }
    print(">>>>>  初始化视频组件: ${widget.trendsModel.id}");

    print(">>>>   需要检测免费视频:${widget.needCheckFree} 播放类型:$_playType");
    if (Config.playVideo) {
      DyStyleVariable.keyCurVideoList = null;
      DyStyleVariable.keyCurVideoPage = null;
      DyStyleVariable.keyCurVideoView = null;
      this.initVideoWidget();
    }
  }

  //初始化视频组件
  void initVideoWidget() {
    if (widget.trendsModel.play == null ||
        widget.trendsModel.play.length == 0) {
      return;
    }
    //因为列表类型打开,会出现两次初始化,所以每次初始化的时候,释放掉之前的引用.
    //_controller?.dispose();
    //_controller = null;
    //重新开始初始化.
    _controllerLoad.then((_) {
      if (!this.mounted) {
        _controller?.dispose();
        _controller = null;
        return;
      }
      if (_controller == null) {
        return;
      }
      this._isInitVideo = true;
      //判断是否需要自动播放
      if (DyStyleVariable.keyCurVideoList == null &&
          DyStyleVariable.keyCurVideoPage == null &&
          DyStyleVariable.keyCurVideoView == null) {
        this.playOrPauseVideo(true);
      } else if (DyStyleVariable.keyCurVideoList == widget.myVideoListKey &&
          DyStyleVariable.keyCurVideoPage == widget.myVideoPageKey &&
          DyStyleVariable.keyCurVideoView == widget.key) {
        this.playOrPauseVideo(true);
      }
      //设置总秒数
      this._totalSeconds = _controller.value.duration.inSeconds;
      this._curSeconds = 0;
      if (this._maxPlaySeconds == 0) {
        this._maxPlaySeconds = this._totalSeconds;
      }
      if (_setBuildVideoViewState != null) _setBuildVideoViewState(() {});
    });
    //循环播放
    _controller.setLooping(true);
    //监听播放进度
    int fps = 0;
    _controller.addListener(() async {
      fps++;
      if (fps == 100) fps = 0;
      if (fps % 3 != 0) {
        return;
      }
      if (!this.mounted) {
        _controller?.dispose();
        _controller = null;
        return;
      }
      if (_controller == null) {
        return;
      }

      Duration res = await _controller.position;
      if (this.mounted) {
        if (_setVideoState != null)
          _setVideoState(() {
            print("_setVideoState");
            this._curSeconds = res.inSeconds;

            if (this._isShowTime) {
              return;
            }
            if (this._totalSeconds == 0) {
              this._sliderValue = 0;
            } else {
              this._sliderValue = this._curSeconds / this._totalSeconds;
            }
          });
      }
    });
  }

  ///绑定成功回调
  void bindSucCallBack() {
    Toast.toast(context, msg: "绑定成功", position: ToastPostion.center);
  }
}
