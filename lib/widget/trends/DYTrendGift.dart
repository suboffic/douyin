import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///动态礼物
class DYTrendGift extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DYTrendGiftState();
  }
}

class DYTrendGiftState extends State<DYTrendGift> {
  ///位置列表
  List<Offset> _posList = [];

  ///礼物映射表
  Map<int, GiftMap> _giftMap = {};

  bool _isActive = false;

  @override
  void initState() {
    super.initState();

    this._isActive = true;
    this.startCreateGift();
  }

  @override
  void dispose() {
    this._isActive = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(400),
      height: ScreenUtil().setWidth(1000),
      child: Stack(
        children: this.getWidgetList(),
      ),
    );
  }

  ///获取组件列表
  getWidgetList() {
    if (!this._isActive) {
      return [];
    }

    Size tempSize =
        Size(ScreenUtil().setWidth(100), ScreenUtil().setWidth(400));
    for (int i = 0; i < this._posList.length; i++) {
      if (this._giftMap[i] == null) {
        //如果映射表为空,创建一个新的点赞
        GlobalKey tempKey = GlobalKey();
        Offset tempOffset = this._posList[i];
        int tempIndex = Random().nextInt(6);
        String tempImg = "images/video/right_gift_0${tempIndex}.png";
        Positioned tempWidget = Positioned(
          right: tempOffset.dx + tempSize.width / 2,
          bottom: tempOffset.dy - tempSize.height,
          child: GiftItem(
              key: tempKey,
              value: i,
              widgetSize: tempSize,
              giftName: tempImg,
              removeFunc: this.removeGiftFunc),
        );
        this._giftMap[i] = GiftMap(tempKey, tempOffset, tempWidget);
      }
    }

    List<Widget> tempList = [];
    tempList.add(this.buildGiftBtn());
    for (int i = 0; i < this._giftMap.length; i++) {
      if (this._giftMap[i].giftWidget != null) {
        tempList.add(this._giftMap[i].giftWidget);
      }
    }
    // tempList.add(this.buildGiftBtn());
    return tempList;
  }

  ///生成礼物按钮
  Widget buildGiftBtn() {
    return Positioned(
      bottom: 0,
      right: ScreenUtil().setWidth(30),
      child: Image.asset(
        "images/video/right_gift.png",
        fit: BoxFit.fill,
        width: ScreenUtil().setWidth(130),
        height: ScreenUtil().setWidth(130),
      ),
    );
  }

  ///移除礼物事件
  void removeGiftFunc(GlobalKey _key) {
    for (int i = 0; i < this._giftMap.length; i++) {
      if (_key == this._giftMap[i].giftKey) {
        this._giftMap[i].giftWidget = null;
        break;
      }
    }
    if(mounted)setState(() {});
  }

  ///开始创建礼物
  void startCreateGift() {
    if (!this._isActive) {
      return;
    }

    //延迟
    int tempTime = Random().nextInt(3000) + 100;
    Future.delayed(Duration(milliseconds: tempTime), () {
      if (!this._isActive) {
        return;
      }
      this.addNewGift();
      this.startCreateGift();
    });
  }

  ///添加新礼物
  void addNewGift() {
    this._posList.add(Offset(
          ScreenUtil().setWidth(Random().nextInt(30)),
          ScreenUtil().setWidth(Random().nextInt(20) + 420),
        ));
    if(mounted)setState(() {});
  }
}

///礼物Item
class GiftItem extends StatefulWidget {
  final int value;
  //组件尺寸
  final Size widgetSize;
  //礼物名称
  final String giftName;
  //移除事件
  final Function(GlobalKey) removeFunc;

  //构造函数
  GiftItem(
      {Key key, this.value, this.widgetSize, this.giftName, this.removeFunc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GiftItemState();
  }
}

class GiftItemState extends State<GiftItem> with TickerProviderStateMixin {
  ///删除计时器
  Timer _deleteTimer = null;

  ///动画
  Animation<double> _animation;

  ///动画控制器
  AnimationController _animController;

  ///动画值
  double _animValue = 0;

  //最大角度(控制值)
  int _maxAngle = 45;
  //随机角度
  double _randomAngle = 0;
  double _moveValue = ScreenUtil().setWidth(400);

  @override
  void initState() {
    super.initState();

    _randomAngle =
        (Random().nextInt(_maxAngle * 2) - _maxAngle) / 360 * 3.1415926;

    _animController = AnimationController(
        duration: const Duration(milliseconds: 2500), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animation.addListener(() {
      setState(() {
        this._animValue = this._animation.value;
      });
    });

    //开始播放动画
    _animController.forward();

    this.startDeleteTimer();
  }

  @override
  void dispose() {
    this.endDeleteTimer();
    this._animController.dispose();
    this._animController = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double tempWidget = widget.widgetSize.width * (1 + this._animValue * 2) / 2;
    double tempPadding = this._animValue * this._moveValue;
    double tempOpacity = 1 - this._animValue;

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
          child: Image.asset(
            widget.giftName,
            width: tempWidget,
          ),
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

class GiftMap {
  GlobalKey giftKey;
  Offset giftOffset;
  Widget giftWidget;
  //构造函数
  GiftMap(GlobalKey _key, Offset _offset, Widget _widget) {
    this.giftKey = _key;
    this.giftOffset = _offset;
    this.giftWidget = _widget;
  }
}
