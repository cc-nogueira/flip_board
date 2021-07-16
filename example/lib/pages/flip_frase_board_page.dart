import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

/// Page with 'FLUTTER!' message shown as an animated board.
///
/// Page displays 'A A A A A A A A', flipping each letter upto 'F L U T T E R !',
/// each in a different random speed.
class FlipFraseBoardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip Frase Board')),
        body: Center(
          child: Theme(
            data: ThemeData(
              colorScheme:
                  ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlipFraseBoard(
                  startLetter: 'A',
                  endFrase: 'FLUTTER',
                  fontSize: 42.0,
                  letterSpacing: 3.0,
                  // startColors: [Colors.black],
                  //endColors: [Colors.blue[900]!],
                  //digitColors: [Colors.white],
                ),
                const SizedBox(height: 10.0),
                FlipFraseBoard(
                  startLetter: 'A',
                  endFrase: 'FLIP BOARD',
                  fontSize: 30.0,
                  flipSpacing: 0.5,
                  // startColors: [Colors.black],
                  endColors: _endColors,
                  // digitColors: [Colors.white],
                ),
              ],
            ),
          ),
        ),
      );

  List<Color> get _endColors => [
        Colors.teal[900]!,
        Colors.blue[900]!,
        Colors.red[900]!,
        Colors.blueGrey[900]!,
        Colors.lightGreen[900]!,
        Colors.orange[900]!,
        Colors.cyan[800]!,
      ];
}
