import 'package:douyin/model/DYModelUnit.dart';
import 'MainModel.dart';

///动态数据
class TrendsModel extends BaseModel {
  ///站点id
  int site_id = 0;
  int id = 0;
  String uuid = "";
  String nickname = "";

  ///在线状态  1在线 2勿扰 0离线(不显示)
  int online = 0;

  ///用户等级  标识头像上小图标
  int vipLevel = 0;

  ///发布动态的用户头像
  String avatarUrl = "";

  ///动态内容
  String content = "";

  ///点赞数
  int likes = 0;

  ///评论数
  int comments = 0;

  ///动态标签组列表
  List<String> tags = [];

  ///默认动态缩率图
  String thumbImg = "";

  ///视频播放信息
  List<PlayData> play = [];

  ///是否已经点赞过
  bool has_like = false;

  ///是否关注过用户
  bool hasFollow = false;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.site_id = _map["site_id"];
    this.id = _map["id"];
    this.uuid = _map["uuid"];
    this.nickname = _map["nickname"] ?? "";
    this.online = _map["online"] ?? 0;
    this.vipLevel = _map["vip_level"] ?? 0;
    this.avatarUrl = _map["avatar_url"] ?? "";
    this.content = _map["content"];
    this.likes = _map["likes"];
    this.comments = _map["comments"] ?? 0;
    if (_map["tags"] != null) {
      this.tags = DYModelUnit.convertList<String>(_map["tags"]);
    }
    this.thumbImg = _map["thumb_img"];
    if (_map["play"] != null && _map["play"].isNotEmpty) {
      this.play = DYModelUnit.convertList<PlayData>(_map["play"]);
    }

    this.has_like = _map["has_like"] == 1;
    this.hasFollow = _map["has_follow"] == 1;
  }
}

///播放数据
class PlayData {
  ///播放类型  video
  String type = "";

  ///播放地址
  String play_url = "";

  ///视频时长(秒)
  int duration = 0;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.type = _map["type"];
    this.play_url = _map["play_url"];
    this.duration = int.parse(_map["duration"]);
  }
}

///动态购买配置信息
class BuyConfig extends BaseModel {
  ///价格
  num price = 0;

  ///是否已经购买过
  bool paid = false;

  ///需要购买的类型  download 下载时需要  show  播放时需要
  String type = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.price = _map["price"];
    this.paid = _map["paid"];
    this.type = _map["type"];
  }
}
