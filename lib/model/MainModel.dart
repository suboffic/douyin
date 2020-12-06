import 'package:douyin/model/ConfigModel.dart';
import 'package:douyin/model/OtherModel.dart';
import 'package:scoped_model/scoped_model.dart';

import 'UserModel.dart';

///数据基类
class BaseModel extends Model {
  void fromMap(Map<String, dynamic> _map) {}

  void toJson(_data) {}
}

///主数据模型 (需要全局使用的数据在这里添加模型)
class MainModel extends Model {
  ///账户数据
  UserModel userModel = new UserModel();

  ///礼物(数据)列表
  List<GiftModel> giftList = [];

  ///配置数据
  ConfigModel configModel = new ConfigModel();

  ///聊天(数据)列表
  List<ChatModel> chatList = [];

  ///新的粉丝关注数
  int new_fans_count = 0;

  ///新的点赞数
  int new_admire_count = 0;

  ///作品收入数量
  int new_opus_count = 0;

  ///今日观看次数
  int todayWatchCount = 0;

  MainModel of(context) => ScopedModel.of<MainModel>(context);
}

///礼物数据
class GiftModel extends BaseModel {
  int id = 0;
  String name = "";
  int amount = 0;
  String img = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.id = _map["id"];
    this.name = _map["name"];
    this.amount = _map["amount"];
    this.img = _map["img"];
  }
}
