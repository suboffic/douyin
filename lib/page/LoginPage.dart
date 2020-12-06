import 'package:douyin/config/Config.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/translations/translations.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:douyin/widget/DYDialogCode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:douyin/model/MainModel.dart';
import 'package:douyin/page/MainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* 登录页面 */
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  BuildContext _buildContext;
  MainModel _mainModel;
  /* 上次按返回键时间 */
  DateTime lastPopTime;
  /* 点击Tip次数 */
  int clickTipCount = 0;

  /* 当前服务器下标 */
  int _curServerUrlIndex = 0;

  /* 选择国家代码 */
  String _selectCountryCode = "+86";
  /* 手机号控制器 */
  TextEditingController _phoneController = TextEditingController();
  /* 手机号焦点 */
  FocusNode _phoneFocusNode = FocusNode();

  // 释放掉Timer
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext buildContext) {
    //初始化数据
    ScreenUtil.init(context,
        designSize: Size(1080, 1920), allowFontScaling: false);
    //ScreenUtil.instance = ScreenUtil(width: 1080, height: 1920)..init(context);
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _buildContext = context;
      _mainModel = model;
      return WillPopScope(
        child: buildScaffold(),
        onWillPop: () async {
          // 点击返回键的操作
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
    });
  }

  Widget buildScaffold() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(80)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildTitle(),
              buildTextField(),
              buildLoginBtn(),
              buildLoginBtnTip(),
            ],
          ),
        ),
      ),
    );
  }

  /* 标题 */
  Widget buildTitle() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: ScreenUtil().setHeight(150),
          ),
          Center(
            child: Image.asset("images/logo.png"),
          ),
          Container(
            height: ScreenUtil().setHeight(80),
          ),
          Text(Translations.of(context).text("login_title"),
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.blue,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal)),
          Container(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(16),
                left: ScreenUtil().setHeight(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.info,
                  color: Colors.red,
                  size: ScreenUtil().setWidth(40),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(12)),
                  child: Container(
                    width: ScreenUtil().setWidth(800),
                    child: Text(
                      Translations.of(context).text("login_title_tip"),
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(36),
                          color: Colors.red,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* 输入框 */
  Widget buildTextField() {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(70)),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(6)),
      width: ScreenUtil().setWidth(920),
      height: ScreenUtil().setHeight(104),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black54, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(200),
            height: ScreenUtil().setHeight(60),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border:
                  Border(right: BorderSide(color: Colors.black54, width: 0.5)),
            ),
            child: Text(
              _selectCountryCode,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(44), color: Colors.blue),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
              child: TextField(
                  // maxLength: 20,
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  style: TextStyle(
                      color: Colors.black, fontSize: ScreenUtil().setSp(44)),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 0),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(44),
                        color: Colors.grey,
                        textBaseline: TextBaseline.alphabetic),
                    hintText:
                        Translations.of(context).text("login_phone_hintText"),
                  ),
                  onChanged: (_str) {}),
            ),
          ),
        ],
      ),
    );
  }

  /* 登录按钮 */
  Widget buildLoginBtn() {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(90)),
      child: MaterialButton(
        minWidth: ScreenUtil().setWidth(920),
        height: ScreenUtil().setHeight(120),
        color: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          Translations.of(context).text("login_loginbtn_text"),
          style:
              TextStyle(fontSize: ScreenUtil().setSp(48), color: Colors.white),
        ),
        onPressed: () {
          loginBtnEvent();
        },
      ),
    );
  }

  /* 登录按钮小提示 */
  Widget buildLoginBtnTip() {
    return Container(
      width: ScreenUtil().setWidth(920),
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
      alignment: Alignment.centerRight,
      child: Container(
        child: InkWell(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("首次登陆自动注册",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(30), color: Colors.grey)),
                Text("版本号 : v${Config.localVersionName}",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(30), color: Colors.grey)),
              ],
            ),
          ),
          onTap: () {
            this.clickTipCount++;
            if (this.clickTipCount >= 5) {
              this.clickTipCount = 0;
              this.showAdministratorsPanel();
            }
          },
        ),
      ),
    );
  }

  /* 登录按钮事件 */
  void loginBtnEvent() {
    //验证手机号码正确性(如果不通过,不允许进行下一步)
    if (this._selectCountryCode == "+86") {
      if (!RegExp(
              '^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$')
          .hasMatch(this._phoneController.text)) {
        Toast.toast(context, msg: "请输入正确手机号码", position: ToastPostion.center);
        return;
      }
    } else {
      if (this._phoneController.text.length < 8) {
        Toast.toast(context, msg: "请输入正确手机号码", position: ToastPostion.center);
        return;
      }
    }
    //显示验证码
    DYDialogCode.showDialogCode(context, this._phoneController.text, 0,
        (String _code) {
      this.sendLogin(this._phoneController.text, _code);
    });
  }

  /* 发送登录 */
  void sendLogin(String _phone, String _code) async {
    ResultData _result = await HttpManager.requestPost(
        context, "/any/auth", {"cellphone": _phone, "sms_code": _code});
    if (_result.result && this.mounted) {
      // 持久化存储token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(DyPreferencesKeys.token, _result.data);
      Config.token = _result.data;
      loginSuccess();
    }
  }

  /* 登录成功 */
  void loginSuccess() {
    Navigator.pushAndRemoveUntil(
      this._buildContext,
      MaterialPageRoute(builder: (context) {
        return ScopedModel<MainModel>(
          model: this._mainModel,
          child: MainPage(),
        );
      }),
      (Route<dynamic> route) => false,
    );
  }

  /* 获取配置信息 */
  void getOreInfo() async {
    // ResultData _result = await HttpManager.requestPost(context, "/any/config", null);
    // if (_result.result && this.mounted) {
    //   Toast.toast(context, msg: "服务器地址切换为:\n${Config.serverUrl}", position: ToastPostion.bottom, showTime: 2000);
    //   this._mainModel.configModel.fromJson(_result.data);
    //   setState(() {  });
    // }
  }

