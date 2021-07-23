# Flip Board

[![pub package](https://img.shields.io/pub/v/flip_board.svg)](https://pub.dartlang.org/packages/flip_board)
[![license](https://img.shields.io/github/license/cc-nogueira/flip_board.svg)](https://github.com/hacktons/convex_bottom_bar/raw/LICENSE)

Widgets to build displays that resemble Mechanical Flip Boards.

The basic components are stateful VerticalFlipWidget and HorizontalFlipWidget that renders flip transitions for a stream of items with an itemBuilder.

The package also includes other widgets that use that compose these basic components in useful ways:

- **[Basic Widgets](#basic-widgets)**
  - [Vertical Flip Widget](#vertical-flip-widget)
  - [Horizontal Flip Widget](#horizontal-flip-widget)
- **[Composed Widgets](#composed-widgets)**
  - [Flip Clock](#flip-clock)
  - [Flip Countdown Clock](#flip-countdown-clock)
  - [Flip Frase Board](#flip-frase-board)
  - [Flip Board](#flip-board)


## Basic Widgets

We have two basic widgets for vertical and horizontal flip animation. These widgets render flip animations for each item received in the provided stream. It is commonly used to display digits and letters but can actualy render any widget you
build through the given itemBuilder.

Both vertical and horizontal flip widgets have the same optional configuration options and the two required parameters:
- ***itemStream***: stream of items to be flipped as they are received.
- ***itemBuilder***: builder to create a widget out of each item

Please check the class documentation that describes these options.

### Vertical Flip Widget

When we remember on Mechanical Flip Boards as we used to see in airports and sport score boards we think on a VerticalFlipWidget or, most likely, on a composition (row) of them.

Its constructor looks like: 
```dart
VerticalFlipWidget({
  Color color,
  required double fontSize,
});
```

### Horizontal Flip Widget

## Composed Widgets

### Flip Clock
### Flip Countdown Clock

### Flip Frase Board

Example page with two FlipFraseBoards


<p>
	<img src="https://github.com/cc-nogueira/flip_board/blob/master/screenshots/FlipFraseBoard.gif?raw=true" width="290" height="533"  />
	<code>
	@override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flip Frase Board')),
        body: Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlipFraseBoard(
                  startLetter: 'A',
                  endFrase: 'FLUTTER',
                  fontSize: 42.0,
                  letterSpacing: 3.0,
                ),
                const SizedBox(height: 10.0),
                FlipFraseBoard(
                  startLetter: 'A',
                  endFrase: 'FLIP BOARD',
                  fontSize: 30.0,
                  flipSpacing: 0.5,
                  endColors: _endColors,
                ),
              ],
            ),
          ),
        ),
      );
		</code>
</p>
