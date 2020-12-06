import 'package:douyin/style/Style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DYDialogExitApp {
  ///显示弹窗
  static showDialog(BuildContext _context) {
    showCupertinoDialog(
        context: _context,
        builder: (_context) {
          return StatefulBuilder(
            builder: (context, state) {
              return CupertinoAlertDialog(
                title: Text(
                  "登录过期",
                  style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                ),
                content: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text("登录过期，请重新登录！"),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () async {
                      //清除Token,保留oaid.
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove(DyPreferencesKeys.token);
                      //退出app
                      await SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                    child: Text('确定'),
                  ),
                ],
              );
            },
          );
        });
  }
}