//========== [ 管理员面板 ] ==========
  /* 是否显示管理密码 */
  bool adm_IsShowAdminitPwd = true;
  /* 密码_控制器 */
  TextEditingController adm_pwdController = TextEditingController();
  /* 密码_焦点 */
  FocusNode adm_pwdFocusNode = FocusNode();

  /* 服务器地址_控制器 */
  TextEditingController adm_urlController = TextEditingController();
  /* 服务器地址_焦点 */
  FocusNode adm_urlFocusNode = FocusNode();
  /* 输入服务器地址 */
  String inputServerUrl = "";

  /* 显示管理员面板 */
  void showAdministratorsPanel() {
    showCupertinoDialog(
        context: context,
        builder: (_context) {
          return StatefulBuilder(builder: (context, state) {
            return CupertinoAlertDialog(
              title: Text(
                '',
                style: TextStyle(fontSize: ScreenUtil().setSp(40)),
              ),
              content: Card(
                elevation: 0.0,
                child: adm_IsShowAdminitPwd
                    ? buildAdminitPanel_Pwd()
                    : buildAdminitPanelTools(state),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    setState(() {
                      this.adm_pwdController.clear();
                      this.adm_IsShowAdminitPwd = true;
                    });
                    Navigator.pop(_context);
                  },
                  child: Text('取消'),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    this.adm_ComfirmBtnEvent(state, () {
                      Navigator.pop(_context);
                    });
                  },
                  child: Text('确定'),
                ),
              ],
            );
          });
        });
  }

  /* 生成管理面板_密码 */
  Widget buildAdminitPanel_Pwd() {
    return Container(
      child: TextField(
        controller: adm_pwdController,
        focusNode: adm_pwdFocusNode,
        textAlign: TextAlign.start, //文本对齐方式
        style: TextStyle(fontSize: ScreenUtil().setSp(40), color: Colors.black),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 0),
          // border: InputBorder.none,
          hintStyle: TextStyle(fontSize: ScreenUtil().setSp(40)),
          hintText: "",
        ),
      ),
    );
  }

  /* 生成管理面板_工具 */
  Widget buildAdminitPanelTools(Function _state) {
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            RadioListTile<String>(
              dense: true,
              value: Config.serverUrl_Debug,
              title: Text(
                Config.serverUrl_Debug,
                style: TextStyle(fontSize: ScreenUtil().setSp(30)),
              ),
              groupValue: Config.serverUrl,
              onChanged: (value) {
                if (_state != null) {
                  _state(() {
                    Config.serverUrl = value;
                  });
                }
              },
            ),
            RadioListTile<String>(
              dense: true,
              value: Config.serverUrl_Release,
              title: Text(
                Config.serverUrl_Release,
                style: TextStyle(fontSize: ScreenUtil().setSp(30)),
              ),
              groupValue: Config.serverUrl,
              onChanged: (value) {
                if (_state != null) {
                  _state(() {
                    Config.serverUrl = value;
                  });
                }
              },
            ),
            TextField(
              controller: adm_urlController,
              focusNode: adm_urlFocusNode,
              textAlign: TextAlign.start, //文本对齐方式
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40), color: Colors.black),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 0),
                // border: InputBorder.none,
                hintStyle: TextStyle(fontSize: ScreenUtil().setSp(40)),
                hintText: "请输入链接服务器地址",
              ),
              onChanged: (_text) {
                _text = _text.indexOf("http") < 0 ? 'http://$_text' : _text;
                _state(() {
                  Config.serverUrl = _text;
                });
              },
            ),
            Container(
              height: ScreenUtil().setHeight(50),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: Config.isDebug,
                    activeColor: Colors.greenAccent,
                    // title: Text("是否开启Debug模式", style: TextStyle(fontSize: ScreenUtil().setSp(40)),),
                    onChanged: (value) {
                      _state(() {
                        Config.isDebug = value;
                      });
                    },
                  ),
                  Text(
                    "是否开启Debug模式",
                    style: TextStyle(fontSize: ScreenUtil().setSp(36)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /* 管理员_确认按钮事件 */
  void adm_ComfirmBtnEvent(Function _state, Function _closePanelFunc) async {

  }
}
