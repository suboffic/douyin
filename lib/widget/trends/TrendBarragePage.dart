import 'dart:async';
import 'dart:math';

import 'package:douyin/model/CommentModel.dart';
import 'package:douyin/model/DYModelUnit.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/HeadWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///动态弹幕界面
class TrendBarragePage extends StatefulWidget {
  //
  final TrendBarragePageState myState = new TrendBarragePageState();

  ///动态id
  final int trendsId;

  ///显示弹幕
  final bool showBarrage;

  ///前往作者信息界面
  final Function(String _uuid) gotoAuthorInfoPage;

  //构造函数
  TrendBarragePage(
      {Key key, this.trendsId, this.showBarrage, this.gotoAuthorInfoPage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return this.myState;
  }

  ///添加评论
  void addComment(CommentModel _model) {
    if (this.myState != null) {
      this.myState.addComment(_model);
    }
  }

  ///播放动画(从上次位置继续)
  void playAnim() {
    if (this.myState != null) {
      this.myState.playAnim();
    }
  }

  ///暂停动画
  void stopAnim() {
    if (this.myState != null) {
      this.myState.stopAnim();
    }
  }

  ///设置显示状态
  void setShowState(bool _state) {
    if (this.myState != null) {
      this.myState.setShowState(_state);
    }
  }

  ///渐显
  void fadeIn() {
    if (this.myState != null) {
      this.myState.fadeIn();
    }
  }

  ///渐隐
  void fadeOut() {
    if (this.myState != null) {
      this.myState.fadeOut();
    }
  }
}

class TrendBarragePageState extends State<TrendBarragePage> {
  ///显示弹幕
  bool _showBarrage = false;

  ///是否渐显
  bool _isFadeIn = false;

  ///界面透明度
  double _pageOpacity = 0;

  ///渐隐的透明度值
  double _fadeoutOpacity = 0.2;

  ///是否激活状态
  bool _isActive = false;

  ///弹幕计时器(单位s)
  Timer _barrageTimer;

  ///显示弹幕时间(x秒后自动关闭)
  int _showBarrageTime = 3;

  ///评论数据列表
  List<CommentModel> _commentDataList = [];

  ///当前页码
  int _curPage = 0;

  ///播放列表
  List<BarrageMap> _playList = [];

  ///能否继续获取评论
  bool _isCanGetComment = true;

  ///空行数列表
  List<int> _emptyLineList = [0, 1, 2, 3];

  ///是否自动播放
  bool _isAutoPlay = true;

  ///选中的key
  GlobalKey _chooseKey;

  ///选中的评论数据
  CommentModel _chooseCommentModel;

  ///选中的行下标
  int _chooseLineIndex = 0;

  @override
  void initState() {
    this._showBarrage = widget.showBarrage;
    //如果打开弹幕功能,首次获取评论数据.
    if (this._showBarrage) {
      this.getCommentData(1);
    }
    this._isActive = true;

    super.initState();
  }

