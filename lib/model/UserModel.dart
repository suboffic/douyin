import 'package:douyin/model/DYModelUnit.dart';

import 'MainModel.dart';

/* 用户数据 */
class UserModel extends BaseModel {
  String uuid = "";

  ///验证id
  String oauthID = "";
  String token = "";
  String mobile = "";
  String nickname = "";
  int birthday = 0;
  String avatarUrl = "";

  ///性别 1男 2女
  int sex = 0;

  ///用户状态(0:异常,1:正常)
  int state = 0;

  ///会员等级
  int vipLevel = 0;

  ///会员到期时间
  String vipExpires = "";

  ///余额
  int balance = 0;
  int lastLoginDevice = 0;
  String lastLoginIp = "";
  String lastLoginTime = "";

  ///免费时间
  String freeViewTime = "";

  ///个性视频介绍 被邀请视频聊天时使用
  String personalityUrl = "";

  ///在线状态  0离线 1在线 2勿扰 3直播中  只有在状态1时,才显示邀请按钮  状态3时 显示右上角的直播按钮
  int onlineState = 0;
  String createdAt = "";
  String updateAt = "";

  ///视频作品总数
  int videoCount = 0;

  ///图片作品总数
  int imgCount = 0;

  ///合集数量
  int collections = 0;

  ///用户合集数据
  List<UserCollectionModel> collection = [];
  int buys = 0;

  ///喜欢数量(包括喜欢和购买)
  int likes = 0;

  ///获赞数量
  int beAdmire = 0;

  ///被关注数量
  int follows = 0;

  ///粉丝数量
  int fans = 0;

  ///
  int photoNum = 0;

  ///上级(推荐人)
  String superiorCode = "";

  ///邀请码
  String inviteCode = "";

  ///用户照片数据
  List<UserPhotoModel> photo = [];

  ///是否关注
  bool hasFollow = false;

  ///默认带入的视频id
  int v = 0;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.uuid = _map["uuid"];
    this.oauthID = _map["oauth_id"];
    this.token = _map["token"];
    this.mobile = _map["mobile"] ?? "";
    this.nickname = _map["nickname"];
    this.birthday = _map["birthday"];
    this.avatarUrl = _map["avatar_url"];
    this.sex = _map["sex"];
    this.state = _map["state"];
    this.vipLevel = _map["vip_level"] ?? 0;
    this.vipExpires = _map["vip_expires"];
    this.balance = _map["balance"] ?? 0;
    this.lastLoginDevice = _map["last_login_device"];
    this.lastLoginIp = _map["last_login_ip"];
    this.lastLoginTime = _map["last_login_time"];
    this.freeViewTime = _map["free_view_time"];
    this.personalityUrl = _map["personality_url"];
    this.onlineState = _map["online_state"];
    this.createdAt = _map["created_at"];
    this.updateAt = _map["update_at"];
    this.videoCount = _map["video_count"];
    this.imgCount = _map["img_count"];
    this.collections = _map["collections"];
    this.collection = _map["collection"] == null
        ? []
        : DYModelUnit.convertList<UserCollectionModel>(_map["collection"]);
    this.buys = _map["buys"];
    this.likes = _map["likes"];
    this.beAdmire = _map["be_admire"];
    this.follows = _map["follows"];
    this.fans = _map["fans"];
    this.photoNum = _map["photo_num"];
    this.superiorCode = _map["superior_code"];
    this.inviteCode = _map["invite_code"];
    this.photo = _map["photo"] == null
        ? []
        : DYModelUnit.convertList<UserPhotoModel>(_map["photo"]);

    this.hasFollow = _map["has_follow"] == 1;

    this.v = _map["v"];
  }
}

///用户照片数据
class UserPhotoModel extends BaseModel {
  int id = 0;

  ///类型 img/video
  String type = "";
  String url = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.type = _map["type"];
    this.url = _map["url"];
  }
}

///用户合集数据
class UserCollectionModel extends BaseModel {
  int id = 0;

  ///是否置顶
  int istop = 0;
  String title = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.istop = _map["istop"] ?? 0;
    this.title = _map["title"];
  }
}
