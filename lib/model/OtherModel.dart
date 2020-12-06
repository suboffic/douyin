import 'package:douyin/model/DYModelUnit.dart';
import 'package:douyin/model/MainModel.dart';

///关注记录数据
class FollowRecordModel extends BaseModel {
  String uuid = "";
  String nickname = "";
  int vipLevel = 0;
  String avatarUrl = "";
  bool hasfollow = true;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.uuid = _map["uuid"];
    this.nickname = _map["nickname"];
    this.vipLevel = _map["vip_level"];
    this.avatarUrl = _map["avatar_url"];
  }
}

///Vip支付模块
class VipPayModel extends BaseModel {
  List<VipPayData> payData = [];
  List<String> payMent = [];

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.payData = DYModelUnit.convertList<VipPayData>(_map["payData"]);
    this.payMent = DYModelUnit.convertList<String>(_map["payMent"]);
  }
}

///Vip支付数据
class VipPayData extends BaseModel {
  int goods_id = 0;
  String img = "";
  String name = "";

  ///描述
  String describe = "";

  ///价格
  int amount = 0;

  ///赠送
  int give = 0;

  ///原价
  int original_amount = 0;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.goods_id = _map["goods_id"];
    this.img = _map["img"];
    this.name = _map["name"];
    this.describe = _map["describe"];
    this.amount = _map["amount"];
    this.give = _map["give"];
    this.original_amount = _map["original_amount"];
  }
}

///钻石支付模块
class DiamondPayModel extends BaseModel {
  List<DiamondPayData> payData = [];
  List<String> payMent = [];

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.payData = DYModelUnit.convertList<DiamondPayData>(_map["payData"]);
    this.payMent = DYModelUnit.convertList<String>(_map["payMent"]);
  }
}

///钻石支付数据
class DiamondPayData extends BaseModel {
  int goods_id = 0;
  String img = "";

  ///钻石数量
  int amount = 0;
  int give = 0;

  ///价格
  int pay_amount = 0;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.goods_id = _map["goods_id"];
    this.img = _map["img"];
    this.amount = _map["amount"];
    this.give = _map["give"];
    this.pay_amount = _map["pay_amount"];
  }
}

///提现通道数据
class CashOutChannelModel extends BaseModel {
  int id = 0;
  String code = "";

  ///汇率
  num exrate = 0;
  int min_money = 0;
  int max_money = 0;

  ///0按比例 1固定
  int charge_type = 0;
  num charge_rate = 0;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.code = _map["code"];
    this.exrate = _map["exrate"];
    this.min_money = _map["min_money"];
    this.max_money = _map["max_money"];
    this.charge_type = _map["charge_type"];
    this.charge_rate = _map["charge_rate"];
  }
}

///(提现)地址数据
class AddressModel extends BaseModel {
  int id = 0;
  String code = "";
  int channel_id = 0;
  String address = "";
  String name = "";
  String createdAt = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.code = _map["code"];
    this.channel_id = _map["channel_id"];
    this.address = _map["address"];
    this.name = _map["name"];
    this.createdAt = _map["created_at"];
  }
}

///支付明细数据
class PayDetailModel extends BaseModel {
  String goods_name = "";
  String pay_name = "";
  String out_trade_no = "";
  int amount = 0;

  ///状态 (0待支付 1已完成 2待确认 3已退还)
  int state = 0;
  String createdAt = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.goods_name = _map["goods_name"];
    this.pay_name = _map["pay_name"];
    this.out_trade_no = _map["out_trade_no"];
    this.amount = _map["amount"];
    this.state = _map["state"];
    this.createdAt = _map["created_at"];
  }
}

///明细数据(包括: 收支明细,收益明细,购买服务)
class DetailModel extends BaseModel {
  int id = 0;
  String content = "";

  ///类型 (1充值钻石 2充值钻石分红 3充值会员 4充值会员分红 5购买动态 6动态收入 7视频打赏 8视频打赏收入 9钻石提现 10 主播打赏 11主播打赏收入)
  int type = 0;

  ///创建日期
  String createdAt = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.content = _map["content"];
    this.type = _map["type"];
    this.createdAt = _map["created_at"];
  }
}

///聊天数据
class ChatModel extends BaseModel {
  String from_uuid = "";
  String nickname = "";
  String avatarUrl = "";
  int vipLevel = 0;

