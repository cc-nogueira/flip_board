import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext buildContext, T? item);

/// There two types of Flip Animations for [FlipWidget].
///
/// - middleFlip is used for FlipWidgets that flip in the middle, like Mechanical Flip Boards do.
/// - spinFlip is used for FlipWidgets that flip like cards do (roll flip).
enum FlipType {
  middleFlip,
  spinFlip,
}

/// FliWidget animates the display of items through flip animations.
///
/// Depending on the flipType parameter it will animate diferently:
///  - with middleFlip type it resembles a single Mechanical Flip Board display element.
///  - with spinFlip type it animates as a regular roll flip.
///
/// It is usually used to flip letters, digits and images but can actually be used to flip any widget change.
class FlipWidget<T> extends StatefulWidget {
  /// FlipWidget constructor.
  ///
  /// Four required parameters:
  ///   required FlipType flipType,           // Either FlipType.middleFlip or FlipType.spinFlip
  ///   required Stream<T> itemStream,        // Stream of items that will be built and flipped into view
  ///   required ItemBuilder<T> itemBuilder,  // Builder to construct widgets out of stream items
  ///   required AxisDirection flipDirection, // Direction of the flip animation
  ///
  /// And a number of optional parameters:
  ///   T? initialValue,           // Initial value to be displayed before the first animation
  ///   Duration flipDuration,     // Duration of the flip animation
  ///   Curve flipCurve            // Curve for flip animation, defaults to Curves.easeInOut
  ///   double hingeWidth          // Width of the middle hinge element, defaults to zero (must pair with lenth)
  ///   double hingeLength         // Length of the middle hinge element, default to zero (must pair with width)
  ///   Color hingeColor           // Color of the middle hinge element, defaults to null (transparent)
  ///   double perspectiveEffect,  // Perspective effect for the Transform Matrix4, defaults to 0.006
  ///   VoidCallback onDone,       // Optional callback for onDone stream event
  ///   int startCount,            // Widget state count that allows the widget state to restart stream listening on widget update.
  const FlipWidget({
    Key? key,
    required this.flipType,
    required this.itemStream,
    required this.itemBuilder,
    required this.flipDirection,
    this.initialValue,
    this.flipDuration = const Duration(milliseconds: 800),
    this.flipCurve = Curves.easeInOut,
    this.hingeWidth = 0.0,
    this.hingeLength = 0.0,
    this.hingeColor,
    this.perspectiveEffect = 0.006,
    this.onDone,
    this.startCount = 0,
  })  : assert(hingeWidth == 0.0 && hingeLength == 0.0 ||
            hingeWidth != 0.0 && hingeLength != 0.0),
        assert(hingeColor == null || hingeWidth != 0.0),
        super(key: key);

  /// Custom animation Curve for a fast bounce effect (bang! effect).
  static const bounceFastFlip = _BounceFastFlipCurve();

  /// Custom animation animation for a slow bounce effect (slow bang! effect).
  static const bounceSlowFlip = _BounceSlowFlipCurve();

  /// Default animation Curve.
  static const defaultFlip = Curves.easeInOut;

  /// Defines the type of animation.
  ///
  /// - middleFlip is used for FlipWidgets that flip in the middle, like Mechanical Flip Boards do.
  /// - spinFlip is used for FlipWidgets that flip like cards do (roll flip).
  final FlipType flipType;

  /// Stream of items that will be built and flipped into view.
  final Stream<T> itemStream;

  /// Builder to construct widgets out of stream items.
  final ItemBuilder<T> itemBuilder;

  /// Direction of the flip animation.
  final AxisDirection flipDirection;

  /// Optional initial value to be displayed before the first animation.
  final T? initialValue;

  /// Duration of the flip animation.
  final Duration flipDuration;

  /// Curve for the flip animation.
  ///
  /// Defaults to Curves.easeInOut
  final Curve flipCurve;

  /// Width of the middle hinge element.
  ///
  /// Defaults to zero
  final double hingeWidth;

  /// Length of the middle hinge element.
  ///
  /// Defaults to zero
  final double hingeLength;

  /// Color of the middle hinge element.
  ///
  /// Defaults to null, rendering a transparent hinge (trasnparent separator)
  final Color? hingeColor;

