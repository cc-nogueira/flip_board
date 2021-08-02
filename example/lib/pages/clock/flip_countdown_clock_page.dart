import 'package:flip_board/flip_clock.dart';
import 'package:flutter/material.dart';

/// An example page to show a [FlipCountdownClock]
///
/// Displays an 1 minute count down.
/// Colors are set at the constructor level (in contrast to using ThemeData).
///
/// Prints a message to the console when done.
class FlipCountdownClockPage extends StatelessWidget {
  const FlipCountdownClockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSwatch(primarySwatch: Colors.grey);
    return Theme(
      data: ThemeData.from(colorScheme: colors),
      child: Scaffold(
        appBar: AppBar(title: const Text('Countdown')),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(24.0),
            child: FlipCountdownClock(
              duration: const Duration(minutes: 1),
              digitSize: 54.0,
              width: 46.0,
              height: 62.0,
              digitColor: colors.surface,
              backgroundColor: colors.onSurface,
              separatorColor: colors.onSurface,
              borderColor: colors.primary,
              hingeColor: colors.surface,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              onDone: () => print('Buzzzz!'),
            ),
          ),
        ),
      ),
    );
  }
}
