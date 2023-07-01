import 'package:guess_a_number/game_state.dart';

class GameManager {
  GameState _gameState;

  GameManager({required GameState initialGameState}) : _gameState = initialGameState;
}
