import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../flip_widget.dart';

/// Page with 'FLUTTER!' message shown as an animated board.
///
/// Page displays 'A A A A A A A A', flipping each letter upto 'F L U T T E R !',
/// each in a different random speed.
class FlipFraseBoard extends StatelessWidget {
  FlipFraseBoard({
    String? startFrase,
    String? startLetter,
    required String endFrase,
    required this.fontSize,
    this.startColors,
    this.endColors,
    this.digitColors,
    double? flipLetterWidth,
    double? flipLetterHeight,
    this.letterSpacing = 1.0,
    this.flipSpacing = 0.8,
    this.maxFlipDelay = 600,
    this.minFlipDelay = 250,
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
        flipLetterHeight = flipLetterHeight ?? fontSize + 6;

  final Characters startChars, endChars;
  final double fontSize;
  final double letterSpacing;
  final double flipSpacing;
  final double flipLetterWidth, flipLetterHeight;
  final List<Color>? startColors, endColors, digitColors;
  final int minFlipDelay, maxFlipDelay;

  final _random = Random();

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < startChars.length; ++i) {
      children.add(_buildLetterFlip(context, index: i, delay: _randomDelay));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  int get _randomDelay =>
      minFlipDelay + _random.nextInt(maxFlipDelay - minFlipDelay);

  Color? _color(List<Color>? colors, int index) =>
      colors == null ? null : colors[index % colors.length];

  Widget _buildLetterFlip(
    BuildContext context, {
    required int index,
    required int delay,
  }) {
    final startLetter = startChars.elementAt(index);
    final endLetter = endChars.elementAt(index);
    final colorScheme = Theme.of(context).colorScheme;
    final startColor = _color(startColors, index) ?? colorScheme.primary;
    final endColor = _color(endColors, index) ?? colorScheme.primaryVariant;
    final digitColor = _color(digitColors, index) ?? colorScheme.onPrimary;

    return Container(
      child: VerticalFlipWidget<String>(
        itemStream: _letterStream(startLetter, endLetter, delay),
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

  VerticalDirection _letterDirection(String startLetter, String endLetter) =>
      startLetter.codeUnitAt(0) < endLetter.codeUnitAt(0)
          ? VerticalDirection.down
          : VerticalDirection.up;
}
