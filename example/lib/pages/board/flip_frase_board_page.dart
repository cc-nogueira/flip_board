import 'package:flip_board/flip_board.dart';
import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

/// Page with two [FlipFraseBoard]s showing frase board animations.
///
/// First frase flip chars horizontally, from "AAAAAAA" to "FLUTTER".
/// Seconde line flip chars verticallu from "AAAAAAAAAA" to "FLIP BOARD".
///
/// FlipFraseBoard uses Theme colors and optional parameterized colors.
/// Chars are configured to flip in different random speeds and end colors.
class FlipFraseBoardPage extends StatefulWidget {
  const FlipFraseBoardPage({Key? key}) : super(key: key);

  @override
  _FlipFraseBoardPageState createState() => _FlipFraseBoardPageState();
}

class _FlipFraseBoardPageState extends State<FlipFraseBoardPage> {
  final _completed = [false, false, false, false, false];
  final _startNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey);
    return Theme(
      data: ThemeData.from(colorScheme: colors),
      child: Scaffold(
        appBar: AppBar(title: const Text('Flip Frase Board')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlipFraseBoard(
                flipType: FlipType.middleFlip,
                axis: Axis.horizontal,
                startLetter: 'A',
                endFrase: 'FLUTTER',
                fontSize: 42.0,
                hingeWidth: 0.4,
                hingeColor: colors.onPrimary,
                borderColor: Colors.white,
                letterSpacing: 3.0,
                onDone: () => _onDone(0),
                startNotifier: _startNotifier,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlipFraseBoard(
                    flipType: FlipType.middleFlip,
                    axis: Axis.vertical,
                    startLetter: 'A',
                    endFrase: 'FLIP',
                    fontSize: 30.0,
                    hingeWidth: 0.6,
                    hingeColor: Colors.black,
                    borderColor: Colors.black,
                    endColors: _flipEndColors,
                    letterSpacing: 2.0,
                    onDone: () => _onDone(1),
                    startNotifier: _startNotifier,
                  ),
                  const SizedBox(width: 10.0),
                  FlipFraseBoard(
                    flipType: FlipType.middleFlip,
                    axis: Axis.vertical,
                    startLetter: 'A',
                    endFrase: '&',
                    fontSize: 30.0,
                    hingeWidth: 0.6,
                    hingeColor: Colors.black,
                    borderColor: Colors.black,
                    endColors: [Colors.lightGreen[900]!],
                    onDone: () => _onDone(2),
                    startNotifier: _startNotifier,
                  ),
                  const SizedBox(width: 10.0),
                  FlipFraseBoard(
                    flipType: FlipType.spinFlip,
                    axis: Axis.vertical,
                    startLetter: 'A',
                    endFrase: 'SPIN',
                    fontSize: 30.0,
                    hingeWidth: 0.6,
                    hingeColor: Colors.black,
                    borderColor: Colors.black,
                    endColors: _spinEndColors,
                    letterSpacing: 2.0,
                    onDone: () => _onDone(3),
                    startNotifier: _startNotifier,
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              FlipFraseBoard(
                flipType: FlipType.spinFlip,
                axis: Axis.horizontal,
                startLetter: 'A',
                endFrase: 'BOARDS',
                fontSize: 30.0,
                borderColor: Colors.black,
                endColors: _boardsEndColors,
                letterSpacing: 2.5,
                minFlipDelay: 400,
                maxFlipDelay: 700,
                onDone: () => _onDone(4),
                startNotifier: _startNotifier,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: (_completed[0] &&
                        _completed[1] &&
                        _completed[2] &&
                        _completed[3] &&
                        _completed[4])
                    ? IconButton(
                        onPressed: _restart,
                        icon: const Icon(
                          Icons.replay_circle_filled,
                          size: 48.0,
                        ),
                      )
                    : const SizedBox(height: 48.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget flipFraseBoard() => FlipFraseBoard(
        flipType: FlipType.middleFlip,
        axis: Axis.vertical,
        startLetter: 'A',
        endFrase: 'FLIP',
        fontSize: 30.0,
        hingeWidth: 0.6,
        hingeColor: Colors.black,
        borderColor: Colors.black,
        endColors: _flipEndColors,
        letterSpacing: 2.0,
        onDone: () => _onDone(1),
        startNotifier: _startNotifier,
      );

  List<Color> get _flipEndColors => [
        Colors.teal[900]!,
        Colors.blue[900]!,
        Colors.red[900]!,
        Colors.blueGrey[900]!,
      ];

  List<Color> get _spinEndColors => [
        Colors.cyan[800]!,
        Colors.orange[900]!,
        Colors.teal[900]!,
        Colors.blue[900]!,
      ];

  List<Color> get _boardsEndColors => [
        Colors.orange[900]!,
        Colors.lightGreen[900]!,
        Colors.red[800]!,
        Colors.blue[900]!,
        Colors.teal[900]!,
        Colors.cyan[800]!,
      ];

  void _onDone(int index) {
    _completed[index] = true;
    if (_completed[0] && _completed[1]) {
      setState(() {});
    }
  }

  void _restart() {
    setState(() {
      _completed[0] = false;
      _completed[1] = false;
      _completed[2] = false;
      _completed[3] = false;
      _completed[4] = false;
      _startNotifier.value = _startNotifier.value + 1;
    });
  }
}
