import 'dart:async';

import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

/// Page with four FlipWidgets showing all flip direction animations.
///
/// Very simple page with four [FlipWidget] instances for the same broadcast stream.
/// Each [FlipWidget] is configured to flip with a different AxisDirection.
class FlipWidgetPage extends StatefulWidget {
  @override
  _FlipWidgetState createState() => _FlipWidgetState();
}

class _FlipWidgetState extends State<FlipWidgetPage> {
  final _controller = StreamController<int>.broadcast();
  int _nextValue = 0;

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip Widget')),
        body: Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _flipWidget(AxisDirection.up),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _flipWidget(AxisDirection.left),
                    _flipButton,
                    _flipWidget(AxisDirection.right),
                  ],
                ),
                _flipWidget(AxisDirection.down),
              ],
            ),
          ),
        ),
      );

  Widget get _flipButton => Container(
        width: 100.0,
        height: 100.0,
        child: IconButton(
          onPressed: _next,
          icon: const Icon(Icons.add_circle, size: 48.0),
        ),
      );

  Widget _flipWidget(AxisDirection direction) => Container(
        width: 60.0,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        child: FlipWidget(
          itemStream: _controller.stream,
          itemBuilder: _itemBuilder,
          initialValue: _nextValue,
          flipDirection: direction,
          perspectiveEffect: 0.008,
          panelSpacing:
              axisDirectionToAxis(direction) == Axis.vertical ? 0.8 : 1.1,
          flipDuration: const Duration(milliseconds: 600),
        ),
      );

  Widget _itemBuilder(BuildContext context, int? value) => Container(
        width: 48.0,
        height: 48.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryVariant,
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            border: Border.all(color: Colors.black)),
        child: Text(
          ((value ?? 0) % 10).toString(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 40.0,
          ),
        ),
      );

  void _next() => _controller.add(++_nextValue);
}
