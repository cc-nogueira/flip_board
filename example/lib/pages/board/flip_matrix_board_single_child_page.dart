import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

/// Example page to display a [FlipMatrixBoardSingleChild].
///
/// Presents a FlipMatrix that will animmate the display of a single asset image.
///
/// The page constructor sets all configuration options:
/// FlipMatricBoardStreamPage(
///   required String imagenName,     // Image.asset names
///   required Axis axis,             // Defines horizontal or vertical flips
///   required double width,          // Board (and image) width
///   required double height,         // Board (and images) height
///   required int columns,           // Number of columns in the matrix
///   required int rows,              // Number of rows in the matrix
///   int animationMillis = 2000,     // Duration of the flip animation
/// )
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
