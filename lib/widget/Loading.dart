import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Loading {
  // 靠它加到屏幕上
  static OverlayEntry _overlayEntry;
  // 是否正在showing
  static bool _showing = false;
  // 开启一个新loading的当前时间，用于对比是否已经展示了足够时间
  static DateTime _startedTime;
  // 显示时间
  static int _showTime;

  /// 开始计时器
  static void start(
    BuildContext context, {
    //显示的时间 单位毫秒
    int showTime = 0,
  }) async {
    if (context == null) return;
    _startedTime = DateTime.now();
    _showTime = showTime;
    //获取OverlayState
    OverlayState overlayState = Overlay.of(context);
    _showing = true;
    if (_overlayEntry == null) {
      //OverlayEntry负责构建布局
      //通过OverlayEntry将构建的布局插入到整个布局的最上层
      _overlayEntry = OverlayEntry(
          builder: (BuildContext context) => Positioned(
                child: Container(
                  alignment: Alignment.center,
                  width: ScreenUtil().setWidth(1080),
                  height: ScreenUtil().setHeight(1920),
                  color: Colors.black26,
                  child: AnimatedOpacity(
                    opacity: _showing ? 1.0 : 0.0, //目标透明度
                    duration: _showing
                        ? Duration(milliseconds: 100)
                        : Duration(milliseconds: 200),
                    child: _buildLoadingWidget(),
                  ),
                ),
              ));
      //插入到整个布局的最上层
      overlayState.insert(_overlayEntry);
    } else {
      //重新绘制UI，类似setState
      _overlayEntry.markNeedsBuild();
    }
    if (_showTime > 0) {
      // 等待时间
      await Future.delayed(Duration(milliseconds: _showTime));
      // 倒计时结束
      if (DateTime.now().difference(_startedTime).inMilliseconds >= _showTime) {
        _showing = false;
        if (_overlayEntry != null) {
          _overlayEntry.markNeedsBuild();
          await Future.delayed(Duration(milliseconds: 200));
          _overlayEntry.remove();
          _overlayEntry = null;
        }
      }
    }
  }

  /// 结束计时器
  static void End() async {
    if (_overlayEntry != null) {
      _overlayEntry.markNeedsBuild();
      await Future.delayed(Duration(milliseconds: 200));
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  /// loading绘制
  static _buildLoadingWidget() {
    return Container(
      width: ScreenUtil().setWidth(1080),
      height: ScreenUtil().setHeight(1920),
      child: CupertinoActivityIndicator(radius: ScreenUtil().setWidth(30)),
    );
  }
}
