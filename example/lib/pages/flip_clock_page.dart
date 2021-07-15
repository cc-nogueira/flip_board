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
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          height: 72.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            child: FlipClock(
              digitColor: Colors.white,
              backgroundColor: const Color(0xFF004046),
              digitSize: 48.0,
              width: 40.0,
              height: 64.0,
              flipSpacing: 0.0,
            ),
          ),
        ),
      ),
    );
  }
}
