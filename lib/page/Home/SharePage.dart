import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:douyin/style/DYPhysicalBtnEvtControll.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/Logger.dart';
import 'package:douyin/tools/PermissionTool.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/DYImage.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

///分享页面
class SharePage extends StatefulWidget {
  ///页面状态
  final SharePageState myState = SharePageState();

  ///昵称
  final String avatarUrl;

  ///等级
  final int level;

  ///封面图
  final String thumbImg;

  ///分享标题
  final String affTitle;

  ///分享码
  final String affCode;

  ///分享Url
  final String affUrl;

  ///扩展值(例如:在视频播放界面需要带上'&v=101')
  final String extendValue = "";

  //构造函数
  SharePage(
      {Key key,
      this.avatarUrl,
      this.level,
      this.thumbImg,
      this.affTitle,
      this.affCode,
      this.affUrl,
      extendValue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    //this.myState = SharePageState();
    return this.myState;
  }

  ///播放页面动画
  void playPageAnim(bool _isShow) {
    var self = this;
    if (self.myState != null) {
      self.myState.playPageAnim(_isShow);
    }
  }
}

class SharePageState extends State<SharePage>
    with SingleTickerProviderStateMixin {
  ///是否显示页面
  bool _isShowPage = false;

  ///(页面缩放)动画
  Animation<double> _animation;

  ///(页面缩放)动画控制器
  AnimationController _animController;
  double _opacityValue = 0;

  ///截图对象key
  GlobalKey _rootWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    //初始化一个动画控制器 定义好动画的执行时长
    _animController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    //初始化一个补间动画 实例化一个补间类动画的实例，明确需要变换的区间大小和作用的controller对象
    _animation = Tween<double>(begin: 0, end: 1).animate(_animController);
    //提供方法 为动画添加监听
    _animation.addListener(() {
      //当widget有变化的时候系统调用setstate方法重新绘制widget
      setState(() {
        this._opacityValue = this._animation.value;
      });
    });
    _animController.reset();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        this.buildMark(),
        this.buildMainBg(),
      ],
    );
  }

  ///生成遮罩
  Widget buildMark() {
    return this._isShowPage
        ? InkWell(
            child: Container(
              color: Colors.black45,
            ),
            onTap: this.btnEventClose,
          )
        : Container();
  }

  ///生成主页面
  Widget buildMainBg() {
    String tempUrl = "${widget.affUrl}${widget.affCode}${widget.extendValue}";
    return RepaintBoundary(
      key: this._rootWidgetKey,
      child: Offstage(
        offstage: _opacityValue == 0,
        child: ScaleTransition(
          alignment: Alignment.center,
          scale: this._animController,
          child: Container(
            width: ScreenUtil().setWidth(860),
            height: ScreenUtil().setWidth(1200),
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(90)),
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
            decoration: BoxDecoration(
              color: AppColors.BgColor,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Column(
              children: <Widget>[
                this.buildTop(),
                this.buildConter(tempUrl),
                this.builBtns(tempUrl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///生成顶部
  Widget buildTop() {
    String tempTitle = Tools.cutString(widget.affTitle, 39);
    return Container();
  }

  ///生成内容
  Widget buildConter(String _shareUrl) {
    return Expanded(
      child: Row(),
    );
  }

  ///生成内容_视频
  Widget buildConterVideo() {
    return ClipRRect(
      borderRadius:
          BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10))),
      child: Container(),
    );
  }

  ///生成内容_二维码
  Widget buildConter_QrCode(String _shareUrl) {
    return ClipRRect(
      borderRadius:
          BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10))),
      child: Container(),
    );
  }

  ///生成按钮
  Widget builBtns(String _shareUrl) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(60)),
      child: Row(),
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_关闭
  void btnEventClose() {
    Function tempFunc = DYPhysicalBtnEvtControll.GetPhysicalBtnEvent();
    tempFunc();
  }

  ///按钮事件_保存图片
  void btnEventSaveImg() async {
  }

  ///按钮事件_复制Url
  void btnEventCopyUrl(String _url) {
  }

  //========== [ 辅助函数 ] ==========
  ///保存图片
  void saveImg() async {
  }

  ///播放页面动画
  void playPageAnim(bool _isShow) {
    if (_isShow) {
      //如果是打开窗口,播放动画
      this._animController.reset();
      this._animController.forward();
    } else {
      this._animController.reverse();
    }

    setState(() {
      this._isShowPage = _isShow;
    });
  }
}
