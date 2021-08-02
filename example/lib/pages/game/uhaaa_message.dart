import 'package:flutter/material.dart';

class UhaaaMessage extends StatefulWidget {
  const UhaaaMessage({
    Key? key,
    required this.uhaaa,
    required this.uhaaaCount,
  }) : super(key: key);

  final bool uhaaa;
  final int uhaaaCount;

  @override
  _UhaaaMessageState createState() => _UhaaaMessageState();
}

class _UhaaaMessageState extends State<UhaaaMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation _sizeAnimation;
  late final Animation _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _sizeAnimation = animation.drive(Tween(begin: 10.0, end: 30.0));
    _opacityAnimation = animation;

    _animate();
  }

  @override
  void didUpdateWidget(covariant UhaaaMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animate();
  }

  void _animate() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedBuilder(animation: _controller, builder: _builder);

  Widget _builder(BuildContext context, Widget? _) =>
      widget.uhaaa ? _uhaaaMessage : _uhaaaCount;

  Widget get _uhaaaMessage => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Uhaaa! ',
            style: TextStyle(
              color: Colors.red,
              fontSize: _sizeAnimation.value,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'in ${widget.uhaaaCount}',
            style: TextStyle(fontSize: _sizeAnimation.value),
          ),
        ],
      );

  Widget get _uhaaaCount => Opacity(
        opacity: _opacityAnimation.value,
        child: Text(
          widget.uhaaaCount.toString(),
          style: const TextStyle(fontSize: 30.0),
        ),
      );
}
