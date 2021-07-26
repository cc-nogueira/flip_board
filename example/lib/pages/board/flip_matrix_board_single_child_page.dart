import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

class FlipMatrixBoardSingleChildPage extends StatelessWidget {
  const FlipMatrixBoardSingleChildPage({
    Key? key,
    required this.imageName,
    required this.axis,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
  }) : super(key: key);

  final String imageName;
  final Axis axis;
  final double width;
  final double height;
  final int columns;
  final int rows;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip Image')),
        body: Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: FlipMatrixBoardSingleChild.assetImage(
                    imageName: imageName,
                    axis: axis,
                    width: width,
                    height: height,
                    columnCount: columns,
                    rowCount: rows,
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
