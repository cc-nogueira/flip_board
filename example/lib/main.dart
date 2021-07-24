import 'package:flutter/material.dart';

import 'pages/board/flip_frase_board_page.dart';
import 'pages/board/flip_matrix_board_single_child_page.dart';
import 'pages/board/flip_matrix_board_stream_page.dart';
import 'pages/clock/flip_clock_page.dart';
import 'pages/clock/flip_countdown_clock_page.dart';
import 'pages/widget/flip_widget_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flip Board',
      routes: {
        'flip_widget': _flipWidgetPage,
        'flip_image': _flipImagePage,
        'flip_stream': _flipStreamPage,
        'flip_frase_board': (_) => FlipFraseBoardPage(),
        'flip_clock': (_) => FlipClockPage(),
        'countdown_clock': (_) => CountdownClockPage(),
      },
      home: HomePage(),
    );
  }

  Widget _flipWidgetPage(BuildContext context) => FlipWidgetPage();

  Widget _flipImagePage(BuildContext context) => FlipMatrixBoardSingleChildPage(
        imageName: 'assets/flutter.png',
        axis: Axis.vertical,
        width: 375.0,
        height: 200.0,
        columns: 8,
        rows: 4,
      );

  Widget _flipStreamPage(BuildContext context) {
    final images = <String>[
      'assets/flower.png',
      'assets/butterfly.png',
      'assets/sea.png',
      'assets/bird.png',
    ];
    return FlipMatrixBoardStreamPage(
      imageNames: images,
      axis: Axis.vertical,
      width: 375.0,
      height: 200.0,
      columns: 8,
      rows: 4,
      animationMillis: 4000,
      imageChangeSeconds: 6,
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flip Board')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTileTheme(
          tileColor: Colors.black12,
          contentPadding: const EdgeInsets.all(8.0),
          shape: Border.all(color: Colors.black38),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ListTile(
                leading: const Icon(Icons.image, size: 48.0),
                title: const Text('Flip Widget'),
                subtitle: const Text('Simple Flip Widgets'),
                onTap: () => Navigator.of(context).pushNamed('flip_widget'),
              ),
              ListTile(
                leading: const Icon(Icons.image, size: 48.0),
                title: const Text('Flip Image Board'),
                subtitle: const Text('Animate the display of a single image'),
                onTap: () => Navigator.of(context).pushNamed('flip_image'),
              ),
              ListTile(
                leading: const Icon(Icons.imagesearch_roller, size: 48.0),
                title: const Text('Flip Stream Board'),
                subtitle: const Text('Animate a stream of images'),
                onTap: () => Navigator.of(context).pushNamed('flip_stream'),
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha, size: 48.0),
                title: const Text('Flip Frase Board'),
                subtitle: const Text('Flip FLUTTER FLIP BOARD'),
                onTap: () =>
                    Navigator.of(context).pushNamed('flip_frase_board'),
              ),
              ListTile(
                leading: const Icon(Icons.watch, size: 48.0),
                title: const Text('Flip Clock'),
                subtitle: const Text('A nice looking clock'),
                onTap: () => Navigator.of(context).pushNamed('flip_clock'),
              ),
              ListTile(
                leading: const Icon(Icons.run_circle, size: 48.0),
                title: const Text('Flip Countdown Clock'),
                subtitle: const Text('A nice looking countdown clock'),
                onTap: () => Navigator.of(context).pushNamed('countdown_clock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
