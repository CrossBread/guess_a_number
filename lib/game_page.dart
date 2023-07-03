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
  int _currentGuess = 0;
  GameManager get _gm => widget.gameManager;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    _gm.newGame();
    resetStateValues();
  }

  void resetStateValues() {
    setState(() {
      _guessSliderValue = (widget.answerMax.toDouble() / 2).round();
      _guessMin = widget.answerMin;
      _guessMax = widget.answerMax;
      _currentGuess = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    int playerAnswerSpaceSize = _guessMax - _guessMin + 1;
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
                  currentAnswerSpaceSize: _gm.aiAnswerSpaceSize,
                  initialAnswerSpaceSize: _gm.gameAnswerSpaceSize,
                ),
                const Spacer(),
                if (_gm.isGameOver)
                  Text(
                    _gm.isPlayerWinner ? 'You Win!!!' : 'AI Wins!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                const Spacer(),
                Text('${_gm.triesRemaining} Tries Left', style: Theme.of(context).textTheme.headlineSmall),
                AnswerSpaceWidget(
                  color: Theme.of(context).colorScheme.primary,
                  currentAnswerSpaceSize: playerAnswerSpaceSize,
                  initialAnswerSpaceSize: _gm.gameAnswerSpaceSize,
                ),
                Row(
                  children: List.generate(
                    _gm.gameAnswerSpaceSize.toString().length,
                    (index) => Expanded(
                      child: Card(
                        child: SizedBox.square(
                          dimension: 75,
                          child: Center(
                            child: Text(
                              // TODO: !!! find better way to pad small guesses with leading zeros
                              _currentGuess.toString().length > index ? _currentGuess.toString()[index] : '0',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            // TODO: !! Display Lock icon or color change when a digit is known for the rest of the answer space.  IE, every possible answer starts with 8, so show the player some progress.
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      GamePage.formatter.format(_guessMin),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      GamePage.formatter.format(_guessMax),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                // Text(
                //   GamePage.formatter.format(_playerLastGuess),
                //   style: Theme.of(context).textTheme.headlineMedium,
                // ),
                Slider(
                  label: _sliderLabelValue,
                  divisions: 100000,
                  onChangeEnd: onGuessMade,
                  value: _guessSliderValue.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _guessSliderValue = value.round();
                      _sliderLabelValue = _guessSliderValue.toString();
                      _currentGuess = _guessSliderValue;
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
      _currentGuess = _guessSliderValue;
      _sliderLabelValue = '';

      print('onChangeEnd: $_guessSliderValue');
      _gm.submitPlayerGuess(_guessSliderValue);

      if (_gm.isPlayerGuessHigh) {
        _guessMax = _guessSliderValue;
      } else if (_gm.isPlayerGuessLow) {
        _guessMin = _guessSliderValue;
      } else if (_gm.isPlayerWinner) {
        _guessMin = _guessSliderValue;
        _guessMax = _guessSliderValue;
        onPlayerWins(_guessSliderValue);
      }
    });

    if (!_gm.isGameOver) {
      setState(() {
        int aiGuess = _gm.generateAiGuess();
        _gm.submitAiGuess(aiGuess);
      });
    }
  }

  void onPlayerWins(int guessSliderValue) {
    print('onPlayerWins: $guessSliderValue');
  }
}
