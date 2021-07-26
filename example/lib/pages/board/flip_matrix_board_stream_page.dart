import 'dart:async';

import 'package:async/async.dart';
import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

/// Example page to display a [FlipMatrixBoardStream] of images.
///
/// Presents a FlipMatrix that will display the images from list asset paths.
///
/// This page includes a loop button and a pause button to demonstrate the use
/// of an internal stream to controll flip feeding.
class FlipMatrixBoardStreamPage extends StatefulWidget {
  final width = 375.0;
  final height = 200.0;
  final List<String> imageNames = [
    'assets/flower.png',
    'assets/butterfly.png',
    'assets/sea.png',
    'assets/bird.png',
  ];

  @override
  _FlipMatrixBoardStreamPageState createState() =>
      _FlipMatrixBoardStreamPageState();
}

class _FlipMatrixBoardStreamPageState extends State<FlipMatrixBoardStreamPage> {
  final _controller = StreamController<String>();
  bool _firstRun = true;
  bool _loop = false;
  bool _done = false;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _feedStream();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip Stream')),
        body: Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.blue)),
                  child: FlipMatrixBoardStream<String>(
                    itemStream: _controller.stream,
                    itemBuilder: _itemBuilder,
                    axis: Axis.vertical,
                    width: 375.0,
                    height: 200.0,
                    columnCount: 8,
                    rowCount: 4,
                  ),
                ),
                const SizedBox(height: 20.0),
                ToggleButtons(
                  color: Colors.black,
                  isSelected: _isSelected,
                  onPressed: _onToggle,
                  borderRadius: BorderRadius.circular(8.0),
                  children: [
                    const Icon(Icons.loop),
                    Icon(Icons.pause, color: _done ? Colors.grey : null),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  List<bool> get _isSelected => [_loop, _paused];

  void _onToggle(int idx) => setState(() {
        switch (idx) {
          case 0:
            _loop = !_loop;
            if (_loop && _done) {
              _firstRun = true;
              _feedStream();
            }
            break;
          case 1:
            _paused = !_done && !_paused;
            break;
        }
      });

  void _feedStream() {
    _done = false;
    _itemStream.listen(
      (event) => _controller.add(event),
      onDone: () {
        if (_loop) {
          _feedStream();
        } else {
          setState(() => _done = true);
        }
      },
    );
  }

  Stream<String> get _itemStream {
    if (_firstRun) {
      _firstRun = false;
      return StreamGroup.mergeBroadcast([
        Stream.value(widget.imageNames.first),
        _periodicItemStream(1),
      ]).where((name) => name.isNotEmpty).take(widget.imageNames.length);
    }
    return _periodicItemStream(0)
        .where((name) => name.isNotEmpty)
        .take(widget.imageNames.length);
  }

  Stream<String> _periodicItemStream(int startIdx) {
    var index = startIdx - 1;
    return Stream.periodic(
      const Duration(seconds: 6),
      (count) {
        if (_paused) return '';
        index = (index + 1) % widget.imageNames.length;
        return widget.imageNames[index];
      },
    );
  }

  Widget _itemBuilder(BuildContext context, String? item) => item == null
      ? Container(
          height: widget.height,
          width: widget.width,
          color: Colors.black12,
        )
      : Image.asset(
          item,
          fit: BoxFit.fill,
          width: widget.width,
          height: widget.height,
        );
}
