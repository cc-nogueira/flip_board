import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flip_board/flip_widget.dart';

class UhaaFlipGamePage extends StatefulWidget {
  const UhaaFlipGamePage({Key? key}) : super(key: key);

  @override
  _UhaaFlipGamePageState createState() => _UhaaFlipGamePageState();
}

class _UhaaFlipGamePageState extends State<UhaaFlipGamePage>
    with SingleTickerProviderStateMixin {
  static final _rand = math.Random();

  late final AnimationController _uhaaController;
  late final Animation _uhaaAnimation;
  late final Animation _opacityAnimation;
  late final List<StreamController<Widget>> _cardControllers;
  late final List<Image> _cards;
  final _currentIndexes = [0, 1, 2];
  int _lastTapIndex = -1;
  bool _hasSecondTap = false;
  bool _uhaa = false;
  int _uhaaCount = 0;

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
    _uhaaController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _uhaaAnimation = _uhaaController.drive(Tween(begin: 10.0, end: 30.0));
    _opacityAnimation =
        CurvedAnimation(parent: _uhaaController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    for (final controller in _cardControllers) {
      controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Uhaaa! Flip Game')),
        body: Center(
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
                child: _uhaaCount == 0
                    ? null
                    : AnimatedBuilder(
                        animation: _uhaaAnimation,
                        builder: _uhaaBuilder,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uhaaBuilder(BuildContext context, Widget? _) {
    if (_uhaa) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Uhaaa! ',
            style: TextStyle(
              color: Colors.red,
              fontSize: _uhaaAnimation.value,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'in $_uhaaCount',
            style: TextStyle(fontSize: _uhaaAnimation.value),
          ),
        ],
      );
    }
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Text(
        _uhaaCount.toString(),
        style: const TextStyle(fontSize: 30.0),
      ),
    );
  }

  Widget _card(int index, double angle) => Transform.rotate(
        angle: angle,
        child: GestureDetector(
          onTap: () => _onTap(index),
          child: FlipCard(
            flipDirection: AxisDirection.down,
            cardStream: _cardControllers[index].stream,
            initialCard: _cards[_currentIndexes[index]],
            angle: angle,
          ),
        ),
      );

  void _onTap(int index) {
    if (_uhaa) {
      setState(() {
        _uhaaCount = 0;
        _uhaa = false;
      });
      _flip(0, resetIndex: 0);
      _flip(1, resetIndex: 1);
      _flip(2, resetIndex: 2);
      return;
    }
    if (_lastTapIndex == index) {
      if (_hasSecondTap) {
        return;
      }
      _flip((index + 1) % 3);
      _flip((index + 2) % 3);
      _hasSecondTap = true;
    } else {
      _flip(index);
      _lastTapIndex = index;
      _hasSecondTap = false;
    }

    final match = _currentIndexes[0] == _currentIndexes[1] &&
        _currentIndexes[1] == _currentIndexes[2];

    setState(() {
      ++_uhaaCount;
      if (match) {
        _lastTapIndex = -1;
        _uhaa = true;
      }
      _uhaaController
        ..reset()
        ..forward();
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
  }) : super(key: key);

  final double angle;
  final Widget initialCard;
  final Stream<Widget> cardStream;
  final AxisDirection flipDirection;
  final Duration flipDuration;

  @override
  Widget build(BuildContext context) => FlipWidget(
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
