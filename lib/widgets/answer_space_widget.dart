import 'package:flutter/material.dart';
import 'package:guess_a_number/game_page.dart';

class AnswerSpaceWidget extends StatelessWidget {
  final Color color;

  const AnswerSpaceWidget({
    super.key,
    required this.currentAnswerSpaceSize,
    required this.initialAnswerSpaceSize,
    required this.color,
  });

  final int currentAnswerSpaceSize;
  final int initialAnswerSpaceSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${GamePage.formatter.format(currentAnswerSpaceSize)} possible answers'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                color: color,
                minHeight: 100,
                value: (1 - currentAnswerSpaceSize / initialAnswerSpaceSize).toDouble(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
