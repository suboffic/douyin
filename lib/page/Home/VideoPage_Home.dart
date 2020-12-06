import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:douyin/config/Config.dart';
import 'package:douyin/model/DYModelUnit.dart';
import 'package:douyin/model/OtherModel.dart';
import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/net/WebSocketManager.dart';
import 'package:douyin/page/Home/AuthorInfoPage.dart';
import 'package:douyin/page/Home/InvitationPage.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/style/DYPhysicalBtnEvtControll.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/DeviceInfoUtil.dart';
import 'package:douyin/widget/DYDialogExitApp.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:douyin/widget/trends/DYTrendListView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

///视频页面_主页
class VideoPage_Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoPage_HomeState();
  }
}

class VideoPage_HomeState extends State<VideoPage_Home>
    with TickerProviderStateMixin {
  ///主数据模块
  MainModel _mainModel;

  ///上次按返回键时间
  DateTime lastPopTime;

  ///是否能拖拽
  bool _canDrag = true;

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///页面控制器
  PageController _pageController;

  ///上个页面下标
  int _lastTabIndex = 1;
  double _pageValue = 2;

  ///Key列表 (视频列表视图)
  List<GlobalKey> _keyList = [];

  ///动态列表视图列表
  List<DYTrendListView> _trendListViewList = [];

  ///没有数据_动态
  bool _notDate_Trend = false;

  ///邀请界面
  InvitationPage _invitationPage;

  ///作者信息界面
  AuthorInfoPage _authorInfoPage;

  @override
  void initState() {
    super.initState();

    this.initEventBus();
    //初始化视图宽度 & 高度
    _viewWidth = ScreenUtil().setWidth(1080);
    double _statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    _viewHeight = ScreenUtil().setHeight(1920) - _statusBarHeight;

    //初始化页面控制器
    _pageController = PageController(initialPage: 2);
    _pageController.addListener(() {
      setState(() {
        this._pageValue = _pageController.page;
      });
    });
    //初始化其他数据
    this._keyList = [GlobalKey(), GlobalKey()];
    this._trendListViewList = [
      DYTrendListView(
        key: this._keyList[0],
        curPageIndex: 0,
        videoType: 1,
        trendsModelList: [],
        reqMoreModelEvent: this.reqMoreVideoModelEvent,
        gotoAuthorInfoPage: (String _uuid) {
          this._authorInfoPage.refreshUuid(_uuid);
          this._pageController.animateToPage(3,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        },
      ),
      DYTrendListView(
        key: this._keyList[1],
        curPageIndex: 0,
        videoType: 0,
        trendsModelList: [],
        reqMoreModelEvent: this.reqMoreVideoModelEvent,
        gotoAuthorInfoPage: (String _uuid) {
          this._authorInfoPage.refreshUuid(_uuid);
          this._pageController.animateToPage(3,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        },
      ),
    ];
    this._trendListViewList[0].injSetDragStateEvent((bool _state) {
      setState(() {
        this._canDrag = _state;
      });
    });
    this._trendListViewList[1].injSetDragStateEvent((bool _state) {
      setState(() {
        this._canDrag = _state;
      });
    });
    this._invitationPage = InvitationPage();
    this._authorInfoPage = AuthorInfoPage(
        dragHomePageEvent: this.dragHomePageEvent, needStatusBarHeight: false);

    //请求个人信息
    DYEventBus.eventBus.fire(ReqUserInfoEvent(context, (_data) async {
      this._mainModel.userModel.fromMap(_data);

      ///持久化缓存
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(DyPreferencesKeys.token, Config.token);
      prefs.setString(DyPreferencesKeys.oauthId, Config.oauthId);
      //同步礼物列表
      DYEventBus.eventBus.fire(SyncGiftList(() {}));
      //请求首页数据
      this.reqMoreVideoModelEvent(0, 1, false);

      //链接WebSocket
      WebSocketManager().initWebSocket();
    }));
  }

  @override
  void dispose() {
    this.ReleaseEventBus();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: buildMainScaffold(),
      onWillPop: () async {
        // 点击返回键的操作
        Function tempFunc = DYPhysicalBtnEvtControll.GetPhysicalBtnEvent();
        if (tempFunc != null) {
          tempFunc();
          return false;
        }
        if (lastPopTime == null ||
            DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
          lastPopTime = DateTime.now();
          Toast.toast(context, msg: "再按一次退出", position: ToastPostion.bottom);
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
        return true;
      },
    );
  }

  Widget buildMainScaffold() {
    //换算页面滑动值_侧边页面
    double tempPageValue_Top = 0;
    if (this._pageValue < 1) {
      tempPageValue_Top = this._pageValue - 1;
    } else if (this._pageValue > 2) {
      tempPageValue_Top = this._pageValue - 2;
    }
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            backgroundColor: Colors.black,
            elevation: 0.0,
            brightness: Brightness.dark,
          ),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            this.buildVideoList(),
            this.buildTabBtnList(tempPageValue_Top),
            this.buildSearchIcon(tempPageValue_Top),
            this.buildHotIcon(tempPageValue_Top),
          ],
        ),
      );
    });
  }

  ///生成视频列表
  Widget buildVideoList() {
    return Positioned(
      child: Container(
        width: this._viewWidth,
        height: this._viewHeight,
        child: PageView(
          controller: _pageController,
          onPageChanged: this.onPageChange,
          physics: this._canDrag
              ? ClampingScrollPhysics()
              : NeverScrollableScrollPhysics(),
          children: <Widget>[
            this._invitationPage,
            this._trendListViewList[0],
            this._trendListViewList[1],
            this._authorInfoPage,
          ],
        ),
      ),
    );
  }

  ///生成翻页按钮列表
  Widget buildTabBtnList(double _pageValueTop) {
    //换算页面滑动值_Tab页
    double tempPageValueTab = this._pageValue - 1;
    tempPageValueTab = tempPageValueTab < 0 ? 0 : tempPageValueTab;
    tempPageValueTab = tempPageValueTab > 1 ? 1 : tempPageValueTab;
    return Positioned(
      top: ScreenUtil().setWidth(30),
      left: this._viewWidth / 2 -
          ScreenUtil().setWidth(200) -
          _pageValueTop * this._viewWidth,
      child: Container(
        width: ScreenUtil().setWidth(400),
        height: ScreenUtil().setWidth(100),
        child: Stack(
          children: <Widget>[
            //底部指示滑块
            this.buildTabBtnSlider(tempPageValueTab),
            //按钮
            Row(
              children: <Widget>[
                this.buildTabBtnText(0, "关注", 1 - tempPageValueTab),
                this.buildTabBtnText(1, "推荐", tempPageValueTab),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///生成翻页按钮文本
  Widget buildTabBtnText(int _index, String _str, double _op) {
    Gradient _gradient =
        LinearGradient(colors: [Color(0xfffff3196), Color(0xffff9d9c)]);
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(200),
        height: ScreenUtil().setHeight(100),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            //白色垫底
            Text(
              _str,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(54), color: Colors.white),
            ),
            //彩色覆盖
            Opacity(
              opacity: _op,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return _gradient.createShader(Offset.zero & bounds.size);
                },
                child: Text(
                  _str,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(54), color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        this._pageController.animateToPage(_index + 1,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      },
    );
  }

  ///生成翻页按钮滑块
  Widget buildTabBtnSlider(double _pageValue) {
    return Positioned(
      bottom: 0,
      left: ScreenUtil().setWidth(50 + (_pageValue * 200).toInt()),
      child: Container(
        width: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(5),
        color: Color(0xffff3196),
      ),
    );
  }

  ///生成搜索按钮
  Widget buildSearchIcon(double _pageValueTop) {
    return Positioned(
      top: ScreenUtil().setWidth(40),
      right: ScreenUtil().setWidth(40) + _pageValueTop * this._viewWidth,
      child: InkWell(
        child: Icon(
          Icons.search,
          size: ScreenUtil().setWidth(90),
          color: Colors.white,
        ),
        onTap: this.btnEventSearch,
      ),
    );
  }

  ///生成火热按钮
  Widget buildHotIcon(double _pageValueTop) {
    return Positioned(
      top: ScreenUtil().setWidth(40),
      left: ScreenUtil().setWidth(40) - _pageValueTop * this._viewWidth,
      child: InkWell(
        child: Image.asset(
          "images/video/text_hot.png",
          width: ScreenUtil().setWidth(80),
        ),
        onTap: this.btnEventHot,
      ),
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_搜索
  void btnEventSearch() {}

  ///按钮事件_搜索
  void btnEventHot() {
    //添加返回按钮事件
  }

  //========== [ 辅助函数 ] ==========
  ///页面切换事件
  void onPageChange(int _index) {
    //切换Tab页面,暂停旧视频.
    if (_lastTabIndex == 0 || _lastTabIndex == 1) {
      this._trendListViewList[this._lastTabIndex].playOrPauseVideo(false);
    }
    this._lastTabIndex = _index - 1;
    //当前页面下标为1/2的时候,才执行判断.
    if (_index == 1 || _index == 2) {
      //通知VideoView检测是否播放视频
      this._trendListViewList[this._lastTabIndex].playOrPauseVideo(true);
      setState(() {});
      //如果'作者页面'滑回'播放页面',需要移除事件列表.
      if (this._lastTabIndex == 1) {
        DYPhysicalBtnEvtControll.GetPhysicalBtnEvent();
      }
      //如果滑到'关注页面',并且视频长度是0,重新获取关注数据
      if (_index == 1 && this._trendListViewList[0].getVideoModelCount() == 0) {
        DyStyleVariable.keyCurVideoList = null;
        DyStyleVariable.keyCurVideoPage = null;
        DyStyleVariable.keyCurVideoView = null;
        this.reqMoreVideoModelEvent(1, 1, false);
      }
    } else if (_index == 3) {
      //添加返回按钮事件
      DYPhysicalBtnEvtControll.AddPhysicalBtnEvent(() {
        this._pageController.animateToPage(2,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    }
  }

  ///拖动主页面事件(提供给作者界面)
  void dragHomePageEvent(double _dragValue, bool _dragToNext) {
    if (_dragToNext) {
      this._pageController.animateToPage(2,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      this._pageController.jumpTo(3 * this._viewWidth - _dragValue);
    }
  }

  ///请求更多视频数据事件 (_videoType: 0推荐 1关注)
  void reqMoreVideoModelEvent(int _videoType, int _page, bool _isForce) async {
    if (this._notDate_Trend) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tempInterets = prefs.getString(DyPreferencesKeys.interests) ?? "";
    ResultData _result = await HttpManager.requestPost(context, "/list", {
      "items": tempInterets,
      "type": _videoType,
      "page": _page,
      "v": this._mainModel.userModel.v
    });
    if (_result.result) {
      this._mainModel.userModel.v = 0;
      //获取成功,清除感兴趣id
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove(DyPreferencesKeys.interests);
      //解析数据
      List<TrendsModel> tempTrendsDataList = [];
      if (_result.data["data"] != null) {
        setState(() {
          this._notDate_Trend = _result.data["page"] == 0;
        });
        tempTrendsDataList =
            DYModelUnit.convertList<TrendsModel>(_result.data["data"]);
      }
      int tempIndex = (_videoType + 1) % 2;
      if (_page == 1 && tempTrendsDataList.length == 0) {
        this._trendListViewList[tempIndex].cleanVideoModel();
      } else {
        this
            ._trendListViewList[tempIndex]
            .addMoreVideoModel(_page, _isForce, tempTrendsDataList);
      }
    }
  }

  //========== [ 事件总线 ] ==========
  ///同步礼物列表事件
  StreamSubscription _scriptionSyncGiftList;

  ///前往广告事件
  StreamSubscription _scriptionGotoAd;

  ///请求个人信息事件
  StreamSubscription _scriptionReqUserInfo;

  ///退出App事件
  StreamSubscription _scriptionExitApp;

  ///检测视频播放状态(动态视图通知Home页面)事件
  StreamSubscription _scriptionCheckVideoPlayStateV2H;

  ///WebSocket_接收消息事件
  StreamSubscription _scriptionWebSocketOnData;

  ///WebSocket_错误事件
  StreamSubscription _scriptionWebSocketOnError;

  ///发送消息事件
  StreamSubscription _scriptionSendMsgChat;

  ///发送消息映射表(key:t_id, 临时列表)
  Map<String, ChatModel> _sendChatMap = {};

  ///同步未读事件
  StreamSubscription _scriptionSyncUnread;

  ///保存本地聊天事件
  StreamSubscription _scriptionSaveLocalChat;

  ///初始化事件总线
  void initEventBus() {
    DYEventBus.initDYEventBus();

    //初始化'前往广告'事件
    if (_scriptionSyncGiftList == null) {
      _scriptionSyncGiftList =
          DYEventBus.eventBus.on<SyncGiftList>().listen((event) async {
        ResultData _result =
            await HttpManager.requestPost(context, "System/gifts", null);
        if (_result.result) {
          this._mainModel.giftList = _result.data == null
              ? []
              : DYModelUnit.convertList<GiftModel>(_result.data);
          event.callBack();
        }
      });
    }
    //初始化'前往广告'事件
    if (_scriptionGotoAd == null) {
      _scriptionGotoAd = DYEventBus.eventBus.on<GotoAd>().listen((event) {
        this.gotoAdEvent(event.adType, event.adUrl);
      });
    }
    //初始化'请求个人信息'事件
    if (_scriptionReqUserInfo == null) {
      _scriptionReqUserInfo =
          DYEventBus.eventBus.on<ReqUserInfoEvent>().listen((event) async {
        Map<String, dynamic> tempReqData = {};
        if (Config.token == "" && Config.oauthId == "") {
          tempReqData["oauth_info"] = await DeviceInfoUtil.getDeviceInfo();
        } else if (Config.token == "" && Config.oauthId != "") {
          tempReqData["oauth_id"] = Config.oauthId;
        }
        ResultData _result = await HttpManager.requestPost(
            event.context, "get_current_userinfo", tempReqData);
        if (_result.result) {
          Config.token = _result.data["token"];
          Config.oauthId = _result.data["oauth_id"];
          event.callback(_result.data);
        } else if (_result.code == 403) {
          //清理本地缓存
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove(DyPreferencesKeys.oauthId);
        }
      });
    }
    //初始化'退出App'事件
    if (_scriptionExitApp == null) {
      _scriptionExitApp =
          DYEventBus.eventBus.on<ExitApp>().listen((event) async {
        DYDialogExitApp.showDialog(event.context);
      });
    }
    //初始化'检测视频播放状态'事件
    if (_scriptionCheckVideoPlayStateV2H == null) {
      _scriptionCheckVideoPlayStateV2H = DYEventBus.eventBus
          .on<CheckVideoPlayState_V2H>()
          .listen((event) async {
        bool tempState = false;
        if (!Navigator.of(context).canPop()) {
          if (this._pageValue == 1 || this._pageValue == 2) {
            tempState = true;
            event.callBack(
                tempState, this._keyList[this._pageValue.toInt() - 1]);
          }
        }
      });
    }
    //初始化'WebSocket_接收消息'事件
    if (_scriptionWebSocketOnData == null) {
      _scriptionWebSocketOnData =
          DYEventBus.eventBus.on<WebSocket_OnData>().listen((event) async {
        print("💫>>> webSocket: 接收消息, ${event.content}");
        var tempData = jsonDecode(event.content);
        if (tempData["data"] != null) {
          this.analysisWebsocketData(tempData["data"]);
        }
      });
    }
    //初始化'WebSocket_错误'事件
    if (_scriptionWebSocketOnError == null) {
      _scriptionWebSocketOnError =
          DYEventBus.eventBus.on<WebSocket_OnError>().listen((event) async {});
    }
    //初始化'发送消息'事件
    if (_scriptionSendMsgChat == null) {
      _scriptionSendMsgChat =
          DYEventBus.eventBus.on<SendMsg_Chat>().listen((event) async {
        _sendChatMap[event.t_id] = event.chatModel;
      });
    }
    //初始化'同步未读'事件
    if (_scriptionSyncUnread == null) {
      _scriptionSyncUnread =
          DYEventBus.eventBus.on<SyncUnread>().listen((event) async {
        this.syncUnread(event.from_uuid);
      });
    }
    //初始化'保存本地聊天'事件
    if (_scriptionSaveLocalChat == null) {
      _scriptionSaveLocalChat =
          DYEventBus.eventBus.on<SaveLocalChat>().listen((event) async {
        this.saveLocalChat();
      });
    }
  }

  ///释放事件总线
  void ReleaseEventBus() {
    _scriptionSyncGiftList?.cancel();
    _scriptionSyncGiftList = null;
    _scriptionGotoAd?.cancel();
    _scriptionGotoAd = null;
    _scriptionReqUserInfo?.cancel();
    _scriptionReqUserInfo = null;
    _scriptionExitApp?.cancel();
    _scriptionExitApp = null;
    _scriptionCheckVideoPlayStateV2H?.cancel();
    _scriptionCheckVideoPlayStateV2H = null;
    _scriptionWebSocketOnData?.cancel();
    _scriptionWebSocketOnData = null;
    _scriptionWebSocketOnError?.cancel();
    _scriptionWebSocketOnError = null;
    _scriptionSendMsgChat?.cancel();
    _scriptionSendMsgChat = null;
    _scriptionSyncUnread?.cancel();
    _scriptionSyncUnread = null;
    _scriptionSaveLocalChat?.cancel();
    _scriptionSaveLocalChat = null;
  }

  ///前往广告
  void gotoAdEvent(int _adType, String _adUrl) {
    //  1打开url  2下载安装apk  3无响应
    switch (_adType) {
      case 1:
        this.openUrl(_adUrl);
        break;
      case 2:
        this.openUrl(_adUrl);
        break;
      case 3:
        break;
    }
  }

  ///打开Url
  void openUrl(String _adUrl) async {
    if (await canLaunch(_adUrl)) {
      //打开外部浏览器
      await launch(_adUrl);
    } else {
      //复制更新链接
      ClipboardData data = ClipboardData(text: _adUrl);
      Clipboard.setData(data);
      Toast.toast(context,
          msg: "链接已复制,打开浏览器即可粘贴.", position: ToastPostion.center);
      throw 'Could not launch $_adUrl';
    }
  }

  //========== [ Socket ] ==========
  ///分析websocket数据
  void analysisWebsocketData(var _data) {
    if (_data["action"] != null) {
      print("💫>>>>  接收websocket数据:  $_data");
    }

    if (_data["action"] == "init_msg") {
      this.socketEventInitMsg(_data["data"]);
    } else if (_data["action"] == "new_msg") {
      this.socketEventNewMsg(_data["data"]);
    } else if (_data["action"] == "confirm_msg") {
      this.socketEventConfirmMsg(_data["data"]);
    } else if (_data["action"] == "new_fans") {
      this.socketEventRefreshFLO(_data["data"], 0, 0);
    } else if (_data["action"] == "new_admire") {
      this.socketEventRefreshFLO(0, _data["data"], 0);
    } else if (_data["action"] == "new_opus") {
      this.socketEventRefreshFLO(0, 0, _data["data"]);
    } else if (_data["action"] == "new_notify") {
      this.socketEventNotify(_data["data"]);
    } else if (_data["action"] == "updateUserInfo") {
      this.socketEventUpdateUserInfo(_data["data"]);
    } else if (_data["action"] == "logout") {
      this.socketEventLogout(_data["data"]);
    }
  }

  ///socket事件_初始化消息
  void socketEventInitMsg(_data) {
    if (_data["unread_msg"] != null) {
      this.socketEventUnreadMsg(_data);
    }
    if (_data["system_msg"] != null) {
      this.socketEventSystemMsg(_data["system_msg"]);
    }
    if (_data["service_info"] != null) {
      this.socketEventServiceMsg(_data["service_info"]);
    }
  }

  //========== [ 聊天 ] ==========
  ///socket事件_未读消息
  void socketEventUnreadMsg(_data) {
    //新数量
    this._mainModel.new_fans_count = _data["new_fans_count"];
    this._mainModel.new_admire_count = _data["new_admire_count"];
    this._mainModel.new_opus_count = _data["new_opus_count"];
    //未读消息
    List<ChatModel> _chatList =
        DYModelUnit.convertList<ChatModel>(_data["unread_msg"]);
    this.refreshLoaclChat(_chatList);
    //保存本地聊天
    this.saveLocalChat();
  }

  ///socket事件_系统消息
  void socketEventSystemMsg(_data) {
    ChatModel tempChat = this._mainModel.chatList[0];
    _data.forEach((_item) {
      tempChat.log_list.add(this.changeSystemMsg(_item));
      tempChat.log_count += 1;
    });
    this._mainModel.chatList[0] = tempChat;
    //保存本地聊天
    this.saveLocalChat();
  }

  ///socket事件_客服消息
  void socketEventServiceMsg(_data) {
    ChatModel tempChat = this._mainModel.chatList[1];
    tempChat.nickname = _data["nickname"];
    tempChat.avatarUrl =
        (_data["avatar_url"] != null && _data["avatar_url"] != "")
            ? _data["avatar_url"]
            : tempChat.avatarUrl;
    tempChat.vipLevel = _data["vip_level"];
    tempChat.onlineState = _data["online_state"];
    tempChat.log_count += _data["log_count"];
    List<MessageModel> tempMsgList =
        DYModelUnit.convertList<MessageModel>(_data["log_list"]);
    tempChat.log_list.addAll(tempMsgList);
    this._mainModel.chatList[1] = tempChat;
    //保存本地聊天
    this.saveLocalChat();
  }

  ///socket事件_接收新消息
  void socketEventNewMsg(_data) {
    ChatModel tempChat = new ChatModel();
    tempChat.fromMap(_data);
    this.refreshLoaclChat([tempChat]);
    DYEventBus.eventBus.fire(ReceiveMsg_Chat(tempChat));
    this.saveLocalChat();
  }

  ///socket事件_完成(发送)消息
  void socketEventConfirmMsg(_data) {
    String tempTid = _data["t_id"];
    ChatModel tempSendChat = this._sendChatMap[tempTid];
    MessageModel tempSendMsg = tempSendChat.log_list[0];
    tempSendMsg.msg_id = _data["msg_id"];
    tempSendMsg.createdAt = _data["created_at"];

    ChatModel tempLocalChat;
    this._mainModel.chatList.forEach((_localChat) {
      if (_localChat.from_uuid == tempSendMsg.from_uuid) {
        tempLocalChat = _localChat;
      }
    });
    //发送聊天,取巧2(借用from_uuid字段)
    tempSendMsg.from_uuid = this._mainModel.userModel.uuid;
    tempSendChat.log_list[0] = tempSendMsg;

    if (tempLocalChat == null) {
      //创建新聊天
      this.refreshLoaclChat([tempSendChat]);
    } else {
      //刷新旧聊天
      tempLocalChat.log_list.add(tempSendMsg);
    }

    DYEventBus.eventBus.fire(ReceiveMsg_Chat(tempLocalChat));
    this.saveLocalChat();
  }

  ///刷新本地聊天数据
  void refreshLoaclChat(List<ChatModel> _chatList) {
    _chatList.forEach((_chat) {
      bool isCreate = true;
      this._mainModel.chatList.forEach((_localChat) {
        if (_localChat.from_uuid == _chat.from_uuid) {
          isCreate = false;
          _localChat.nickname = _chat.nickname;
          _localChat.avatarUrl = _chat.avatarUrl;
          _localChat.vipLevel = _chat.vipLevel;
          _localChat.onlineState = _chat.onlineState;
          _localChat.log_count += _chat.log_count;
          _localChat.log_list.addAll(_chat.log_list);
        }
      });

      if (isCreate) {
        this._mainModel.chatList.add(_chat);
      }
    });
  }

  ///同步未读
  void syncUnread(String _fromUuid) async {
    this._mainModel.chatList.forEach((_localChat) {
      if (_localChat.from_uuid == _fromUuid) {
        _localChat.log_count = 0;
      }
    });
    this.saveLocalChat();
  }

  ///保存本地聊天数据
  void saveLocalChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> tempList =
        DYModelUnit.convertListDynamic<ChatModel>(this._mainModel.chatList);
    prefs.setString(DyPreferencesKeys.message, jsonEncode(tempList));
  }

  //========== [ 通知 ] ==========
  ///socket事件_刷新粉丝/点赞/作品
  void socketEventRefreshFLO(int _fan, int _like, int _opu) async {
    this._mainModel.new_fans_count += _fan;
    _mainModel.new_fans_count =
        _mainModel.new_fans_count > 0 ? _mainModel.new_fans_count : 0;
    this._mainModel.new_admire_count += _like;
    _mainModel.new_admire_count =
        _mainModel.new_admire_count > 0 ? _mainModel.new_admire_count : 0;
    this._mainModel.new_opus_count += _opu;
    _mainModel.new_opus_count =
        _mainModel.new_opus_count > 0 ? _mainModel.new_opus_count : 0;
    DYEventBus.eventBus.fire(RefreshFLO());
  }

  ///socket事件_(系统)通知
  void socketEventNotify(_data) async {
    ChatModel tempChat = this._mainModel.chatList[0];
    tempChat.log_list.add(this.changeSystemMsg(_data));
    tempChat.log_count += 1;
    this._mainModel.chatList[0] = tempChat;
    //通知UI
    DYEventBus.eventBus.fire(ReceiveMsg_Chat(tempChat));
    //保存本地聊天
    this.saveLocalChat();
  }

  ///转换系统消息
  MessageModel changeSystemMsg(_data) {
    MessageModel tempMsg = MessageModel();
    tempMsg.msg_id = _data["msg_id"];
    tempMsg.from_uuid = "0";
    tempMsg.type = 0;
    tempMsg.content = _data["content"];
    tempMsg.createdAt = _data["created_at"];
    return tempMsg;
  }

  ///socket事件_更新用户信息
  void socketEventUpdateUserInfo(_data) async {
    //请求个人信息
    DYEventBus.eventBus.fire(ReqUserInfoEvent(context, (_data) async {
      this._mainModel.userModel.fromMap(_data);

      ///持久化缓存
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString(DyPreferencesKeys.token, Config.token);
      // prefs.setString(DyPreferencesKeys.oauthId, Config.oauthId);
    }));
  }

  ///socket事件_登出
  void socketEventLogout(_data) async {
    DYEventBus.eventBus.fire(ExitApp(context));
  }
}
