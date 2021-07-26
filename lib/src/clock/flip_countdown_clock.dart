import 'dart:async';

import 'package:flutter/material.dart';

import 'flip_clock_builder.dart';

/// FlipCountdownClock display a countdown flip clock.
///
/// Dispaly a row of [FlipWidget] to show the countdown digits,
/// this digits are refreshed by a stream of time left [Duration] instances,
/// Since FlipWidget only animate changes, only digits that actually
/// change between seconds are flipped.
///
/// Most constructor parameters are required to define digits appearance,
/// some parameters are optional, configuring flip panel appearance.
///
/// There is a onDone optional callback parameter to notify when the countdown finishes.
class FlipCountdownClock extends StatelessWidget {
  FlipCountdownClock({
    Key? key,
    required this.duration,
    Color? digitColor,
    Color? backgroundColor,
    Color? separatorColor,
    Color? separatorBackgroundColor,
    required double digitSize,
    required double height,
    required double width,
    double? separatorWidth,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    EdgeInsets digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
    double flipSpacing = 0.8,
    AxisDirection flipDirection = AxisDirection.up,
    this.onDone,
  })  : _showHours = duration.inHours > 0,
        _displayBuilder = FlipClockBuilder(
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          separatorColor: separatorColor,
          separatorBackgroundColor: separatorBackgroundColor,
          digitSize: digitSize,
          height: height,
          width: width,
          separatorWidth: separatorWidth ?? width / 3.0,
          borderRadius: borderRadius,
          digitSpacing: digitSpacing,
          flipSpacing: flipSpacing,
          flipDirection: flipDirection,
        );

  final Duration duration;
  final VoidCallback? onDone;

  final FlipClockBuilder _displayBuilder;
  final bool _showHours;

  @override
  Widget build(BuildContext context) {
    const step = Duration(seconds: 1);
    final startTime = DateTime.now();
    final endTime = startTime.add(duration).add(const Duration(seconds: 1));

    var done = false;
    final periodicStream = Stream<Duration>.periodic(step, (_) {
      final now = DateTime.now();
      if (now.isBefore(endTime)) {
        return endTime.difference(now);
      }
      if (!done && onDone != null) {
        onDone!();
      }
      done = true;
      return Duration.zero;
    });

    // Take up to (including) Duration.zero
    var fetchedZero = false;
    final durationStream = periodicStream.takeWhile((timeLeft) {
      final waitingZero = !fetchedZero;
      fetchedZero |= timeLeft.inSeconds == 0;
      return waitingZero;
    }).asBroadcastStream();

    final hoursDisplay = <Widget>[];
    if (_showHours) {
      hoursDisplay.addAll([
        _buildHoursDisplay(durationStream, duration),
        _displayBuilder.buildSeparator(context),
      ]);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...hoursDisplay,
        _buildMinutesDisplay(durationStream, duration),
        _displayBuilder.buildSeparator(context),
        _buildSecondsDisplay(durationStream, duration),
      ],
    );
  }

  Widget _buildHoursDisplay(Stream<Duration> stream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inHours % 24),
        initValue.inHours % 24,
      );

  Widget _buildMinutesDisplay(Stream<Duration> stream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inMinutes % 60),
        initValue.inMinutes % 60,
      );

  Widget _buildSecondsDisplay(Stream<Duration> stream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inSeconds % 60),
        initValue.inSeconds % 60,
      );
}