  @override
  void dispose() {
    this._isActive = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: this._pageOpacity,
      child: Container(
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(180)),
        child: Container(
          width: ScreenUtil().setWidth(1080),
          height: ScreenUtil().setWidth(500),
          child: Stack(
            children: this.getTrendBarrageList(),
          ),
        ),
      ),
    );
  }

  ///获取弹幕列表
  getTrendBarrageList() {
    List<Widget> tempWidgetList = [];
    this._playList.forEach((_m) {
      if (_m.bWidget == null) {
        GlobalKey tempKey = GlobalKey();
        TrendBarrage tempWidget = TrendBarrage(
          key: tempKey,
          lineIndex: _m.bLineIndex,
          playComplete: this.barragePlayComplete,
          playOverEvent: this.barragePlayOverEvent,
          headClickEvent: this.headClickEvent,
          barrageClickEvent: this.barrageClickEvent,
          isAutoPlay: this._isAutoPlay,
          commentModel: _m.bModel,
        );
        _m.bKey = tempKey;
        _m.bWidget = tempWidget;
        tempWidgetList.add(tempWidget);
      } else {
        tempWidgetList.add(_m.bWidget);
      }
    });
    tempWidgetList.add(this.buildComment());
    return tempWidgetList;
  }

  ///生成评论
  Widget buildComment() {
    if (this._chooseCommentModel != null) {
      String tempContent =
          Tools.cutString(this._chooseCommentModel.content, 12);
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          InkWell(
            child: Container(
                // color: Colors.black12,
                ),
            onTap: this.closeChooseComment,
          ),
          Positioned(
            top: ScreenUtil().setWidth(this._chooseLineIndex * 100 + 20),
            child: Container(
              height: ScreenUtil().setWidth(100),
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30), vertical: 0),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(50)),
              ),
              child: Row(
                children: <Widget>[
                  //头像
                  InkWell(
                    child: HeadWidget(
                      headSize: Size(
                        ScreenUtil().setWidth(80),
                        ScreenUtil().setWidth(80),
                      ),
                      avatarUrl: this._chooseCommentModel.avatarUrl,
                      level: 0,
                    ),
                    onTap: () {
                      this.headClickEvent(
                          this._chooseCommentModel.uuid, this._chooseLineIndex);
                    },
                  ),
                  //内容
                  Container(
                    height: ScreenUtil().setWidth(80),
                    margin: EdgeInsets.only(
                      left: ScreenUtil().setWidth(10),
                    ),
                    child: Text(
                      tempContent,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(50),
                          color: Colors.white),
                    ),
                  ),
                  this.buildCommentLike(),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  ///生成评论_点赞
  Widget buildCommentLike() {
    String tempStrLike =
        Tools.ToString(this._chooseCommentModel.likes, "W", false);
    String tempStrBtn = this._chooseCommentModel.is_like
        ? "已赞 $tempStrLike"
        : "点赞 $tempStrLike";
    return InkWell(
      child: Container(
        height: ScreenUtil().setWidth(80),
        margin: EdgeInsets.only(
          left: ScreenUtil().setWidth(10),
        ),
        padding: EdgeInsets.all(
          ScreenUtil().setWidth(10),
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: this._chooseCommentModel.is_like
              ? Color(0xffff3196)
              : Colors.grey,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        ),
        child: Text(
          tempStrBtn,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(40),
              color: this._chooseCommentModel.is_like
                  ? Colors.white
                  : Colors.white),
        ),
      ),
      onTap: () {
        this.btnEventLike(
            this._chooseCommentModel.id, !this._chooseCommentModel.is_like);
      },
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_点赞
  void btnEventLike(int _cid, bool _like) async {
    this.refreshData(_like);

    ResultData _result = await HttpManager.requestPost(
        context,
        "/setCommentLike",
        {"id": _cid, "tid": widget.trendsId, "type": _like ? "1" : "2"});
    if (_result.result) {
      //延迟
      Future.delayed(Duration(milliseconds: 400), () {
        this.closeChooseComment();
      });
    } else {
      this.refreshData(!_like);
    }
  }

  ///刷新数据
  void refreshData(bool _like) {
    int tempLikeCnt = _chooseCommentModel.likes + (_like ? 1 : -1);
    this._commentDataList.forEach((_c) {
      if (_c.id == this._chooseCommentModel.id) {
        _c.is_like = _like;
        _c.likes = tempLikeCnt;
      }
    });
    this._playList.forEach((_m) {
      if (_m.bKey == this._chooseKey) {
        _m.bModel.is_like = _like;
        _m.bModel.likes = tempLikeCnt;
      }
    });
    this._chooseCommentModel.is_like = _like;
    this._chooseCommentModel.likes = tempLikeCnt;
    setState(() {});
  }

  //========== [ 辅助函数 ] ==========
  ///获取评论数据
  void getCommentData(int _page) async {
    ResultData _result = await HttpManager.requestPost(context, "/get_comments",
        {"id": widget.trendsId, "target_comment_id": 0, "page": _page});
    if (!mounted) return;
    if (_result.result) {
      this._isCanGetComment = _result.data["page"] != 0;
      //如果页码相同,丢弃
      if (_result.data["page"] != 0 && this._curPage == _result.data["page"]) {
        return;
      }
      List<int> tempLikeList = _result.data["like_ids"] == null
          ? []
          : DYModelUnit.convertList<int>(_result.data["like_ids"]);
      //添加数据,并且触发渲染.
      List<CommentModel> tempCommentDataList = [];
      if (_result.data["data"] != null) {
        _result.data["data"].forEach((_data) {
          CommentModel tempCommentData = CommentModel();
          tempCommentData.fromMap(_data);
          tempCommentData.is_like =
              this.checkIsLike(tempCommentData.id, tempLikeList);
          tempCommentDataList.add(tempCommentData);
        });
      }
      setState(() {
        this._curPage = _result.data["page"];
        if (_curPage == 1) {
          this._commentDataList = tempCommentDataList;
        } else {
          this._commentDataList.addAll(tempCommentDataList);
        }
      });
      if (_page == 1) {
        this.firstPlayBarrage();
      }
    }
  }

  ///检测是否喜欢(点赞)
  bool checkIsLike(int _id, List<int> _likeList) {
    bool tempLike = false;
    for (int i = 0; i < _likeList.length; i++) {
      if (_likeList[i] == _id) {
        tempLike = true;
        break;
      }
    }
    return tempLike;
  }

  ///首次播放弹幕
  firstPlayBarrage() {
    int tempDelay = 0;
    List<int> tempLineList = [0, 1, 2, 3];
    for (int i = 0; i < tempLineList.length; i++) {
      int tempTime = this.getRandomTime(2);
      tempDelay += tempTime;
      //延迟
      Future.delayed(Duration(milliseconds: tempDelay), () {
        if (!this._isActive) {
          return;
        }
        CommentModel tempComment = this.getSingleComment();
        if (tempComment == null) {
          return;
        }
        //
        this._emptyLineList.remove(i);
        setState(() {
          this._playList.add(BarrageMap(null, i, tempComment, null));
        });
      });
    }
  }

  ///开始弹幕计时器
  startBarrageTimer() {
    this._barrageTimer = Timer(Duration(seconds: this._showBarrageTime), () {
      this.closeChooseComment();
    });
  }

  ///结束弹幕计时器
  endBarrageTimer() {
    this._barrageTimer?.cancel();
    this._barrageTimer = null;
  }

  ///获取随机时间(毫秒单位,取值范围:1 -> n+1秒)
  ///空屏的时候取值稍微小些,播放完的时候取值稍微大些.
  int getRandomTime(int _second) {
    return Random().nextInt(_second * 1000) + 1000;
  }

  ///获取单条评论(可能为空)
  getSingleComment() {
    CommentModel tempComment;
    if (this._commentDataList.length > 0) {
      tempComment = this._commentDataList.removeAt(0);
    }
    //判断取完条数
    if (this._commentDataList.length <= 2 && this._isCanGetComment) {
      this.getCommentData(this._curPage + 1);
    }
    return tempComment;
  }

  ///弹幕播放完成
  void barragePlayComplete(GlobalKey _key, int _lineIndex) {
    CommentModel tempComment = this.getSingleComment();
    if (tempComment == null) {
      this._emptyLineList.add(_lineIndex);
      return;
    }
    //增加数据(需要延迟)
    Future.delayed(Duration(milliseconds: this.getRandomTime(2)), () {
      if (!this._isActive) {
        return;
      }
      //
      setState(() {
        this._playList.add(BarrageMap(null, _lineIndex, tempComment, null));
      });
    });
  }

  ///弹幕播放结束事件
  void barragePlayOverEvent(GlobalKey _key, int _lineIndex) {
    //移除数据
    int tempIndex = -1;
    for (int i = 0; i < this._playList.length; i++) {
      if (this._playList[i].bKey == _key) {
        tempIndex = i;
      }
    }
    //如果出现-1,证明找不到这一条,避免错上加错.
    if (tempIndex == -1) {
      return;
    }
    this._playList.removeAt(tempIndex);
  }

  ///头像点击事件
  void headClickEvent(String _uuid, int _lineIndex) {
    this.closeChooseComment();
    //前往作者信息
    if (widget.gotoAuthorInfoPage != null) {
      widget.gotoAuthorInfoPage(_uuid);
    }
  }

  ///弹幕点击事件
  void barrageClickEvent(GlobalKey _key, CommentModel _model, int _lineIndex) {
    setState(() {
      this._chooseCommentModel = _model;
      this._chooseLineIndex = _lineIndex;
    });
    this.startBarrageTimer();
  }

  ///关闭选中评论
  void closeChooseComment() {
    this.endBarrageTimer();
    setState(() {
      this._chooseKey = null;
      this._chooseCommentModel = null;
      this._chooseLineIndex = 0;
    });
  }

  ///添加评论
  void addComment(CommentModel _model) {
    //如果存在空行,直接创建弹幕.否则存入对象池.
    if (this._emptyLineList.length > 0) {
      int tempLineIndex = this._emptyLineList.removeAt(0);
      setState(() {
        this._playList.add(BarrageMap(null, tempLineIndex, _model, null));
      });
    } else {
      this._commentDataList.add(_model);
    }
  }

  ///播放动画(从上次位置继续)
  void playAnim() {
    setState(() {
      this._isAutoPlay = true;
    });
    this._playList.forEach((_m) {
      _m.bWidget.playAnim();
    });
  }

  ///暂停动画
  void stopAnim() {
    setState(() {
      this._isAutoPlay = false;
    });
    this._playList.forEach((_m) {
      if (_m.bWidget != null) {
        _m.bWidget.stopAnim();
      }
    });
  }

  ///设置显示状态
  void setShowState(bool _state) {
    if (_state && this._commentDataList.length == 0) {
      this.getCommentData(1);
    }
    setState(() {
      this._showBarrage = _state;
      this._pageOpacity =
          this._showBarrage ? (this._isFadeIn ? 1 : this._fadeoutOpacity) : 0;
    });
  }

  ///渐显
  void fadeIn() {
    setState(() {
      this._isFadeIn = true;
      this._pageOpacity =
          this._showBarrage ? (this._isFadeIn ? 1 : this._fadeoutOpacity) : 0;
    });
  }

  ///渐隐
  void fadeOut() {
    setState(() {
      this._isFadeIn = false;
      this._pageOpacity =
          this._showBarrage ? (this._isFadeIn ? 1 : this._fadeoutOpacity) : 0;
    });
  }
}

///弹幕
class TrendBarrage extends StatefulWidget {
  //
  final TrendBarrageState myState = TrendBarrageState();

  ///行下标(0-3)
  final int lineIndex;

  ///播放完成回调(回传'行下标')
  final Function(GlobalKey, int) playComplete;

  ///播放结束回调(回传'行下标')
  final Function(GlobalKey, int) playOverEvent;

  ///头像点击回调(回传'行下标')
  final Function(String, int) headClickEvent;

  ///弹幕点击回调(回传'行下标')
  final Function(GlobalKey, CommentModel, int) barrageClickEvent;

  ///是否自动播放
  final bool isAutoPlay;

  ///评论数据
  final CommentModel commentModel;

  //构造函数
  TrendBarrage(
      {Key key,
      this.lineIndex,
      this.playComplete,
      this.playOverEvent,
      this.headClickEvent,
      this.barrageClickEvent,
      this.isAutoPlay,
      this.commentModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    //this.myState = TrendBarrageState();
    return this.myState;
  }

  ///播放动画(从上次位置继续)
  void playAnim() {
    if (this.myState != null) {
      this.myState.playAnim();
    }
  }

  ///暂停动画
  void stopAnim() {
    if (this.myState != null) {
      this.myState.stopAnim();
    }
  }
}

class TrendBarrageState extends State<TrendBarrage>
    with TickerProviderStateMixin {
  ///气泡字符串长度
  double _barrageStrLength = 0;

  ///动画
  Animation<double> _animation;

  ///动画控制器
  AnimationController _animController;

  ///动画值
  double _animValue = 0;

  ///是否播放完成
  bool _isPlayComplete = false;

  @override
  void initState() {
    super.initState();

    //获取一条播报的总时间
    //+23大概是一屏的字数长度,保证长短文本的速度一致.
    this._barrageStrLength = Tools.GetStrLength(widget.commentModel.content);
    int tempAllTime = ((this._barrageStrLength + 23) * 300).toInt();
    //初始化动画控制器
    _animController = AnimationController(
        duration: Duration(milliseconds: tempAllTime), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animation.addListener(() {
      setState(() {
        this._animValue = this._animation.value;

        double tempStrWidth =
            ScreenUtil().setWidth((this._barrageStrLength * 50).toInt() + 80);
        double tempTotalWidth = tempStrWidth + ScreenUtil().setWidth(1080);
        if (_animValue >= (tempStrWidth / tempTotalWidth) &&
            widget.playComplete != null &&
            !this._isPlayComplete) {
          //文本全部显示
          this._isPlayComplete = true;
          widget.playComplete(widget.key, widget.lineIndex);
        }
        if (_animValue >= 1) {
          //文本收回完毕
          if (widget.playOverEvent != null) {
            widget.playOverEvent(widget.key, widget.lineIndex);
          }
        }
      });
    });
    //开始动画
    if (widget.isAutoPlay) {
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _animController = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double tempStrWidth =
        ScreenUtil().setWidth((this._barrageStrLength * 50).toInt() + 80);
    double tempTotalWidth = tempStrWidth + ScreenUtil().setWidth(1080);
    double tempCurPos = this._animValue * tempTotalWidth - tempStrWidth;
    return Positioned(
      top: ScreenUtil().setWidth(widget.lineIndex * 100 + 20),
      right: tempCurPos,
      child: Container(
        height: ScreenUtil().setWidth(90),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //头像
            InkWell(
              child: HeadWidget(
                headSize: Size(
                  ScreenUtil().setWidth(80),
                  ScreenUtil().setWidth(80),
                ),
                avatarUrl: widget.commentModel.avatarUrl,
                level: 0,
              ),
              onTap: () {
                widget.headClickEvent(
                    widget.commentModel.uuid, widget.lineIndex);
              },
            ),
            Container(
              width: ScreenUtil().setWidth(10),
            ),
            //评论
            InkWell(
              child: Text(
                widget.commentModel.content,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(50), color: Colors.white),
              ),
              onTap: () {
                widget.barrageClickEvent(
                    widget.key, widget.commentModel, widget.lineIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  ///播放动画(从上次位置继续)
  void playAnim() {
    this._animController.forward(from: this._animValue);
  }

  ///暂停动画
  void stopAnim() {
    this._animController.stop();
  }
}

///弹幕类表()
class BarrageMap {
  GlobalKey bKey;
  int bLineIndex;
  CommentModel bModel;
  TrendBarrage bWidget;

  BarrageMap(GlobalKey _key, int _lineIndex, CommentModel _model,
      TrendBarrage _widget) {
    this.bKey = _key;
    this.bLineIndex = _lineIndex;
    this.bModel = _model;
    this.bWidget = _widget;
  }
}
