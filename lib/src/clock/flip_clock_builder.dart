import 'package:flutter/material.dart';

import '../widget/flip_widget.dart';

/// Helper class with builder methods to compose a flip clock display.
///
/// Used by [FlipClock] and [FlipCountdownClock].
class FlipClockBuilder {
  /// Constructor where all not null parameters are required.
  ///
  /// Default values should be defined in composing classes.
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

  /// FontSize for clock digits.
  final double digitSize;

  /// Width of each digit panel.
  final double width;

  /// Height of each digit panel.
  final double height;

  /// Animation flip direction.
  final AxisDirection flipDirection;

  /// Animation curve.
  ///
  /// If null FlipWidget.defaultAnimation will be used
  final Curve? flipCurve;

  /// Digit color.
  ///
  /// Defaults to colorScheme.onPrimary
  final Color? digitColor;

  /// Digit panel color (background color).
  ///
  /// Defauts to colorScheme.primary
  final Color? backgroundColor;

  /// Separator width to display a ":" between digit groups.
  ///
  /// Defaults to digit width / 3
  final double separatorWidth;

  /// Separator color to display a ":" between digit groups.
  ///
  /// Defaults to colorScheme.onPrimary
  final Color? separatorColor;

  /// Separator background color where we display a ":" between digit groups.
  ///
  /// Defaults to null (transparent)
  final Color? separatorBackgroundColor;

  /// Flag to define if there will be a border for each digit panel.
  final bool showBorder;

  /// Border width for each digit panel.
  ///
  /// Defaults to 1.0
  final double? borderWidth;

  /// Border color for each digit panel.
  ///
  /// Defaults to colorScheme.onPrimary when showBorder is true
  final Color? borderColor;

  /// Border radius for each digit panel.
  final BorderRadius borderRadius;

  /// Hinge width for each digit panel.
  final double hingeWidth;

  /// Hinge length for each digit panel.
  final double hingeLength;

  /// Hinge color for each digit panel.
  ///
  /// Defaults to null (transparent)
  final Color? hingeColor;

  /// Spacing betwen digit panels.
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
