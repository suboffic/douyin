class DYPhysicalBtnEvtControll {
  ///物理按键事件列表
  static List<Function> physicalBtnEventList = [];

  ///添加物理按键事件
  static void AddPhysicalBtnEvent(Function func) {
    DYPhysicalBtnEvtControll.physicalBtnEventList.add(func);
  }

  ///获取物理按键事件
  static Function GetPhysicalBtnEvent() {
    Function tempFunc;
    if (DYPhysicalBtnEvtControll.physicalBtnEventList.length > 0) {
      tempFunc = DYPhysicalBtnEvtControll.physicalBtnEventList.removeLast();
    }
    return tempFunc;
  }
}
