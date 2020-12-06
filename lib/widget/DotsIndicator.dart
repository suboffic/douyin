
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///点状指示器
class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.colorNoraml,
    this.colorSelect,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;

  final Color colorNoraml;
  final Color colorSelect;

  static const double _kDotSpacing = 12.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: selectedness<1.0 ? this.colorNoraml : this.colorSelect,
          type: MaterialType.circle,
          child: new Container(
            width: 5.0,
            height: 5.0,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}