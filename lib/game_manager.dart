import 'dart:math';

import 'package:guess_a_number/game_state.dart';

class GameManager {
  GameState _gameState;

  GameManager({initialGameState}) : _gameState = initialGameState;

  get answer => _gameState.answer;

  void newGame() {
    _gameState = GameState.empty.copyWith(
      answer: Random().nextInt(GameState.answerMax) + GameState.answerMin,
    );
  }
}
