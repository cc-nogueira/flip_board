import 'package:flutter/material.dart';

import 'flip_panel_builder.dart';

class FlipPanel extends StatelessWidget {
  FlipPanel({
    Key? key,
    required Widget child,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    int animationMillis = 2000,
    Color backgroundColor = Colors.white,
  })  : _builder = SingleChildFlipPanelBuilder(
          child: child,
          width: width,
          height: height,
          columnCount: columnCount,
          rowCount: rowCount,
        ),
        super(key: key);

  FlipPanel.assetImage({
    Key? key,
    required String imageName,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    Color backgroundColor = Colors.white,
    int animationMillis = 2000,
  }) : this(
          child: Image.asset(
            imageName,
            fit: BoxFit.fill,
            width: width,
            height: height,
          ),
          width: width,
          height: height,
          columnCount: columnCount,
          rowCount: rowCount,
          animationMillis: animationMillis,
          backgroundColor: backgroundColor,
        );

  final SingleChildFlipPanelBuilder _builder;

  @override
  Widget build(BuildContext context) => _builder.build(context);
}
