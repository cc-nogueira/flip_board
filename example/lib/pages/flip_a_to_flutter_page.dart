import 'dart:async';
import 'dart:math';

import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

class FlipFromAToFlutterPage extends StatelessWidget {
  final _aCodeUnit = 'A'.codeUnitAt(0);
  final _width = 40.0;
  final _height = 42.0;
  final _fontSize = 36.0;
  final _maxDelay = 500;
  final _random = Random();
  final _message = 'FLUTTER';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip from A to Flutter')),
        body: Center(
          child: _buildDisplay(),
        ),
      );

  Widget _buildDisplay() {
    final children = <Widget>[];
    for (final letter in _message.characters) {
      children.add(_buildLetterFlip(letter, _randomDelay));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  int get _randomDelay => 250 + _random.nextInt(_maxDelay - 250);

  Widget _buildLetterFlip(String letter, int delay) => Container(
        child: VerticalFlipWidget<String>(
          itemStream: _letterStream(letter, delay),
          itemBuilder: (context, item) => _itemBuilder(context, item, letter),
          direction: VerticalDirection.down,
          duration: Duration(milliseconds: delay ~/ 3),
          spacing: 1.0,
        ),
      );

  Widget _itemBuilder(BuildContext context, String? item, String letter) {
    final color = item == letter ? Colors.blue[900] : Colors.black;
    final child = item == null
        ? null
        : Text(
            item,
            style: TextStyle(color: Colors.yellow, fontSize: _fontSize),
          );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _width,
            height: _height,
            alignment: Alignment.center,
            child: child,
          ),
        ],
      ),
    );
  }

  Stream<String> _letterStream(String letter, int delay) {
    final lastCode = letter.codeUnitAt(0);
    final letters = <String>[];
    for (var code = _aCodeUnit; code <= lastCode; ++code) {
      letters.add(String.fromCharCode(code));
    }

    return Stream.periodic(
      Duration(milliseconds: delay),
      (idx) => idx < letters.length ? letters[idx] : '',
    ).takeWhile((item) => item.isNotEmpty);
  }
}
