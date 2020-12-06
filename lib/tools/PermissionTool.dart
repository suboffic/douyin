import 'package:douyin/tools/Logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionTool {
  /* 申请权限 */
  static Future requestPermission(
      BuildContext _context, Permission _pg, Function _callback) async {
    PermissionStatus permission = await _pg.request();

    if (permission == PermissionStatus.granted) {
      // Logger.Log("权限申请通过");
      if (_callback != null) {
        _callback();
      }
    } else if (permission == PermissionStatus.denied) {
      Logger.LogError("权限申请 否认");
      PermissionTool.showAppSettings(_context, _pg, _callback);
    } else if (permission == PermissionStatus.undetermined) {
      Logger.LogError("权限申请 等待用户确认");
    } else if (permission == PermissionStatus.restricted ||
        permission == PermissionStatus.permanentlyDenied) {
      Logger.LogError("权限申请 受限制");
      PermissionTool.showAppSettings(_context, _pg, _callback);
    } else {
      Logger.LogError("权限申请 未知错误");
    }
  }

  /* 显示弹窗_前往设置 */
  static showAppSettings(
      BuildContext _context, Permission _pg, Function _callback) {
    showCupertinoDialog(
        context: _context,
        builder: (_context) {
          return CupertinoAlertDialog(
            title: Text(
              '请允许授权',
              style: TextStyle(fontSize: ScreenUtil().setSp(40)),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  await SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop');
                },
                child: Text('取消'),
              ),
              CupertinoDialogAction(
                onPressed: () async {
                  Navigator.pop(_context);
                  await openAppSettings();
                },
                child: Text('确定'),
              ),
            ],
          );
        });
  }
}
