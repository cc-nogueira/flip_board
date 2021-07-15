import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';

/// Helper class with builder methods to compose a flip clock display.
///
/// Used by [FlipClock] and [FlipCountdownClock].
class FlipClockBuilder {
  const FlipClockBuilder({
    required this.digitColor,
    required this.backgroundColor,
    required this.digitSize,
    required this.height,
    required this.width,
    required this.flipDirection,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
    this.flipSpacing = 1.5,
  });

  final Color digitColor;
  final Color backgroundColor;
  final double digitSize;
  final double height;
  final double width;

  final BorderRadius borderRadius;
  final EdgeInsets digitSpacing;
  final double flipSpacing;
  final VerticalDirection flipDirection;

  /// Builds a Flip display for a time part (hour, minute, second).
  ///
  /// Returns a Row with the decimal and unit digits of a time part,
  /// where each digit is a [VerticalFlipWidget].
  Widget buildTimePartDisplay(Stream<int> timePartStream, int initValue) => Row(
        children: [
          _buildTensDisplay(timePartStream, initValue),
          _buildUnitsDisplay(timePartStream, initValue),
        ],
      );

  Widget _buildTensDisplay(Stream<int> timePartStream, int initialValue) =>
      _buildDisplay(
        timePartStream.map<int>((value) => value ~/ 10),
        initialValue ~/ 10,
      );

  Widget _buildUnitsDisplay(Stream<int> digitStream, int initialValue) =>
      _buildDisplay(
        digitStream.map<int>((value) => value % 10),
        initialValue % 10,
      );

  Widget _buildDisplay(Stream<int> digitStream, int initialValue) => Column(
        children: [
          Padding(
            padding: digitSpacing,
            child: VerticalFlipWidget<int>(
              itemStream: digitStream,
              itemBuilder: _digitBuilder,
              initialValue: initialValue,
              spacing: flipSpacing,
              direction: flipDirection,
            ),
          ),
        ],
      );

  Widget _digitBuilder(BuildContext context, int? digit) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        width: width,
        height: height,
        alignment: Alignment.center,
        child: Text(
          digit == null ? ' ' : digit.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: digitSize,
            color: digitColor,
          ),
        ),
      );

  /// Builds a display separator for time parts.
  ///
  /// This separator is a ":" Text in clock display style.
  Widget buildSeparator() => Padding(
        padding: digitSpacing,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
          width: width / 2,
          height: height,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              ':',
              style: TextStyle(fontSize: digitSize - 4, color: digitColor),
            ),
          ),
        ),
      );
}
