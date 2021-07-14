import 'dart:async';

import 'package:flutter/material.dart';

import 'clock_display_builder.dart';

/// FlipCountdownClock display a countdown flip clock.
///
/// Dispaly a row of [VerticalFlipPanel] to show the countdown digits,
/// this digits are refreshed by a stream of time left [Duration] instances,
class FlipCountdownClock extends StatelessWidget {
  FlipCountdownClock({
    Key? key,
    required this.duration,
    required Color digitColor,
    required Color backgroundColor,
    required double digitSize,
    required double height,
    required double width,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    EdgeInsets digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
    double flipSpacing = 1.5,
    VerticalDirection flipDirection = VerticalDirection.up,
    this.onDone,
  })  : _showHours = duration.inHours > 0,
        _displayBuilder = ClockDisplayBuilder(
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          digitSize: digitSize,
          height: height,
          width: width,
          borderRadius: borderRadius,
          digitSpacing: digitSpacing,
          flipSpacing: flipSpacing,
          flipDirection: flipDirection,
        );

  final Duration duration;
  final VoidCallback? onDone;

  final ClockDisplayBuilder _displayBuilder;
  final bool _showHours;

  @override
  Widget build(BuildContext context) {
    const step = Duration(seconds: 1);
    final startTime = DateTime.now();
    final endTime = startTime.add(duration).add(const Duration(seconds: 1));

    var done = false;
    final initStream = Stream<Duration>.periodic(step, (_) {
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
    final durationStream = initStream.takeWhile((timeLeft) {
      final waitingZero = !fetchedZero;
      fetchedZero |= timeLeft.inSeconds == 0;
      return waitingZero;
    }).asBroadcastStream();

    final hoursDisplay = <Widget>[];
    if (_showHours) {
      hoursDisplay.addAll([
        _buildHoursDisplay(durationStream, duration),
        _displayBuilder.buildSeparator(),
      ]);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...hoursDisplay,
        _buildMinutesDisplay(durationStream, duration),
        _displayBuilder.buildSeparator(),
        _buildSecondsDisplay(durationStream, duration),
      ],
    );
  }

  Widget _buildHoursDisplay(
          Stream<Duration> durationStream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        durationStream.map((time) => time.inHours % 24),
        initValue.inHours % 24,
      );

  Widget _buildMinutesDisplay(
          Stream<Duration> durationStream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        durationStream.map((time) => time.inMinutes % 60),
        initValue.inMinutes % 60,
      );

  Widget _buildSecondsDisplay(
          Stream<Duration> durationStream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        durationStream.map((time) => time.inSeconds % 60),
        initValue.inSeconds % 60,
      );
}
