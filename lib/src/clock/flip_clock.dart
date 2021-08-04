import 'dart:async';

import 'package:flutter/material.dart';

import '../../flip_widget.dart';
import 'flip_clock_builder.dart';

/// FlipClock display with current time.
///
/// Display a row of [FlipWidget] to show the current time digits,
/// this digits are refreshed by a stream of [DateTime].now() instances.
/// Since FlipWidget animates only changes, just digits that actually
/// change between seconds are flipped.
///
/// Constructor parameters define clock digits and flip panel appearance.
/// - flipDirection defaults to AxisDirection.down.
/// - flipCurve defaults to FlipWidget.bounceFastFlip when direction is down, to FlipWidget.defaultFlip otherwise
/// - digitColor and separatorColor defaults to colorScheme.onPrimary.
/// - backgroundColor defauts to colorScheme.primary.
/// - separatorWidth defaults to width / 3.
/// - separatorColor defaults to colorScheme.onPrimary.
/// - separatorBackground defaults to null (transparent).
/// - showBorder can be set or defaults to true if boderColor or borderWidth is set
/// - borderWidth defaults to 1.0 when a borderColor is set
/// - borderColor defaults to colorScheme.onPrimary when a width is set.
/// - borderRadius defaults to Radius.circular(4.0)
/// - digitSpacing defaults to horizontal: 2.0
/// - hingeWidth defaults to 0.8
/// - hindeLength defaults to CrossAxis size
/// - hingeColor defaults to null (transparent)
class FlipClock extends StatelessWidget {
  FlipClock({
    Key? key,
    required double digitSize,
    required double width,
    required double height,
    AxisDirection flipDirection = AxisDirection.down,
    Curve? flipCurve,
    Color? digitColor,
    Color? backgroundColor,
    double? separatorWidth,
    Color? separatorColor,
    Color? separatorBackgroundColor,
    bool? showBorder,
    double? borderWidth,
    Color? borderColor,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    double hingeWidth = 0.8,
    double? hingeLength,
    Color? hingeColor,
    EdgeInsets digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
  })  : assert(hingeLength == null ||
            hingeWidth == 0.0 && hingeLength == 0.0 ||
            hingeWidth > 0.0 && hingeLength > 0.0),
        assert((borderWidth == null && borderColor == null) ||
            (showBorder == null || showBorder == true)),
        _displayBuilder = FlipClockBuilder(
          digitSize: digitSize,
          width: width,
          height: height,
          flipDirection: flipDirection,
          flipCurve: flipCurve ??
              (flipDirection == AxisDirection.down
                  ? FlipWidget.bounceFastFlip
                  : FlipWidget.defaultFlip),
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          separatorWidth: separatorWidth ?? width / 3.0,
          separatorColor: separatorColor,
          separatorBackgroundColor: separatorBackgroundColor,
          showBorder:
              showBorder ?? (borderColor != null || borderWidth != null),
          borderWidth: borderWidth,
          borderColor: borderColor,
          borderRadius: borderRadius,
          hingeWidth: hingeWidth,
          hingeLength: hingeWidth == 0.0
              ? 0.0
              : hingeLength ??
                  (flipDirection == AxisDirection.down ||
                          flipDirection == AxisDirection.up
                      ? width
                      : height),
          hingeColor: hingeColor,
          digitSpacing: digitSpacing,
        ),
        super(key: key);

  final FlipClockBuilder _displayBuilder;

  @override
  Widget build(BuildContext context) {
    final initValue = DateTime.now();
    final timeStream = Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    ).asBroadcastStream();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHourDisplay(timeStream, initValue),
        _displayBuilder.buildSeparator(context),
        _buildMinuteDisplay(timeStream, initValue),
        _displayBuilder.buildSeparator(context),
        _buildSecondDisplay(timeStream, initValue),
      ],
    );
  }

  Widget _buildHourDisplay(Stream<DateTime> timeStream, DateTime initValue) =>
      _displayBuilder.buildTimePartDisplay(
          timeStream.map((time) => time.hour), initValue.hour);

  Widget _buildMinuteDisplay(Stream<DateTime> timeStream, DateTime initValue) =>
      _displayBuilder.buildTimePartDisplay(
          timeStream.map((time) => time.minute), initValue.minute);

  Widget _buildSecondDisplay(Stream<DateTime> timeStream, DateTime initValue) =>
      _displayBuilder.buildTimePartDisplay(
          timeStream.map((time) => time.second), initValue.second);
}
