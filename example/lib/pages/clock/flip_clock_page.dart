import 'package:flip_board/flip_clock.dart';
import 'package:flutter/material.dart';

/// An example page to show a [FlipClock]
///
/// Colors are use ThemeData and are customized at constructor level.
class FlipClockPage extends StatelessWidget {
  const FlipClockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSwatch(primarySwatch: Colors.amber);
    return Theme(
      data: ThemeData.from(colorScheme: colors),
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text('Flip Clock'),
          backgroundColor: colors.background,
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: colors.onPrimary,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: FlipClock(
              digitSize: 54.0,
              width: 46.0,
              height: 62.0,
              separatorColor: colors.primary,
              hingeColor: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
