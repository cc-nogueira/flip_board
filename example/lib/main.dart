import 'package:flutter/material.dart';

import 'pages/flip_clock_page.dart';
import 'pages/flip_countdown_clock_page.dart';
import 'pages/flip_image_page.dart';
import 'pages/flip_stream_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flip Board',
      routes: {
        'flip_image': _flipImagePage,
        'flip_stream': _flipStreamPage,
        'flip_clock': (_) => FlipClockPage(),
        'countdown_clock': (_) => CountdownClockPage(),
      },
      home: HomePage(),
    );
  }

  Widget _flipImagePage(BuildContext context) => FlipImagePage(
        imageName: 'assets/flutter.png',
        width: 375.0,
        height: 200.0,
        columns: 8,
        rows: 2,
      );

  Widget _flipStreamPage(BuildContext context) {
    final images = <String>[
      'assets/flower.png',
      'assets/butterfly.png',
      'assets/sea.png',
      'assets/bird.png',
    ];
    return FlipStreamPage(
      imageNames: images,
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
