import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

class FlipMatrixBoardSingleChildPage extends StatelessWidget {
  FlipMatrixBoardSingleChildPage({
    Key? key,
    required String imageName,
    required double width,
    required double height,
    required int columns,
    required int rows,
  })  : _imageFlipBoard = FlipMatrixBoardSingleChild.assetImage(
          imageName: imageName,
          width: width,
          height: height,
          columnCount: columns,
          rowCount: rows,
        ),
        super(key: key);

  final FlipMatrixBoardSingleChild _imageFlipBoard;

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
                  child: _imageFlipBoard,
                )
              ],
            ),
          ),
        ),
      );
}
