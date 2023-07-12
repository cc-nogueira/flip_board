import 'dart:async';

import 'package:async/async.dart';
import 'package:flip_board/flip_board.dart';
import 'package:flutter/material.dart';

/// Example page to display a [FlipMatrixBoardStream] of images.
///
/// Presents a FlipMatrix that will display the images from a list of asset paths.
///
/// This page includes a loop button and a pause button and demonstrates the use
/// of stream feeding controlled in this parent widget.
class FlipMatrixBoardStreamPage extends StatefulWidget {
  const FlipMatrixBoardStreamPage({Key? key}) : super(key: key);

  final width = 375.0;
  final height = 200.0;
  final List<String> imageNames = const [
    'assets/horizontal/flower.png',
    'assets/horizontal/butterfly.png',
    'assets/horizontal/sea.png',
    'assets/horizontal/bird.png',
  ];

  @override
  State<FlipMatrixBoardStreamPage> createState() => _FlipMatrixBoardStreamPageState();
}

class _FlipMatrixBoardStreamPageState extends State<FlipMatrixBoardStreamPage> {
  final _controller = StreamController<String>();
  StreamSubscription<String>? _feedSubscription;
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
    _feedSubscription?.cancel();
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
                _flipWidget,
                _animationControl,
              ],
            ),
          ),
        ),
      );

  Widget get _flipWidget => Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
        child: FlipMatrixBoardStream<String>(
          itemStream: _controller.stream,
          itemBuilder: _itemBuilder,
          axis: Axis.vertical,
          width: 375.0,
          height: 200.0,
          columnCount: 8,
          rowCount: 4,
        ),
      );

  Widget get _animationControl => Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: ToggleButtons(
          color: Colors.black,
          isSelected: _isSelected,
          onPressed: _onToggle,
          borderRadius: BorderRadius.circular(8.0),
          children: [
            const Icon(Icons.loop),
            Icon(Icons.pause, color: _done ? Colors.grey : null),
          ],
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
    _feedSubscription?.cancel();
    _feedSubscription = _itemStream.listen(
      (event) => _controller.add(event),
      onDone: () {
        if (_loop && !_controller.isClosed) {
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
    return _periodicItemStream(0).where((name) => name.isNotEmpty).take(widget.imageNames.length);
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
