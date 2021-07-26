import 'dart:async';

import 'package:async/async.dart';
import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

/// Example page to display a [FlipMatrixBoardStream] of images.
///
/// Presents a FlipMatrix that will display the images from list of imageNames
/// representing local asset paths.
///
/// The page constructor sets all configuration options:
/// FlipMatricBoardStreamPage(
///   required List<String> imagenNames, // Image.asset names
///   required Axis axis,                // Defines horizontal or vertical flips
///   required double width,             // Board (and image) width
///   required double height,            // Board (and images) height
///   required int columns,              // Number of columns in the matrix
///   required int rows,                 // Number of rows in the matrix
/// )
///
/// This page includes a loop button and a pause button to demonstrate the use
/// of an internal stream to controll flip feeding.
class FlipMatrixBoardStreamPage extends StatefulWidget {
  FlipMatrixBoardStreamPage({
    Key? key,
    required this.imageNames,
    required this.axis,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
  })  : assert(imageNames.isNotEmpty),
        super(key: key);

  final List<String> imageNames;
  final Axis axis;
  final double width;
  final double height;
  final int columns;
  final int rows;

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
                    axis: widget.axis,
                    width: widget.width,
                    height: widget.height,
                    columnCount: widget.columns,
                    rowCount: widget.rows,
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
                    Icon(
                      Icons.pause,
                      color: _done ? Colors.grey : null,
                    ),
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
