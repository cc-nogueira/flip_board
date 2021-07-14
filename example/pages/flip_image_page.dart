import 'package:flip_widget/flip_panel.dart';
import 'package:flutter/material.dart';

class AnimatedImagePage extends StatelessWidget {
  AnimatedImagePage({
    Key? key,
    required String imageName,
    required double width,
    required double height,
    required int columns,
    required int rows,
  })  : _imageFlipPanel = FlipPanel(
            imageName: imageName,
            width: width,
            height: height,
            columnCount: columns,
            rowCount: rows),
        super(key: key);

  final FlipPanel _imageFlipPanel;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('FlipImage')),
        body: Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_imageFlipPanel],
            ),
          ),
        ),
      );
}
