import 'dart:async';

import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';
import 'flip_matrix_board_builder.dart';

/// Component to present a matrix board of FlipWidgets that animates the display of a single child.
///
/// Most common code between [FlipMatrixBoardSingleChild] and [FlipMatrixBoardStream] is found in [FlipMatrixBoardBuilder].
class FlipMatrixBoardSingleChild extends StatelessWidget {
  /// FlipMatrixBoardSingleChild constructor.
  ///
  /// Configure this FlipBoard with the number of rows and columns, flipping orientation
  /// and animation speed and delay parameters.
  ///
  /// Recieves a single child widget that will be displayed through all cell animations
  FlipMatrixBoardSingleChild({
    Key? key,
    required Widget child,
    required Axis axis,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    int minAnimationMillis = 1000,
    int maxAnimationMillis = 3000,
    int maxDelayMillis = 4000,
    Color? backgroundColor,
  })  : _builder = SingleChildFlipMatrixBoardBuilder(
          child: child,
          axis: axis,
          width: width,
          height: height,
          columnCount: columnCount,
          rowCount: rowCount,
          minAnimationMillis: minAnimationMillis,
          maxAnimationMillis: maxAnimationMillis,
          maxDelayMillis: maxDelayMillis,
          backgroundColor: backgroundColor,
        ),
        super(key: key);

  /// FlipMatrixBoardSingleChild specialized constructor to display an asset image.
  ///
  /// Configure this FlipBoard with the number of rows and columns, flipping orientation
  /// and animation speed and delay parameters.
  ///
  /// Recieves a single image name that will be rendered with BoxFit.fill option.
  FlipMatrixBoardSingleChild.assetImage({
    Key? key,
    required String imageName,
    required Axis axis,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    Color? backgroundColor,
    int minAnimationMillis = 500,
    int maxAnimationMillis = 1500,
    int maxDelayMillis = 2500,
  }) : this(
          child: Image.asset(
            imageName,
            fit: BoxFit.fill,
            width: width,
            height: height,
          ),
          axis: axis,
          width: width,
          height: height,
          columnCount: columnCount,
          rowCount: rowCount,
          minAnimationMillis: minAnimationMillis,
          maxAnimationMillis: maxAnimationMillis,
          maxDelayMillis: maxDelayMillis,
          backgroundColor: backgroundColor,
        );

  /// Builder with common code for all FlipMatrixBoard types and specific
  /// code for single child boards.
  ///
  /// This builder is created with most of my constructor parameters
  final SingleChildFlipMatrixBoardBuilder _builder;

  @override
  Widget build(BuildContext context) => _builder.build(context);
}

/// Component to present a matrix board of FlipWidgets that animates the arrival of items in a stream.
///
/// Most common code between [FlipMatrixBoardSingleChild] and [FlipMatrixBoardStream] is found in [FlipMatrixBoardBuilder].
class FlipMatrixBoardStream<T> extends StatefulWidget {
  /// FlipMatrixBoardStream constructor.
  ///
  /// Configure this FlipBoard with the number of rows and columns, flipping orientation
  /// and animation speed and delay parameters.
  ///
  /// The initialValue parameter is optional thus the itemBuilder signature builds over an optional item.
  const FlipMatrixBoardStream({
    Key? key,
    this.initialValue,
    required this.itemStream,
    required this.itemBuilder,
    required this.axis,
    required this.width,
    required this.height,
    required this.columnCount,
    required this.rowCount,
    this.minAnimationMillis = 1000,
    this.maxAnimationMillis = 3000,
    this.maxDelayMillis = 2500,
    this.backgroundColor,
  }) : super(key: key);

  /// Optional initial value to be displayed before the first animation.
  final T? initialValue;

  /// Stream of items that will be built and flipped into view.
  final Stream<T> itemStream;

  /// Builder to construct widgets out of stream items.
  final ItemBuilder<T> itemBuilder;

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

  /// Number of rows of the display matrix.
  final int rowCount;

  /// Minimum animation duration for the generated random value.
  final int minAnimationMillis;

  /// Max animation duration for the generated random value.
  final int maxAnimationMillis;

  /// Max flip delay for the generate random delay.
  final int maxDelayMillis;

  /// Background before the first animation when there is no initialValue.
  ///
  /// Defaults colorScheme.surface
  final Color? backgroundColor;

  @override
  State<FlipMatrixBoardStream<T>> createState() => _FlipMatrixBoardStreamState<T>();
}

class _FlipMatrixBoardStreamState<T> extends State<FlipMatrixBoardStream<T>> {
  final _controller = StreamController<T>.broadcast();
  late final StreamSubscription<T> _subscription;
  late final StreamFlipMatrixBoardBuilder<T> _builder;

  @override
  void initState() {
    super.initState();

    _builder = StreamFlipMatrixBoardBuilder<T>(
      initialValue: widget.initialValue,
      itemStream: _controller.stream,
      itemBuilder: widget.itemBuilder,
      axis: widget.axis,
      width: widget.width,
      height: widget.height,
      columnCount: widget.columnCount,
      rowCount: widget.rowCount,
      minAnimationMillis: widget.minAnimationMillis,
      maxAnimationMillis: widget.maxAnimationMillis,
      maxDelayMillis: widget.maxDelayMillis,
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
