import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../flip_widget.dart';

/// Component to present a frase, shown as an mechanical flip board.
///
/// Displays an animation flipping from each start letter upto each letter in the endFrase,
/// letter streams flip in different random speeds, controlled by given parameters.
class FlipFraseBoard extends StatelessWidget {
  /// FlipFraseBoard constructor.
  ///
  /// The start letter may be given for each letter with a startFrase
  /// or a start letter may be set to build a startFrase with all letters equal.
  /// StartFrase and endFrase must have the same length.
  ///
  /// Colors parameters for startColors and endColors can have any number of colors,
  /// if fewer colors are given they will be cycled to define start/end colors for each letter.
  ///
  /// Parameters customize size, colors, spacing, border, hinge and flip delay randomization.
  ///
  /// There is an optional callback parameter for onDone event, and an optional parameter
  /// for a [ValueNotifier] to signal a restart of the whole animation.
  FlipFraseBoard({
    Key? key,
    required this.flipType,
    required this.axis,
    String? startFrase,
    String? startLetter,
    required String endFrase,
    this.letterColors,
    this.startColors,
    this.endColors,
    required this.fontSize,
    double? flipLetterWidth,
    double? flipLetterHeight,
    this.showBorder,
    this.borderWidth,
    this.borderColor,
    this.hingeWidth = 0.0,
    double? hingeLength,
    this.hingeColor,
    this.letterSpacing = 1.0,
    this.minFlipDelay = 250,
    this.maxFlipDelay = 600,
    this.onDone,
    ValueNotifier<int>? startNotifier,
  })  : assert(startFrase == null || startLetter == null),
        assert(startFrase != null && startFrase.isNotEmpty ||
            startLetter != null && startLetter.length == 1),
        assert(endFrase.isNotEmpty),
        assert(startFrase == null || startFrase.length == endFrase.length),
        assert(endColors == null || endColors.isNotEmpty),
        assert(hingeLength == null ||
            hingeLength == 0.0 && hingeWidth == 0.0 ||
            hingeLength != 0.0 && hingeWidth != 0.0),
        assert(hingeColor == null || hingeWidth != 0.0),
        assert(minFlipDelay <= maxFlipDelay),
        _startChars = startFrase?.characters ??
            (startLetter! * endFrase.length).characters,
        _endChars = endFrase.characters,
        flipLetterWidth = flipLetterWidth ?? fontSize + 4,
        flipLetterHeight = flipLetterHeight ?? fontSize + 6,
        hingeLength = hingeLength ??
            (hingeWidth == 0.0
                ? 0.0
                : (axis == Axis.vertical ? fontSize + 4 : fontSize + 6)),
        startNotifier = startNotifier ?? ValueNotifier(0),
        super(key: key) {
    _clearDoneList();
  }

  static final _random = Random(DateTime.now().millisecondsSinceEpoch);

  /// Defines the type of animation.
  ///
  /// - middleFlip is used for FlipWidgets that flip in the middle, like Mechanical Flip Boards do.
  /// - spinFlip is used for FlipWidgets that flip like cards do (roll flip).
  final FlipType flipType;

  /// Flip animation axis.
  ///
  /// Flip direction will be decided over this axis depending
  /// whether we will be animating up or down the alphabet
  final Axis axis;

  /// Font size of board letters.
  final double fontSize;

  /// Letter panel width.
  ///
  /// Defaults to fontSize + 4
  final double flipLetterWidth;

  /// Letter panel height.
  ///
  /// Defaults to fontSize + 6
  final double flipLetterHeight;

  /// Flag to define if there will be a border for each digit panel.
  ///
  /// Defaults to null, when the existence of the border is infered from
  /// border color and border width attributes
  final bool? showBorder;

  /// Letter panel border width.
  ///
  /// Defaults to 1.0
  final double? borderWidth;

  /// Letter panel border color.
  ///
  /// Defaults to colorScheme.onPrimary
  final Color? borderColor;

  /// Width of the middle hinge element.
  ///
  /// Defaults to zero
  final double hingeWidth;

  /// Length of the middle hinge element.
  ///
  /// Defaults to zero
  final double hingeLength;

  /// Color of the middle hinge element.
  ///
  /// Defaults to null, rendering a transparent hinge (trasnparent separator)
  final Color? hingeColor;

  /// Optional list of colors for the panel background when animation starts.
  ///
  /// The color for each letter panel will be retrieved in order from this list.
  /// Colors wil be cycled if this color list is smaller then the length of the frase.
  ///
  /// The default is colorScheme.primary
  final List<Color>? startColors;

  /// Optional list of colors for the panel background when animation finishes.
  ///
  /// The color for each letter panel will be retrieved in order from this list.
  /// Colors wil be cycled if this color list is smaller then the length of the frase.
  ///
  /// The default is colorScheme.primaryVariant
  final List<Color>? endColors;

  /// Optional list of colors for letters.
  ///
  /// The color for each letter will be retrieved in order from this list.
  /// Colors wil be cycled if this color list is smaller then the length of the frase.
  ///
  /// The default is colorScheme.onPrimary
  final List<Color>? letterColors;

  /// Spacing between letters.
  ///
  /// Defaults to 1.0
  final double letterSpacing;

  /// Minimum flip delay for the generate random delay.
  final int minFlipDelay;

  /// Max flip delay for the generate random delay.
  final int maxFlipDelay;

  /// Optional callback for the whole frase animation completion.
  final VoidCallback? onDone;

  /// Optional parameter for a [ValueNotifier] to signal a restart of the whole animation.
  ///
  /// Defaults to a private VelueNotifier(0)
  final ValueNotifier<int> startNotifier;

  final Characters _startChars, _endChars;
  final _doneList = <bool>[];

  _clearDoneList() {
    _doneList.clear();
    for (var i = 0; i < _startChars.length; ++i) {
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
          for (var i = 0; i < _startChars.length; ++i) {
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
    final startLetter = _startChars.elementAt(index);
    final endLetter = _endChars.elementAt(index);
    final colorScheme = Theme.of(context).colorScheme;
    final startColor = _color(startColors, index) ?? colorScheme.primary;
    final endColor = _color(endColors, index) ?? colorScheme.primaryVariant;
    final letterColor = _color(letterColors, index) ?? colorScheme.onPrimary;

    return Container(
      child: FlipWidget<String>(
        startCount: startCount,
        itemStream: _letterStream(startLetter, endLetter, delay),
        itemBuilder: (context, item) => _itemBuilder(
          context,
          item,
          endLetter: endLetter,
          startColor: startColor,
          endColor: endColor,
          letterColor: letterColor,
        ),
        flipType: flipType,
        flipDirection: _letterDirection(startLetter, endLetter),
        flipDuration: Duration(milliseconds: (delay * 2.0 / 3.0).truncate()),
        hingeWidth: hingeWidth,
        hingeLength: hingeLength,
        hingeColor: hingeColor,
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
    required Color letterColor,
  }) {
    final textStyle = TextStyle(color: letterColor, fontSize: fontSize);

    final child = item == null ? null : Text(item, style: textStyle);
    final color = item == endLetter ? endColor : startColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: letterSpacing),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        border: (showBorder ?? (borderColor != null || borderWidth != null))
            ? Border.all(
                color: borderColor ?? Theme.of(context).colorScheme.onPrimary,
                width: borderWidth ?? 1.0,
              )
            : null,
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
