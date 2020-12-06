import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///加载球(动画)
class LoadingBall extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoadingBallState();
  }
}

class LoadingBallState extends State<LoadingBall>
    with SingleTickerProviderStateMixin {
  ///
  GlobalKey _myKey = GlobalKey();

  ///(小球)动画
  Animation<double> _animation;

  ///(小球)动画控制器
  AnimationController _animController;

  ///动画值
  double _animValue = 0;

  ///是否显示蓝色小球
  bool _isShowBlueBall = true;

  ///小球宽度
  double _ballWidth = ScreenUtil().setWidth(40);

  ///Context宽度
  double _contextWidth = -1;

  ///位移距离
  double _moveValue = ScreenUtil().setWidth(40);

  ///曲线_P(抛物线公式的p值. p越大,球的变化越小)
  double _curve_P = 0.2;

  @override
  void initState() {
    super.initState();

    //初始化动画控制器
    _animController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animation.addListener(() {
      if (!this._animController.isAnimating) {
        return;
      }
      setState(() {
        this._animValue = this._animation.value;
      });
    });
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.reverse();
        try {
          setState(() {
            this._isShowBlueBall = false;
          });
        } catch (_err) {}
      } else if (status == AnimationStatus.dismissed) {
        _animController.forward();
        try {
          setState(() {
            this._isShowBlueBall = true;
          });
        } catch (_err) {}
      }
    });

    //延迟
    Future.delayed(Duration(milliseconds: 50), () {
      this._contextWidth = this.context.size.width;
      this.showLoading();
    });
  }

  @override
  void dispose() {
    this.hideLoading();

    this._animController.dispose();
    this._animController = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: this._myKey,
      alignment: Alignment.center,
      children: this._isShowBlueBall
          ? <Widget>[
              //红球
              this.buildBall_Red(),
              //蓝球
              this.buildBall_Blue(),
            ]
          : <Widget>[
              //蓝球
              this.buildBall_Blue(),
              //红球
              this.buildBall_Red(),
            ],
    );
  }

  ///生成球_蓝色
  Widget buildBall_Blue() {
    //偏移,产出-0.5,0,0.5 (映射抛物线的-1,0,1)
    double tempAv = this._animValue - 0.5;
    //公式:x方=-2py 演变:x平方/-2/p (p越大,开口越大)
    double tempCurve = this._isShowBlueBall
        ? tempAv * tempAv / -2 / _curve_P
        : tempAv * tempAv / 2 / _curve_P;
    //修正 (取最小值)
    double tempOffset = this._isShowBlueBall
        ? 0.5 * 0.5 / 2 / _curve_P
        : 0.5 * 0.5 / -2 / _curve_P;
    tempCurve += tempOffset;
    double tempWidth = tempCurve * ScreenUtil().setWidth(20) + this._ballWidth;
    //位移
    double tempMove = this._contextWidth / 2 +
        this._moveValue * (this._animValue - 0.5) -
        tempWidth / 2;
    return Positioned(
      left: tempMove,
      child: Opacity(
        opacity: 0.7,
        child: Image(
          width: tempWidth,
          image: AssetImage("images/icon_circular_blue.png"),
        ),
      ),
    );
  }

  ///生成球_红色
  Widget buildBall_Red() {
    //偏移,产出0.5,0,-0.5 (映射抛物线的-1,0,1)
    double tempAv = 1 - this._animValue - 0.5;
    //公式:x方=-2py 演变:x平方/-2/p (p越大,开口越大)
    double tempCurve = this._isShowBlueBall
        ? tempAv * tempAv / 2 / _curve_P
        : tempAv * tempAv / -2 / _curve_P;
    //修正 (取最小值)
    double tempOffset = this._isShowBlueBall
        ? 0.5 * 0.5 / -2 / _curve_P
        : 0.5 * 0.5 / 2 / _curve_P;
    tempCurve += tempOffset;
    double tempWidth = tempCurve * ScreenUtil().setWidth(20) + this._ballWidth;
    //位移
    double tempMove = this._contextWidth / 2 +
        this._moveValue * (this._animValue - 0.5) -
        tempWidth / 2;
    return Positioned(
      right: tempMove,
      child: Opacity(
        opacity: 0.7,
        child: Image(
          width: tempWidth,
          image: AssetImage("images/icon_circular_red.png"),
        ),
      ),
    );
  }

  //========== [ 辅助函数 ] ==========
  ///显示等待
  showLoading() {
    this._animController.forward();
  }

  ///隐藏等待
  hideLoading() {
    this._animController.reset();
  }
}
