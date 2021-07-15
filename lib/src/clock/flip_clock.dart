import 'dart:async';

import 'package:flutter/material.dart';

import 'clock_display_builder.dart';

/// FlipClock display with current time.
///
/// Display a row of [VerticalFlipWidget] to show the current time digits,
/// this digits are refreshed by a stream of [DateTime].now() instances
class FlipClock extends StatelessWidget {
  FlipClock({
    Key? key,
    required Color digitColor,
    required Color backgroundColor,
    required double digitSize,
    required double height,
    required double width,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    EdgeInsets digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
    double flipSpacing = 1.5,
    VerticalDirection flipDirection = VerticalDirection.down,
  })  : _displayBuilder = ClockDisplayBuilder(
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          digitSize: digitSize,
          height: height,
          width: width,
          borderRadius: borderRadius,
          digitSpacing: digitSpacing,
          flipSpacing: flipSpacing,
          flipDirection: flipDirection,
        ),
        super(key: key);

  final ClockDisplayBuilder _displayBuilder;

  @override
  Widget build(BuildContext context) {
    final initValue = DateTime.now();
    final timeStream = Stream<DateTime>.periodic(
      const Duration(milliseconds: 1000),
      (_) => DateTime.now(),
    ).asBroadcastStream();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHourDisplay(timeStream, initValue),
        _displayBuilder.buildSeparator(),
        _buildMinuteDisplay(timeStream, initValue),
        _displayBuilder.buildSeparator(),
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
