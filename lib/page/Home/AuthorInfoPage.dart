import 'dart:async';
import 'dart:ui';

import 'package:douyin/model/OtherModel.dart';
import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/model/UserModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/page/Other/CollectionPage.dart';
import 'package:douyin/page/Other/LikeListView.dart';
import 'package:douyin/page/Other/MoreImgPage.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/DYImage.dart';
import 'package:douyin/widget/HeadWidget.dart';
import 'package:douyin/widget/trends/SimpleTrendsListView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:douyin/model/MainModel.dart';

///作者信息界面
class AuthorInfoPage extends StatefulWidget {

  ///滑动主页面事件
  final Function(double _dragValue, bool _dragToNext) dragHomePageEvent;

  ///是否需要空出状态栏高度
  final bool needStatusBarHeight;

  ///作者Uuid
  String authorUuid;

  //构造函数
  AuthorInfoPage(
      {Key key,
      this.dragHomePageEvent,
      this.needStatusBarHeight,
      this.authorUuid})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AuthorInfoPageState();

  ///刷新Uuid
  void refreshUuid(String _uuid) {
    this.authorUuid = _uuid;
  }
}

class AuthorInfoPageState extends State<AuthorInfoPage>
    with SingleTickerProviderStateMixin {
  ///主数据模块
  MainModel _mainModel;

  ///用户数据(作者数据)
  UserModel _userModel = UserModel();

  ///视图宽度
  double _viewWidth = 0;

  ///视图高度
  double _viewHeight = 0;

  ///状态栏高度
  double _statusBarHeight = 0;

  ///页面控制器
  PageController _pageController;

  ///是否能拖拽
  bool _canDrag = true;

  ///页面滑动值
  double _pageValue = 0;

  ///动态列表视图列表
  List<SimpleTrendsListView> _trendsListViewList = [null, null];

  ///动态列表key列表
  List<GlobalKey> _trendsListKeyList = [];

  ///作者Uuid
  String _authorUuid;

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
    _viewWidth = ScreenUtil().setWidth(1080);
    _statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    _viewHeight = ScreenUtil().setHeight(1920) - _statusBarHeight;

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
    //初始化作者uuid
    this._authorUuid = widget.authorUuid ?? DyStyleVariable.curVideoAuthorId;

    //请求作者信息
    this.reqAuthorInfo();
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
      return Material(
        color: AppColors.BgColor,
        child: Column(
          children: <Widget>[
            Container(
              width: _viewWidth,
              height: widget.needStatusBarHeight ? _statusBarHeight : 0,
            ),
            this.buildUserInfo(),
            this.buildMore(),
            this.buildPage(),
          ],
        ),
      );
    });
  }

  ///生成用户信息
  Widget buildUserInfo() {
    return Container(
      height: ScreenUtil().setWidth(240),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(25),
          ),
          this.buildUserInfo_Head(),
          Container(
            width: ScreenUtil().setWidth(35),
          ),
          this.buildUserInfoInfo(),
        ],
      ),
    );
  }

  ///生成用户信息_头像
  Widget buildUserInfo_Head() {
    return HeadWidget(
      avatarUrl: this._userModel.avatarUrl,
      headSize: Size(ScreenUtil().setWidth(200), ScreenUtil().setWidth(200)),
      level: 0,
    );
  }

  ///生成用户信息__信息
  Widget buildUserInfoInfo() {
    String tempImgSex = this._userModel.sex == 1
        ? "images/icon_sex_boy.png"
        : "images/icon_sex_girl.png";
    String tempNick = this._userModel.nickname;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
            )
          ],
        ),
        this.buildUserInfoBtns(),
      ],
    );
  }

  ///生成用户信息_按钮
  Widget buildUserInfoBtns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        this.buildUserInfoBtnsFollow(),
        Container(
          width: ScreenUtil().setWidth(20),
        ),
        this.buildUserInfoBtnsMessage(),
      ],
    );
  }

  ///生成用户信息_按钮_关注
  Widget buildUserInfoBtnsFollow() {
    bool tempFollow = this._userModel.hasFollow;
    Color tempColor = tempFollow ? Colors.grey[600] : Color(0xffb541f8);
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          //背景
          Container(
            width: ScreenUtil().setWidth(220),
            height: ScreenUtil().setWidth(80),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
              color: tempColor,
            ),
          ),
          //文字
          Text(
            tempFollow ? "取消关注" : "关注",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(40), color: Colors.white),
          ),
        ],
      ),
      onTap: () {
        this.btnEventFollow(this._userModel.uuid, !tempFollow);
      },
    );
  }

  ///生成用户信息_按钮_私信
  Widget buildUserInfoBtnsMessage() {
    bool tempFollow = this._userModel.hasFollow;
    return tempFollow
        ? InkWell(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                //背景
                Container(
                  width: ScreenUtil().setWidth(220),
                  height: ScreenUtil().setWidth(80),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(20)),
                    color: AppColors.TextColor,
                  ),
                ),
                //文字
                Text(
                  "私信",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(40), color: Colors.white),
                ),
              ],
            ),
            onTap: this.btnEventMessage,
          )
        : Container();
  }

  ///生成更多
  Widget buildMore() {
    return Container(
      // height: ScreenUtil().setWidth(280),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      child: Column(
        children: <Widget>[
          this.buildMoreData(),
          Container(
            height: ScreenUtil().setWidth(30),
          ),
          // this.buildMore_ImgList(),
        ],
      ),
    );
  }

  ///生成更多_数据
  Widget buildMoreData() {
    return Container(
      height: ScreenUtil().setWidth(90),
      child: Row(
        children: <Widget>[
          this.buildMoreDataItem("获赞", this._userModel.beAdmire),
          this.buildMoreDataItem("关注", this._userModel.follows),
          this.buildMoreDataItem("粉丝", this._userModel.fans),
        ],
      ),
    );
  }

  ///生成更多_数据
  Widget buildMoreDataItem(String _title, int _cnt) {
    String tempCnt = Tools.ToString(_cnt, "w", false);
    return Container(
      margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
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

  ///生成页面
  Widget buildPage() {
    return Expanded(
      child: Column(
        children: <Widget>[
          this.buildPageBtns(),
          this.buildPage_View(),
        ],
      ),
    );
  }

  ///生成页面_按钮
  Widget buildPageBtns() {

    return Container();
  }

  ///生成页面_按钮_文本
  Widget buildPageBtnsText(int _index, String _str, double _op) {

    return InkWell(
      child: Container(),
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
      left: ScreenUtil().setWidth(400 + (_pageValue * 300).toInt()),
      child: Container(
        width: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(5),
        color: Color(0xffff3196),
      ),
    );
  }

  ///生成页面_视图
  Widget buildPage_View() {
    return Expanded(
      child: Container()
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
        dragEvent: _index == 0 ? this.dragEvent : null,
        itemEvent: this.trendItemEvent,
      );
    }
    return this._trendsListViewList[_index];
  }

  ///生成页面_视图_合集列表
  Widget buildPageViewCollectionList(List<dynamic> _videoList) {
    return Container();
  }

  ///生成页面_视图_合集Item
  Widget buildPageViewCollectionItem(
      UserCollectionModel _collection, int _index) {
    return InkWell(
      child: Container()
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_更多
  void btnEventMore() {

  }

  ///按钮事件_关注
  void btnEventFollow(String _uuid, bool _hasFollow) async {

  }

  ///按钮事件_私信
  void btnEventMessage() async {

  }

  //========== [ 辅助函数 ] ==========
  ///请求作者信息
  void reqAuthorInfo() async {

  }

  ///拖动事件
  void dragEvent(bool _isLeft, double _dragValue, bool _dragToNext) {
    if (_isLeft) {
      //如果往左,上传给上级事件
      if (widget.dragHomePageEvent != null) {
        widget.dragHomePageEvent(_dragValue, _dragToNext);
      }
    } else {
      //如果往右,触发自身拖动
      if (_dragToNext) {
        this._pageController.animateToPage(1,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      } else {
        this._pageController.jumpTo(-_dragValue);
      }
    }
  }

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
    return [];
  }

  ///获取喜欢列表
  Future<List<TrendsModel>> getLikesList(int _page) async {
    return [];
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
}
