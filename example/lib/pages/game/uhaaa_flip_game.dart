import 'dart:async';
import 'dart:math' as math;

import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

import 'uhaaa_message.dart';

/// Uhaaa! Flip Game demonstrate the use of three FlipWidgets intances
/// to provide a game of matching cards.
///
/// Each FlipWidget is driven by on Stream of cards. These streams are fed by
/// user actions in controlled by this class, as defined by the following game rules:
///  - The goal of the game is to flip cards until all three cards match with the same painting.
///  - There are two valid actions:
///    - A first tap on a card: will flip that card
///    - A second consecutive tap on a card: wil flip the other two cards
///
/// It is a simple game to demonstrate how one can use a FlipWidget through a local StreamConotroller.
///
/// Give it try, and good luck!
class UhaaaFlipGame extends StatefulWidget {
  const UhaaaFlipGame({Key? key}) : super(key: key);

  @override
  State<UhaaaFlipGame> createState() => _UhaaaFlipGameState();
}

class _UhaaaFlipGameState extends State<UhaaaFlipGame> {
  static final _rand = math.Random(DateTime.now().millisecondsSinceEpoch);

  late final List<StreamController<Widget>> _cardControllers;
  late final List<Image> _cards;
  final _cardsIdx = [0, 1, 2];

  bool _uhaaa = false;
  int _uhaaaCount = 0;
  int _lastTapIndex = -1;
  bool _hasSecondTap = false;

  @override
  void initState() {
    super.initState();

    _cards = [
      Image.asset('assets/vertical/van-Gogh_The-Bedroom.jpg', width: 80.0),
      Image.asset('assets/vertical/van-Gogh_Self-Portrait-1.jpg', width: 80.0),
      Image.asset('assets/vertical/van-Gogh_Starry-Night.jpg', width: 80.0),
      Image.asset('assets/vertical/van-Gogh_The-Factory.jpg', width: 80.0),
      Image.asset('assets/vertical/van-Gogh_Irises.jpg', width: 80.0),
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
            Container(
              height: 120.0,
              alignment: Alignment.center,
              child: UhaaaInstruction(uhaaa: _uhaaa, uhaaaCount: _uhaaaCount),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _card(0, -math.pi / 11),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _card(1, 0),
                    const SizedBox(height: 35),
                  ],
                ),
                _card(2, math.pi / 11),
              ],
            ),
            Container(
              height: 140.0,
              child: UhaaaMessage(
                uhaaa: _uhaaa,
                uhaaaCount: _uhaaaCount,
                onTapRestart: _restart,
              ),
            ),
          ],
        ),
      );

  Widget _card(int index, double angle) => FlipCard(
        angle: angle,
        onTap: () => _onTap(index),
        flipDirection: AxisDirection.right,
        cardStream: _cardControllers[index].stream,
        initialCard: _cards[_cardsIdx[index]],
      );

  void _onTap(int index) {
    if (_uhaaa) {
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

    setState(() {
      ++_uhaaaCount;
      if (_cardsIdx[0] == _cardsIdx[1] && _cardsIdx[1] == _cardsIdx[2]) {
        _lastTapIndex = -1;
        _uhaaa = true;
      }
    });
  }

  void _restart() {
    _flip(0, resetIndex: 0);
    _flip(1, resetIndex: 1);
    _flip(2, resetIndex: 2);
    setState(() {
      _uhaaaCount = 0;
      _uhaaa = false;
    });
  }

  void _flip(int index, {int? resetIndex}) {
    _cardsIdx[index] = resetIndex ?? _nextRandomIndexFor(index);
    _cardControllers[index].add(_cards[_cardsIdx[index]]);
  }

  int _nextRandomIndexFor(int index) => (_cardsIdx[index] + _rand.nextInt(_cards.length - 1) + 1) % _cards.length;
}

/// Simple Stateless class to build a FlipWidget with given parameters.
///
/// FlipWidget content is controlled by the owner of the given card stream.
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
