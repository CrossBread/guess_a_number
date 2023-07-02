import 'dart:math';

import 'package:guess_a_number/game_state.dart';

class GameManager {
  GameState _gameState;

  GameManager({required GameState initialGameState}) : _gameState = initialGameState;

  get answer => _gameState.answer;

  get triesCount => _gameState.triesCount;

  get isGameOver => isPlayerWinner || isAiWinner || isOutOfTries;

  get isPlayerWinner => _gameState.playerGuess == _gameState.answer;
  get isAiWinner => _gameState.aiGuess == _gameState.answer;
  get isOutOfTries => _gameState.triesCount >= GameState.triesMax;

  get isPlayerGuessHigh => _gameState.playerGuess > _gameState.answer;

  get isPlayerGuessLow => _gameState.playerGuess < _gameState.answer;

  void newGame() {
    _gameState = GameState.empty.copyWith(
      answer: Random().nextInt(GameState.answerMax) + GameState.answerMin,
    );
  }

  void submitPlayerGuess(int i) {
    if (i < GameState.answerMin || i > GameState.answerMax) {
      throw RangeError.range(i, GameState.answerMin, GameState.answerMax);
    }
    if (_gameState.triesCount >= GameState.triesMax) {
      throw StateError('Max tries exceeded');
    }
    _gameState = _gameState.copyWith(
      playerGuess: i,
      triesCount: _gameState.triesCount + 1,
    );
  }

  submitAiGuess(int i) {
    if (i < GameState.answerMin || i > GameState.answerMax) {
      throw RangeError.range(i, GameState.answerMin, GameState.answerMax);
    }
    _gameState = _gameState.copyWith(
      aiGuess: i,
      aiGuessCount: _gameState.aiGuessCount + 1,
      // TODO: Set the following so they help the AI close in on the answer.
      aiGuessMax: max(_gameState.aiGuessMax, i),
      aiGuessMin: min(_gameState.aiGuessMin, i),
    );
  }
}
