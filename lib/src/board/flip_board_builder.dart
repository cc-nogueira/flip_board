import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';

final _random = Random();

abstract class FlipBoardBuilder<T> {
  const FlipBoardBuilder({
    required this.width,
    required this.height,
    required this.columnCount,
    required this.rowCount,
    this.animationMillis = 2000,
    this.backgroundColor = Colors.white,
  })  : assert(columnCount > 1),
        assert(rowCount > 0),
        widthSizeFactor = 1.0 / columnCount,
        widthAlignFactor = 2.0 / (columnCount - 1),
        heightSizeFactor = 1.0 / rowCount,
        heightAlignFactor = rowCount == 1 ? 1.0 : 2.0 / (rowCount - 1);

  final double width;
  final double height;
  final int columnCount;
  final int rowCount;
  final int animationMillis;
  final Color backgroundColor;

  final double widthSizeFactor;
  final double widthAlignFactor;
  final double heightSizeFactor;
  final double heightAlignFactor;

  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildRows(context),
      );

  List<Widget> _buildRows(BuildContext context) =>
      Iterable<int>.generate(rowCount)
          .map(
            (row) => Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildColumns(context, row),
            ),
          )
          .toList();

  List<Widget> _buildColumns(BuildContext context, int row) =>
      Iterable<int>.generate(columnCount)
          .map(
            (col) => VerticalFlipWidget<T>(
              initialValue: initialValue,
              itemStream: randomDelayedStream(),
              itemBuilder: (_, value) => value == null
                  ? Container(
                      color: backgroundColor,
                      width: widthSizeFactor * width,
                      height: heightSizeFactor * height,
                    )
                  : ClipRect(
                      child: Align(
                        alignment: Alignment(
                          -1.0 + col * widthAlignFactor,
                          -1.0 + row * heightAlignFactor,
                        ),
                        widthFactor: widthSizeFactor,
                        heightFactor: heightSizeFactor,
                        child: buildChild(context, value),
                      ),
                    ),
              spacing: 0.0,
              direction: _randomDirection(),
            ),
          )
          .toList();

  T? get initialValue => null;

  Stream<T> randomDelayedStream();

  Widget buildChild(BuildContext context, T value);

  VerticalDirection _randomDirection() => _random.nextInt(10).isEven
      ? VerticalDirection.up
      : VerticalDirection.down;
}

class SingleChildFlipBoardBuilder extends FlipBoardBuilder<Widget> {
  const SingleChildFlipBoardBuilder({
    required this.child,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    int animationMillis = 2000,
    Color backgroundColor = Colors.white,
  }) : super(
            width: width,
            height: height,
            columnCount: columnCount,
            rowCount: rowCount,
            animationMillis: animationMillis,
            backgroundColor: backgroundColor);

  final Widget child;

  @override
  Stream<Widget> randomDelayedStream() => Stream.fromFuture(
        Future.delayed(
          Duration(milliseconds: _random.nextInt(3000)),
          () => child,
        ),
      );

  @override
  Widget buildChild(BuildContext context, Widget value) => child;
}

class StreamFlipBoardBuilder<T> extends FlipBoardBuilder<T> {
  const StreamFlipBoardBuilder({
    this.initialValue,
    required this.itemStream,
    required this.itemBuilder,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    int animationMillis = 2000,
    Color backgroundColor = Colors.white,
  }) : super(
            width: width,
            height: height,
            columnCount: columnCount,
            rowCount: rowCount,
            animationMillis: animationMillis,
            backgroundColor: backgroundColor);

  @override
  final T? initialValue;

  final Stream<T> itemStream;
  final ItemBuilder<T> itemBuilder;

  @override
  Stream<T> randomDelayedStream() => itemStream.transform(_delayedTransformer);

  @override
  Widget buildChild(BuildContext context, T value) =>
      itemBuilder(context, value);

  StreamTransformer<T, T> get _delayedTransformer =>
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) async {
          await Future.delayed(
            Duration(milliseconds: _random.nextInt(animationMillis)),
            () => sink.add(data),
          );
        },
      );
}
