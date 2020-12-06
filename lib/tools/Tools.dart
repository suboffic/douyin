import 'package:douyin/config/Config.dart';

/* 工具类 */
class Tools {
  /* 
   * 复制数据
   * (把源数据拷贝到目标数据块中)
   */
  static void CopyData(Map<String, dynamic> _sourceData, _targetData) {
    _sourceData.forEach((_key, _value) {
      _targetData[_key] = _value;
    });
  }

  /*
   * 把数字转换为字符串
   * _company : "w" / "k" / ""
   * _isTb : 是否千分位
   */
  static String ToString(var _num, String _company, bool _isTb) {
    bool isMinus = _num < 0;
    _num = isMinus ? -_num : _num;
    String tempStr = "$_num";

    //判断是否需要转换单位
    if (_company == "W" || _company == "w") {
      if (_num >= 10000) {
        double tempDoubleInterger = _num / 10000;
        tempStr = "${tempDoubleInterger.toStringAsFixed(1)}";
      } else {
        _company = "";
      }
    } else if (_company == "K" || _company == "k") {
      if (_num >= 1000) {
        double tempDoubleInterger = _num / 1000;
        tempStr = "${tempDoubleInterger.toStringAsFixed(1)}";
      } else {
        _company = "";
      }
    } else {
      _company = "";
      tempStr = "$_num";
    }

    //判断是否需要千分位
    if (_isTb) {
      String tempStrInteger = tempStr.split(".")[0];
      String tempStrDecimal =
          tempStr.split(".").length > 2 ? _num.toString().split(".")[1] : "";

      List<String> tempStrList = [];
      int tempStartIndex = tempStrInteger.length % 3;
      int tempCount = tempStrInteger.length ~/ 3;
      if (tempStartIndex > 0) {
        tempStrList.add(tempStrInteger.substring(0, tempStartIndex));
      }
      for (int i = 0; i < tempCount; i++) {
        tempStrList.add(tempStrInteger.substring(
            i * 3 + tempStartIndex, (i + 1) * 3 + tempStartIndex));
      }
      tempStr = tempStrList.join(",");
      tempStr += "$tempStrDecimal";
    }
    tempStr += "$_company";

    return isMinus ? "-$tempStr" : "$tempStr";
  }

  /*
   * 适应字体尺寸
   * (_text:文本, _width:区域宽度, _maxSize:最大字号.)
   */
  static int adaptFontSize(String _text, _width, int _maxSize) {
    int _fontSize = (_width / _text.length * 1.8).toInt();
    _fontSize = _fontSize > _maxSize ? _maxSize : _fontSize;
    return _fontSize;
  }

  /* 
   * 裁剪字符串
   * (按照长度裁剪,如果过长,后面补充...)
   */
  static String cutString(String _str, int _lenght) {
    num tempLength = 0;
    String tempStr = "";
    bool tempTooLong = false;
    for (int i = 0; i < _str.length; i++) {
      String _s = _str[i];
      if (RegExp("^[\u4e00-\u9fa5]").hasMatch(_s)) {
        tempLength += 1;
      } else {
        tempLength += 0.5;
      }
      if (tempLength > _lenght) {
        tempTooLong = true;
        break;
      } else {
        tempStr += _s;
      }
    }
    tempStr += tempTooLong ? "..." : "";
    return tempStr;
  }

  /* 
   * 获取字符串长度
   */
  static double GetStrLength(String _str) {
    double tempLength = 0;
    for (int i = 0; i < _str.length; i++) {
      String _s = _str[i];
      if (RegExp("^[\u4e00-\u9fa5]").hasMatch(_s)) {
        tempLength += 1;
      } else {
        tempLength += 0.5;
      }
    }
    return tempLength;
  }

  /* 获取日期_年月日格式 (如:2020-01-01) */
  static String GetDateTime_YMD() {
    var today = DateTime.now();
    return "${today.year}-${today.month}-${today.day}";
  }

  ///转换时间为文本格式
  static String changeDurationToStr(int _second) {
    int allSeconds = _second;
    int tempD = allSeconds ~/ (3600 * 24);
    allSeconds -= tempD * (3600 * 24);
    int tempH = allSeconds ~/ 3600;
    allSeconds -= tempH * 3600;
    int tempM = allSeconds ~/ 60;
    allSeconds -= tempM * 60;
    int tempS = allSeconds;
    String tempStr = "";
    tempStr += tempD > 0 ? "$tempD天" : "";
    tempStr += tempH > 0 ? "${Tools.getStandardTimeStr(tempH)}时" : "";
    tempStr += tempM > 0 ? "${Tools.getStandardTimeStr(tempM)}分" : "";
    tempStr += tempS > 0 ? "${Tools.getStandardTimeStr(tempS)}秒" : "";
    return tempStr;
  }

  ///获取标准时间字符串
  static String getStandardTimeStr(int _int) {
    String tempStr = "000$_int";
    return tempStr.substring(tempStr.length - 2);
  }

  ///获取图像Url
  static String GetImageUrl(String _avatarUrl) {
    if (_avatarUrl == "") {
      return _avatarUrl;
    }
    return _avatarUrl;
  }
}
