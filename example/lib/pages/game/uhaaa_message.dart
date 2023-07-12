import 'package:flutter/material.dart';

/// StatefulWidget to display the proper messages for the current game state.
///
/// Provides various status informations that show and hide with animations.
/// Also shows a restart button when the game finishes.
class UhaaaMessage extends StatefulWidget {
  const UhaaaMessage({
    Key? key,
    required this.uhaaa,
    required this.uhaaaCount,
    required this.onTapRestart,
  }) : super(key: key);

  final bool uhaaa;
  final int uhaaaCount;
  final VoidCallback onTapRestart;

  @override
  State<UhaaaMessage> createState() => _UhaaaMessageState();
}

class _UhaaaMessageState extends State<UhaaaMessage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation _countAnimation;
  late final Animation _uhaaaAnimation;
  late final Animation _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _countAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _uhaaaAnimation = Tween(begin: 10.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _buttonAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _animate();
  }

  @override
  void didUpdateWidget(covariant UhaaaMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animate();
  }

  void _animate() {
    if (widget.uhaaaCount == 0) {
      _controller.reverse(from: 1.0);
    } else {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _controller, builder: _builder);

  Widget _builder(BuildContext context, Widget? _) => Column(
        children: [
          const SizedBox(height: 16.0),
          widget.uhaaa ? _uhaaaMessage : _uhaaaCount,
          const SizedBox(height: 16.0),
          _restartButton,
        ],
      );

  Widget get _uhaaaMessage => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Uhaaa! ',
            style: TextStyle(
              color: Colors.red,
              fontSize: _uhaaaAnimation.value,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'in ${widget.uhaaaCount}',
            style: TextStyle(fontSize: _uhaaaAnimation.value),
          ),
        ],
      );

  Widget get _uhaaaCount {
    final message = widget.uhaaaCount == 0 ? 'Ready!' : widget.uhaaaCount.toString();
    final color = widget.uhaaaCount == 0 ? Colors.blue[800]! : Colors.black;
    return Opacity(
      opacity: _countAnimation.value,
      child: Text(message,
          style: TextStyle(
            color: color,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  Widget get _restartButton => Opacity(
        opacity: widget.uhaaa ? _buttonAnimation.value : 0.0,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            disabledForegroundColor: Colors.green.withOpacity(0.38),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
          ),
          onPressed: widget.onTapRestart,
          child: const Text('Play Again', style: TextStyle(fontSize: 20.0)),
        ),
      );
}

/// StatefulWidget to display the proper instruction message for the current game state.
///
/// Message parts show and hide with animations.
class UhaaaInstruction extends StatefulWidget {
  const UhaaaInstruction({
    Key? key,
    required this.uhaaa,
    required this.uhaaaCount,
  }) : super(key: key);

  final bool uhaaa;
  final int uhaaaCount;

  @override
  State<UhaaaInstruction> createState() => _UhaaaInstructionState();
}

class _UhaaaInstructionState extends State<UhaaaInstruction> with TickerProviderStateMixin {
  late final AnimationController _firstController;
  late final AnimationController _secondController;
  late final Animation _firstAnimation;
  late final Animation _secondAnimation;

  @override
  void initState() {
    super.initState();

    _firstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _secondController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _firstAnimation = CurvedAnimation(
      parent: _firstController,
      curve: Curves.easeIn,
    );
    _secondAnimation = CurvedAnimation(
      parent: _secondController,
      curve: Curves.easeIn,
    );

    _animate();
  }

  @override
  void didUpdateWidget(covariant UhaaaInstruction oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animate();
  }

  void _animate() {
    if (widget.uhaaaCount == 0) {
      _firstController.forward(from: 0.0);
    } else {
      _firstController.reverse();
    }
    if (widget.uhaaa) {
      _secondController.reverse(from: 1.0);
    } else {
      _secondController.forward();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(animation: _firstController, builder: _firstBuilder),
          AnimatedBuilder(animation: _secondController, builder: _secondBuilder),
        ],
      );

  Widget _firstBuilder(BuildContext context, Widget? _) => Opacity(
        opacity: _firstAnimation.value,
        child: Text(
          'Flip Cards To',
          style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
      );

  Widget _secondBuilder(BuildContext context, Widget? _) => Opacity(
        opacity: _secondAnimation.value,
        child: Text(
          'Match All Three',
          style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
      );
}
