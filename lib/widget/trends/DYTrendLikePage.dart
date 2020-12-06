import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///点赞界面
class DYTrendLikePage extends StatefulWidget {
  //
  final DYTrendLikePageState myState = DYTrendLikePageState();

  @override
  State<StatefulWidget> createState() {
    //this.myState = DYTrendLikePageState();
    return this.myState;
  }

  ///双击点赞
  void doubleTapToLike(Offset _offset) {
    if (this.myState != null) {
      this.myState.doubleTapToLike(_offset);
    }
  }
}

class DYTrendLikePageState extends State<DYTrendLikePage> {
  ///位置列表
  List<Offset> _posList = [];

  ///点赞映射表
  Map<int, LikeMap> _likeMap = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(1080),
      height: ScreenUtil().setHeight(1920),
      child: Stack(
        children: this.getVideoLikeList(),
      ),
    );
  }

  getVideoLikeList() {
    Size tempSize =
        Size(ScreenUtil().setWidth(300), ScreenUtil().setWidth(500));
    for (int i = 0; i < this._posList.length; i++) {
      if (this._likeMap[i] == null) {
        //如果映射表为空,创建一个新的点赞
        GlobalKey tempKey = GlobalKey();
        Offset tempOffset = this._posList[i];
        Positioned tempWidget = Positioned(
          left: tempOffset.dx - tempSize.width / 2,
          top: tempOffset.dy - tempSize.height,
          child: DYTrendLike(
              key: tempKey,
              value: i,
              widgetSize: tempSize,
              removeFunc: this.removeLikeFunc),
        );
        this._likeMap[i] = LikeMap(tempKey, tempOffset, tempWidget);
      }
    }

    List<Widget> tempList = [];
    for (int i = 0; i < this._likeMap.length; i++) {
      if (this._likeMap[i].likeWidget != null) {
        tempList.add(this._likeMap[i].likeWidget);
      }
    }
    return tempList;
  }

  ///双击点赞
  void doubleTapToLike(Offset _offset) {
    setState(() {
      this._posList.add(_offset);
    });
  }

  ///移除点赞事件
  void removeLikeFunc(GlobalKey _key) {
    for (int i = 0; i < this._likeMap.length; i++) {
      if (_key == this._likeMap[i].likeKey) {
        this._likeMap[i].likeWidget = null;
        break;
      }
    }
    setState(() {});
  }
}

///视频点赞
class DYTrendLike extends StatefulWidget {
  final int value;
  //组件尺寸
  final Size widgetSize;
  //移除事件
  final Function(GlobalKey) removeFunc;

  //构造函数
  DYTrendLike({Key key, this.value, this.widgetSize, this.removeFunc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DYVideoLikeState();
  }
}

class DYVideoLikeState extends State<DYTrendLike>
    with TickerProviderStateMixin {
  ///删除计时器
  Timer _deleteTimer;

  ///动画_显示
  Animation<double> _animationShow;

  ///动画控制器_显示
  AnimationController _animControllerShow;

  ///动画值_显示
  double _animValueShow = 0;

  ///动画_隐藏
  Animation<double> _animationHide;

  ///动画控制器_隐藏
  AnimationController _animControllerHide;

  ///动画值_隐藏
  double _animValueHide = 0;

  //播放隐藏动画
  bool _playHideAnim = false;

  //最大角度(控制值)
  int _maxAngle = 45;
  //随机角度
  double _randomAngle = 0;

  @override
  void initState() {
    super.initState();

    _randomAngle =
        (Random().nextInt(_maxAngle * 2) - _maxAngle) / 360 * 3.1415926;
    //初始化动画控制器
    _animControllerShow = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animationShow =
        Tween<double>(begin: 1, end: 0).animate(_animControllerShow);
    _animationShow.addListener(() {
      if (_animControllerShow.isCompleted) {
        //延迟
        Future.delayed(Duration(milliseconds: 200), () {
          setState(() {
            this._playHideAnim = true;
          });
          _animControllerHide.forward();
        });
      }
      setState(() {
        this._animValueShow = this._animationShow.value;
      });
    });

    _animControllerHide = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animationHide =
        Tween<double>(begin: 0, end: 1).animate(_animControllerHide);
    _animationHide.addListener(() {
      setState(() {
        this._animValueHide = this._animationHide.value;
      });
    });

    //开始播放动画
    _animControllerShow.forward();

    this.startDeleteTimer();
  }

  @override
  void dispose() {
    super.dispose();

    this.endDeleteTimer();
  }

  @override
  Widget build(BuildContext context) {
    double tempWidget = !this._playHideAnim
        ? widget.widgetSize.width * (1 + this._animValueShow) / 2
        : widget.widgetSize.width * (1 + this._animValueHide) / 2;
    double tempPadding = !this._playHideAnim ? 0 : this._animValueHide * 100;
    double tempOpacity = !this._playHideAnim ? 1 : 1 - this._animValueHide;
    return Opacity(
      opacity: tempOpacity,
      child: Container(
        width: widget.widgetSize.width,
        height: widget.widgetSize.height,
        padding: EdgeInsets.only(bottom: tempPadding),
        alignment: Alignment.bottomCenter,
        child: Transform(
          transform: Matrix4.identity()..rotateZ(_randomAngle),
          origin: Offset(0, 0),
          child:
              Image.asset("images/video/right_like_01.png", width: tempWidget),
        ),
      ),
    );
  }

  ///开始功能计时器
  void startDeleteTimer() {
    if (_deleteTimer != null) {
      return;
    }
    _deleteTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      this.endDeleteTimer();
      if (widget.removeFunc != null) {
        widget.removeFunc(widget.key);
      }
    });
  }

  ///关闭功能计时器
  void endDeleteTimer() {
    _deleteTimer?.cancel();
    _deleteTimer = null;
  }
}

class LikeMap {
  GlobalKey likeKey;
  Offset likeOffset;
  Widget likeWidget;
  //构造函数
  LikeMap(GlobalKey _key, Offset _offset, Widget _widget) {
    this.likeKey = _key;
    this.likeOffset = _offset;
    this.likeWidget = _widget;
  }
}
