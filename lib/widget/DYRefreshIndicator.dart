import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 将指示器移动到其最大位移的上滚动距离，以可滚动容器范围的百分比表示。
const double _kDragContainerExtentPercentage = 0.25;

// 卷轴的拖动姿态可以超过DYRefreshIndicator的位移多少
// max displacement = _kDragSizeFactorLimit * displacement.
// 修改
// const double _kDragSizeFactorLimit = 1.5;
const double _kDragSizeFactorLimit = 4;

// 当滚动结束时，刷新指示器动画的持续时间将变为DYRefreshIndicator的位移。
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);

// 刷新操作完成时开始的ScaleTransition的持续时间。
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// 当用户将[DYRefreshIndicator]拖到足以证明他们希望应用程序刷新的位置时调用的函数的签名。
/// 刷新操作完成后，返回的[Future]必须完成。
/// Used by [DYRefreshIndicator.onRefresh].
typedef RefreshCallback = Future<void> Function();

// 只有当scrollableKey标识的可滚动条被滚动到其最小或最大限制时，状态机才会在这些模式中移动。
enum _RefreshIndicatorMode {
  drag,     // 指针向下
  armed,    // 拖得足够远，up事件将运行onRefresh回调
  snap,     // 动画到指示器的最终“位移”
  refresh,  // 正在运行刷新回调
  done,     // 刷新后设置指示器淡出的动画
  canceled, // 设置指示灯的动画在未启用后淡出
}

class DYRefreshIndicator extends StatefulWidget {
  /// 创建刷新指示器
  ///
  /// [onRefresh]、[child]和[notificationPredicate]参数必须为非空
  /// 默认[displacement]为40.0逻辑像素
  ///
  /// [semanticsLabel]用于指定此小部件的辅助功能标签
  /// 如果为空，则默认为[MaterialAllocalizations.refreshIndicatorSemanticLabel]
  /// 可以传递空字符串，以避免屏幕读取软件读取任何内容
  /// [semanticsValue]可用于指定小部件的进度.
  const DYRefreshIndicator({
    Key key,
    @required this.child,
    this.displacement = 40.0,
    @required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
  }) : assert(child != null),
       assert(onRefresh != null),
       assert(notificationPredicate != null),
       super(key: key);

  /// 树中此小部件下面的小部件。
  ///
  /// 刷新指示器将堆叠在此子级上。当子级的可滚动子代被过度滚动时，将显示该指示器。
  ///
  /// 通常是[ListView]或[CustomScrollView]。
  final Widget child;

  /// 从子级的上边缘或下边缘到刷新指示器将固定的位置的距离。
  /// 在显示刷新指示器的拖动过程中，其实际位移可能会显著超过此值。
  final double displacement;

  /// 当用户将刷新指示器拖到足以显示他们希望应用程序刷新的程度时调用的函数。
  /// 刷新操作完成后，返回的[Future]必须完成。
  final RefreshCallback onRefresh;

  /// 进度指示器的前景色。默认情况下，当前主题为[ThemeData.accentColor]。
  final Color color;

  /// 进度指示器的背景色。默认情况下，当前主题为[ThemeData.accentColor]。
  final Color backgroundColor;

  /// 指定此小部件是否应处理[ScrollNotification]的检查。
  ///
  /// 默认情况下，检查“notification.depth==0”。设置为其他更复杂的布局。
  final ScrollNotificationPredicate notificationPredicate;

  /// {@macro flutter.material.progressIndicator.semanticsLabel}
  ///
  /// This will be defaulted to [MaterialLocalizations.refreshIndicatorSemanticLabel]
  /// if it is null.
  final String semanticsLabel;

  /// {@macro flutter.material.progressIndicator.semanticsValue}
  final String semanticsValue;

  @override
  RefreshIndicatorState createState() => RefreshIndicatorState();
}

/// Contains the state for a [DYRefreshIndicator]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
class RefreshIndicatorState extends State<DYRefreshIndicator> with TickerProviderStateMixin<DYRefreshIndicator> {
  AnimationController _positionController;
  AnimationController _scaleController;
  Animation<double> _positionFactor;
  Animation<double> _scaleFactor;
  Animation<double> _value;
  Animation<Color> _valueColor;

  _RefreshIndicatorMode _mode;
  Future<void> _pendingRefreshFuture;
  bool _isIndicatorAtTop;
  double _dragOffset;

