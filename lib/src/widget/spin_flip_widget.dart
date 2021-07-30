import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'flip_widget.dart';

class SpinFlipWidget<T> extends StatefulWidget {
  const SpinFlipWidget({
    Key? key,
    required this.itemStream,
    required this.itemBuilder,
    required this.flipDirection,
    this.initialValue,
    this.flipDuration = const Duration(milliseconds: 800),
    this.flipCurve = Curves.easeInOut,
    this.panelSpacing = 0.0,
    this.perspectiveEffect = 0.006,
    this.onDone,
    this.startCount = 0,
  }) : super(key: key);

  static const defaultFlip = Curves.easeInOut;

  final Stream<T> itemStream;
  final ItemBuilder<T> itemBuilder;
  final AxisDirection flipDirection;
  final T? initialValue;
  final Duration flipDuration;
  final Curve flipCurve;
  final double panelSpacing;
  final double perspectiveEffect;
  final VoidCallback? onDone;
  final int startCount;

  Axis get axis => axisDirectionToAxis(flipDirection);

  @override
  _SpinFlipWidgetState<T> createState() => _SpinFlipWidgetState<T>();
}

/// FlipWidget state class
///
/// Performs flip animations as widget.itemStream delivers items.
/// Parameters are documented in [SpinFlipWidget] class constructor.
class _SpinFlipWidgetState<T> extends State<SpinFlipWidget<T>>
    with SingleTickerProviderStateMixin {
  static const _piBy2 = math.pi / 2;

  final _clipper = const _WidgetClipper();

  late final AnimationController _controller;
  late final Animation _flipAnimation;
  late final Animation _perspectiveAnimation;
  StreamSubscription<T>? _subscription;

  // late bool _isReversePhase;
  late bool _firstRun;

  T? _nextValue;

  late Widget _nextChild;
  late Widget _firstPanelChild1, _firstPanelChild2;
  late Widget _secondPanelChild1, _secondPanelChild2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.flipDuration,
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.flipCurve,
    );
    _flipAnimation = Tween(begin: 0.0, end: math.pi).animate(curvedAnimation);
    _perspectiveAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(
            begin: 0.0,
            end: widget.perspectiveEffect,
          ),
          weight: 1.0),
      TweenSequenceItem(
          tween: Tween(
            begin: widget.perspectiveEffect,
            end: 0.0,
          ),
          weight: 1.0),
    ]).animate(curvedAnimation);

    _initValues();
  }

  void _initValues() {
    _nextValue = widget.initialValue;
    _firstRun = true;
    _subscription?.cancel();
    _subscription = widget.itemStream.listen(_onNewItem, onDone: widget.onDone);
  }

  @override
  void didUpdateWidget(covariant SpinFlipWidget<T> oldWidget) {
    if (oldWidget.startCount != widget.startCount) {
      _initValues();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _onNewItem(T value) {
    if (value != _nextValue) {
      _nextValue = value;
      _nextChild = widget.itemBuilder(context, _nextValue);
      _firstPanelChild1 = _firstPanelChild2;
      _secondPanelChild1 = _secondPanelChild2;
      _firstPanelChild2 = _clipper.makeFirstClip(_nextChild, widget.axis);
      _secondPanelChild2 = _clipper.makeSecondClip(_nextChild, widget.axis);

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedBuilder(animation: _flipAnimation, builder: _buildDisplay);

  Widget _buildDisplay(BuildContext context, Widget? _) {
    late final List<Widget> children;
    if (_firstRun) {
      _firstRun = false;
      _initChildWidgets(context);
      children = [
        _firstFlatPanel(AxisDirection.up),
        _padding,
        _secondFlatPanel(AxisDirection.down),
      ];
    } else {
      children = [
        _buildFirstFlipPanel(),
        _padding,
        _buildSecondFlipPanel(),
      ];
    }

    return widget.axis == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          );
  }

  void _initChildWidgets(BuildContext context) {
    _nextChild = widget.itemBuilder(context, widget.initialValue);
    _firstPanelChild2 = _clipper.makeFirstClip(_nextChild, widget.axis);
    _secondPanelChild2 = _clipper.makeSecondClip(_nextChild, widget.axis);
    _firstPanelChild1 = _firstPanelChild2;
    _secondPanelChild1 = _secondPanelChild2;
  }

  Widget get _padding => Padding(
        padding: EdgeInsets.only(
          top: widget.panelSpacing,
          left: widget.panelSpacing,
        ),
      );

  Widget _buildFirstFlipPanel() {
    final flatPanel = _firstFlatPanel(widget.flipDirection);
    final movingPanel = _transform2FirstPanel(widget.flipDirection);
    return movingPanel ?? flatPanel;
  }

  Widget _buildSecondFlipPanel() {
    final flatPanel = _secondFlatPanel(widget.flipDirection);
    final movingPanel = _transform2SecondPanel(widget.flipDirection);
    return movingPanel ?? flatPanel;
  }

  Widget _firstFlatPanel(AxisDirection direction) =>
      direction == AxisDirection.up || direction == AxisDirection.left
          ? _firstPanelChild1
          : _firstPanelChild2;

  Widget _secondFlatPanel(AxisDirection direction) =>
      direction == AxisDirection.up || direction == AxisDirection.left
          ? _secondPanelChild2
          : _secondPanelChild1;

  Transform? _transform2FirstPanel(AxisDirection direction) {
    final isPastMiddle = _flipAnimation.value > _piBy2;
    final isVertical = widget.axis == Axis.vertical;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;

    final sign = isVertical ? 1.0 : -1.0;
    final rotation =
        sign * (isUpOrLeft ? -_flipAnimation.value : _flipAnimation.value);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, _perspectiveAnimation.value);

    if (isVertical) {
      if (isPastMiddle) {
        transform.rotateX(math.pi);
      }
      transform.rotateX(rotation);
    } else {
      if (isPastMiddle) {
        transform.rotateY(math.pi);
      }
      transform.rotateY(rotation);
    }
    return Transform(
      alignment: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
      transform: transform,
      child: isPastMiddle ? _firstPanelChild2 : _firstPanelChild1,
    );
  }

  Transform? _transform2SecondPanel(AxisDirection direction) {
    final isPastMiddle = _flipAnimation.value > _piBy2;
    final isVertical = widget.axis == Axis.vertical;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;

    final sign = isVertical ? 1.0 : -1.0;
    final rotation =
        sign * (isUpOrLeft ? _flipAnimation.value : -_flipAnimation.value);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, -_perspectiveAnimation.value);

    if (isVertical) {
      if (isPastMiddle) {
        transform.rotateX(math.pi);
      }
      transform.rotateX(rotation);
    } else {
      if (isPastMiddle) {
        transform.rotateY(math.pi);
      }
      transform.rotateY(rotation);
    }

    return Transform(
      alignment: isVertical ? Alignment.topCenter : Alignment.centerLeft,
      transform: transform,
      child: isPastMiddle ? _secondPanelChild2 : _secondPanelChild1,
    );
  }
}

/// Helper class to clip each flip panel rectangle
class _WidgetClipper {
  const _WidgetClipper();

  Widget makeFirstClip(Widget widget, Axis axis) =>
      axis == Axis.horizontal ? makeLeftClip(widget) : makeUpperClip(widget);

  Widget makeSecondClip(Widget widget, Axis axis) =>
      axis == Axis.horizontal ? makeRightClip(widget) : makeLowerClip(widget);

  Widget makeUpperClip(Widget widget) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 0.5,
          child: widget,
        ),
      );

  Widget makeLowerClip(Widget widget) => ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 0.5,
          child: widget,
        ),
      );

  Widget makeLeftClip(Widget widget) => ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 0.5,
          child: widget,
        ),
      );

  Widget makeRightClip(Widget widget) => ClipRect(
        child: Align(
          alignment: Alignment.centerRight,
          widthFactor: 0.5,
          child: widget,
        ),
      );
}
