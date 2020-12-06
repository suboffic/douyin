import 'package:douyin/model/MainModel.dart';

///合伙人数据
class PartnerModel extends BaseModel {
  ///合伙人等级 0初级合伙人 1中级合伙人 2高级合伙人 3超级合伙人 8平台股东
  int level = 0;
  ///分润比例
  String bonus_rate = "";
  ///总业绩
  int total_performance = 0;
  ///总收益
  int total_profit = 0;
  ///本月收益
  int month_profit = 0;
  ///本业业绩
  int month_performance = 0;
  ///本月推广数
  int month_spread = 0;
  ///一级推广人数
  int spread_1 = 0;
  ///二级推广人数
  int spread_2 = 0;
  ///三级推广人数
  int spread_3 = 0;
  ///四级推广人数
  int spread_4 = 0;
  ///钻石收益
  int diamond_bonus = 0;
  ///VIP收益
  int service_bonus = 0;
  ///作品收益
  int opus_bonus = 0;
  ///礼物收益
  int gift_bonus = 0;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.level = _map["level"];
    this.bonus_rate = _map["bonus_rate"];
    this.total_performance = _map["total_performance"];
    this.total_profit = _map["total_profit"];
    this.month_profit = _map["month_profit"];
    this.month_performance = _map["month_performance"];
    this.month_spread = _map["month_spread"];
    this.spread_1 = _map["spread_1"];
    this.spread_2 = _map["spread_2"];
    this.spread_3 = _map["spread_3"];
    this.spread_4 = _map["spread_4"];
    this.diamond_bonus = _map["diamond_bonus"];
    this.service_bonus = _map["service_bonus"];
    this.opus_bonus = _map["opus_bonus"];
    this.gift_bonus = _map["gift_bonus"];
  }
}