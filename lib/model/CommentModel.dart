import 'package:douyin/model/MainModel.dart';

///评论数据
class CommentModel extends BaseModel {
  int id = 0;
  String uuid = "";
  String nickname = "";
  int vipLevel = 0;
  String avatarUrl = "";
  int likes = 0;
  String content = "";
  String createdAt = "";
  int sub_sum = 0;

  ///是否喜欢(点赞,客户端补充字段)
  bool is_like = false;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.uuid = _map["uuid"];
    this.nickname = _map["nickname"];
    this.vipLevel = _map["vip_level"];
    this.avatarUrl = _map["avatar_url"];
    this.likes = _map["likes"];
    this.content = _map["content"];
    this.createdAt = _map["created_at"];
    this.sub_sum = _map["sub_sum"];
  }
}