  // 修改
  // static final Animatable<double> _threeQuarterTween = Tween<double>(begin: 0.0, end: 0.75);
  static final Animatable<double> _threeQuarterTween = Tween<double>(begin: 0.0, end: 2.5);
  static final Animatable<double> _kDragSizeFactorLimitTween = Tween<double>(begin: 0.0, end: _kDragSizeFactorLimit);
  static final Animatable<double> _oneToZeroTween = Tween<double>(begin: 1.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
    _value = _positionController.drive(_threeQuarterTween); // The "value" of the circular progress indicator during a drag.

    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _valueColor = _positionController.drive(
      ColorTween(
        begin: (widget.color ?? theme.accentColor).withOpacity(0.0),
        end: (widget.color ?? theme.accentColor).withOpacity(1.0),
      ).chain(CurveTween(
        curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit)
      )),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification))
      return false;
    if (notification is ScrollStartNotification && notification.metrics.extentBefore == 0.0 &&
        _mode == null && _start(notification.metrics.axisDirection)) {
      setState(() {
        _mode = _RefreshIndicatorMode.drag;
      });
      return false;
    }
    bool indicatorAtTopNow;
    switch (notification.metrics.axisDirection) {
      case AxisDirection.down:
        indicatorAtTopNow = true;
        break;
      case AxisDirection.up:
        indicatorAtTopNow = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        indicatorAtTopNow = null;
        break;
    }
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_mode == _RefreshIndicatorMode.drag || _mode == _RefreshIndicatorMode.armed)
        _dismiss(_RefreshIndicatorMode.canceled);
    } else if (notification is ScrollUpdateNotification) {
      if (_mode == _RefreshIndicatorMode.drag || _mode == _RefreshIndicatorMode.armed) {
        if (notification.metrics.extentBefore > 0.0) {
          _dismiss(_RefreshIndicatorMode.canceled);
        } else {
          _dragOffset -= notification.scrollDelta;
          _checkDragOffset(notification.metrics.viewportDimension);
        }
      }
      if (_mode == _RefreshIndicatorMode.armed && notification.dragDetails == null) {
        // 在iOS上，当滚动条从overscroll反弹回来时，启动刷新（滚动通知指示没有dragDetails，因为滚动活动不是由拖动直接触发的）。
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_mode == _RefreshIndicatorMode.drag || _mode == _RefreshIndicatorMode.armed) {
        _dragOffset -= notification.overscroll / 2.0;
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_mode) {
        case _RefreshIndicatorMode.armed:
          _show();
          break;
        case _RefreshIndicatorMode.drag:
          _dismiss(_RefreshIndicatorMode.canceled);
          break;
        default:
          // do nothing
          break;
      }
    }
    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading)
      return false;
    if (_mode == _RefreshIndicatorMode.drag) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    assert(_mode == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case AxisDirection.down:
        _isIndicatorAtTop = true;
        break;
      case AxisDirection.up:
        _isIndicatorAtTop = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        _isIndicatorAtTop = null;
        // we do not support horizontal scroll views.
        return false;
    }
    _dragOffset = 0.0;
    _scaleController.value = 0.0;
    _positionController.value = 0.0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(_mode == _RefreshIndicatorMode.drag || _mode == _RefreshIndicatorMode.armed);
    double newValue = _dragOffset / (containerExtent * _kDragContainerExtentPercentage);
    if (_mode == _RefreshIndicatorMode.armed)
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    _positionController.value = newValue.clamp(0.0, 1.0); // this triggers various rebuilds
    if (_mode == _RefreshIndicatorMode.drag && _valueColor.value.alpha == 0xFF)
      _mode = _RefreshIndicatorMode.armed;
  }

  // Stop showing the refresh indicator.
  Future<void> _dismiss(_RefreshIndicatorMode newMode) async {
    await Future<void>.value();
    // This can only be called from _show() when refreshing and
    // _handleScrollNotification in response to a ScrollEndNotification or
    // direction change.
    assert(newMode == _RefreshIndicatorMode.canceled || newMode == _RefreshIndicatorMode.done);
    setState(() {
      _mode = newMode;
    });
    switch (_mode) {
      case _RefreshIndicatorMode.done:
        await _scaleController.animateTo(1.0, duration: _kIndicatorScaleDuration);
        break;
      case _RefreshIndicatorMode.canceled:
        await _positionController.animateTo(0.0, duration: _kIndicatorScaleDuration);
        break;
      default:
        assert(false);
    }
    if (mounted && _mode == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() {
        _mode = null;
      });
    }
  }

  void _show() {
    assert(_mode != _RefreshIndicatorMode.refresh);
    assert(_mode != _RefreshIndicatorMode.snap);
    final Completer<void> completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _mode = _RefreshIndicatorMode.snap;
    _positionController
      .animateTo(1.0 / _kDragSizeFactorLimit, duration: _kIndicatorSnapDuration)
      .then<void>((void value) {
        if (mounted && _mode == _RefreshIndicatorMode.snap) {
          assert(widget.onRefresh != null);
          setState(() {
            // 显示不确定的进度指示器。
            _mode = _RefreshIndicatorMode.refresh;
          });

          final Future<void> refreshResult = widget.onRefresh();
          assert(() {
            if (refreshResult == null)
              FlutterError.reportError(FlutterErrorDetails(
                exception: FlutterError(
                  'The onRefresh callback returned null.\n'
                  'The DYRefreshIndicator onRefresh callback must return a Future.'
                ),
                context: ErrorDescription('when calling onRefresh'),
                library: 'material library',
              ));
            return true;
          }());
          if (refreshResult == null)
            return;
          refreshResult.whenComplete(() {
            if (mounted && _mode == _RefreshIndicatorMode.refresh) {
              completer.complete();
              _dismiss(_RefreshIndicatorMode.done);
            }
          });
        }
      });
  }

  /// 显示刷新指示器并运行刷新回调，就好像它是以交互方式启动的一样。
  /// 如果在运行刷新回调时调用此方法，则它不会悄悄地执行任何操作。
  ///
  /// 使用[GlobalKey<RefreshIndicatorState>]创建[DYRefreshIndicator]
  /// 可以引用[RefreshIndicatorState]。
  ///
  /// 当[DYRefreshIndicator.onRefresh]回调的未来完成。
  ///
  /// 如果等待此函数从[State]返回的未来，则应在调用[setState]之前检查状态是否仍为[mounted]。
  /// 
  /// 以这种方式启动时，刷新指示器独立于任何实际的滚动视图。
  /// 它默认在顶部显示指示器。要在底部显示，请将“atTop”设置为false。
  Future<void> show({ bool atTop = true }) {
    if (_mode != _RefreshIndicatorMode.refresh &&
        _mode != _RefreshIndicatorMode.snap) {
      if (_mode == null)
        _start(atTop ? AxisDirection.down : AxisDirection.up);
      _show();
    }
    return _pendingRefreshFuture;
  }

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final Widget child = NotificationListener<ScrollNotification>(
      key: _key,
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: widget.child,
      ),
    );
    if (_mode == null) {
      assert(_dragOffset == null);
      assert(_isIndicatorAtTop == null);
      return child;
    }
    assert(_dragOffset != null);
    assert(_isIndicatorAtTop != null);

    final bool showIndeterminateIndicator =
      _mode == _RefreshIndicatorMode.refresh || _mode == _RefreshIndicatorMode.done;

    return Stack(
      children: <Widget>[
        child,
        Positioned(
          top: _isIndicatorAtTop ? 0.0 : null,
          bottom: !_isIndicatorAtTop ? 0.0 : null,
          left: 0.0,
          right: 0.0,
          child: SizeTransition(
            axisAlignment: _isIndicatorAtTop ? 1.0 : -1.0,
            sizeFactor: _positionFactor, // this is what brings it down
            child: Container(
              padding: _isIndicatorAtTop
                ? EdgeInsets.only(top: widget.displacement)
                : EdgeInsets.only(bottom: widget.displacement),
              alignment: _isIndicatorAtTop
                ? Alignment.topCenter
                : Alignment.bottomCenter,
              child: ScaleTransition(
                scale: _scaleFactor,
                child: AnimatedBuilder(
                  animation: _positionController,
                  builder: (BuildContext context, Widget child) {
                    return RefreshProgressIndicator(
                      semanticsLabel: widget.semanticsLabel ?? MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
                      semanticsValue: widget.semanticsValue,
                      value: showIndeterminateIndicator ? null : _value.value,
                      valueColor: _valueColor,
                      backgroundColor: widget.backgroundColor,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
