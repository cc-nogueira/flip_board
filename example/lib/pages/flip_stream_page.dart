import 'package:async/async.dart';
import 'package:flip_widget/flip_panel.dart';
import 'package:flutter/material.dart';

class FlipStreamPage extends StatelessWidget {
  const FlipStreamPage({
    Key? key,
    this.initialImageName,
    required this.imageNames,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    this.imageChangeSeconds = 5,
    this.animationMillis = 2000,
  }) : super(key: key);

  final String? initialImageName;
  final List<String> imageNames;
  final double width;
  final double height;
  final int columns;
  final int rows;
  final int animationMillis;
  final int imageChangeSeconds;

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
                  child: FlipStreamPanel<String>(
                    initialValue: initialImageName,
                    itemStream: _itemStream,
                    itemBuilder: _itemBuilder,
                    width: width,
                    height: height,
                    columnCount: columns,
                    rowCount: rows,
                    animationMillis: animationMillis,
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Stream<String> get _itemStream {
    if (initialImageName == null && imageNames.isNotEmpty) {
      final initial = imageNames.removeAt(0);
      return StreamGroup.mergeBroadcast(
          [Stream.value(initial), _periodicItemStream]);
    }
    return _periodicItemStream;
  }

  Stream<String> get _periodicItemStream {
    return Stream.periodic(
      Duration(seconds: imageChangeSeconds),
      (idx) => idx < imageNames.length ? imageNames[idx] : '',
    ).take(imageNames.length).asBroadcastStream();
  }

  Widget _itemBuilder(BuildContext context, String? item) => item == null
      ? Container(
          height: height,
          width: width,
          color: Colors.black12,
        )
      : Image.asset(
          item,
          fit: BoxFit.fill,
          width: width,
          height: height,
        );
}
