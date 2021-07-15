import 'package:flip_widget/flip_clock.dart';
import 'package:flutter/material.dart';

class CountdownClockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Center(
        child: Container(
          height: 61.0,
          child: FlipCountdownClock(
            duration: const Duration(minutes: 1),
            digitColor: Colors.white,
            backgroundColor: Colors.black,
            digitSize: 54.0,
            width: 46.0,
            height: 60.0,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            flipSpacing: 1.0,
            onDone: () => print('Haya!'),
          ),
        ),
      ),
    );
  }
}
