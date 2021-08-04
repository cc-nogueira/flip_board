import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';

/// Helper class with builder methods to compose a flip clock display.
///
/// Used by [FlipClock] and [FlipCountdownClock].
///
/// All not null parameters are required,
/// default values should be defined in composing classes.
class FlipClockBuilder {
  const FlipClockBuilder({
    required this.digitSize,
    required this.width,
    required this.height,
    required this.flipDirection,
    this.flipCurve,
    this.digitColor,
    this.backgroundColor,
    required this.separatorWidth,
    this.separatorColor,
    this.separatorBackgroundColor,
    required this.showBorder,
    this.borderWidth,
    this.borderColor,
    required this.borderRadius,
    required this.hingeWidth,
    required this.hingeLength,
    this.hingeColor,
    required this.digitSpacing,
  });

  final double digitSize;
  final double width;
  final double height;
  final AxisDirection flipDirection;
  final Curve? flipCurve;
  final Color? digitColor;
  final Color? backgroundColor;
  final double separatorWidth;
  final Color? separatorColor;
  final Color? separatorBackgroundColor;
  final bool showBorder;
  final double? borderWidth;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final double hingeWidth;
  final double hingeLength;
  final Color? hingeColor;
  final EdgeInsets digitSpacing;

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
              flipType: FlipType.middleFlip,
              itemStream: digitStream,
              itemBuilder: _digitBuilder,
              initialValue: initialValue,
              hingeWidth: hingeWidth,
              hingeLength: hingeLength,
              hingeColor: hingeColor,
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
          border: showBorder
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
