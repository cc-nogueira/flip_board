import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext buildContext, T? item);

class VerticalFlipWidget<T> extends StatefulWidget {
  const VerticalFlipWidget({
    Key? key,
    required this.itemStream,
    required this.itemBuilder,
    this.initialValue,
    this.direction = VerticalDirection.down,
    this.duration = const Duration(milliseconds: 300),
    this.spacing = 0.0,
    this.perspectiveEffect = 0.006,
  }) : super(key: key);

  final Stream<T> itemStream;
  final ItemBuilder<T> itemBuilder;
  final T? initialValue;
  final Duration duration;
  final VerticalDirection direction;
  final double spacing;
  final double perspectiveEffect;

  @override
  VerticalFlipWidgetState<T> createState() => VerticalFlipWidgetState<T>();
}

class VerticalFlipWidgetState<T> extends State<VerticalFlipWidget<T>>
    with SingleTickerProviderStateMixin {
  final _clipper = WidgetClipper();

  late final AnimationController _controller;
  late final Animation _animation;
  late final Animation _perspectiveAnimation;
  late final StreamSubscription<T> _subscription;

  late bool _isReversePhase;
  late bool _running;
  late bool _firstRun;

  T? _currentValue, _nextValue;

  late Widget _child2;
  late Widget _upperChild1, _upperChild2;
  late Widget _lowerChild1, _lowerChild2;

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

    _currentValue = widget.initialValue;
    _subscription = widget.itemStream.distinct().listen(_onNewItem);
    _firstRun = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  void _onRun() {
    setState(() => _running = true);
  }

  void _onNewItem(T value) {
    if (_currentValue == null) {
      _currentValue = value;
    } else if (value != _currentValue) {
      _nextValue = value;
      _isReversePhase = false;
      _controller.forward(); // will trigger _onRun
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildChildWidgets(context);
    return _buildPanel();
  }

  void _initChildWidgets(BuildContext context) {
    _child2 = widget.itemBuilder(context, widget.initialValue);
    _upperChild2 = _clipper.makeUpperClip(_child2);
    _lowerChild2 = _clipper.makeLowerClip(_child2);
    _upperChild1 = _upperChild2;
    _lowerChild1 = _lowerChild2;
  }

  void _buildChildWidgets(BuildContext context) {
    if (_firstRun) {
      _initChildWidgets(context);
      _firstRun = false;
    }

    if (_running) {
      _child2 = widget.itemBuilder(context, _nextValue);
      _upperChild2 = _clipper.makeUpperClip(_child2);
      _lowerChild2 = _clipper.makeLowerClip(_child2);
    } else {
      _upperChild1 = _upperChild2;
      _lowerChild1 = _lowerChild2;
    }
  }

  Widget _buildPanel() {
    return _running
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUpperFlipPanel(),
              Padding(padding: EdgeInsets.only(top: widget.spacing)),
              _buildLowerFlipPanel(),
            ],
          )
        : _currentValue == null
            ? Container()
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _transform1UpperPanel(VerticalDirection.up),
                  Padding(padding: EdgeInsets.only(top: widget.spacing)),
                  _transform1LowerPanel(VerticalDirection.down),
                ],
              );
  }

  Widget _buildUpperFlipPanel() => Stack(
        children: [
          _transform1UpperPanel(widget.direction),
          _transform2UpperPanel(widget.direction),
        ],
      );

  Widget _buildLowerFlipPanel() => Stack(
        children: [
          _transform1LowerPanel(widget.direction),
          _transform2LowerPanel(widget.direction),
        ],
      );

  Transform _transform1UpperPanel(VerticalDirection direction) => Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, _perspectiveAnimation.value),
      child: direction == VerticalDirection.up ? _upperChild1 : _upperChild2);

  Transform _transform1LowerPanel(VerticalDirection direction) => Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, _perspectiveAnimation.value),
      child: direction == VerticalDirection.up ? _lowerChild2 : _lowerChild1);

  Transform _transform2UpperPanel(VerticalDirection direction) {
    final isUp = direction == VerticalDirection.up;
    final rotX = isUp == _isReversePhase ? _animation.value : math.pi / 2;
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, _perspectiveAnimation.value)
        ..rotateX(rotX),
      child: isUp ? _upperChild2 : _upperChild1,
    );
  }

  Transform _transform2LowerPanel(VerticalDirection direction) {
    final isUp = direction == VerticalDirection.up;
    final rotX = isUp == _isReversePhase ? math.pi / 2 : -_animation.value;
    return Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, _perspectiveAnimation.value)
        ..rotateX(rotX),
      child: isUp ? _lowerChild1 : _lowerChild2,
    );
  }
}

class WidgetClipper {
  Widget makeUpperClip(Widget widget) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.5,
        child: widget,
      ),
    );
  }

  Widget makeLowerClip(Widget widget) {
    return ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 0.5,
        child: widget,
      ),
    );
  }
}
