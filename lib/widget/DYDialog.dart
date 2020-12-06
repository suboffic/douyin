import 'package:douyin/widget/Toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DYDialog {
  /* (修改)昵称控制器 */
  static TextEditingController _nickController = TextEditingController();
  /* (修改)昵称焦点 */
  static FocusNode _nickFocusNode = FocusNode();

  /* 绑定推荐人控制器 */
  static TextEditingController _bindReferrController = TextEditingController();
  /* 绑定推荐人焦点 */
  static FocusNode _bindReferrFocusNode = FocusNode();

  /* 显示弹窗_修改昵称 */
  static void showDialog_ChangeNick(BuildContext _context, Function _func) {
    showCupertinoDialog(
        context: _context,
        builder: (_context) {
          try {
            FocusScope.of(_context).requestFocus(_nickFocusNode);
          } catch (err) {}
          return CupertinoAlertDialog(
            title: Text(
              '修改昵称',
              style: TextStyle(fontSize: ScreenUtil().setSp(40)),
            ),
            content: Card(
              elevation: 0.0,
              child: Column(
                children: <Widget>[
                  TextField(
                    textAlignVertical: TextAlignVertical.center,
                    controller: _nickController,
                    focusNode: _nickFocusNode,
                    style: TextStyle(fontSize: ScreenUtil().setSp(36)),
                    scrollPadding: EdgeInsets.all(0),
                    decoration: InputDecoration(
                      hintText: '请输入新的昵称（3-12个字符）',
                      hintStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(36), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  _nickController.text = "";
                  _nickFocusNode.unfocus();
                  Navigator.pop(_context);
                },
                child: Text('取消'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  if (_nickController.text == "") {
                    Toast.toast(_context,
                        msg: "请填写昵称!", position: ToastPostion.center);
                    return;
                  }
                  if (_func != null) {
                    _func(_nickController.text);
                  }
                  _nickController.text = "";
                  _nickFocusNode.unfocus();
                  Navigator.pop(_context);
                },
                child: Text('确定'),
              ),
            ],
          );
        });
  }

  /* 显示弹窗_绑定推荐人 */
  static void showDialog_BindReferr(BuildContext _context, Function _func) {
    showCupertinoDialog(
        context: _context,
        builder: (_context) {
          try {
            FocusScope.of(_context).requestFocus(_bindReferrFocusNode);
          } catch (err) {}
          return CupertinoAlertDialog(
            title: Text(
              '绑定推荐人',
              style: TextStyle(fontSize: ScreenUtil().setSp(40)),
            ),
            content: Card(
              elevation: 0.0,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _bindReferrController,
                    focusNode: _bindReferrFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    style: TextStyle(fontSize: ScreenUtil().setSp(36)),
                    decoration: InputDecoration(
                      hintText: '请输入推荐人ID',
                      hintStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(36), height: 1),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  _bindReferrController.text = "";
                  _bindReferrFocusNode.unfocus();
                  Navigator.pop(_context);
                },
                child: Text('取消'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  if (_bindReferrController.text == "") {
                    Toast.toast(_context,
                        msg: "请填写推荐人ID!", position: ToastPostion.center);
                    return;
                  }
                  if (_func != null) {
                    _func(_bindReferrController.text);
                  }
                  _bindReferrController.text = "";
                  _bindReferrFocusNode.unfocus();
                  Navigator.pop(_context);
                },
                child: Text('确定'),
              ),
            ],
          );
        });
  }
}
