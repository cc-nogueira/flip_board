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
