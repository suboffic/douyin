import 'package:douyin/model/MainModel.dart';
import 'package:douyin/model/UserModel.dart';
import 'package:douyin/net/Api.dart';
import 'package:douyin/net/ResultData.dart';
import 'package:douyin/style/DYEventBus.dart';
import 'package:douyin/style/Style.dart';
import 'package:douyin/tools/Tools.dart';
import 'package:douyin/widget/Toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scoped_model/scoped_model.dart';

///动态礼物页面
class TrendGiftPage extends StatefulWidget {
  ///页面状态
  final TrendGiftPageState myState = TrendGiftPageState();

  ///动态id
  final int trendsId;

  //构造函数
  TrendGiftPage({Key key, this.trendsId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    //this.myState = TrendGiftPageState();
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

class TrendGiftPageState extends State<TrendGiftPage>
    with TickerProviderStateMixin {
  ///主数据模块
  MainModel _mainModel;

  ///用户数据
  UserModel _userModel;

  ///弹窗高度(用于动画等)
  int _popWindowHeight = 700;

  ///是否显示页面
  bool _isShowPage = false;

  ///(页面位移)动画
  Animation<double> _animation;
  ///(礼物缩放)动画
  AnimationController _giftAnimController;

  ///(页面位移)动画控制器
  AnimationController _animController;

  ///礼物列表
  List<GiftModel> _giftList = [];

  @override
  void initState() {
    super.initState();

    //初始化一个动画控制器 定义好动画的执行时长
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,

    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animation.addListener(() {
      setState(() {});
    });
    _animController.reset();
    _giftAnimController = AnimationController(
      duration: const Duration(seconds: 1),
      //value: 1,
      vsync: this,
    );

  }

  @override
  void dispose() {
    super.dispose();

    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      _mainModel = model;
      _userModel = model.userModel;

      this._giftList = this._mainModel.giftList ?? [];

      ///获取礼物列表
      this.getGiftList();
      return Stack(
        children: <Widget>[
          this.buildMark(),
          this.buildMainBg(),
        ],
      );
    });
  }

  ///生成遮罩
  Widget buildMark() {
    return this._isShowPage
        ? InkWell(
            child: Container(
              color: Colors.black45,
            ),
            onTap: () {
              this.playPageAnim(false);
            },
          )
        : Container();
  }

  ///生成主页面
  Widget buildMainBg() {
    double tempRadiu = ScreenUtil().setWidth(20);
    return Positioned(
      bottom: ScreenUtil().setWidth(
          ((this._animation.value - 1.0) * this._popWindowHeight).toInt()),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: ScreenUtil().setWidth(1080),
          height: ScreenUtil().setWidth(this._popWindowHeight),
          decoration: BoxDecoration(
            color: AppColors.BgColor_Deep,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(tempRadiu),
                topRight: Radius.circular(tempRadiu)),
          ),
          child: Column(
            children: <Widget>[
              this.buildTitlp(),
              this.buildBalance(),
              this.buildGiftList(),
              // this.buildRewardsBtn(),
            ],
          ),
        ),
      ),
    );
  }

  ///生成顶部
  Widget buildTitlp() {
    return Container(
      height: ScreenUtil().setWidth(120),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white54, width: 0.5)),
      ),
      child: Text(
        "赠送礼物",
        style: TextStyle(
            fontSize: ScreenUtil().setSp(50), color: AppColors.TextColor),
      ),
    );
  }

  ///生成余额
  Widget buildBalance() {
    String tempBalance = Tools.ToString(this._userModel.balance, "", true);
    return Container(
      height: ScreenUtil().setWidth(120),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: ScreenUtil().setWidth(40)),
      child: RichText(
        text: TextSpan(
          text: "余额",
          style:
              TextStyle(fontSize: ScreenUtil().setSp(40), color: Colors.white),
          children: [
            TextSpan(
              text: tempBalance,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40), color: AppColors.TextColor),
            ),
            TextSpan(
              text: "钻石",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40), color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  int selected = 0;
  ///生成礼物列表
  Widget buildGiftList() {
    print("buildGiftList");
    Future.delayed(Duration(milliseconds: 500)).then((value){
      if(!_giftAnimController.isAnimating) {
        _giftAnimController.reset();
        _giftAnimController.forward();
      }
    });
    return StatefulBuilder(
      builder: (context, _setState) {
        return Container(
          height: ScreenUtil().setWidth(350),
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(40)),
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: this._giftList.length,
            itemBuilder: (BuildContext _context, int _index) {
              //return this.buildGiftItem(_index, this._giftList[_index]);
              var _data = this._giftList[_index];
              String tempAmount = Tools.ToString(_data.amount, "", true);
              var isSelected = _index == selected;
              return //图标
                ScaleTransition(
                    scale: Tween(begin: 0.9,end: isSelected ? 1.1 : 0.9).animate(CurvedAnimation(curve: Curves.elasticOut, parent: _giftAnimController)),
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueGrey[200].withAlpha(60) : Colors.transparent,
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                          border:isSelected ? Border.all(width: 0.5,color: Colors.white70) : null,
                        ),
                        //padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                        width: ScreenUtil().setWidth(220),
                        //height: ScreenUtil().setWidth(200),
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(25)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                width: ScreenUtil().setWidth(selected == _index ? 200 : 150),
                                height: ScreenUtil().setWidth(selected == _index ? 200 : 150),
                                padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                                child: Image.asset("images/video/gift_${_data.id}.png",
                                    fit: BoxFit.contain),
                              ),
                            Container(
                              height: ScreenUtil().setWidth(6),
                            ),
                            //名称
                            selected != _index ?Text(
                              _data.name,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40), color: Colors.white),
                            )
                            :Container(),
                            //价格
                            Text(
                              '$tempAmount 钻石',
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(36), color: Colors.white54),
                            ),
                            selected == _index ? Container(
                              height: ScreenUtil().setWidth(79),
                              margin: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
                              child: FlatButton(
                                color: Colors.redAccent,
                                child:Text("赠送",style: TextStyle(color: Colors.white70)),
                                onPressed: (){
                                  _giftAnimController.reverse().then((value){
                                    print("btnEventRewards");
                                    this.btnEventRewards(_data.id, _data.amount);
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                    side: BorderSide.none,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(ScreenUtil().setWidth(20)),
                                      bottomLeft: Radius.circular(ScreenUtil().setWidth(20)),
                                    )
                                ),
                              ),
                            )
                            :Container(),
                          ],
                        ),
                      ),
                      onTap: () {
                        _setState((){
                          selected = _index;
                          _giftAnimController.reset();
                          _giftAnimController.forward();
                        });
                        //this.btnEventRewards(_data.id, _data.amount);
                      },
                    ),
              );
            },
          ),
        );
      }
    );
  }

  ///生成礼物Item
  Widget buildGiftItem(int _index, GiftModel _data) {
    String tempAmount = Tools.ToString(_data.amount, "", true);
    
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(220),
        height: ScreenUtil().setWidth(200),
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(25)),
        child: Column(
          children: <Widget>[
            //图标
            Image.asset("images/video/gift_${_data.id}.png",
                fit: BoxFit.contain),
            Container(
              height: ScreenUtil().setWidth(6),
            ),
            //名称
            Text(
              _data.name,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40), color: Colors.white),
            ),
            //价格
            Text(
              '$tempAmount 钻石',
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(36), color: Colors.white54),
            ),
          ],
        ),
      ),
      onTap: () {
        this.btnEventRewards(_data.id, _data.amount);
      },
    );
  }

  //========== [ 按钮事件 ] ==========
  ///按钮事件_打赏
  void btnEventRewards(int _giftid, int _amount) async {
    if (this._userModel.balance < _amount) {
      Toast.toast(context, msg: "钻石不足", position: ToastPostion.center);
    }

    ResultData _result = await HttpManager.requestPost(
        context, "System/rewards", {"id": widget.trendsId, "gift_id": _giftid});
    if (_result.result) {
      setState(() {
        this._userModel.balance = _result.data;
        Toast.toast(context, msg: "打赏成功", position: ToastPostion.center);
      });
    }
  }

  //========== [ 辅助函数 ] ==========
  ///获取礼物列表
  void getGiftList() async {
    if (this._giftList.length == 0) {
      DYEventBus.eventBus.fire(SyncGiftList(() {
        this._giftList = this._mainModel.giftList;
        setState(() {});
      }));
    }
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
