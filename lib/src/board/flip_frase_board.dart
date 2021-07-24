import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../flip_widget.dart';

/// Component present message shown as an mechanical flip board.
///
/// Displays an anumation flipping each letter from a startFrase upto each letter in endFrase,
/// each letter animation in a different random speed.
///
/// The startFrase may be given or a start letter may be set to build a startFrase with all letters equal.
/// StartFrase and endFrase must have the same length.
///
/// Colors parameters can have any number of letters that will be cycled for each letter.
///
/// There are a number of parameters to customize size, colors, spacing and speed.
///
/// There is a optional callback parameter for onDone event.
class FlipFraseBoard extends StatelessWidget {
  FlipFraseBoard({
    Key? key,
    String? startFrase,
    String? startLetter,
    required String endFrase,
    required this.fontSize,
    required this.axis,
    this.startColors,
    this.endColors,
    this.digitColors,
    double? flipLetterWidth,
    double? flipLetterHeight,
    this.letterSpacing = 1.0,
    this.flipSpacing = 0.8,
    this.maxFlipDelay = 600,
    this.minFlipDelay = 250,
    this.onDone,
    ValueNotifier<int>? startNotifier,
  })  : assert(startFrase == null || startLetter == null),
        assert(startFrase != null && startFrase.isNotEmpty ||
            startLetter != null && startLetter.length == 1),
        assert(endFrase.isNotEmpty),
        assert(startFrase == null || startFrase.length == endFrase.length),
        assert(endColors == null || endColors.isNotEmpty),
        startChars = startFrase?.characters ??
            (startLetter! * endFrase.length).characters,
        endChars = endFrase.characters,
        flipLetterWidth = flipLetterWidth ?? fontSize + 4,
        flipLetterHeight = flipLetterHeight ?? fontSize + 6,
        startNotifier = startNotifier ?? ValueNotifier(0),
        super(key: key) {
    _clearDoneList();
  }

  final Characters startChars, endChars;
  final Axis axis;
  final double fontSize;
  final double letterSpacing;
  final double flipSpacing;
  final double flipLetterWidth, flipLetterHeight;
  final List<Color>? startColors, endColors, digitColors;
  final int minFlipDelay, maxFlipDelay;
  final void Function()? onDone;
  final ValueNotifier<int> startNotifier;

  final _random = Random();
  final _doneList = <bool>[];

  _clearDoneList() {
    _doneList.clear();
    for (var i = 0; i < startChars.length; ++i) {
      _doneList.add(false);
    }
  }

  void _onStreamDone(int index) {
    _doneList[index] = true;
    for (final done in _doneList) {
      if (!done) return;
    }
    _clearDoneList();
    if (onDone != null) {
      onDone!();
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        builder: (BuildContext context, int startCount, Widget? __) {
          final children = <Widget>[];
          for (var i = 0; i < startChars.length; ++i) {
            children.add(_buildLetterFlip(context,
                index: i, delay: _randomDelay, startCount: startCount));
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        },
        valueListenable: startNotifier,
      );

  int get _randomDelay =>
      minFlipDelay + _random.nextInt(maxFlipDelay - minFlipDelay);

  Color? _color(List<Color>? colors, int index) =>
      colors == null ? null : colors[index % colors.length];

  Widget _buildLetterFlip(
    BuildContext context, {
    required int index,
    required int delay,
    required int startCount,
  }) {
    final startLetter = startChars.elementAt(index);
    final endLetter = endChars.elementAt(index);
    final colorScheme = Theme.of(context).colorScheme;
    final startColor = _color(startColors, index) ?? colorScheme.primary;
    final endColor = _color(endColors, index) ?? colorScheme.primaryVariant;
    final digitColor = _color(digitColors, index) ?? colorScheme.onPrimary;

    return Container(
      child: FlipWidget<String>(
        startCount: startCount,
        itemStream: _letterStream(startLetter, endLetter, delay),
        // itemStream: _letterStream(startLetter, endLetter, delay),
        itemBuilder: (context, item) => _itemBuilder(
          context,
          item,
          endLetter: endLetter,
          startColor: startColor,
          endColor: endColor,
          digitColor: digitColor,
        ),
        direction: _letterDirection(startLetter, endLetter),
        duration: Duration(milliseconds: delay ~/ 3),
        spacing: flipSpacing,
        onDone: () => _onStreamDone(index),
      ),
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    String? item, {
    required String endLetter,
    required Color startColor,
    required Color endColor,
    required Color digitColor,
  }) {
    final textStyle = TextStyle(color: digitColor, fontSize: fontSize);

    final child = item == null ? null : Text(item, style: textStyle);
    final color = item == endLetter ? endColor : startColor;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: letterSpacing),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Container(
        width: flipLetterWidth,
        height: flipLetterHeight,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Stream<String> _letterStream(
    String startLetter,
    String endLetter,
    int delay,
  ) {
    final firstCode = startLetter.codeUnitAt(0);
    final lastCode = endLetter.codeUnitAt(0);
    final letters = <String>[];
    if (firstCode <= lastCode) {
      for (var code = firstCode; code <= lastCode; ++code) {
        letters.add(String.fromCharCode(code));
      }
    } else {
      for (var code = firstCode; code >= lastCode; --code) {
        letters.add(String.fromCharCode(code));
      }
    }
    return Stream.periodic(
      Duration(milliseconds: delay),
      (idx) => idx < letters.length ? letters[idx] : '',
    ).takeWhile((item) => item.isNotEmpty);
  }

  AxisDirection _letterDirection(String startLetter, String endLetter) =>
      startLetter.codeUnitAt(0) < endLetter.codeUnitAt(0)
          ? axis == Axis.vertical
              ? AxisDirection.down
              : AxisDirection.left
          : axis == Axis.vertical
              ? AxisDirection.up
              : AxisDirection.right;
}
