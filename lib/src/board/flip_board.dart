import 'package:flutter/material.dart';

import 'flip_board_builder.dart';

class FlipBoard extends StatelessWidget {
  FlipBoard({
    Key? key,
    required Widget child,
    required double width,
    required double height,
    required int columnCount,
    required int rowCount,
    int animationMillis = 2000,
    Color backgroundColor = Colors.white,
  })  : _builder = SingleChildFlipBoardBuilder(
          child: child,
          width: width,
          height: height,
          columnCount: columnCount,
          rowCount: rowCount,
        ),
        super(key: key);

  FlipBoard.assetImage({
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

  final SingleChildFlipBoardBuilder _builder;

  @override
  Widget build(BuildContext context) => _builder.build(context);
}
