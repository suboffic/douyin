import 'package:douyin/model/DYModelUnit.dart';
import 'MainModel.dart';

///配置数据
class ConfigModel extends BaseModel {
  ///站点名称
  String siteName = "";

  ///站点主机
  String siteHost = "";

  ///站点状态
  int siteState = 0;

  ///站点状态提示语
  String siteStateTips = "";

  ///货币单位
  String coinUnit = "";

  ///seo标题
  String seoTitle = "";

  ///seo关键字
  String seoKeywords = "";

  ///seo简述
  String seoDescription = "";

  ///
  int shareAwardTime = 0;

  //
  String inviteUrl = "";

  ///分享时 复制文字链接的内容
  String affTitle = "";

  ///通知列表
  List<NoticeConfig> notice = [];

  ///启动页广告列表(客户端)
  List<AdsConfig> adsList = [];

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.siteName = _map["site_name"];
    this.siteHost = _map["site_host"];
    this.siteState = _map["site_state"];
    this.siteStateTips = _map["site_state_tips"];
    this.coinUnit = _map["coin_unit"];
    this.seoTitle = _map["seo_title"];
    this.seoKeywords = _map["seo_keywords"];
    this.seoDescription = _map["seo_description"];

    this.shareAwardTime = _map["share_award_time"];

    this.inviteUrl = _map["invite_url"];
    this.affTitle = _map["aff_title"];

    this.notice = DYModelUnit.convertList<NoticeConfig>(_map["notice"]);

    AdsConfig ads = new AdsConfig();
    ads.fromMap(_map["ads"]);
  }
}

///分享配置
class ShareConfig extends BaseModel {
  String title = "";
  String content = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.title = _map["title"];
    this.content = _map["content"];
  }
}

///App配置
class AppConfig extends BaseModel {
  ///版本号
  String ver = "";

  ///Url
  String url = "";

  ///提示语
  String tips = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.ver = _map["ver"];
    this.url = _map["url"];
    this.tips = _map["tips"];
  }
}

///通知配置
class NoticeConfig extends BaseModel {
  ///通知类型
  int type = 0;
  String title = "";
  String contents = "";

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.type = _map["type"];
    this.title = _map["title"];
    this.contents = _map["contents"];
  }
}

///启动页广告配置
class AdsConfig extends BaseModel {
  ///广告文件类型
  int fileType = 0;

  ///广告文件地址
  String contentUrl = "";

  ///点击广告响应方式
  int clickAction = 0;

  ///点击广告响应对应的url
  String actionUrl = "";

  ///广告播放时长
  int duration = 0;

  @override
  void fromMap(Map<String, dynamic> _map) {
    this.fileType = _map["file_type"];
    this.contentUrl = _map["content_url"];
    this.clickAction = _map["click_action"];
    this.actionUrl = _map["action_url"];
    this.duration = _map["duration"];
  }
}
