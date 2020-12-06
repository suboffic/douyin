import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeviceInfoUtil {
  ///获取设备信息
  static getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    if(Platform.isIOS){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    }else if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }
  }

  ///显示设备信息
  static void showDeviceInfo(BuildContext _context, Function _func) async{
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    if(Platform.isIOS){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      DeviceInfoUtil.showInfoDiolog(_context, {
        "name" : iosInfo.name,
        "systemName" : iosInfo.systemName,
        "systemVersion" : iosInfo.systemVersion,
        "model" : iosInfo.model,
        "localizedModel" : iosInfo.localizedModel,
        "identifierForVendor" : iosInfo.identifierForVendor,
        "=====[分割线]=====" : "",
        "utsname.sysname" : iosInfo.utsname.sysname,
        "utsname.nodename" : iosInfo.utsname.nodename,
        "utsname.release" : iosInfo.utsname.release,
        "utsname.version" : iosInfo.utsname.version,
        "utsname.machine" : iosInfo.utsname.machine,
      }, _func);
    }else if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      DeviceInfoUtil.showInfoDiolog(_context, {
        "version.baseOS" : androidInfo.version.baseOS,
        "version.codename" : androidInfo.version.codename,
        "version.incremental" : androidInfo.version.incremental,
        "version.previewSdkInt" : androidInfo.version.previewSdkInt.toString(),
        "version.release" : androidInfo.version.release,
        "version.sdkInt" : androidInfo.version.sdkInt.toString(),
        "version.securityPatch" : androidInfo.version.securityPatch,
        "=====[分割线]=====" : "",
        "board" : androidInfo.board,
        "bootloader" : androidInfo.bootloader,
        "brand" : androidInfo.brand,
        "device" : androidInfo.device,
        "display" : androidInfo.display,
        "fingerprint" : androidInfo.fingerprint,
        "hardware" : androidInfo.hardware,
        "host" : androidInfo.host,
        "id" : androidInfo.id,
        "manufacturer" : androidInfo.manufacturer,
        "model" : androidInfo.model,
        "product" : androidInfo.product,
        // "supported32BitAbis" : androidInfo.supported32BitAbis,
        // "supported64BitAbis" : androidInfo.supported64BitAbis,
        // "supportedAbis" : androidInfo.supportedAbis,
        "tags" : androidInfo.tags,
        "type" : androidInfo.type,
        // "isPhysicalDevice" : androidInfo.isPhysicalDevice,
      }, _func);
    }
  }

  ///显示信息弹窗
  static void showInfoDiolog(BuildContext _context, Map<String, String> _infoMap, Function _func) {
    TextStyle tempTextStyle = TextStyle(fontSize: ScreenUtil().setSp(40));
    List<String> tempKeyList = _infoMap.keys.toList();
    List<String> tempValueList = _infoMap.values.toList();
    List<Widget> tempInfoList = [];
    for (int i=0; i<tempKeyList.length; i++) {
      String tempKey = tempKeyList[i];
      String tempValue = tempValueList[i];
      tempInfoList.add(
        Text("${tempKey}: ${tempValue}")
      );
    }

    showCupertinoDialog(
      context: _context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('设备信息', style: tempTextStyle,),
          content: Card(
            color: Colors.transparent,
            elevation: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tempInfoList,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(_context);
                if (_func != null) {
                  _func();
                }
              },
              child: Text('确定'),
            ),
          ],
        );
    });
  }

}