import 'package:guess_a_number/game_manager.dart';
import 'package:guess_a_number/game_state.dart';
import 'package:test/test.dart';

main() {
  // Verify that specific game rules are implemented correctly
  group('Game Rules', () {
    group('Rules 1-7', () {
      setUp(() {});
      test('1. Answer is different when new game starts', () {
        int originalAnswer = 123;
        GameManager manager = GameManager(initialGameState: GameState.empty.copyWith(answer: originalAnswer));

        // Start a new Game
        manager.newGame();
        expect(manager.answer != originalAnswer, isTrue);

        // Start another new Game (to ensure the answer consistently different, not just once different)
        originalAnswer = manager.answer;
        manager.newGame();
        expect(manager.answer != originalAnswer, isTrue);
      });
      test('2. Answer is within limits when generated', () {
        GameManager manager = GameManager(initialGameState: GameState.empty);
        manager.newGame();

        expect(manager.answer, isNonNegative);
        expect(manager.answer, greaterThanOrEqualTo(GameState.answerMin));
        expect(manager.answer, lessThanOrEqualTo(GameState.answerMax));
      });
      test('3. Evaluated Guesses are always within limits', () {
        GameManager manager = GameManager(initialGameState: GameState.empty);
        manager.submitPlayerGuess(GameState.answerMin);
        expect(manager.triesCount, equals(1));

        manager.submitPlayerGuess(GameState.answerMax);
        expect(manager.triesCount, equals(2));

        expect(() => manager.submitPlayerGuess(GameState.answerMin - 1), throwsRangeError);
        // Don't count out of bounds guesses
        expect(manager.triesCount, equals(2));

        expect(() => manager.submitPlayerGuess(GameState.answerMax + 1), throwsRangeError);
        // Don't count out of bounds guesses
        expect(manager.triesCount, equals(2));

        // AI Guesses are always within limits and don't consume tries
        manager.submitAiGuess(GameState.answerMin);
        expect(manager.triesCount, equals(2));
        manager.submitAiGuess(GameState.answerMax);
        expect(manager.triesCount, equals(2));

        expect(() => manager.submitAiGuess(GameState.answerMin - 1), throwsRangeError);
        // Don't count out of bounds guesses
        expect(manager.triesCount, equals(2));

        expect(() => manager.submitAiGuess(GameState.answerMax + 1), throwsRangeError);
        // Don't count out of bounds guesses
        expect(manager.triesCount, equals(2));
      });

      // manager.submitAiGuess(1);
      // manager.submitAiGuess(1000000);
      test('4. Game is over and player wins if they guess the answer', () {
        GameManager manager = GameManager(initialGameState: GameState.empty);
        manager.newGame();

        manager.submitPlayerGuess(manager.answer);
        manager.submitAiGuess(manager.answer);
        expect(manager.triesCount, equals(1));
        expect(manager.isGameOver, isTrue);
        expect(manager.isPlayerWinner, isTrue);
      });
      test('5. Game is over and player loses if the try limit is reached', () {
        GameManager manager =
            GameManager(initialGameState: GameState.empty.copyWith(answer: GameState.answerMax));

        for (int i = 0; i < GameState.triesMax; i++) {
          manager.submitPlayerGuess(GameState.answerMin);
          manager.submitAiGuess(GameState.answerMin);
        }
        expect(manager.triesCount, equals(GameState.triesMax));
        expect(manager.isGameOver, isTrue);
        expect(manager.isPlayerWinner, isFalse);
      });
      test('6. Game is over and player loses if the AI guesses the answer', () {
        GameManager manager = GameManager(initialGameState: GameState.empty.copyWith(answer: 123));

        manager.submitPlayerGuess(1);
        manager.submitAiGuess(manager.answer);
        expect(manager.triesCount, equals(1));
        expect(manager.isGameOver, isTrue);
        expect(manager.isPlayerWinner, isFalse);
        expect(manager.isAiWinner, isTrue);
      });
      test('7. Player Guesses return corresponding high or low indicator', () => throw UnimplementedError());
    });

    // Verify that the AI is behaving as expected, the behavior is not defined in the rules, but it should
    // be "intelligent" in the context of the rules
    group('AI Behavior', () {
      test('AI Guess is always within limits', () => throw UnimplementedError());
      test('AI Guess is always between last guess and the answer', () => throw UnimplementedError());
      test('AI Guess is not deterministic', () => throw UnimplementedError());
    });

    // Test conditions that should never occur and would represent a bug in the code
    // Defensive programming should anticipate where these may occur and throw errors
    // The UI layer is responsible for handling these errors and recovering gracefully
    group('Error Conditions', () {
      test('Player Guesses out of bounds throw an error', () => throw UnimplementedError());
      test('Player Guesses after game over throw an error', () => throw UnimplementedError());
      test('AI Guesses after game over throw an error', () => throw UnimplementedError());
    });
  });

  // Walk through different possible states and edge cases to ensure the game isn't brittle
  // Also helps ensure different logic branches are covered
  group('Game State', () {
    test('Guess is correct', () => throw UnimplementedError());
    test('Guess is above answer', () => throw UnimplementedError());
    test('Guess is below answer', () => throw UnimplementedError());
    test('Guess is negative', () => throw UnimplementedError());
    test('Guess is out of bounds', () => throw UnimplementedError());
    test('Guess limit is reached', () => throw UnimplementedError());
    test('AI Guess is correct', () => throw UnimplementedError());
    test('AI Guess is above answer', () => throw UnimplementedError());
    test('AI Guess is below answer', () => throw UnimplementedError());
    test('New game state', () => throw UnimplementedError());
    test('Play again state is reset', () => throw UnimplementedError());
  });
}
