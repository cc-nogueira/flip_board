import 'package:flip_board/flip_clock.dart';
import 'package:flutter/material.dart';

/// An example page to show a [FlipCountdownClock]
///
/// Displays an 1 minute count down.
/// Colors are set at the constructor level (in contrast to using ThemeData).
///
/// Prints a message to the console when done.
class FlipCountdownClockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(24.0),
          child: FlipCountdownClock(
            duration: const Duration(minutes: 1),
            digitColor: Colors.white,
            backgroundColor: Colors.black,
            separatorColor: Colors.black,
            borderColor: Colors.grey,
            digitSize: 54.0,
            width: 46.0,
            height: 62.0,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            onDone: () => print('Buzzzz!'),
          ),
        ),
      ),
    );
  }
}
