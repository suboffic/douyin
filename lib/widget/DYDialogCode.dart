import 'dart:async';

import 'package:douyin/translations/translations.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DYDialogCode {
  /* 验证码控制器 */
  static TextEditingController _codeController = TextEditingController();
  /* 验证码焦点 */
  static FocusNode _codeFocusNode = FocusNode();
  /* 验证码内容 */
  static String _codeStr = "";
  /* 手机号码 */
  static String _phone = "";
  /* 短信类型 */
  static int _smsType = 0;

  /* 倒计时器 */
  static Timer _countdownTimer;
  /* 倒计时状态 */
  static bool _countdownState = false;
  /* 倒计时提示 */
  static String _codeCountdownStr = "获取验证码";
  /* 倒计时时间 */
  static int _countdown = 59;
  static int _curCdTime = 0;

  /* 显示弹窗_验证码 */
  static void showDialogCode(BuildContext _context, String _phoneNum,
      int _usage, Function(String) _callback) {
    _phone = _phoneNum;
    _smsType = _usage;
    _codeCountdownStr = "获取验证码";
    _codeController.clear();
    _codeStr = "";
    showCupertinoDialog(
        context: _context,
        builder: (_context) {
          try {
            FocusScope.of(_context).requestFocus(_codeFocusNode);
          } catch (err) {}
          return StatefulBuilder(
            builder: (context, state) {
              return CupertinoAlertDialog(
                title: Text(
                  "请填写验证码",
                  style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                ),
                content: buildContent(_context, state, _callback),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      _codeController.clear();
                      _codeFocusNode.unfocus();
                      resetCodeState();
                      Navigator.pop(_context);
                    },
                    child: Text('取消'),
                  ),
                  CupertinoDialogAction(
                    onPressed: () {
                      if (_codeController.text.length < 6) {
                        Toast.toast(_context,
                            msg: "请填写正确交易密码!", position: ToastPostion.center);
                        return;
                      }
                      _codeController.clear();
                      _codeFocusNode.unfocus();
                      resetCodeState();
                      Navigator.pop(_context);
                      if (_callback != null) {
                        _callback(_codeController.text);
                      }
                    },
                    child: Text('确定'),
                  ),
                ],
              );
            },
          );
        });
  }

  /* 生成内容 */
  static Widget buildContent(
      BuildContext _context, Function state, Function(String) _callback) {
    List<Widget> tempCodeBtnList = [];
    int tempChooseIndex = -1;
    for (int i = 0; i < 4; i++) {
      String tempCodeStr = (_codeStr + "    ").substring(i, i + 1);
      if (tempChooseIndex < 0 && tempCodeStr == " ") {
        tempChooseIndex = i;
      }
      tempCodeBtnList.add(buildCodeBtn(tempCodeStr, tempChooseIndex == i));
    }

    return Card(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(60)),
      elevation: 0,
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(360),
            height: ScreenUtil().setHeight(100),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: tempCodeBtnList,
                ),
                Container(
                  height: ScreenUtil().setWidth(80),
                  color: Colors.transparent,
                  child: TextField(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    cursorWidth: 0,
                    textAlign: TextAlign.start, //文本对齐方式
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(80),
                        color: Colors.transparent),
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 0),
                      border: InputBorder.none,
                    ),
                    onChanged: (_text) {
                      if (_text.length >= 4) {
                        _text = _text.substring(0, 4);
                        resetCodeState();
                        state(() {});
                        Navigator.pop(_context);
                        Future.delayed(Duration(milliseconds: 200), () {
                          if (_callback != null) {
                            _callback(_text);
                          }
                        });
                      } else {
                        _codeStr = _text;
                        state(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(40),
          ),
          Expanded(
            child: OutlineButton(
              padding: EdgeInsets.all(0),
              child: Text(_codeCountdownStr,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(_curCdTime > 0 ? 26 : 30),
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal)),
              onPressed: () {
                getCodeBtnEvent(_context, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  /* 生成验证码按钮 */
  static Widget buildCodeBtn(String _str, bool _isChoose) {
    return Container(
      width: ScreenUtil().setWidth(60),
      height: ScreenUtil().setWidth(86),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: _isChoose ? Colors.black : Colors.grey, width: 1)),
      ),
      child: Center(
        child: Text(_str,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(60),
                color: Colors.black,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal)),
      ),
    );
  }

  /* 获取验证码按钮事件 */
  static void getCodeBtnEvent(BuildContext context, Function state) async {
    print(">>  获取验证码按钮");
  }

  /* 重置获取按钮文本 */
  static void resetCodeBtnText(BuildContext context, Function state) {
    if (_countdownTimer != null) {
      return;
    }
    // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
    state(() {
      _curCdTime = _countdown;
      _codeCountdownStr =
          '${_curCdTime--}s ${Translations.of(context).text("login_getcode_tip_cooling")}';
    });
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      state(() {
        if (_curCdTime > 0) {
          _codeCountdownStr =
              '${_curCdTime--}s ${Translations.of(context).text("login_getcode_tip_cooling")}';
        } else {
          _codeCountdownStr =
              Translations.of(context).text("login_getcode_tip_normal");
          resetCodeState();
        }
      });
    });
  }

  /* 重置验证码状态 */
  static void resetCodeState() {
    _countdownTimer?.cancel();
    _countdownTimer = null;

    _countdownState = false;
    _curCdTime = _countdown;

    _codeStr = "";
    _codeController.clear();
    _codeFocusNode.unfocus();
  }
}
