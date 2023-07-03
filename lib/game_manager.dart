import 'dart:math';

import 'package:guess_a_number/game_state.dart';

class GameManager {
  late final Random _rng;
  late GameState _gameState;

  GameManager({required GameState initialGameState, int? randomSeed}) {
    _rng = Random(randomSeed);
    _gameState = initialGameState;
  }

  get answer => _gameState.answer;

  get triesCount => _gameState.triesCount;

  get isGameOver => isPlayerWinner || isAiWinner || isOutOfTries;

  get isPlayerWinner => _gameState.playerGuess == _gameState.answer;

  get isAiWinner => _gameState.aiGuess == _gameState.answer;

  get isOutOfTries => _gameState.triesCount >= GameState.triesMax;

  get isPlayerGuessHigh => _gameState.playerGuess > _gameState.answer;

  get isPlayerGuessLow => _gameState.playerGuess < _gameState.answer;

  get lastAiGuess => _gameState.aiGuess;

  get aiGuessMax => _gameState.aiGuessMax;

  get aiGuessMin => _gameState.aiGuessMin;

  get aiAnswerSpaceSize => _gameState.aiGuessMax - _gameState.aiGuessMin + 1;

  get gameAnswerSpaceSize => GameState.answerMax - GameState.answerMin + 1;

  get triesRemaining => GameState.triesMax - _gameState.triesCount;

  void newGame() {
    var randInt = _rng.nextInt(GameState.answerMax);
    _gameState = GameState.empty.copyWith(
      answer: randInt + GameState.answerMin,
    );
  }

  void submitPlayerGuess(int i) {
    if (i < GameState.answerMin || i > GameState.answerMax) {
      throw RangeError.range(i, GameState.answerMin, GameState.answerMax);
    }
    if (_gameState.triesCount >= GameState.triesMax) {
      throw StateError('Max tries exceeded');
    }
    if (isGameOver) {
      throw StateError('Game has already ended');
    }
    _gameState = _gameState.copyWith(
      playerGuess: i,
      triesCount: _gameState.triesCount + 1,
    );
  }

  void submitAiGuess(int guess) {
    if (guess < GameState.answerMin || guess > GameState.answerMax) {
      throw RangeError.range(guess, GameState.answerMin, GameState.answerMax);
    }

    if (isGameOver) {
      throw StateError('Game has already ended');
    }

    _gameState = _gameState.copyWith(
      aiGuess: guess,
      aiGuessCount: _gameState.aiGuessCount + 1,
      aiGuessMax: _gameState.answer <= guess ? guess : _gameState.aiGuessMax,
      aiGuessMin: _gameState.answer >= guess ? guess : _gameState.aiGuessMin,
    );
  }

  int generateAiGuess() {
    // Allow a deviation of up to +/- 10% of the answer space size, bounded by actual answer space
    var modifier = -.1 + 0.2 * _rng.nextDouble(); // (-10%, 10%)
    var deviation = (aiAnswerSpaceSize * modifier).round();
    var guess = ((aiAnswerSpaceSize) / 2 + _gameState.aiGuessMin + deviation)
        .round()
        .clamp(_gameState.aiGuessMin, _gameState.aiGuessMax);
    return guess;
  }
}
