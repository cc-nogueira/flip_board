import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext buildContext, T? item);

/// FliWidget animates the display of items through flip animations.
///
/// Resembles a single Mechanical Flip Board display element, such as a digit or a letter,
/// but can actualy render any widget you build.
///
/// Constructor with three required parameters:
/// FlipWidget<T>(
///   required Stream<T> itemStream,        // Stream of items to flip as they arrive
///   required ItemBuilder<T> itemBuilder,  // Builder function to create a Widget of each item
///   required AxisDirection flipDirection, // Direction of flip
///
///   T? initialValue,           // Initial item to build before the first stream item
///   Duration flipDuration,     // Duration of the flip animation
///   double panelSpacing,       // Spacing betwewn the pair of widget panels
///   double perspectiveEffect,  // Perspective effect for the Transform Matrix4
///   VoidCallback onDone,       // Optional callback for onDone stream event
///   int startCount,            // Widget state count that allows the widget state to restart stream listening on widget update.
/// )
///
///
class FlipWidget<T> extends StatefulWidget {
  const FlipWidget({
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

  static const bounceFastFlip = _BounceFastFlipCurve();
  static const bounceSlowFlip = _BounceSlowFlipCurve();
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
  _FlipWidgetState<T> createState() => _FlipWidgetState<T>();
}

/// FlipWidget state class
///
/// Performs flip animations as widget.itemStream delivers items.
/// Parameters are documented in [FlipWidget] class constructor.
class _FlipWidgetState<T> extends State<FlipWidget<T>>
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

  Widget _buildFirstFlipPanel() => Stack(
        children: [
          _firstFlatPanel(widget.flipDirection),
          _transform2FirstPanel(widget.flipDirection),
        ],
      );

  Widget _buildSecondFlipPanel() => Stack(
        children: [
          _secondFlatPanel(widget.flipDirection),
          _transform2SecondPanel(widget.flipDirection),
        ],
      );

  Widget _firstFlatPanel(AxisDirection direction) =>
      direction == AxisDirection.up || direction == AxisDirection.left
          ? _firstPanelChild1
          : _firstPanelChild2;

  Widget _secondFlatPanel(AxisDirection direction) =>
      direction == AxisDirection.up || direction == AxisDirection.left
          ? _secondPanelChild2
          : _secondPanelChild1;

  Transform _transform2FirstPanel(AxisDirection direction) {
    final isPastMiddle = _flipAnimation.value > _piBy2;
    final isVertical = widget.axis == Axis.vertical;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;
    final sign = isVertical ? 1.0 : -1.0;
    late final double rotation;
    if (isUpOrLeft) {
      rotation =
          (isPastMiddle ? math.pi - _flipAnimation.value : _piBy2) * sign;
    } else {
      rotation = (!isPastMiddle ? _flipAnimation.value : _piBy2) * sign;
    }

    final transform = Matrix4.identity()
      ..setEntry(3, 2, _perspectiveAnimation.value);

    if (isVertical) {
      transform.rotateX(rotation);
    } else {
      transform.rotateY(rotation);
    }
    return Transform(
      alignment: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
      transform: transform,
      child: isUpOrLeft ? _firstPanelChild2 : _firstPanelChild1,
    );
  }

  Transform _transform2SecondPanel(AxisDirection direction) {
    final isPastMiddle = _flipAnimation.value > _piBy2;
    final isAxisVertical = widget.axis == Axis.vertical;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;
    final sign = isAxisVertical ? 1.0 : -1.0;
    late final double rotation;
    if (isUpOrLeft) {
      rotation = (isPastMiddle ? _piBy2 : _flipAnimation.value) * sign;
    } else {
      rotation =
          (isPastMiddle ? math.pi - _flipAnimation.value : _piBy2) * sign;
    }

    final transform = Matrix4.identity()
      ..setEntry(3, 2, -_perspectiveAnimation.value);

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

class _BounceFastFlipCurve extends Curve {
  const _BounceFastFlipCurve();

  static const factor_1 = 121.0 / 49.0;
  static const factor_2 = 121.0 / 16.0;
  static const factor_3 = 121.0 / 4.0;

  @override
  double transformInternal(double t) => _bounce(t);

  double _bounce(double t) {
    if (t < 1.75 / 2.75) {
      return factor_1 * t * t;
    } else if (t < 2.5 / 2.75) {
      t -= 2.125 / 2.75;
      return factor_2 * t * t + 0.859375;
    }
    t -= 2.625 / 2.75;
    return factor_3 * t * t + 0.9375;
  }
}

class _BounceSlowFlipCurve extends Curve {
  const _BounceSlowFlipCurve();

  static const factor_1 = 121.0 / 64.0;
  static const factor_2 = 121.0 / 8.0;
  static const factor_3 = 121.0 / 4.0;

  @override
  double transformInternal(double t) => _bounce(t);

  double _bounce(double t) {
    if (t < 2.0 / 2.75) {
      return factor_1 * t * t;
    } else if (t < 2.5 / 2.75) {
      t -= 2.25 / 2.75;
      return factor_2 * t * t + 0.875;
    }
    t -= 2.625 / 2.75;
    return factor_3 * t * t + 0.9375;
  }
}
