import 'package:flip_board/flip_clock.dart';
import 'package:flutter/material.dart';

/// An example page to show a [FlipClock]
///
/// Colors are set at through ThemeData and customized at constructor level.
class FlipClockPage extends StatelessWidget {
  final colorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.amber);

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData.from(colorScheme: colorScheme),
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            title: const Text('Flip Clock'),
            backgroundColor: colorScheme.background,
          ),
          body: Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: FlipClock(
                digitSize: 54.0,
                width: 46.0,
                height: 62.0,
                separatorColor: colorScheme.primary,
                showBorder: true,
              ),
            ),
          ),
        ),
      );
}
