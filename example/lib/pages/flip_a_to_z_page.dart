import 'dart:async';

import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

class FlipAToZPage extends StatelessWidget {
  final aCodeUnit = 'A'.codeUnitAt(0);
  final zCodeUnit = 'Z'.codeUnitAt(0);
  final width = 68.0;
  final height = 68.0;
  final fontSize = 65.0;
  final delay = const Duration(milliseconds: 500);
  final animation = const Duration(milliseconds: 170);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip A to Z')),
        body: Center(
          child: _buildDisplay(),
        ),
      );

  Widget _buildDisplay() => Container(
        child: VerticalFlipWidget<String>(
          itemStream: _lettersStream,
          itemBuilder: _itemBuilder,
          direction: VerticalDirection.down,
          duration: animation,
          spacing: 1.0,
        ),
      );

  Widget _itemBuilder(BuildContext context, String? item) {
    final child = item == null
        ? null
        : Text(
            item,
            style: TextStyle(color: Colors.yellow, fontSize: fontSize),
          );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: child,
          ),
        ],
      ),
    );
  }

  Stream<String> get _lettersStream {
    final letters = <String>[];
    for (var code = aCodeUnit; code <= zCodeUnit; ++code) {
      letters.add(String.fromCharCode(code));
    }

    return Stream.periodic(
      delay,
      (idx) => idx < letters.length ? letters[idx] : '',
    ).takeWhile((item) => item.isNotEmpty);
  }
}
