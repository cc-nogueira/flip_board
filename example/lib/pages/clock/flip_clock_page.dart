import 'package:flip_board/flip_clock.dart';
import 'package:flutter/material.dart';

/// An example page to show a [FlipClock]
///
/// Colors are set at through ThemeData and customized at constructor level.
class FlipClockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip Clock')),
        body: Theme(
          data: ThemeData.from(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
          ),
          child: Center(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              height: 71.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 2.0,
                vertical: 4.0,
              ),
              child: FlipClock(
                digitSize: 54.0,
                width: 46.0,
                height: 62.0,
                separatorColor: Colors.grey,
              ),
            ),
          ),
        ),
      );
}
