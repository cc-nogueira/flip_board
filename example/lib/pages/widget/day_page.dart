import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';

class DayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final yesterday = DateTime.now().add(const Duration(days: -1)).day;
    final today = DateTime.now().day;
    return Scaffold(
      appBar: AppBar(title: const Text('Day of Month')),
      body: Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: FlipWidget(
          initialValue: yesterday,
          flipType: FlipType.middleFlip,
          itemStream: Stream.fromIterable([today]),
          itemBuilder: (_, day) => _container(day.toString()),
          flipDirection: AxisDirection.down,
        ),
      ),
    );
  }

  Widget _container(String text) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border.all(),
          borderRadius: BorderRadius.circular(4.0),
        ),
        width: 100.0,
        height: 100.0,
        child: Text(
          text,
          style: const TextStyle(fontSize: 64.0, fontWeight: FontWeight.bold),
        ),
      );
}
