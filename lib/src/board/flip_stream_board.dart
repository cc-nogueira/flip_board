import 'dart:async';

import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';
import 'flip_board_builder.dart';

class FlipStreamBoard<T> extends StatefulWidget {
  const FlipStreamBoard({
    Key? key,
    this.initialValue,
    required this.itemStream,
    required this.itemBuilder,
    required this.width,
    required this.height,
    required this.columnCount,
    required this.rowCount,
    this.animationMillis = 2000,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  final T? initialValue;
  final Stream<T> itemStream;
  final ItemBuilder<T> itemBuilder;

  final double width;
  final double height;
  final int columnCount;
  final int rowCount;
  final int animationMillis;
  final Color backgroundColor;

  @override
  _FlipStreamBoardState<T> createState() => _FlipStreamBoardState<T>();
}

class _FlipStreamBoardState<T> extends State<FlipStreamBoard<T>> {
  final _controller = StreamController<T>.broadcast();
  late final StreamSubscription<T> _subscription;
  late final StreamFlipBoardBuilder<T> _builder;

  @override
  void initState() {
    super.initState();

    _builder = StreamFlipBoardBuilder<T>(
      initialValue: widget.initialValue,
      itemStream: _controller.stream,
      itemBuilder: widget.itemBuilder,
      width: widget.width,
      height: widget.height,
      columnCount: widget.columnCount,
      rowCount: widget.rowCount,
      animationMillis: widget.animationMillis,
      backgroundColor: widget.backgroundColor,
    );

    _subscription = widget.itemStream.listen(_onNewItem);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.close();
    super.dispose();
  }

  void _onNewItem(T value) => _controller.add(value);

  @override
  Widget build(BuildContext context) => _builder.build(context);
}
