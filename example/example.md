# FlipWidget and FlipBoards examples

There are various examples in this project showing the use o FlipWidgets and Flipboards to animate de display of images, frases, clocks and even a simple game example.

Below a couple of simple examples: 

## FlipWidget displaying Day of Month

This is the basic building block for flipping animations. Below an example page that flips the current day of the month:

```dart
import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

class DayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final yesterday = DateTime.now().add(const Duration(days: -1)).day;
    final today = DateTime.now().day;
    return Scaffold(
      appBar: AppBar(title: const Text('Day of Month')),
      body: Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: FlipWidget(
          initialValue: yesterday,
          flipType: FlipType.middleFlip,
          itemStream: Stream.fromIterable([today]),
          itemBuilder: (_, day) => _container(day.toString()),
          flipDirection: AxisDirection.down,
        ),
      ),
    );
  }

  Widget _container(String text) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border.all(),
          borderRadius: BorderRadius.circular(4.0),
        ),
        width: 100.0,
        height: 100.0,
        child: Text(
          text,
          style: const TextStyle(fontSize: 64.0, fontWeight: FontWeight.bold),
        ),
      );
}
```

## FlipWidget Color Tap Count

A more elaborate example where most code is in a StatefullWidget with application
logic. FlipWidget invocation is actually quite simple.

<img src="https://raw.githubusercontent.com/cc-nogueira/flip_board/master/screenshots/Color_Tap_300.gif?raw=true" width="300" height="521"  />

```dart
import 'dart:async';

import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

class ColorTapCountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Tap Count')),
      body: const Center(
        child: _ColorTapCount([Colors.red, Colors.green, Colors.blue]),
      ),
    );
  }
}

class _ColorTapCount extends StatefulWidget {
  const _ColorTapCount(this.colors);

  final List<Color> colors;

  @override
  _ColorTapCountState createState() => _ColorTapCountState();
}

class _ColorTapCountState extends State<_ColorTapCount> {
  final _colorTapCounts = <Color, int>{};
  final _flipController = StreamController<ColorCount>();

  @override
  void initState() {
    super.initState();
    for (final color in widget.colors) {
      _colorTapCounts[color] = 0;
    }
  }

  @override
  void dispose() {
    _flipController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24.0,
            children: _tapTargets,
          ),
          const SizedBox(height: 80.0),
          _tapCountWidget,
        ],
      );

  List<Widget> get _tapTargets => widget.colors
      .map(
        (color) => Material(
          shape: const CircleBorder(),
          color: color,
          child: InkWell(
            onTap: () => _onTap(color),
            customBorder: const CircleBorder(),
            child: Container(width: 80.0, height: 80.0),
          ),
        ),
      )
      .toList();

  void _onTap(Color color) {
    final count = _colorTapCounts[color]! + 1;
    _colorTapCounts[color] = count;
    _flipController.add(ColorCount(color, count));
  }

  Widget get _tapCountWidget => FlipWidget(
        flipType: FlipType.spinFlip,
        itemStream: _flipController.stream,
        itemBuilder: _itemBuilder,
        flipDirection: AxisDirection.down,
        flipDuration: const Duration(milliseconds: 1200),
      );

  Widget _itemBuilder(BuildContext _, ColorCount? colorCount) {
    return _container(
      color: colorCount?.color ?? Colors.grey[900]!,
      text: colorCount?.count.toString() ?? '',
    );
  }

  Widget _container({required Color color, required String text}) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(),
          borderRadius: BorderRadius.circular(4.0),
        ),
        width: 80,
        height: 80,
        child: Text(
          text,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      );
}

class ColorCount {
  const ColorCount(this.color, this.count);

  final Color color;
  final int count;
}
```