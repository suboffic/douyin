import 'package:douyin/model/OtherModel.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';

class DYEventBus {
  ///登录事件总线
  static EventBus loginEventBus = new EventBus();

  ///普通事件总线
  static EventBus eventBus = new EventBus();

  static void initDYEventBus() {
    DYEventBus.eventBus = new EventBus();
  }
}

///前往登陆事件
///(force : 是否强制登陆)
class GotoLoginEvent {
  BuildContext context;
  String title;
  bool force;
  GotoLoginEvent(this.context, this.title, this.force);
}

///退出App
class ExitApp {
  BuildContext context;
  ExitApp(this.context);
}

///检测更新
class CheckVersion {
  BuildContext context;
  CheckVersion(this.context);
}

///请求个人信息事件
///(由于多个地方需要请求个人信息,所以提取到事件总线.)
class ReqUserInfoEvent {
  BuildContext context;
  Function callback;
  ReqUserInfoEvent(this.context, this.callback);
}

///前往广告
class GotoAd {
  int adType;
  String adUrl;
  GotoAd(this.adType, this.adUrl);
}

///视频视图通知视频列表
class VideoViewToVideoList {
  GlobalKey listKey;
  String eventName;
  dynamic eventArg;
  VideoViewToVideoList(this.listKey, this.eventName, this.eventArg);
}

///关注通知视频列表
class FollowToVideoList {
  String uuid;
  bool state;
  FollowToVideoList(this.uuid, this.state);
}

///同步礼物列表
class SyncGiftList {
  Function callBack;
  SyncGiftList(this.callBack);
}

///检测视频播放状态_动态视图通知Home页面
class CheckVideoPlayState_V2H {
  Function(bool _state, GlobalKey _key) callBack;
  CheckVideoPlayState_V2H(this.callBack);
}

///WebSocket_接收消息
class WebSocket_OnData {
  dynamic content;
  WebSocket_OnData(this.content);
}

///WebSocket_错误
class WebSocket_OnError {
  dynamic content;
  WebSocket_OnError(this.content);
}

///接收消息_聊天
class ReceiveMsg_Chat {
  ChatModel chatModel;
  ReceiveMsg_Chat(this.chatModel);
}

///发送消息_聊天
class SendMsg_Chat {
  String t_id;
  ChatModel chatModel;
  SendMsg_Chat(this.t_id, this.chatModel);
}

///同步未读
class SyncUnread {
  String from_uuid;
  SyncUnread(this.from_uuid);
}

///保存本地聊天
class SaveLocalChat {
  SaveLocalChat();
}

///刷新FLO(粉丝/点赞/作品收入)
class RefreshFLO {
  RefreshFLO();
}
