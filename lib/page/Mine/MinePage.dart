import 'dart:ui';

import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/model/UserModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/page/Home/SharePage.dart';
import 'package:douyin/page/Other/LikeListView.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/style/DYPhysicalBtnEvtControll.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/DYImage.dart';
import 'package:douyin/widget/HeadWidget.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:douyin/widget/trends/SimpleTrendsListView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:douyin/model/MainModel.dart';

///我的界面
class MinePage extends StatefulWidget {
  final MinePageState myState = MinePageState();

  ///退出页面回调
  final Function popPageCallBack;

  //构造函数
  MinePage({Key key, this.popPageCallBack}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    //this.myState = MinePageState();
    return this.myState;
  }
}

class MinePageState extends State<MinePage>
    with SingleTickerProviderStateMixin {
  ///主数据模块
  MainModel _mainModel;

  ///用户数据
  UserModel _userModel = UserModel();

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///状态栏高度
  double _statusBarHeight = 0;

  ///(整页)滑动
  ScrollController _scrollController = ScrollController();

  ///分享界面
  SharePage _sharePage;

  ///Tab页控制器
  PageController _pageController = PageController();

  ///页面滑动值
  double _pageValue = 0;

  ///动态列表视图列表
  List<SimpleTrendsListView> _trendsListViewList = [null, null];

  ///动态列表key列表
  List<GlobalKey> _trendsListKeyList = [];

  ///作品列表
  List<TrendsModel> _opusList = [];

  ///喜欢列表
  List<TrendsModel> _likesList = [];

  ///没有数据_作品
  bool _notDateOpus = false;

  ///没有数据_喜欢
  bool _notDateLikes = false;

  @override
  void initState() {
    super.initState();

    //初始化视图宽度 & 高度
    this._viewWidth = ScreenUtil().setWidth(1080);
    this._statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    this._viewHeight = ScreenUtil().setHeight(1920) - this._statusBarHeight;

    _trendsListKeyList = [GlobalKey(), GlobalKey()];
    //初始化页面控制器
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        this._pageValue = _pageController.page;
      });
      if (this._pageValue == 0.0 && _opusList.length == 0) {
        this.reqMoreTrendsData(_trendsListKeyList[0], 1, 0);
      } else if (this._pageValue == 1.0 && _likesList.length == 0) {
        this.reqMoreTrendsData(_trendsListKeyList[1], 1, 1);
      }
    });

    //请求个人信息
    DYEventBus.eventBus.fire(ReqUserInfoEvent(context, (_data) async {
      this._mainModel.userModel.fromMap(_data);
      this._userModel = this._mainModel.userModel;
      setState(() {});
    }));
    //请求作品数据
    this.reqMoreTrendsData(_trendsListKeyList[0], 1, 0);
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
      return WillPopScope(
        onWillPop: () async {
          // 点击返回键的操作
          Function tempFunc = DYPhysicalBtnEvtControll.GetPhysicalBtnEvent();
          if (tempFunc != null) {
            tempFunc();
            return false;
          }
          this.btnEventGotoPlay();
          return true;
        },
        child: Scaffold(
          backgroundColor: AppColors.BgColor,
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // this.buildNestedScrollView(),
              Column(
                children: <Widget>[
                  Container(
                    height: _statusBarHeight,
                  ),
                  this.buildTop(),
                  Container(
                    width: this._viewWidth,
                    height: this._viewHeight - ScreenUtil().setWidth(320),
                    child: this.buildNestedScrollView(),
                  ),
                ],
              ),
              this.builQuickBtn(),
              this.buildSharePage(),
              this.buildUploadBtn(),
            ],
          ),
        ),
      );
    });
  }

  //生成嵌套滚动视图
  Widget buildNestedScrollView() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            backgroundColor: AppColors.BgColor,
            leading: Container(),
            centerTitle: true,
            //设置该属性使 Appbar 折叠后不消失
            pinned: true,
            expandedHeight: ScreenUtil().setWidth(350 + 100) + _statusBarHeight,
            forceElevated: true,
            bottom: PreferredSize(
                child: Container(
                  color: AppColors.BgColor,
                  child: this.buildPageBtns(),
                ),
                preferredSize: Size(double.infinity, ScreenUtil().setWidth(0))),
            //通过这个属性设置 AppBar 的背景
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              // 背景折叠动画
              collapseMode: CollapseMode.parallax,
              background: Container(
                color: AppColors.BgColor,
                child: Column(
                  children: <Widget>[
                    // this.buildTop(),
                    this.buildOption(),
                    this.buildMore(),
                  ],
                ),
              ),
            ),
          )
        ];
      },
      body: Container(
        color: AppColors.BgColor,
        child: PageView(
          controller: _pageController,
          children: <Widget>[
            this.buildPageViewVideoList(0, 0, 1, _opusList),
            this.buildPageViewVideoList(1, 1, 1, _likesList),
          ],
        ),
      ),
    );
  }

  ///生成快捷按钮
  Widget builQuickBtn() {
    return Positioned(
      left: 0,
      bottom: ScreenUtil().setWidth(370),
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: Image.asset(
              "images/mine/icon_gotoplay.png",
              width: ScreenUtil().setWidth(150),
            ),
            onTap: this.btnEventGotoPlay,
          ),
          Container(
            height: ScreenUtil().setWidth(100),
          ),
          GestureDetector(
            child: Image.asset(
              "images/mine/icon_gotomsg.png",
              width: ScreenUtil().setWidth(150),
            ),
            onTap: this.btnEventGotoMsg,
          ),
        ],
      ),
    );
  }

  ///生成上传按钮
  Widget buildUploadBtn() {
    return Positioned(
      bottom: ScreenUtil().setWidth(60),
      child: Opacity(
        opacity: 1 - this._pageValue,
        child: ClipOval(
          child: InkWell(
            child: Container(
              width: ScreenUtil().setWidth(150),
              height: ScreenUtil().setWidth(150),
              color: AppColors.TextColor,
              child: Icon(
                Icons.backup,
                color: Colors.white,
                size: ScreenUtil().setWidth(100),
              ),
            ),
            onTap: this.btnEventUpload,
          ),
        ),
      ),
    );
  }

  ///生成顶部
  Widget buildTop() {
    return InkWell(
      child: Container(
        height: ScreenUtil().setWidth(320),
        child: Column(
          children: <Widget>[
            Container(
              height: ScreenUtil().setWidth(240),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  this.buildTopUserInfo(),
                  // this.buildTopCompilation(),
                  this.buildTopTest(),
                ],
              ),
            ),
            this.buildTopSign(),
          ],
        ),
      ),
      onTap: this.btnEventUserInfo,
    );
  }

  ///生成顶部_用户信息
  Widget buildTopUserInfo() {
    String tempImg = Tools.GetImageUrl(this._userModel.avatarUrl);
    return Positioned(
      left: ScreenUtil().setWidth(10),
      child: Container(
        width: ScreenUtil().setWidth(680),
        height: ScreenUtil().setWidth(200),
        child: Row(
          children: <Widget>[
            HeadWidget(
              headSize:
                  Size(ScreenUtil().setWidth(180), ScreenUtil().setWidth(180)),
              avatarUrl: tempImg,
              level: this._userModel.vipLevel,
            ),
            Container(
              width: ScreenUtil().setWidth(20),
            ),
            this.buildTopUserInfoInfo(),
          ],
        ),
      ),
    );
  }

  ///生成顶部_用户信息_信息
  Widget buildTopUserInfoInfo() {
    String tempImgSex = this._userModel.sex == 1
        ? "images/icon_sex_boy.png"
        : "images/icon_sex_girl.png";
    String tempNick = this._userModel.nickname;
    String tempStrVip, tempStrFree = "";
    if (this._userModel.vipExpires != null) {
      tempStrVip = "VIP到期时间:  ${this._userModel.vipExpires}";
      tempStrFree = "";
    } else {
      tempStrVip = this._userModel.vipLevel > 0 ? "已到期" : "";
      if (this._userModel.freeViewTime != null) {
        tempStrFree = "免费观看时间:  ${this._userModel.freeViewTime}";
      } else {
        tempStrFree =
            "免费观看次数:  ${this._mainModel.todayWatchCount} / ${this._mainModel.configModel.freeWatchCount}";
      }
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //性别&昵称
          Row(
            children: <Widget>[
              //性别
              Image.asset(
                tempImgSex,
                width: ScreenUtil().setWidth(30),
              ),
              //昵称
              Container(
                width: ScreenUtil().setWidth(20),
              ),
              Text(
                tempNick,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(42), color: Colors.white),
              ),
            ],
          ),
          //年龄
          // Text("0岁",
          //   style: TextStyle(fontSize: ScreenUtil().setSp(28), color: Colors.white),),
          //VIP时间
          tempStrVip == ""
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Text(
                  tempStrVip,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(34),
                      color: AppColors.TextColor),
                ),
          tempStrFree == ""
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Text(
                  tempStrFree,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(34), color: Colors.white),
                ),
        ],
      ),
    );
  }

  ///生成顶部_合集
  Widget buildTopCompilation() {
    return Positioned(
      right: ScreenUtil().setWidth(10),
      child: GestureDetector(
        child: Container(
          width: ScreenUtil().setWidth(340),
          height: ScreenUtil().setWidth(86),
          child: Image.asset("images/mine/info_btn_compilation.png"),
        ),
        onTap: () {
          this.btnEventCompilation();
        },
      ),
    );
  }

  ///生成顶部_签名
  Widget buildTopSign() {
    String tempSign = "这个家伙很懒,什么都没留下!";
    return Container(
      width: ScreenUtil().setWidth(1030),
      height: ScreenUtil().setWidth(60),
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      child: Text(
        tempSign,
        style: TextStyle(fontSize: ScreenUtil().setSp(36), color: Colors.white),
      ),
    );
  }

  ///生成顶部_测试
  Widget buildTopTest() {
    return Positioned(
      right: ScreenUtil().setWidth(40),
      child: GestureDetector(
        child: Container(
          width: ScreenUtil().setWidth(340),
          height: ScreenUtil().setWidth(86),
          alignment: Alignment.center,
          color: Colors.red[200],
          child: Text(
            "测试",
          ),
        ),
        onTap: () {
          this.btnEventTest();
        },
      ),
    );
  }

  ///生成操作
  Widget buildOption() {
    return Container(
      height: ScreenUtil().setWidth(330),
      margin: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(20),
          horizontal: ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        color: Colors.white24,
      ),
      child: Column(
        children: <Widget>[
          this.buildOptionBtnList(),
          this.buildOptionLine(),
          this.buildOptionBalance(),
        ],
      ),
    );
  }

  ///生成操作_按钮列表
  Widget buildOptionBtnList() {
    return Container(
      height: ScreenUtil().setWidth(180),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          //Vip
          this.buildOptionBtnItem(
              "images/mine/option_vip.png", this.btnEventVip),
          //分享
          this.buildOptionBtnItem(
              "images/mine/option_share.png", this.btnEventShare),
          //加群
          this.buildOptionBtnItem(
              "images/mine/option_addgroup.png", this.btnEventAddGroup),
          //代理
          this.buildOptionBtnItem(
              "images/mine/option_agent.png", this.btnEventAgent),
        ],
      ),
    );
  }

  ///生成操作_按钮Item
  Widget buildOptionBtnItem(String _img, Function _func) {
    return Container(
      width: ScreenUtil().setWidth(140),
      height: ScreenUtil().setWidth(120),
      child: GestureDetector(
        child: Image.asset(
          _img,
          fit: BoxFit.fill,
        ),
        onTap: _func,
      ),
    );
  }

  ///生成操作_直线
  Widget buildOptionLine() {
    return Container(
      height: ScreenUtil().setWidth(1),
      color: Colors.black,
    );
  }

  ///生成操作_余额
  Widget buildOptionBalance() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //钻石
            this.buildOptionBalanceDiamonds(),
            //充值 & 提现
            this.buildOptionBalanceRecharge(),
          ],
        ),
      ),
    );
  }

  ///生成操作_余额_钻石
  Widget buildOptionBalanceDiamonds() {
    String tempBalance = Tools.ToString(this._userModel.balance, "", true);
    return Container(
      width: ScreenUtil().setWidth(440),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //标题
          Container(
            height: ScreenUtil().setWidth(36),
            child: Row(
              children: <Widget>[
                Container(
                  width: ScreenUtil().setWidth(10),
                ),
                Image.asset(
                  "images/mine/option_diamond.png",
                  fit: BoxFit.fill,
                  width: ScreenUtil().setWidth(30),
                  height: ScreenUtil().setWidth(28),
                ),
                Container(
                  width: ScreenUtil().setWidth(10),
                ),
                Text("钻石",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(24), color: Colors.white)),
              ],
            ),
          ),
          //余额
          Container(
            height: ScreenUtil().setWidth(60),
            alignment: Alignment.topLeft,
            child: Text(tempBalance,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    color: Color(0xffffb047),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  ///生成操作_余额_充值
  Widget buildOptionBalanceRecharge() {
    return Container(
      width: ScreenUtil().setWidth(474),
      child: Row(
        children: <Widget>[
          this.buildOptionBalanceRechargeBtn("充值", Color(0xff3cbde8), true),
          this.buildOptionBalanceRechargeBtn("提现", Colors.transparent, false),
        ],
      ),
    );
  }

  ///生成操作_余额_充值_按钮
  Widget buildOptionBalanceRechargeBtn(
      String _text, Color _btnColor, bool _isLeft) {
    return Container(
      width: ScreenUtil().setWidth(237),
      height: ScreenUtil().setWidth(80),
      child: FlatButton(
        color: _btnColor,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_isLeft ? 16 : 0),
                bottomLeft: Radius.circular(_isLeft ? 16 : 0),
                topRight: Radius.circular(_isLeft ? 0 : 16),
                bottomRight: Radius.circular(_isLeft ? 0 : 16)),
            side: BorderSide(
                color: Color(0xff3cbde8), style: BorderStyle.solid, width: 1)),
        child: Text(
          _text,
          style: TextStyle(fontSize: ScreenUtil().setSp(44)),
        ),
        onPressed: () {
          if (_isLeft) {
            this.btnEventRecharge();
          } else {
            this.btnEventCash();
          }
        },
      ),
    );
  }

  ///生成更多
  Widget buildMore() {
    return Container(
      // height: ScreenUtil().setWidth(280),
      height: ScreenUtil().setWidth(80),
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      child: Column(
        children: <Widget>[
          this.buildMoreData(),
          // Container(height: ScreenUtil().setWidth(30),),
          // this.buildMore_ImgList(),
        ],
      ),
    );
  }

  ///生成更多_数据
  Widget buildMoreData() {
    return Container(
      height: ScreenUtil().setWidth(80),
      child: Row(
        children: <Widget>[
          this.buildMoreDataItem("获赞", this._userModel.beAdmire, null),
          this.buildMoreDataItem(
              "关注", this._userModel.follows, this.btnEventGotoFollow),
          this.buildMoreDataItem(
              "粉丝", this._userModel.fans, this.btnEventGotoFans),
        ],
      ),
    );
  }

  ///生成更多_数据
  Widget buildMoreDataItem(String _title, int _cnt, Function _ontap) {
    String tempCnt = Tools.ToString(_cnt, "w", false);
    return InkWell(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
        child: Row(
          children: <Widget>[
            Text(
              tempCnt,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(44), color: Colors.white),
            ),
            Container(
              width: ScreenUtil().setWidth(16),
            ),
            Text(
              _title,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(44), color: Color(0xff7b757f)),
            ),
          ],
        ),
      ),
      onTap: _ontap,
    );
  }

  ///生成更多_图片列表
  Widget buildMore_ImgList() {
    return GestureDetector(
      child: Container(
        height: ScreenUtil().setWidth(150),
        child: Row(
          children: <Widget>[
            Container(width: ScreenUtil().setWidth(10)),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: this._userModel.photo.length,
                itemBuilder: (BuildContext _context, int _index) {
                  return this.buildMoreImgItem(this._userModel.photo[_index]);
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text("更多",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          color: Colors.white)),
                  Icon(Icons.keyboard_arrow_right,
                      size: ScreenUtil().setSp(60), color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        this.btnEventMore();
      },
    );
  }

  ///生成更多_图片Item
  Widget buildMoreImgItem(UserPhotoModel _photo) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(11)),
      width: ScreenUtil().setWidth(160),
      height: ScreenUtil().setWidth(160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        color: Colors.white,
      ),
      child: Container(
        width: ScreenUtil().setWidth(160),
        height: ScreenUtil().setWidth(160),
        child: DYImage(
          imageUrl: _photo.url,
        ),
      ),
    );
  }

  ///生成页面_按钮
  Widget buildPageBtns() {
    String tempWorkCnt = Tools.ToString(this._userModel.videoCount, "w", false);
    String tempLikeCnt = Tools.ToString(this._userModel.likes, "w", false);
    /*String tempRecordCnt =
        Tools.ToString(this._userModel.collection.length, "w", false);*/
    //换算页面滑动值_Tab页
    double tempPageValueTab1, tempPageValueTab2 = 0; //, tempPageValueTab3
    tempPageValueTab1 = _pageValue > 1 ? 0 : 1 - _pageValue;
    tempPageValueTab2 = _pageValue <= 1 ? _pageValue : 1 - (_pageValue - 1);
    //tempPageValueTab3 = _pageValue <= 1 ? 0 : _pageValue - 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(90)),
      height: ScreenUtil().setWidth(100),
      child: Stack(
        children: <Widget>[
          //底部指示滑块
          this.buildPageBtnsSlider(_pageValue - 1),
          //按钮
          Row(
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(150),
              ),
              this.buildPageBtnsText(0, "作品 $tempWorkCnt", tempPageValueTab1),
              this.buildPageBtnsText(1, "喜欢 $tempLikeCnt", tempPageValueTab2),
              // this.buildPageBtnsText(2, "合集 ${tempRecordCnt}", tempPageValueTab3),
              Container(
                width: ScreenUtil().setWidth(150),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///生成页面_按钮_文本
  Widget buildPageBtnsText(int _index, String _str, double _op) {
    _op = _op < 0 ? 0 : _op;
    _op = _op > 1 ? 1 : _op;
    Gradient _gradient =
        LinearGradient(colors: [Color(0xfffff3196), Color(0xffff9d9c)]);
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(300),
        height: ScreenUtil().setHeight(100),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            //白色垫底
            Text(
              _str,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40), color: Colors.white),
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
                      fontSize: ScreenUtil().setSp(40), color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        this._pageController.animateToPage(_index,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      },
    );
  }

  ///生成页面_按钮_滑块
  Widget buildPageBtnsSlider(double _pageValue) {
    return Positioned(
      bottom: 0,
      left: ScreenUtil().setWidth(400 + 150 + (_pageValue * 300).toInt()),
      child: Container(
        width: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(5),
        color: Color(0xffff3196),
      ),
    );
  }

  ///生成页面_视图_视频列表
  Widget buildPageViewVideoList(
      int _index, int _category, int _curPage, List<TrendsModel> _trendsList) {
    if (this._trendsListViewList[_index] == null) {
      this._trendsListViewList[_index] = SimpleTrendsListView(
        key: _trendsListKeyList[_index],
        category: _category,
        curPage: _curPage,
        dataList: _trendsList,
        reqMoreDataEvent: this.reqMoreTrendsData,
        itemEvent: this.trendItemEvent,
      );
      this._trendsListViewList[_index].injScrollController(
          this._scrollController,
          ScreenUtil().setWidth(300 + 330 + 280 + 120) + _statusBarHeight);
    }
    return this._trendsListViewList[_index];
  }

  ///生成分享界面
  Widget buildSharePage() {
    if (this._sharePage == null) {
      this._sharePage = SharePage(
        avatarUrl: this._userModel.avatarUrl,
        level: this._userModel.vipLevel,
        thumbImg: null,
        affTitle: this._mainModel.configModel.affTitle,
        affCode: this._userModel.inviteCode,
        affUrl: this._mainModel.configModel.inviteUrl,
        extendValue: "",
      );
    }
    return this._sharePage;
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_用户信息
  void btnEventUserInfo() {}

  ///按钮事件_合集
  void btnEventCompilation() {}

  ///按钮事件_测试
  void btnEventTest() async {}

  ///按钮事件_加群
  void btnEventAddGroup() async {
    DYEventBus.eventBus.fire(GotoAd(1, this._mainModel.configModel.tgGroup));
  }

  ///按钮事件_Vip
  void btnEventVip() {}

  ///按钮事件_上传
  void btnEventUpload() {}

  ///按钮事件_分享
  void btnEventShare() {}

  ///按钮事件_代理
  void btnEventAgent() async {}

  ///按钮事件_充值
  void btnEventRecharge() {}

  ///按钮事件_提现
  void btnEventCash() {}

  ///按钮事件_前往关注
  void btnEventGotoFollow() {}

  ///按钮事件_前往粉丝
  void btnEventGotoFans() {}

  ///按钮事件_更多
  void btnEventMore() {}

  ///按钮事件_前往播放
  void btnEventGotoPlay() {}

  ///按钮事件_前往邮件
  void btnEventGotoMsg() {}

  //========== [ 辅助函数 ] ==========
  ///请求更多动态数据
  void reqMoreTrendsData(GlobalKey _key, int _page, int _category) async {
    // int tempIndex = _key == this._trendsListKeyList[0] ? 0 : 1;
    List<TrendsModel> tempDataList = [];
    if (_category == 0) {
      tempDataList = await this.getOpusList(_page);
      if (_page == 1) {
        this._opusList = tempDataList;
      } else {
        this._opusList.addAll(tempDataList);
      }
    }
    if (_category == 1) {
      tempDataList = await this.getLikesList(_page);
      if (_page == 1) {
        this._likesList = tempDataList;
      } else {
        this._likesList.addAll(tempDataList);
      }
    }

    if (this._pageValue == _category) {
      this._trendsListViewList[_category].addMoreData(tempDataList);
    }
  }

  ///获取作品列表
  Future<List<TrendsModel>> getOpusList(int _page) async {
    if (this._notDateOpus) {
      return [];
    }
    List<TrendsModel> tempDataList = [];
    ResultData _result = await HttpManager.requestPost(
        context, "/opus", {"uuid": this._userModel.uuid, "page": _page});
    if (_result.result) {
      setState(() {
        this._notDateOpus = _result.data["page"] == 0;
      });
      if (_result.data["data"] != null) {
        _result.data["data"].forEach((_data) {
          TrendsModel tempData = TrendsModel();
          tempData.fromMap(_data);
          tempDataList.add(tempData);
        });
      }
    }
    return tempDataList;
  }

  ///获取喜欢列表
  Future<List<TrendsModel>> getLikesList(int _page) async {
    if (this._notDateLikes) {
      return [];
    }
    List<TrendsModel> tempDataList = [];
    ResultData _result = await HttpManager.requestPost(
        context, "/likes", {"uuid": this._userModel.uuid, "page": _page});
    if (_result.result) {
      setState(() {
        this._notDateLikes = _result.data["page"] == 0;
      });
      if (_result.data["data"] != null) {
        _result.data["data"].forEach((_data) {
          TrendsModel tempData = TrendsModel();
          tempData.fromMap(_data);
          tempDataList.add(tempData);
        });
      }
    }
    return tempDataList;
  }

  ///动态Item事件(作品/喜欢)
  void trendItemEvent(int _type, int _id) {
    List<TrendsModel> tempTrendsModelList = [];
    if (_type == 0) {
      tempTrendsModelList = this._opusList;
    } else if (_type == 1) {
      tempTrendsModelList = this._likesList;
    }
    int tempPgaeIndex = 0;
    for (int i = 0; i < tempTrendsModelList.length; i++) {
      if (tempTrendsModelList[i].id == _id) {
        tempPgaeIndex = i;
        break;
      }
    }

    Widget tempPage = LikeListView(
      uuid: this._userModel.uuid,
      curPageIndex: tempPgaeIndex,
      trendsModelList: this._likesList,
    );

    DyStyleVariable.keyCurVideoList = null;
    DyStyleVariable.keyCurVideoPage = null;
    DyStyleVariable.keyCurVideoView = null;
    //跳转页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ScopedModel<MainModel>(
          model: this._mainModel,
          child: tempPage,
        );
      }),
    );
  }

  ///绑定成功回调
  void bindSucCallBack() {
    Toast.toast(context, msg: "绑定成功", position: ToastPostion.center);
  }

  ///提现成功回调
  void cashOutSucCallBack() {
    Toast.toast(context, msg: "提现成功", position: ToastPostion.center);
  }
}
