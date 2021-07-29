import 'dart:async';

import 'package:flutter/material.dart';

import '../../flip_widget.dart';
import 'flip_clock_builder.dart';

/// FlipClock display with current time.
///
/// Display a row of [FlipWidget] to show the current time digits,
/// this digits are refreshed by a stream of [DateTime].now() instances.
/// Since FlipWidget only animate changes, only digits that actually
/// change between seconds are flipped.
///
/// Constructor parameters define clock digits and flip panel appearance.
/// - backgroundColor defauts to colorScheme.primary.
/// - digitColor and separatorColor defaults to colorScheme.onPrimary.
/// - separatorColor defaults to colorScheme.onPrimary.
/// - separatorBackground defaults to null (no separator background color)
class FlipClock extends StatelessWidget {
  FlipClock({
    Key? key,
    Color? digitColor,
    Color? backgroundColor,
    Color? separatorColor,
    Color? separatorBackgroundColor,
    Color? borderColor,
    double? borderWidth,
    bool? showBorder,
    required double digitSize,
    required double height,
    required double width,
    double? separatorWidth,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    EdgeInsets digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
    double flipSpacing = 0.8,
    AxisDirection flipDirection = AxisDirection.down,
  })  : _displayBuilder = FlipClockBuilder(
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          separatorColor: separatorColor,
          separatorBackgroundColor: separatorBackgroundColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          showBorder: showBorder,
          digitSize: digitSize,
          height: height,
          width: width,
          separatorWidth: separatorWidth ?? width / 3.0,
          borderRadius: borderRadius,
          digitSpacing: digitSpacing,
          flipSpacing: flipSpacing,
          flipDirection: flipDirection,
          flipCurve: FlipWidget.bounceFastFlip,
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
