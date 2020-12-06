import 'dart:ui';
import 'package:douyin/config/Config.dart';
import 'package:douyin/model/UserModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/style/DYPhysicalBtnEvtControll.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/HeadWidget.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///用户信息
class UserInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserInfoPageState();
  }
}

class UserInfoPageState extends State<UserInfoPage>
    with SingleTickerProviderStateMixin {
  ///主数据模块
  MainModel _mainModel;

  ///用户数据
  UserModel _userModel;

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///状态栏高度
  double _statusBarHeight = 0;

  ///原始的用户数据(用于提交出错的时候,回滚数据)
  UserModel _normalUserModel;

  ///当前操作类型
  Enum_OptionType _curOptionType = Enum_OptionType.invalid;

  ///动画控制器_弹窗(页面缩放)
  AnimationController _animController_PopWindow;

  ///输入控制器_昵称
  TextEditingController _teController_Nick = TextEditingController();

  ///焦点_昵称
  FocusNode _focusNode_Nick = FocusNode();

  @override
  void initState() {
    super.initState();

    //初始化视图宽度 & 高度
    this._viewWidth = ScreenUtil().setWidth(1080);
    this._statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    this._viewHeight = ScreenUtil().setHeight(1920) - this._statusBarHeight;

    //初始化一个动画控制器 定义好动画的执行时长
    _animController_PopWindow = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      _userModel = model.userModel;
      this.copyUserModel();
      return Scaffold(
        backgroundColor: AppColors.BgColor_Deep,
        body: WillPopScope(
          onWillPop: () async {
            Function tempFunc = DYPhysicalBtnEvtControll.GetPhysicalBtnEvent();
            if (tempFunc != null) {
              tempFunc();
              return false;
            }
            this.btnEventReturn();
            return true;
          },
          child: Container(
            width: this._viewWidth,
            height: this._viewHeight,
            margin: EdgeInsets.only(top: this._statusBarHeight),
            child: this.buildMain(),
          ),
        ),
      );
    });
  }

  Widget buildMain() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        //列表
        Column(
          children: <Widget>[
            this.buildTop(),
            this.buildHead(),
            this.buildList_0(),
            this.buildList_1(),
            this.buildList_2(),
            this.buildList_3(),
          ],
        ),
        //弹窗
        this.buildPopWindow(),
      ],
    );
  }

  ///生成顶部
  Widget buildTop() {
    return Container(
      height: ScreenUtil().setWidth(120),
      color: AppColors.BgColor_Deep,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //返回
          this.buildTopReturn(),
          //标题
          this.buildTopTitle(),
          Container(
            width: ScreenUtil().setWidth(120),
          ),
        ],
      ),
    );
  }

  ///生成顶部_返回
  Widget buildTopReturn() {
    return Container(
      width: ScreenUtil().setWidth(120),
      height: ScreenUtil().setWidth(120),
      alignment: Alignment.center,
      child: InkWell(
        child: Icon(
          Icons.keyboard_arrow_left,
          size: ScreenUtil().setWidth(100),
          color: Colors.white,
        ),
        onTap: this.btnEventReturn,
      ),
    );
  }

  ///生成顶部_标题
  Widget buildTopTitle() {
    return Expanded(
      child: Center(
        child: Text(
          "我的资料",
          style:
              TextStyle(fontSize: ScreenUtil().setSp(50), color: Colors.white),
        ),
      ),
    );
  }

  ///生成头像
  Widget buildHead() {
    String tempImg = Tools.GetImageUrl(this._userModel.avatarUrl);
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(100)),
        width: ScreenUtil().setWidth(350),
        child: Column(
          children: <Widget>[
            //头像
            Container(
              width: ScreenUtil().setWidth(250),
              child: HeadWidget(
                headSize: Size(
                    ScreenUtil().setWidth(250), ScreenUtil().setWidth(250)),
                avatarUrl: tempImg,
                level: this._userModel.vipLevel,
              ),
            ),
            Container(
              height: ScreenUtil().setWidth(10),
            ),
            //提示
            Text(
              "点击更换头像",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(36), color: Colors.white),
            ),
          ],
        ),
      ),
      onTap: this.btnEventHead,
    );
  }

  ///生成列表_0
  Widget buildList_0() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(40),
        left: ScreenUtil().setWidth(40),
        right: ScreenUtil().setWidth(40),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        color: Color(0xff250748),
      ),
      child: Column(
        children: <Widget>[
          this.buildInfoItem("相册", "0", false, () {
            print(">>> 点击 相册");
          }),
        ],
      ),
    );
  }

  ///生成列表_1
  Widget buildList_1() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(40),
        left: ScreenUtil().setWidth(40),
        right: ScreenUtil().setWidth(40),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        color: Color(0xff250748),
      ),
      child: Column(
        children: <Widget>[
          this.buildInfoItem("昵称", this._userModel.nickname, true, () {
            this.showPopWindow(Enum_OptionType.nick);
          }),
          this.buildInfoItem("性别", this._userModel.sex == 1 ? "男" : "女", true,
              () {
            this.showPopWindow(Enum_OptionType.sex);
          }),
          // this.buildInfoItem("生日", this._userModel.birthday.toString(), false, (){this.showPopWindow(Enum_OptionType.birthday);} ),
        ],
      ),
    );
  }

  ///生成列表_2
  Widget buildList_2() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(40),
        left: ScreenUtil().setWidth(40),
        right: ScreenUtil().setWidth(40),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        color: Color(0xff250748),
      ),
      child: Column(
        children: <Widget>[
          this.buildInfoItem("手机号", this._userModel.mobile, true, null),
          // this.buildInfoItem("城市", "", false, (){this.showPopWindow(Enum_OptionType.city);} ),
        ],
      ),
    );
  }

  ///生成列表_3
  Widget buildList_3() {
    String tempSuperior = this._userModel.superiorCode ?? "暂无邀请人";
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(40),
        left: ScreenUtil().setWidth(40),
        right: ScreenUtil().setWidth(40),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        color: Color(0xff250748),
      ),
      child: Column(
        children: <Widget>[
          this.buildInfoItem("我的邀请人", tempSuperior, false, null),
        ],
      ),
    );
  }

  ///生成信息Item
  Widget buildInfoItem(
      String _title, String _conter, bool _haveLine, Function _func) {
    TextStyle tempStyle_Title = TextStyle(
      fontSize: ScreenUtil().setSp(50),
      color: Colors.white70,
    );
    return InkWell(
      child: Container(
        height: ScreenUtil().setWidth(120),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            //
            Row(
              children: <Widget>[
                Container(
                  width: ScreenUtil().setWidth(40),
                ),
                //标题
                Text(_title, style: tempStyle_Title),
                Expanded(child: Container()),
                //内容
                Text(
                  _conter,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(50),
                    color: Colors.white,
                  ),
                ),
                //图标
                _func == null
                    ? Container(
                        width: ScreenUtil().setWidth(100),
                      )
                    : Icon(
                        Icons.keyboard_arrow_right,
                        size: ScreenUtil().setWidth(100),
                        color: Colors.white54,
                      )
              ],
            ),
            //
            Positioned(
              bottom: 0,
              child: !_haveLine
                  ? Container()
                  : Container(
                      width: ScreenUtil().setWidth(900),
                      height: 0.5,
                      color: Colors.white12,
                    ),
            ),
          ],
        ),
      ),
      onTap: () {
        if (_func != null) {
          _func();
        }
      },
    );
  }

  ///生成弹窗
  Widget buildPopWindow() {
    return _curOptionType != Enum_OptionType.invalid
        ? Container(
            width: this._viewWidth,
            height: this._viewHeight,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                //遮罩
                this.buildPopWindow_Mark(),
                //窗口
                ScaleTransition(
                  alignment: Alignment.center,
                  scale: this._animController_PopWindow,
                  child: Container(
                    width: ScreenUtil().setWidth(1000),
                    height: ScreenUtil().setWidth(500),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(20)),
                      color: AppColors.BgColor,
                    ),
                    child: this.buildPopWindow_Content(),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  ///生成弹窗_遮罩
  Widget buildPopWindow_Mark() {
    return InkWell(
      child: Container(
        color: Colors.black54,
      ),
      onTap: this.closePopWindow,
    );
  }

  ///生成弹窗_内容
  Widget buildPopWindow_Content() {
    String tempTitle = "";
    Widget tempContent = Container();
    if (this._curOptionType == Enum_OptionType.nick) {
      tempTitle = "修改昵称";
      tempContent = this.buildPopWindowContentNick();
    } else if (this._curOptionType == Enum_OptionType.sex) {
      tempTitle = "修改性别";
      tempContent = this.buildPopWindowContentSex();
    } else if (this._curOptionType == Enum_OptionType.birthday) {
      tempTitle = "修改生日";
      tempContent = this.buildPopWindowContentBirthday();
    } else if (this._curOptionType == Enum_OptionType.city) {
      tempTitle = "修改城市";
      tempContent = this.buildPopWindowContentCity();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        //标题
        Container(
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(40)),
          child: Text(
            tempTitle,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(50), color: Colors.white),
          ),
        ),
        //内容
        tempContent,
        //按钮
        InkWell(
          child: Container(
            width: ScreenUtil().setWidth(300),
            height: ScreenUtil().setWidth(100),
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(40)),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
              color: Colors.green[400],
            ),
            child: Text(
              "确定",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(44), color: Colors.white),
            ),
          ),
          onTap: this.btnEventChange,
        ),
      ],
    );
  }

  ///生成弹窗_内容_昵称
  Widget buildPopWindowContentNick() {
    return Container(
      width: ScreenUtil().setWidth(700),
      height: ScreenUtil().setWidth(100),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        color: Colors.white24,
      ),
      alignment: Alignment.center,
      child: TextField(
          controller: _teController_Nick,
          focusNode: _focusNode_Nick,
          style:
              TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(44)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 0),
            border: InputBorder.none,
            hintStyle: TextStyle(
                fontSize: ScreenUtil().setSp(44),
                color: Colors.grey,
                textBaseline: TextBaseline.alphabetic),
            hintText: "请输入新昵称",
          ),
          onChanged: (_str) {
            setState(() {});
          }),
    );
  }

  ///生成弹窗_内容_性别
  Widget buildPopWindowContentSex() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        this.buildPopWindowContentSex_Btn(this._userModel.sex, 1),
        Container(
          width: ScreenUtil().setWidth(100),
        ),
        this.buildPopWindowContentSex_Btn(this._userModel.sex, 2),
      ],
    );
  }

  ///生成弹窗_内容_性别_按钮
  Widget buildPopWindowContentSex_Btn(int _curSex, int _sex) {
    bool tempSexIsMan = _sex == 1;
    Color tempColor = _curSex == _sex
        ? tempSexIsMan
            ? Colors.blue[200]
            : Colors.red[200]
        : Colors.grey;
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(150),
        height: ScreenUtil().setWidth(100),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
          color: tempColor,
        ),
        child: Text(
          tempSexIsMan ? "男" : "女",
          style:
              TextStyle(fontSize: ScreenUtil().setSp(50), color: Colors.white),
        ),
      ),
      onTap: () {
        this.btnEventSex(tempSexIsMan);
      },
    );
  }

  ///生成弹窗_内容_生日
  Widget buildPopWindowContentBirthday() {
    return Container();
  }

  ///生成弹窗_内容_城市
  Widget buildPopWindowContentCity() {
    return Container();
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_返回
  void btnEventReturn() {
    Navigator.pop(context);
  }

  ///按钮事件_头像
  void btnEventHead() async {}

  ///按钮事件_性别
  void btnEventSex(bool _isMan) {
    setState(() {
      this._userModel.sex = _isMan ? 1 : 2;
    });
  }

  ///按钮事件_修改(资料)
  void btnEventChange() async {
    Map<String, dynamic> tempReqData = {"birthday": 0};

    if (this._curOptionType == Enum_OptionType.nick) {
      String tempNick = this._teController_Nick.text;
      this._userModel.nickname = tempNick;
      tempReqData["nickname"] = tempNick;
    } else if (this._curOptionType == Enum_OptionType.sex) {
      tempReqData["sex"] = this._userModel.sex;
    }

    setState(() {});
    this.closePopWindow();

    ResultData _result =
        await HttpManager.requestPost(context, "edit_my_info", tempReqData);
    if (_result.result) {
      this._normalUserModel = null;
      this.copyUserModel();
    } else {
      this.resetUserModel();
    }
    this._teController_Nick.clear();
  }

  //========== [ 辅助函数 ] ==========
  ///显示弹窗
  void showPopWindow(Enum_OptionType _type) {
    //添加返回按钮事件
    DYPhysicalBtnEvtControll.AddPhysicalBtnEvent(() {
      setState(() {
        this.resetUserModel();
        this._animController_PopWindow.reverse();
        this._curOptionType = Enum_OptionType.invalid;
      });
    });
    setState(() {
      this._curOptionType = _type;
      this._animController_PopWindow.reset();
      this._animController_PopWindow.forward();
    });
  }

  ///关闭弹窗
  void closePopWindow() {
    Function tempFunc = DYPhysicalBtnEvtControll.GetPhysicalBtnEvent();
    tempFunc();
  }

  ///复制用户数据
  void copyUserModel() {
    if (this._normalUserModel == null) {
      this._normalUserModel = new UserModel();
      this._normalUserModel.nickname = this._userModel.nickname;
      this._normalUserModel.sex = this._userModel.sex;
      this._normalUserModel.birthday = this._userModel.birthday;
    }
  }

  ///恢复用户数据
  void resetUserModel() {
    if (this._normalUserModel != null) {
      this._userModel.nickname = this._normalUserModel.nickname;
      this._userModel.sex = this._normalUserModel.sex;
      this._userModel.birthday = this._normalUserModel.birthday;
    }
    setState(() {});
  }
}

///选项类型
enum Enum_OptionType {
  ///无效
  invalid,

  ///相册
  album,

  ///昵称
  nick,

  ///性别
  sex,

  ///生日
  birthday,

  ///城市
  city
}
