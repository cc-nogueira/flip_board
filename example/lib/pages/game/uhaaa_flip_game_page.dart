import 'package:flutter/material.dart';

import 'uhaaa_flip_game.dart';

/// Uhaaa! Flip Game Page to show a page for a example game with FlipWidgets.
///
/// More documentation in [UhaaaFlipGame] class.
class UhaaaFlipGamePage extends StatelessWidget {
  UhaaaFlipGamePage({Key? key}) : super(key: key);

  final colors = ColorScheme.fromSwatch(primarySwatch: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(colorScheme: colors),
      child: Scaffold(
        appBar: AppBar(title: const Text('Uhaaa! Flip Game')),
        body: const UhaaaFlipGame(),
      ),
    );
  }
}
