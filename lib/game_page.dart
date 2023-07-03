import 'package:flutter/material.dart';
import 'package:guess_a_number/widgets/answer_space_widget.dart';
import 'package:guess_a_number/game_manager.dart';
import 'package:intl/intl.dart';

class GamePage extends StatefulWidget {
  static final formatter = NumberFormat("#,###");
  final GameManager gameManager;
  final int answerMin;
  final int answerMax;

  const GamePage({
    super.key,
    required this.gameManager,
    required this.answerMin,
    required this.answerMax,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _guessSliderValue = 1;
  String _sliderLabelValue = '';
  int _guessMin = 0;
  int _guessMax = 1;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    widget.gameManager.newGame();
    resetStateValues();
  }

  void resetStateValues() {
    setState(() {
      _guessSliderValue = (widget.answerMax.toDouble() / 2).round();
      _guessMin = widget.answerMin;
      _guessMax = widget.answerMax;
    });
  }

  @override
  Widget build(BuildContext context) {
    int playerAnswerSpaceSize = _guessMax - _guessMin;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Guess a Number"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FilledButton.icon(
              label: const Text('New Game'),
              icon: const Icon(Icons.refresh),
              onPressed: () {
                startNewGame();
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Between ${widget.answerMin} and ${GamePage.formatter.format(widget.answerMax)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                AnswerSpaceWidget(
                  color: Theme.of(context).colorScheme.secondary,
                  currentAnswerSpaceSize: widget.gameManager.aiAnswerSpaceSize,
                  initialAnswerSpaceSize: widget.gameManager.gameAnswerSpaceSize,
                ),
                const Spacer(),
                if (widget.gameManager.isGameOver)
                  Text(
                    widget.gameManager.isPlayerWinner ? 'You Win!!!' : 'AI Wins!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                const Spacer(),
                Text('${widget.gameManager.triesRemaining} Tries Left',
                    style: Theme.of(context).textTheme.headlineSmall),
                AnswerSpaceWidget(
                  color: Theme.of(context).colorScheme.primary,
                  currentAnswerSpaceSize: playerAnswerSpaceSize,
                  initialAnswerSpaceSize: widget.gameManager.gameAnswerSpaceSize,
                ),
                // Text(
                //   GamePage.formatter.format(_playerLastGuess),
                //   style: Theme.of(context).textTheme.headlineMedium,
                // ),
                const Spacer(),
                Slider(
                  label: _sliderLabelValue,
                  divisions: 100000,
                  onChangeEnd: onGuessMade,
                  value: _guessSliderValue.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _guessSliderValue = value.round();
                      _sliderLabelValue = _guessSliderValue.toString();
                    });
                  },
                  min: _guessMin.toDouble(),
                  max: _guessMax.toDouble(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onGuessMade(double value) {
    setState(() {
      _guessSliderValue = value.round();
      _sliderLabelValue = '';

      print('onChangeEnd: $_guessSliderValue');
      widget.gameManager.submitPlayerGuess(_guessSliderValue);

      if (widget.gameManager.isPlayerGuessHigh) {
        _guessMax = _guessSliderValue;
      } else if (widget.gameManager.isPlayerGuessLow) {
        _guessMin = _guessSliderValue;
      } else if (widget.gameManager.isPlayerWinner) {
        _guessMin = _guessSliderValue;
        _guessMax = _guessSliderValue;
        onPlayerWins(_guessSliderValue);
      }
    });

    if (!widget.gameManager.isGameOver) {
      setState(() {
        int aiGuess = widget.gameManager.generateAiGuess();
        widget.gameManager.submitAiGuess(aiGuess);
      });
    }
  }

  void onPlayerWins(int guessSliderValue) {
    print('onPlayerWins: $guessSliderValue');
  }
}
