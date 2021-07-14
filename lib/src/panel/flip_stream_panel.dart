import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';

class FlipStreamPanel<T> extends StatefulWidget {
  const FlipStreamPanel({
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
  })  : assert(columnCount > 1),
        assert(rowCount > 0),
        widthSizeFactor = 1.0 / columnCount,
        widthAlignFactor = 2.0 / (columnCount - 1),
        heightSizeFactor = 1.0 / rowCount,
        heightAlignFactor = rowCount == 1 ? 1.0 : 2.0 / (rowCount - 1),
        super(key: key);

  final T? initialValue;
  final Stream<T> itemStream;
  final ItemBuilder<T> itemBuilder;

  final double width;
  final double height;
  final int columnCount;
  final int rowCount;
  final int animationMillis;

  final double widthSizeFactor;
  final double widthAlignFactor;
  final double heightSizeFactor;
  final double heightAlignFactor;
  final Color backgroundColor;

  @override
  _FlipStreamPanelState<T> createState() => _FlipStreamPanelState<T>();
}

class _FlipStreamPanelState<T> extends State<FlipStreamPanel<T>> {
  final random = Random();
  final _controller = StreamController<T>.broadcast();
  late final StreamSubscription<T> _subscription;
  late final StreamTransformer<T, T> _delayedTransformer;

  @override
  void initState() {
    super.initState();
    _delayedTransformer = StreamTransformer<T, T>.fromHandlers(
      handleData: (data, sink) async {
        await Future.delayed(
          Duration(milliseconds: random.nextInt(widget.animationMillis)),
          () => sink.add(data),
        );
      },
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
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildRows(context),
      );

  List<Widget> _buildRows(BuildContext context) =>
      Iterable<int>.generate(widget.rowCount)
          .map(
            (row) => Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildColumns(context, row),
            ),
          )
          .toList();

  List<Widget> _buildColumns(BuildContext context, int row) =>
      Iterable<int>.generate(widget.columnCount)
          .map(
            (col) => VerticalFlipWidget<T>(
              initialValue: widget.initialValue,
              itemStream: _randomDealyedStream(),
              itemBuilder: (_, value) => value == null
                  ? Container(
                      color: widget.backgroundColor,
                      width: widget.widthSizeFactor * widget.width,
                      height: widget.heightSizeFactor * widget.height,
                    )
                  : ClipRect(
                      child: Align(
                        alignment: Alignment(
                          -1.0 + col * widget.widthAlignFactor,
                          -1.0 + row * widget.heightAlignFactor,
                        ),
                        widthFactor: widget.widthSizeFactor,
                        heightFactor: widget.heightSizeFactor,
                        child: widget.itemBuilder(context, value),
                      ),
                    ),
              spacing: 0.0,
              direction: _randomDirection(),
            ),
          )
          .toList();

  Stream<T> _randomDealyedStream() =>
      _controller.stream.transform(_delayedTransformer);

  VerticalDirection _randomDirection() =>
      random.nextInt(10).isEven ? VerticalDirection.up : VerticalDirection.down;
}
