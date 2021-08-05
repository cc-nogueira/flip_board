import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';

final _random = Random();

/// Abstract class with common code building FlipMatrixBoards either
/// for SingleChild or for Stream classes.
///
/// Used by [FlipMatrixBoardSingleChild] and [FlipMatrixBoardStream].
abstract class FlipMatrixBoardBuilder<T> {
  /// Constructor where all parameters are required.
  ///
  /// Default values should be defined in composing classes.
  const FlipMatrixBoardBuilder({
    required this.axis,
    required this.width,
    required this.height,
    required this.columnCount,
    required this.rowCount,
    required this.minAnimationMillis,
    required this.maxAnimationMillis,
    required this.maxDelayMillis,
    this.backgroundColor,
  })  : assert(columnCount > 1),
        assert(rowCount > 0),
        assert(minAnimationMillis <= maxAnimationMillis),
        _widthSizeFactor = 1.0 / columnCount,
        _widthAlignFactor = 2.0 / (columnCount - 1),
        _heightSizeFactor = 1.0 / rowCount,
        _heightAlignFactor = rowCount == 1 ? 1.0 : 2.0 / (rowCount - 1);

  /// Flip animation axis.
  ///
  /// Flip direction will be random on this axis.
  final Axis axis;

  /// Whole widget width.
  final double width;

  /// Whole widget height.
  final double height;

  /// Number of columns of the display matrix.
  final int columnCount;

  // Number of rows of the display matrix.
  final int rowCount;

  /// Minimum animation duration for the generated random value.
  final int minAnimationMillis;

  /// Max animation duration for the generated random value.
  final int maxAnimationMillis;

  /// Max flip delay for the generate random delay.
  final int maxDelayMillis;

  /// Background before the first animation when there is no initialValue.
  ///
  /// Defaults to colorScheme.surface
  final Color? backgroundColor;

  final double _widthSizeFactor;
  final double _widthAlignFactor;
  final double _heightSizeFactor;
  final double _heightAlignFactor;

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
            (col) => FlipWidget<T>(
              flipType: FlipType.middleFlip,
              initialValue: initialValue,
              itemStream: randomDelayedStream(),
              itemBuilder: (_, value) => value == null
                  ? Container(
                      color: backgroundColor ??
                          Theme.of(context).colorScheme.surface,
                      width: _widthSizeFactor * width,
                      height: _heightSizeFactor * height,
                    )
                  : ClipRect(
                      child: Align(
                        alignment: Alignment(
                          -1.0 + col * _widthAlignFactor,
                          -1.0 + row * _heightAlignFactor,
                        ),
                        widthFactor: _widthSizeFactor,
                        heightFactor: _heightSizeFactor,
                        child: buildChild(context, value),
                      ),
                    ),
              hingeWidth: 0.0,
              flipDirection: _randomDirection,
              flipDuration: _randomFlipDuration,
            ),
          )
          .toList();

  T? get initialValue => null;

  Stream<T> randomDelayedStream();

  Duration get _randomFlipDuration => Duration(
      milliseconds: _random.nextInt(maxAnimationMillis - minAnimationMillis) +
          minAnimationMillis);

  Widget buildChild(BuildContext context, T value);

  AxisDirection get _randomDirection => _random.nextInt(10).isEven
      ? (axis == Axis.vertical ? AxisDirection.up : AxisDirection.left)
      : (axis == Axis.vertical ? AxisDirection.down : AxisDirection.right);
}

/// SingleChild builder implementation.
class SingleChildFlipMatrixBoardBuilder extends FlipMatrixBoardBuilder<Widget> {
  /// Constructor where all parameters are required.
  ///
  /// Default values should be defined in composing classes.
  const SingleChildFlipMatrixBoardBuilder({
    required this.child,
    required Axis axis,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    required int minAnimationMillis,
    required int maxAnimationMillis,
    required int maxDelayMillis,
    Color? backgroundColor,
  }) : super(
            axis: axis,
            width: width,
            height: height,
            columnCount: columnCount,
            rowCount: rowCount,
            minAnimationMillis: minAnimationMillis,
            maxAnimationMillis: maxAnimationMillis,
            maxDelayMillis: maxDelayMillis,
            backgroundColor: backgroundColor);

  /// Child widget that will be displayed through all cell animations.
  final Widget child;

  @override
  Stream<Widget> randomDelayedStream() => Stream.fromFuture(
        Future.delayed(
          Duration(milliseconds: _random.nextInt(maxDelayMillis)),
          () => child,
        ),
      );

  @override
  Widget buildChild(BuildContext context, Widget value) => child;
}

/// Stream implementation.
class StreamFlipMatrixBoardBuilder<T> extends FlipMatrixBoardBuilder<T> {
  /// Constructor where all not null parameters are required.
  ///
  /// Default values should be defined in composing classes.
  const StreamFlipMatrixBoardBuilder({
    this.initialValue,
    required this.itemStream,
    required this.itemBuilder,
    required Axis axis,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    required int minAnimationMillis,
    required int maxAnimationMillis,
    required int maxDelayMillis,
    Color? backgroundColor,
  }) : super(
            axis: axis,
            width: width,
            height: height,
            columnCount: columnCount,
            rowCount: rowCount,
            minAnimationMillis: minAnimationMillis,
            maxAnimationMillis: maxAnimationMillis,
            maxDelayMillis: maxDelayMillis,
            backgroundColor: backgroundColor);

  /// Optional initial value to be displayed before the first animation.
  @override
  final T? initialValue;

  /// Stream of items that will be built and flipped into view.
  final Stream<T> itemStream;

  /// Builder to construct widgets out of stream items.
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
            Duration(milliseconds: _random.nextInt(maxDelayMillis)),
            () => sink.add(data),
          );
        },
      );
}
