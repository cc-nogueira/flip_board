import 'dart:async';
import 'dart:math' as math;

import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

import 'uhaaa_message.dart';

class UhaaaFlipGame extends StatefulWidget {
  const UhaaaFlipGame({Key? key}) : super(key: key);

  @override
  _UhaaaFlipGameState createState() => _UhaaaFlipGameState();
}

class _UhaaaFlipGameState extends State<UhaaaFlipGame> {
  static final _rand = math.Random(DateTime.now().millisecondsSinceEpoch);

  late final List<StreamController<Widget>> _cardControllers;
  late final List<Image> _cards;
  final _currentIndexes = [0, 1, 2];

  bool _uhaaa = false;
  int _uhaaaCount = 0;
  int _lastTapIndex = -1;
  bool _hasSecondTap = false;

  @override
  void initState() {
    super.initState();

    _cards = [
      Image.asset('assets/sea.png', width: 125.0),
      Image.asset('assets/bird.png', width: 125.0),
      Image.asset('assets/butterfly.png', width: 125.0),
      Image.asset('assets/flower.png', width: 125.0),
    ];

    _cardControllers = [
      StreamController<Widget>(),
      StreamController<Widget>(),
      StreamController<Widget>(),
    ];
  }

  @override
  void dispose() {
    for (final controller in _cardControllers) {
      controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _card(0, 2 * math.pi / 5),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _card(1, math.pi / 2),
                    const SizedBox(height: 40),
                  ],
                ),
                _card(2, 3 * math.pi / 5),
              ],
            ),
            Container(
              height: 90.0,
              alignment: Alignment.center,
              child: _uhaaaCount > 0
                  ? UhaaaMessage(uhaaa: _uhaaa, uhaaaCount: _uhaaaCount)
                  : null,
            ),
          ],
        ),
      );

  Widget _card(int index, double angle) => FlipCard(
        angle: angle,
        onTap: () => _onTap(index),
        flipDirection: AxisDirection.down,
        cardStream: _cardControllers[index].stream,
        initialCard: _cards[_currentIndexes[index]],
      );

  void _onTap(int index) {
    if (_uhaaa) {
      _resetState();
      return;
    }
    if (_lastTapIndex == index) {
      if (_hasSecondTap) {
        return;
      }
      _hasSecondTap = true;

      _flip((index + 1) % 3);
      _flip((index + 2) % 3);
    } else {
      _lastTapIndex = index;
      _hasSecondTap = false;
      _flip(index);
    }

    final match = _currentIndexes[0] == _currentIndexes[1] &&
        _currentIndexes[1] == _currentIndexes[2];

    setState(() {
      ++_uhaaaCount;
      if (match) {
        _lastTapIndex = -1;
        _uhaaa = true;
      }
    });
  }

  void _resetState() {
    _flip(0, resetIndex: 0);
    _flip(1, resetIndex: 1);
    _flip(2, resetIndex: 2);
    setState(() {
      _uhaaaCount = 0;
      _uhaaa = false;
    });
  }

  void _flip(int index, {int? resetIndex}) {
    _currentIndexes[index] = resetIndex ?? _nextRandomIndexFor(index);
    _cardControllers[index].add(_cards[_currentIndexes[index]]);
  }

  int _nextRandomIndexFor(int index) =>
      (_currentIndexes[index] + _rand.nextInt(_cards.length - 1) + 1) %
      _cards.length;
}

class FlipCard extends StatelessWidget {
  const FlipCard({
    Key? key,
    required this.angle,
    required this.initialCard,
    required this.cardStream,
    required this.flipDirection,
    this.flipDuration = const Duration(seconds: 2),
    this.onTap,
  }) : super(key: key);

  final double angle;
  final Widget initialCard;
  final Stream<Widget> cardStream;
  final AxisDirection flipDirection;
  final Duration flipDuration;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: angle,
        child: GestureDetector(
          onTap: onTap,
          child: _flipWidget,
        ),
      );

  Widget get _flipWidget => FlipWidget(
        initialValue: initialCard,
        itemStream: cardStream,
        itemBuilder: _itemBuilder,
        flipType: FlipType.spinFlip,
        flipDirection: flipDirection,
        flipDuration: flipDuration,
        flipCurve: Curves.easeOutQuint,
        perspectiveEffect: 0.002,
      );

  Widget _itemBuilder(BuildContext context, Widget? item) =>
      Container(decoration: BoxDecoration(border: Border.all()), child: item);
}
