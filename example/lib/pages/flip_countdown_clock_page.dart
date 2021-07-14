import 'package:flip_widget/flip_clock.dart';
import 'package:flutter/material.dart';

class CountdownClockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Center(
        child: Container(
          height: 74.0,
          child: FlipCountdownClock(
            duration: const Duration(minutes: 1),
            digitColor: Colors.white,
            backgroundColor: Colors.black,
            digitSize: 64.0,
            width: 50.0,
            height: 72.0,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            onDone: () => print('Haya!'),
          ),
        ),
      ),
    );
  }
}
