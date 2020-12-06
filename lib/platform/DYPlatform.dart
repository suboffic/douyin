import 'package:flutter/services.dart';

class DYPlatform {
  /* 通讯渠道名称 */
  static const String CHANNEL = "dypldp";

  /* 插件监听器_视频插件 */
  static BasicMessageChannel<dynamic> pluginResult_DYPLDP =
      const BasicMessageChannel("YunPianResult", StandardMessageCodec());
  /* 回调_视频插件 */
  static Function(Map) callBack_DYPLDP = null;

  /* 初始化平台 */
  static void initDYPlatform() {
    // pluginResult_DYPLDP.setMessageHandler(DYPlatform.A2FEvent_DYPLDP);
  }

  //========== [ 视频插件_Start ] ==========
  /* 
     * 注册回调_视频插件
     */
  static void rgsCallBack_DYPLDP(Function(Map) callBack) async {
    callBack_DYPLDP = callBack;
  }

  /* 获取版本号 */
  static Future<Null> getPlatformVersion() async {
    try {
      var tempValue =
          await MethodChannel(CHANNEL).invokeMethod("getPlatformVersion");
      print(">>>>   getPlatformVersion 结果:");
      print(tempValue);
    } on PlatformException catch (_error) {
      print(">>>>  getPlatformVersion  通讯出错:");
      print(_error);
    }
  }

  /* 播放视频 */
  static Future<Null> PlayVideoUrl(String _url) async {
    try {
      var tempValue =
          await MethodChannel(CHANNEL).invokeMethod("DYPLDP", {"Url": _url});
      print(">>>>   视频播放回调：");
      print(tempValue);
    } on PlatformException catch (_error) {
      print(">>>>  PlayVideoUrl  通讯出错:");
      print(_error);
    }
  }

  /* AndroidToFlutter事件_视频插件 */
  static Future<dynamic> A2FEvent_DYPLDP(result) {
    print(">>>> 视频插件 回调：");
    print(result);
    if (result["EventType"] == "DYPLDP") {
      callBack_DYPLDP(result);
    }
    return null;
  }
  //========== [ 视频插件_End ] ==========

}
