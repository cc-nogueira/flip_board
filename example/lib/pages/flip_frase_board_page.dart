import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

/// Page with two FlipFraseBoards showing frase board animations.
///
/// Frase animate theis chars from "AAAAAAA" to "FLUTTER" on one line,
/// and from "AAAAAAAAAA" to "FLIP BOARD" on the second line
/// FlipFraseBoard uses Theme colors and optional parameterized colors.
/// Chars are flipped in different random speeds.
class FlipFraseBoardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip Frase Board')),
        body: Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlipFraseBoard(
                  startLetter: 'A',
                  endFrase: 'FLUTTER',
                  fontSize: 42.0,
                  letterSpacing: 3.0,
                ),
                const SizedBox(height: 10.0),
                FlipFraseBoard(
                  startLetter: 'A',
                  endFrase: 'FLIP BOARD',
                  fontSize: 30.0,
                  flipSpacing: 0.5,
                  endColors: _endColors,
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
