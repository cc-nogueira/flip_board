import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';

/// Helper class with builder methods to compose a flip clock display.
///
/// Used by [FlipClock] and [FlipCountdownClock].
class FlipClockBuilder {
  const FlipClockBuilder({
    this.digitColor,
    this.backgroundColor,
    this.separatorColor,
    this.separatorBackgroundColor,
    this.borderColor,
    this.borderWidth,
    this.showBorder,
    required this.digitSize,
    required this.height,
    required this.width,
    required this.separatorWidth,
    required this.flipDirection,
    required this.borderRadius,
    required this.digitSpacing,
    required this.flipSpacing,
    this.flipCurve,
  });

  final Color? digitColor;
  final Color? backgroundColor;
  final Color? separatorColor;
  final Color? separatorBackgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final bool? showBorder;
  final double digitSize;
  final double height;
  final double width;
  final double separatorWidth;
  final BorderRadius borderRadius;
  final EdgeInsets digitSpacing;
  final double flipSpacing;
  final AxisDirection flipDirection;
  final Curve? flipCurve;

  /// Builds a Flip display for a time part (hour, minute, second).
  ///
  /// Returns a Row with the decimal and unit digits of a time part,
  /// where each digit is a [FlipWidget].
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

  Widget _buildUnitsDisplay(Stream<int> timePartStream, int initialValue) =>
      _buildDisplay(
        timePartStream.map<int>((value) => value % 10),
        initialValue % 10,
      );

  Widget _buildDisplay(Stream<int> digitStream, int initialValue) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: digitSpacing,
            child: FlipWidget<int>(
              itemStream: digitStream,
              itemBuilder: _digitBuilder,
              initialValue: initialValue,
              panelSpacing: flipSpacing,
              flipDirection: flipDirection,
              flipCurve: flipCurve ?? FlipWidget.defaultFlip,
            ),
          ),
        ],
      );

  Widget _digitBuilder(BuildContext context, int? digit) => Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.primary,
          borderRadius: borderRadius,
          border: (showBorder ?? (borderColor != null || borderWidth != null))
              ? Border.all(
                  color: borderColor ?? Theme.of(context).colorScheme.onPrimary,
                  width: borderWidth ?? 1.0,
                )
              : null,
        ),
        width: width,
        height: height,
        alignment: Alignment.center,
        child: Text(
          digit == null ? ' ' : digit.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: digitSize,
            color: digitColor ?? Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );

  /// Builds a display separator for time parts.
  ///
  /// This separator is a ":" Text in clock display style.
  Widget buildSeparator(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: digitSpacing,
            child: Container(
              decoration: BoxDecoration(
                color: separatorBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              ),
              width: separatorWidth,
              height: height,
              alignment: Alignment.center,
              child: Text(
                ':',
                style: TextStyle(
                    fontSize: digitSize - 4,
                    color: separatorColor ??
                        Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      );
}
