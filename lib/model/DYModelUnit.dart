import 'package:douyin/model/ConfigModel.dart';
import 'package:douyin/model/MainModel.dart';
import 'package:douyin/model/OtherModel.dart';
import 'package:douyin/model/TrendsModel.dart';
import 'package:douyin/model/UserModel.dart';

class DYModelUnit {
  ///转换列表
  static List<T> convertList<T>(List<dynamic> _sourceList) {
    _sourceList = _sourceList == null ? [] : _sourceList;
    List<T> _targetList = [];
    dynamic tempClass = getClassByTName(T.toString());
    if (tempClass != null) {
      _sourceList.forEach((_item) {
        dynamic tempItem = getClassByTName(T.toString());
        tempItem.fromMap(_item);
        _targetList.add(tempItem);
      });
    } else if (T.toString() == "num") {
      _sourceList.forEach((_item) {
        dynamic tempValue = num.parse(_item.toString());
        _targetList.add(tempValue);
      });
    } else if (T.toString() == "int") {
      _sourceList.forEach((_item) {
        dynamic tempValue = int.parse(_item.toString());
        _targetList.add(tempValue);
      });
    } else if (T.toString() == "double") {
      _sourceList.forEach((_item) {
        dynamic tempValue = double.parse(_item.toString());
        _targetList.add(tempValue);
      });
    } else {
      _sourceList.forEach((_item) {
        _targetList.add(_item);
      });
    }
    return _targetList;
  }

  ///通过T类名获取类结构
  static getClassByTName(String _className) {
    switch (_className) {
      case "TrendsModel":
        return new TrendsModel();
      case "FollowRecordModel":
        return new FollowRecordModel();
      case "PlayData":
        return new PlayData();
      case "VipPayData":
        return new VipPayData();
      case "GiftModel":
        return new GiftModel();
      case "DetailModel":
        return new DetailModel();
      case "ChatModel":
        return new ChatModel();
      case "AdmireModel":
        return new AdmireModel();
      case "ActivityOpuModel":
        return new ActivityOpuModel();
      case "MovieModel":
        return new MovieModel();
      case "TagModel":
        return new TagModel();
    }
  }

  ///转换列表_未定义
  static List<dynamic> convertListDynamic<T>(List<T> _sourceList) {
    List<dynamic> _targetList = [];
    dynamic tempClass = getClassByTName(T.toString());
    if (tempClass != null) {
      _sourceList.forEach((_item) {
        dynamic tempItem = getClassByTName(T.toString());
        _targetList.add(tempItem.toJson(_item));
      });
    }
    return _targetList;
  }
}