  ///在线状态 0离线 1在线 2勿扰 3直播中
  int onlineState = 0;
  int log_count = 0;
  List<MessageModel> log_list = [];

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.from_uuid = _map["from_uuid"];
    this.nickname = _map["nickname"];
    this.avatarUrl = _map["avatar_url"];
    this.vipLevel = _map["vip_level"];
    this.onlineState = _map["online_state"];
    this.log_count = _map["log_count"];
    // this.log_list = DYModelUnit.convertList<MessageModel>(_map["log_list"]);
    var tempDataList = _map["log_list"] ?? _map["log"];
    this.log_list = DYModelUnit.convertList<MessageModel>(tempDataList);
  }

  @override
  Map toJson(_data) {
    Map _map = {};
    _map["from_uuid"] = _data.from_uuid;
    _map["nickname"] = _data.nickname;
    _map["avatar_url"] = _data.avatarUrl;
    _map["vip_level"] = _data.vipLevel;
    _map["online_state"] = _data.onlineState;
    _map["log_count"] = _data.log_count;
    _map["log_list"] =
        DYModelUnit.convertListDynamic<MessageModel>(_data.log_list);
    return _map;
  }
}

///消息数据
class MessageModel extends BaseModel {
  String msg_id = "";
  String from_uuid = "";

  /// 消息类型 0文本 1图片
  int type = 0;
  String content = "";
  String createdAt = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.msg_id = _map["msg_id"];
    this.from_uuid = _map["from_uuid"];
    this.type = _map["type"];
    this.content = _map["content"];
    this.createdAt = _map["created_at"];
  }

  Map toJson(_data) {
    Map _map = {};
    _map["msg_id"] = _data.msg_id;
    _map["from_uuid"] = _data.from_uuid;
    _map["type"] = _data.type;
    _map["content"] = _data.content;
    _map["created_at"] = _data.createdAt;
    return _map;
  }
}

///点赞数据
class AdmireModel extends BaseModel {
  int trends_id = 0;
  String nickname = "";
  String avatarUrl = "";
  String thumbImg = "";
  int price = 0;
  String createdAt = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.trends_id = _map["trends_id"];
    this.nickname = _map["nickname"];
    this.avatarUrl = _map["avatar_url"];
    this.thumbImg = _map["thumb_img"];
    this.price = _map["price"];
    this.createdAt = _map["created_at"];
  }
}

///热点数据
class HotModel extends BaseModel {
  ActivityModel activity = new ActivityModel();
  List<MovieModel> movie = [];
  Map<String, TagModel> catalog = {};
  List<TagModel> tags = [];

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.activity.fromMap(_map["activity"]);
    if (_map["movie"] != null) {
      this.movie = DYModelUnit.convertList<MovieModel>(_map["movie"]);
    }

    Map<String, dynamic> tempDataCatalog = _map["catalog"] ?? {};
    tempDataCatalog.forEach((_key, _value) {
      TagModel tempModelTag = TagModel();
      tempModelTag.fromMap(_value);
      this.catalog[_key] = tempModelTag;
    });

    this.tags = DYModelUnit.convertList<TagModel>(_map["tags"]);
  }
}

///活动数据
class ActivityModel extends BaseModel {
  int id = 0;
  int end_time = 0;
  String img = "";
  String content = "";
  List<ActivityOpuModel> data = [];

  @override
  void fromMap(Map<String, dynamic> _map) {
    if (_map != null) {
      this.id = _map["id"];
      this.end_time = _map["end_time"];
      this.img = _map["img"];
      this.content = _map["content"];
      List<dynamic> tempDataList =
          _map["data"] is Map ? _map["data"]["data"] : _map["data"];
      this.data = DYModelUnit.convertList<ActivityOpuModel>(tempDataList);
    }
  }
}

///活动作品数据
class ActivityOpuModel extends BaseModel {
  int top = 0;
  int id = 0;
  int likes = 0;
  int price = 0;
  int paid_type = 0;
  int mustVip = 0;
  String content = "";
  String thumbImg = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.top = _map["top"];
    this.id = _map["id"];
    this.likes = _map["likes"];
    this.price = _map["price"];
    this.paid_type = _map["paid_type"];
    this.mustVip = _map["must_vip"];
    this.content = _map["content"];
    this.thumbImg = _map["thumb_img"];
  }
}

///视频数据
class MovieModel extends BaseModel {
  int id = 0;
  int likes = 0;
  String thumbImg = "";
  String content = "";
  int mustVip = 0;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.likes = _map["likes"];
    this.thumbImg = _map["thumb_img"];
    this.content = _map["content"];
    this.mustVip = _map["must_vip"];
  }
}

///标签数据
class TagModel extends BaseModel {
  int id = 0;
  String name = "";
  String thumbImg = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.name = _map["name"];
    this.thumbImg = _map["thumb_img"];
  }
}
