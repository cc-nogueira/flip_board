import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

/// Example page to display a [FlipMatrixBoardSingleChild].
///
/// Presents a FlipMatrix that will animmate the display of a single asset image.
class FlipMatrixBoardSingleChildPage extends StatelessWidget {
  const FlipMatrixBoardSingleChildPage({Key? key}) : super(key: key);

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
                    imageName: 'assets/horizontal/flutter.png',
                    axis: Axis.vertical,
                    width: 375.0,
                    height: 200.0,
                    columnCount: 8,
                    rowCount: 4,
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
