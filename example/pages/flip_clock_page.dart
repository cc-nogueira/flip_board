import 'package:flip_widget/flip_clock.dart';
import 'package:flutter/material.dart';

class FlipClockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlipClock')),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          height: 66.0,
          child: FlipClock(
            digitColor: Colors.white,
            backgroundColor: Colors.black,
            digitSize: 48.0,
            width: 40.0,
            height: 64.0,
            flipSpacing: 0.0,
          ),
        ),
      ),
    );
  }
}
