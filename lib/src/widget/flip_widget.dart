import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext buildContext, T? item);

/// FliWidget animates the display of items through flip animations.
///
/// Resembles a single Mechanical Flip Board display element, such as a digit or a letter,
/// but can actualy render any widget you build.
class FlipWidget<T> extends StatefulWidget {
  const FlipWidget({
    Key? key,
    required this.itemStream,
    required this.itemBuilder,
    required this.direction,
    this.initialValue,
    this.duration = const Duration(milliseconds: 300),
    this.spacing = 0.0,
    this.perspectiveEffect = 0.006,
    this.onDone,
    this.startCount = 0,
  }) : super(key: key);

  final Stream<T> itemStream;
  final ItemBuilder<T> itemBuilder;
  final T? initialValue;
  final Duration duration;
  final AxisDirection direction;
  final double spacing;
  final double perspectiveEffect;
  final void Function()? onDone;
  final int startCount;

  Axis get axis => axisDirectionToAxis(direction);

  @override
  FlipWidgetState<T> createState() => FlipWidgetState<T>();
}

class FlipWidgetState<T> extends State<FlipWidget<T>>
    with SingleTickerProviderStateMixin {
  final _clipper = _WidgetClipper();

  late final AnimationController _controller;
  late final Animation _animation;
  late final Animation _perspectiveAnimation;
  StreamSubscription<T>? _subscription;

  late bool _isReversePhase;
  late bool _running;
  late bool _firstRun;

  T? _currentValue, _nextValue;

  late Widget _nextChild;
  late Widget _firstPanelChild1, _firstPanelChild2;
  late Widget _secondPanelChild1, _secondPanelChild2;

  @override
  void initState() {
    super.initState();
    _isReversePhase = false;
    _running = false;

    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isReversePhase = true;
          _controller.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          _currentValue = _nextValue ?? _currentValue;
          _running = false;
        }
      })
      ..addListener(_onRun);

    _animation = Tween(begin: 0.0, end: math.pi / 2).animate(_controller);
    _perspectiveAnimation =
        Tween(begin: 0.0, end: widget.perspectiveEffect).animate(_controller);

    _initValues();
  }

  void _initValues() {
    _currentValue = widget.initialValue;
    _firstRun = true;
    _subscription?.cancel();
    _subscription =
        widget.itemStream.distinct().listen(_onNewItem, onDone: widget.onDone);
  }

  @override
  void didUpdateWidget(covariant FlipWidget<T> oldWidget) {
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

  void _onRun() {
    setState(() => _running = true);
  }

  void _onNewItem(T value) {
    if (value != _currentValue) {
      _nextValue = value;
      _isReversePhase = false;
      _controller.forward(); // will trigger _onRun
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildChildWidgets(context);
    return _buildDisplay();
  }

  void _buildChildWidgets(BuildContext context) {
    if (_firstRun) {
      _initChildWidgets(context);
      _firstRun = false;
    }

    if (_running) {
      _nextChild = widget.itemBuilder(context, _nextValue);
      _firstPanelChild2 = _clipper.makeFirstClip(_nextChild, widget.axis);
      _secondPanelChild2 = _clipper.makeSecondClip(_nextChild, widget.axis);
    } else {
      _firstPanelChild1 = _firstPanelChild2;
      _secondPanelChild1 = _secondPanelChild2;
    }
  }

  void _initChildWidgets(BuildContext context) {
    _nextChild = widget.itemBuilder(context, widget.initialValue);
    _firstPanelChild2 = _clipper.makeFirstClip(_nextChild, widget.axis);
    _secondPanelChild2 = _clipper.makeSecondClip(_nextChild, widget.axis);
    _firstPanelChild1 = _firstPanelChild2;
    _secondPanelChild1 = _secondPanelChild2;
  }

  Widget _buildDisplay() {
    final children = _running
        ? [
            _buildFirstFlipPanel(),
            Padding(
              padding: EdgeInsets.only(
                top: widget.spacing,
                left: widget.spacing,
              ),
            ),
            _buildSecondFlipPanel(),
          ]
        : [
            _transform1FirstPanel(AxisDirection.up),
            Padding(
              padding: EdgeInsets.only(
                top: widget.spacing,
                left: widget.spacing,
              ),
            ),
            _transform1SecondPanel(AxisDirection.down),
          ];

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

  Widget _buildFirstFlipPanel() => Stack(
        children: [
          _transform1FirstPanel(widget.direction),
          _transform2FirstPanel(widget.direction),
        ],
      );

  Widget _buildSecondFlipPanel() => Stack(
        children: [
          _transform1SecondPanel(widget.direction),
          _transform2SecondPanel(widget.direction),
        ],
      );

  Transform _transform1FirstPanel(AxisDirection direction) => Transform(
      alignment: widget.axis == Axis.vertical
          ? Alignment.bottomCenter
          : Alignment.centerRight,
      transform: Matrix4.identity()
        ..setEntry(3, 2, _perspectiveAnimation.value),
      child: direction == AxisDirection.up || direction == AxisDirection.left
          ? _firstPanelChild1
          : _firstPanelChild2);

  Transform _transform1SecondPanel(AxisDirection direction) => Transform(
      alignment: widget.axis == Axis.vertical
          ? Alignment.topCenter
          : Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, _perspectiveAnimation.value),
      child: direction == AxisDirection.up || direction == AxisDirection.left
          ? _secondPanelChild2
          : _secondPanelChild1);

  Transform _transform2FirstPanel(AxisDirection direction) {
    final isAxisVertical = widget.axis == Axis.vertical;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;
    final sign = isAxisVertical ? 1.0 : -1.0;
    final rotation =
        (isUpOrLeft == _isReversePhase ? _animation.value : math.pi / 2) * sign;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, _perspectiveAnimation.value);

    if (isAxisVertical) {
      transform.rotateX(rotation);
    } else {
      transform.rotateY(rotation);
    }
    return Transform(
      alignment:
          isAxisVertical ? Alignment.bottomCenter : Alignment.centerRight,
      transform: transform,
      child: isUpOrLeft ? _firstPanelChild2 : _firstPanelChild1,
    );
  }

  Transform _transform2SecondPanel(AxisDirection direction) {
    final isAxisVertical = widget.axis == Axis.vertical;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;
    final sign = isAxisVertical ? 1.0 : -1.0;
    final rotation =
        (isUpOrLeft == _isReversePhase ? math.pi / 2 : -_animation.value) *
            sign;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, _perspectiveAnimation.value);

    if (isAxisVertical) {
      transform.rotateX(rotation);
    } else {
      transform.rotateY(rotation);
    }

    return Transform(
      alignment: isAxisVertical ? Alignment.topCenter : Alignment.centerLeft,
      transform: transform,
      child: isUpOrLeft ? _secondPanelChild1 : _secondPanelChild2,
    );
  }
}

class _WidgetClipper {
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
