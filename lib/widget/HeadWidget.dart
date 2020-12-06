import 'package:douyin/widget/DYImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/* 头像组件 */
class HeadWidget extends StatefulWidget {
  /* 头像尺寸 */
  final Size headSize;
  /* 头像Url */
  final String avatarUrl;
  /* 等级 */
  final int level;

  const HeadWidget({Key key, this.headSize, this.avatarUrl, this.level})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HeadWidgetState();
  }
}

class HeadWidgetState extends State<HeadWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Stack(
        children: <Widget>[
          Container(
            width: widget.headSize.width,
            height: widget.headSize.height,
            child: widget.avatarUrl != null && widget.avatarUrl != ""
                ? widget.avatarUrl.startsWith("images")
                    ? Image.asset(widget.avatarUrl)
                    : DYImage(
                        imageUrl: widget.avatarUrl,
                      )
                : Image.asset("images/replace/head.jpg"),
          ),
          widget.level == 0
              ? Container(
                  height: 0,
                )
              : Positioned(
                  bottom: 0,
                  child: Container(
                    width: widget.headSize.width,
                    height: widget.headSize.height / 3,
                    color: Color(0xffffe200),
                    alignment: Alignment.center,
                    child: Text(
                      "LV ${widget.level}",
                      style: TextStyle(
                          fontSize: widget.headSize.height / 5,
                          color: Color(0xffb80270)),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
