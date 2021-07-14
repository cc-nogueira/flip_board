import 'package:flutter/material.dart';

import 'pages/flip_clock_page.dart';
import 'pages/flip_countdown_clock_page.dart';
import 'pages/flip_image_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlipPanel',
      routes: {
        'flip_image': (_) => AnimatedImagePage(
              imageName: 'assets/flutter_cover.png',
              width: 375.0,
              height: 200.0,
              columns: 8,
              rows: 2,
            ),
        'flip_clock': (_) => FlipClockPage(),
        'countdown_clock': (_) => CountdownClockPage(),
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlipPanel')),
      body: Column(
        children: [
          ListTile(
            title: const Text('FlipImage'),
            onTap: () => Navigator.of(context).pushNamed('flip_image'),
          ),
          ListTile(
            title: const Text('FlipClock'),
            onTap: () => Navigator.of(context).pushNamed('flip_clock'),
          ),
          ListTile(
            title: const Text('CountdownClock'),
            onTap: () => Navigator.of(context).pushNamed('countdown_clock'),
          ),
        ],
      ),
    );
  }
}
