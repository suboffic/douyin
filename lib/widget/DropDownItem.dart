import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DropDownFilter extends StatefulWidget {
  DropDownFilter({Key key, this.btnEvent, this.buttons});
  final Function btnEvent; //每一个子按钮的点击事件
  final List<FilterButtonModel> buttons; //按钮数组 数据类型FilterButtonModel

  @override
  _DropDownFilterState createState() => _DropDownFilterState();
}

class _DropDownFilterState extends State<DropDownFilter> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  double innerHeight = ScreenUtil().setHeight(1480);
  bool isMask = false; //下拉蒙层是否显示
  FilterButtonModel curButton;
  int curFilterIndex;

  initState() {
    super.initState();
    //初始化下拉列表
    curButton = widget.buttons[0];

    controller = new AnimationController(
      duration: const Duration(milliseconds: 200), 
      vsync: this
    );

    animation = new Tween(begin: 0.0, end: innerHeight).animate(controller)
    ..addListener(() {
      //这行如果不写，没有动画效果
      setState(() {});
    });
  }

  void ontap (String _btnText) {
    controller.reverse();
    triggerIcon(widget.buttons[curFilterIndex]);
    triggerMask();

    widget.buttons[curFilterIndex].title = _btnText;
    widget.btnEvent(curFilterIndex, _btnText);
  }

  void triggerMask () {
    setState(() {
      isMask = !isMask;
    });
  }

  void triggerIcon (btn) {
    if(btn.direction == 'up') {
      btn.direction = 'down';
    } else {
      btn.direction = 'up';
    }
  }

  void initButtonStatus () {
    widget.buttons.forEach((i) {
      setState(() {
        i.direction = 'down';
      });
    });
  }

  //更新数据
  void updateData (i) {
    setState(() {
      curButton = widget.buttons[i];
      curFilterIndex = i;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(1080),
      height: ScreenUtil().setHeight(1920),
      child: Stack( //stack设置为overflow：visible之后，内部的元素中超出的部分就不能触发点击事件；所以尽量避免这种布局
        children: <Widget>[
          _button(),
          _contentList(curButton),
        ],
      )
    );
  }

  //筛选按钮
  Widget _button() {
    return Row(
      children: List.generate(widget.buttons.length, (i) {
        final thisButton = widget.buttons[i];
        return SizedBox(
          height: ScreenUtil().setHeight(140),
          width: MediaQuery.of(context).size.width / widget.buttons.length,
          child: thisButton.title!="" ? FlatButton(
            padding: EdgeInsets.all(0),
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(thisButton.title, 
                      style: TextStyle(fontSize: ScreenUtil().setSp(34), 
                        color: thisButton.direction=='up' ? Colors.blue : Colors.grey),),
                    _rotateIcon(thisButton.direction)
                  ],
                ),
                thisButton.action,
              ],
            ),
            onPressed: () {
              //处理 下拉列表打开时，点击别的按钮
              if(isMask && i != curFilterIndex) {
                initButtonStatus();
                triggerIcon(widget.buttons[i]);
                updateData(i);
                return;
              }

              updateData(i);

              if(curButton.callback == null) {
                if(animation.status == AnimationStatus.completed) {
                  controller.reverse();
                } else {
                  controller.forward();
                }
                triggerMask();
              } else {
                curButton.callback();
              }
              
              triggerIcon(widget.buttons[i]);
            },
          ) : new Container(),
        );
      }),
    );
    
  }

  //筛选弹出的下拉列表
  Widget _contentList(FilterButtonModel lists) {
    if(lists.contents != null && lists.contents.length > 0 ) {
      return Positioned(
          width:  MediaQuery.of(context).size.width,
          top: ScreenUtil().setHeight(140),
          left: 0,
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                height: animation.value,
                child: _innerConList(lists)
              ),
              _mask()
            ],
          )
          
      );
    } else {
      return Container(height: 0,);
    }
  }
  
  Widget _innerConList(FilterButtonModel lists) {
    if(lists.type == 'Row') {
      setState(() {
        innerHeight = 50.0 * lists.contents.length;
      });
      
      return Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 15),
        child: Wrap(
          alignment: WrapAlignment.start,
          verticalDirection: VerticalDirection.down,
          runSpacing: 15,
          children: List.generate(lists.contents.length, (i) {
            return GestureDetector(
              onTap: () { ontap(lists.contents[i]); },
              child: Container(
                width: (MediaQuery.of(context).size.width - 20) / 3, //每行显示3个
                child: Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color.fromRGBO(216,216,216,0.3),
                  ),
                  child: Text(lists.contents[i]),
                )
              )
            ); 
          }),
        )
      );
    } else {
      setState(() {
        innerHeight = 50.0 * lists.contents.length;
      });
      return ListView(
        children: List.generate(lists.contents.length, (i) {
          return FlatButton(
            onPressed: () { ontap(lists.contents[i]); },
            child: Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: Text(lists.contents[i],style: TextStyle(
              
              ),),
            )
            
          );
        }),
      );
    }
  }

  //筛选的黑色蒙层
  Widget _mask() {
    if(isMask) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color.fromRGBO(0, 0, 0, 0.5),
      );
    } else {
      return Container( 
        height: 0,
      );
    }
  }

  //右侧旋转箭头组建
  Widget _rotateIcon(direction) {
    if(direction == 'up') {
      return Icon(Icons.keyboard_arrow_up, color: Colors.blue);
    } else {
      return Icon(Icons.keyboard_arrow_down, color: Colors.grey,);
    }
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}

class FilterButtonModel {
  String title; //按钮title
  List contents; //下拉列表
  String type; //下拉筛选类型 'Column'、'Row'
  Function callback; //按钮点击回调，可以自定义回调，如跳转页面等
  String direction; //下拉箭头方向
  Widget action;

  FilterButtonModel({this.title, this.contents, this.type, this.callback, this.direction, this.action});
}