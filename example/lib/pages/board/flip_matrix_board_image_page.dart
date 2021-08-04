import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

/// Example page to display a [FlipMatrixBoardSingleChild].
///
/// Presents a FlipMatrix that will animmate the display of a single asset image.
class FlipMatrixBoardImagePage extends StatelessWidget {
  const FlipMatrixBoardImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(title: const Text('Flip Image')),
        body: Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _flipImage,
                _imageTitle,
              ],
            ),
          ),
        ),
      );

  Widget get _flipImage => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 3.0, color: Colors.red[900]!),
        ),
        child: FlipMatrixBoardSingleChild.assetImage(
          imageName: 'assets/horizontal/dart-frog.jpg',
          backgroundColor: Colors.black,
          axis: Axis.vertical,
          width: 364.0,
          height: 205.0,
          columnCount: 8,
          rowCount: 4,
        ),
      );

  Widget get _imageTitle => const Padding(
        padding: EdgeInsets.only(top: 24.0),
        child: Text(
          'Dart Frog',
          style: TextStyle(
            fontSize: 30.0,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