  /// Perspective effect for the Transform Matrix4.
  ///
  /// Defaults to 0.006
  final double perspectiveEffect;

  /// Optional callback for onDone stream event.
  final VoidCallback? onDone;

  /// Widget state count flag.
  ///
  /// Allows this widget state to restart stream listening on widget update.
  final int startCount;

  /// Axis of my flipDirection.
  Axis get axis => axisDirectionToAxis(flipDirection);

  @override
  State<FlipWidget<T>> createState() => flipType == FlipType.middleFlip
      ? _MiddleFlipWidgetState<T>()
      : _SpinFlipWidgetState<T>();
}

abstract class _FlipWidgetState<T> extends State<FlipWidget<T>>
    with SingleTickerProviderStateMixin {
  static const _piBy2 = math.pi / 2;

  final _clipper = const _WidgetClipper();

  late final AnimationController _controller;
  late final Animation _flipAnimation;
  late final Animation _perspectiveAnimation;
  StreamSubscription<T>? _subscription;

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

    initValues();
  }

  @override
  void didUpdateWidget(covariant FlipWidget<T> oldWidget) {
    if (oldWidget.startCount != widget.startCount) {
      initValues();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void initValues() {
    _nextValue = widget.initialValue;
    _firstRun = true;
    _subscription?.cancel();
    _subscription = widget.itemStream.listen(_onNewItem, onDone: widget.onDone);
  }

  void initChildWidgets(BuildContext context) {
    _nextChild = widget.itemBuilder(context, widget.initialValue);
    _firstPanelChild2 = _clipper.makeFirstClip(_nextChild, widget.axis);
    _secondPanelChild2 = _clipper.makeSecondClip(_nextChild, widget.axis);
    _firstPanelChild1 = _firstPanelChild2;
    _secondPanelChild1 = _secondPanelChild2;
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
      initChildWidgets(context);
      children = [
        firstFlatPanel(AxisDirection.up),
        _hinge,
        secondFlatPanel(AxisDirection.down),
      ];
    } else {
      children = [
        buildFirstFlipPanel(),
        _hinge,
        buildSecondFlipPanel(),
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

  Widget get _hinge {
    return widget.axis == Axis.vertical
        ? Container(
            height: widget.hingeWidth,
            width: widget.hingeLength,
            color: widget.hingeColor,
          )
        : Container(
            height: widget.hingeLength,
            width: widget.hingeWidth,
            color: widget.hingeColor,
          );
  }

  Widget buildFirstFlipPanel();

  Widget buildSecondFlipPanel();

  Widget firstFlatPanel(AxisDirection direction) =>
      direction == AxisDirection.up || direction == AxisDirection.left
          ? _firstPanelChild1
          : _firstPanelChild2;

  Widget secondFlatPanel(AxisDirection direction) =>
      direction == AxisDirection.up || direction == AxisDirection.left
          ? _secondPanelChild2
          : _secondPanelChild1;

  Transform? transform2FirstPanel(AxisDirection direction);

  Transform? transform2SecondPanel(AxisDirection direction);
}

/// FlipWidget state class.
///
/// Performs flip animations as widget.itemStream delivers items.
/// Parameters are documented in [FlipWidget] class constructor.
class _MiddleFlipWidgetState<T> extends _FlipWidgetState<T> {
  @override
  Widget buildFirstFlipPanel() {
    final flatPanel = firstFlatPanel(widget.flipDirection);
    final movingPanel = transform2FirstPanel(widget.flipDirection);
    return movingPanel == null
        ? flatPanel
        : Stack(children: [flatPanel, movingPanel]);
  }

  @override
  Widget buildSecondFlipPanel() {
    final flatPanel = secondFlatPanel(widget.flipDirection);
    final movingPanel = transform2SecondPanel(widget.flipDirection);
    return movingPanel == null
        ? flatPanel
        : Stack(children: [flatPanel, movingPanel]);
  }

  @override
  Transform? transform2FirstPanel(AxisDirection direction) {
    final isPastMiddle = _flipAnimation.value > _FlipWidgetState._piBy2;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;
    if (isUpOrLeft != isPastMiddle) return null;

    final isVertical = widget.axis == Axis.vertical;
    final sign = isVertical ? 1.0 : -1.0;
    final rotation = sign *
        (isUpOrLeft ? math.pi - _flipAnimation.value : _flipAnimation.value);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, _perspectiveAnimation.value);

    late final Offset originOffset;
    if (isVertical) {
      transform.rotateX(rotation);
      originOffset = Offset(0.0, widget.hingeWidth / 2);
    } else {
      transform.rotateY(rotation);
      originOffset = Offset(widget.hingeWidth / 2, 0.0);
    }
    return Transform(
      alignment: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
      origin: originOffset,
      transform: transform,
      child: isUpOrLeft ? _firstPanelChild2 : _firstPanelChild1,
    );
  }

  @override
  Transform? transform2SecondPanel(AxisDirection direction) {
    final isPastMiddle = _flipAnimation.value > _FlipWidgetState._piBy2;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;
    if (isUpOrLeft == isPastMiddle) return null;

    final isAxisVertical = widget.axis == Axis.vertical;
    final sign = isAxisVertical ? 1.0 : -1.0;
    final rotation = sign *
        (isUpOrLeft ? _flipAnimation.value : math.pi - _flipAnimation.value);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, -_perspectiveAnimation.value);

    late final Offset originOffset;
    if (isAxisVertical) {
      transform.rotateX(rotation);
      originOffset = Offset(0.0, -widget.hingeWidth);
    } else {
      transform.rotateY(rotation);
      originOffset = Offset(-widget.hingeWidth, 0.0);
    }

    return Transform(
      alignment: isAxisVertical ? Alignment.topCenter : Alignment.centerLeft,
      origin: originOffset,
      transform: transform,
      child: isUpOrLeft ? _secondPanelChild1 : _secondPanelChild2,
    );
  }
}

class _SpinFlipWidgetState<T> extends _FlipWidgetState<T> {
  @override
  Widget buildFirstFlipPanel() {
    final movingPanel = transform2FirstPanel(widget.flipDirection);
    return movingPanel ?? firstFlatPanel(widget.flipDirection);
  }

  @override
  Widget buildSecondFlipPanel() {
    final movingPanel = transform2SecondPanel(widget.flipDirection);
    return movingPanel ?? secondFlatPanel(widget.flipDirection);
  }

  @override
  Transform? transform2FirstPanel(AxisDirection direction) {
    final isPastMiddle = _flipAnimation.value > _FlipWidgetState._piBy2;
    final isVertical = widget.axis == Axis.vertical;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;

    final sign = isVertical ? 1.0 : -1.0;
    final rotation =
        sign * (isUpOrLeft ? -_flipAnimation.value : _flipAnimation.value) +
            (isPastMiddle ? math.pi : 0.0);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, _perspectiveAnimation.value);

    late final Offset originOffset;
    if (isVertical) {
      transform.rotateX(rotation);
      originOffset = Offset(0.0, widget.hingeWidth / 2);
    } else {
      transform.rotateY(rotation);
      originOffset = Offset(widget.hingeWidth / 2, 0.0);
    }

    return Transform(
      alignment: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
      origin: originOffset,
      transform: transform,
      child: isPastMiddle ? _firstPanelChild2 : _firstPanelChild1,
    );
  }

  @override
  Transform? transform2SecondPanel(AxisDirection direction) {
    final isPastMiddle = _flipAnimation.value > _FlipWidgetState._piBy2;
    final isVertical = widget.axis == Axis.vertical;
    final isUpOrLeft =
        direction == AxisDirection.up || direction == AxisDirection.left;

    final sign = isVertical ? 1.0 : -1.0;
    final rotation =
        sign * (isUpOrLeft ? _flipAnimation.value : -_flipAnimation.value) +
            (isPastMiddle ? math.pi : 0.0);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, -_perspectiveAnimation.value);

    late final Offset originOffset;
    if (isVertical) {
      transform.rotateX(rotation);
      originOffset = Offset(0.0, -widget.hingeWidth / 2);
    } else {
      transform.rotateY(rotation);
      originOffset = Offset(-widget.hingeWidth / 2, 0.0);
    }

    return Transform(
      alignment: isVertical ? Alignment.topCenter : Alignment.centerLeft,
      origin: originOffset,
      transform: transform,
      child: isPastMiddle ? _secondPanelChild2 : _secondPanelChild1,
    );
  }
}

/// Helper class to clip each flip panel rectangle.
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
