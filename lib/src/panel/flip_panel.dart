import 'dart:math';

import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';

class FlipPanel extends StatelessWidget {
  FlipPanel({
    Key? key,
    required String imageName,
    required this.width,
    required this.height,
    required this.columnCount,
    required this.rowCount,
    this.backgroundColor = Colors.white,
  })  : assert(columnCount > 1),
        assert(rowCount > 0),
        image = Image.asset(
          imageName,
          fit: BoxFit.fill,
          width: width,
          height: height,
        ),
        widthSizeFactor = 1.0 / columnCount,
        widthAlignFactor = 2.0 / (columnCount - 1),
        heightSizeFactor = 1.0 / rowCount,
        heightAlignFactor = rowCount == 1 ? 1.0 : 2.0 / (rowCount - 1),
        super(key: key);

  final double width;
  final double height;
  final int columnCount;
  final int rowCount;

  final Image image;
  final double widthSizeFactor;
  final double widthAlignFactor;
  final double heightSizeFactor;
  final double heightAlignFactor;
  final Color backgroundColor;
  final random = Random();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildRows(),
      );

  List<Widget> _buildRows() => Iterable<int>.generate(rowCount)
      .map(
        (row) => Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildColumns(row),
        ),
      )
      .toList();

  List<Widget> _buildColumns(int row) => Iterable<int>.generate(columnCount)
      .map(
        (col) => VerticalFlipWidget<int>(
          itemStream: _createRandomTimeStream(),
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
                    child: image,
                  ),
                ),
          spacing: 0.0,
          direction: _randomDirection(),
        ),
      )
      .toList();

  Stream<int> _createRandomTimeStream() => Stream.fromFuture(
      Future.delayed(Duration(milliseconds: random.nextInt(3000)), () => 1));

  VerticalDirection _randomDirection() =>
      random.nextInt(10).isEven ? VerticalDirection.up : VerticalDirection.down;
}
