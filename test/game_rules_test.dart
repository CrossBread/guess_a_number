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
        manager.newGame();

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
        expect(manager.triesCount, equals(1));
        expect(manager.isGameOver, isTrue);
        expect(manager.isPlayerWinner, isTrue);
      });
      test('5. Game is over and player loses if the try limit is reached', () {
        GameManager manager =
            GameManager(initialGameState: GameState.empty.copyWith(answer: GameState.answerMax));

        for (int i = 0; i < GameState.triesMax; i++) {
          manager.submitPlayerGuess(GameState.answerMin);
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
      test('7. Player Guesses return corresponding high or low indicator', () {
        GameManager manager = GameManager(initialGameState: GameState.empty);
        manager.newGame();

        manager.submitPlayerGuess(manager.answer - 1);
        expect(manager.isPlayerGuessHigh, isFalse);
        expect(manager.isPlayerGuessLow, isTrue);

        manager.submitPlayerGuess(manager.answer + 1);
        expect(manager.isPlayerGuessHigh, isTrue);
        expect(manager.isPlayerGuessLow, isFalse);

        manager.submitPlayerGuess(manager.answer);
        expect(manager.isPlayerGuessHigh, isFalse);
        expect(manager.isPlayerGuessLow, isFalse);
      });
    });

    // Verify that the AI is behaving as expected, the behavior is not defined in the rules, but it should
    // be "intelligent" in the context of the rules
    group('AI Behavior', () {
      var manager = GameManager(initialGameState: GameState.empty);
      setUp(() {
        manager = GameManager(initialGameState: GameState.empty, randomSeed: 123);
        manager.newGame();
      });

      test('AI Guess is always within max and min answer limits', () {
        for (int i = 0; i < 1000; i++) {
          int aiGuess = manager.generateAiGuess();
          expect(GameState.answerMax, greaterThanOrEqualTo(aiGuess));
          expect(GameState.answerMin, lessThanOrEqualTo(aiGuess));
        }
      });
      test('AI Guess is always between max and min ai guess', () {
        for (int i = 0; i < 1000; i++) {
          int aiGuess = manager.generateAiGuess();
          expect(manager.aiGuessMax, greaterThanOrEqualTo(aiGuess));
          expect(manager.aiGuessMin, lessThanOrEqualTo(aiGuess));
        }
      });
      test('AI Guesses converge on the answer', () {
        print('Test, answer: ${manager.answer}');
        int lastDistanceToAnswer = GameState.answerMax;
        for (int i = 0; i < 50; i++) {
          int aiGuess = manager.generateAiGuess();
          manager.submitAiGuess(aiGuess);
          if (aiGuess == manager.answer) {
            break;
          }
          int distanceToAnswer = (manager.answer - aiGuess).abs();
          expect(distanceToAnswer, lessThan(lastDistanceToAnswer));
        }
        expect(manager.isAiWinner, isTrue);
        expect(manager.isGameOver, isTrue);
      });
      test('AI Guess is not deterministic', () {
        int lastAiGuess = manager.generateAiGuess();
        for (int i = 0; i < 1000; i++) {
          int aiGuess = manager.generateAiGuess();
          expect(aiGuess, isNot(equals(lastAiGuess)));
          lastAiGuess = aiGuess;
        }
      });
    });

    // Test conditions that should never occur and would represent a bug in the code
    // Defensive programming should anticipate where these may occur and throw errors
    // The UI layer is responsible for handling these errors and recovering gracefully
    group('Error Conditions', () {
      var manager = GameManager(initialGameState: GameState.empty);
      setUp(() {
        manager = GameManager(initialGameState: GameState.empty, randomSeed: 123);
        manager.newGame();
      });
      test('Player Guesses out of bounds throw an error', () {
        expect(() => manager.submitPlayerGuess(GameState.answerMin - 1), throwsRangeError);
        expect(() => manager.submitPlayerGuess(GameState.answerMax + 1), throwsRangeError);
      });
      test('Player Guesses after out of tries throws an error', () {
        for (int i = 0; i < GameState.triesMax; i++) {
          manager.submitPlayerGuess(GameState.answerMin);
        }
        expect(() => manager.submitPlayerGuess(GameState.answerMin), throwsStateError);
      });
      test('Player Guesses after game over throws an error', () {
        manager.submitPlayerGuess(manager.answer);
        expect(() => manager.submitPlayerGuess(GameState.answerMin), throwsStateError);
      });
      test('AI Guesses after game over throws an error', () {
        manager.submitPlayerGuess(manager.answer);
        expect(() => manager.submitAiGuess(GameState.answerMin), throwsStateError);
      });
    });
  });

  // Walk through different possible states and edge cases to ensure the game isn't brittle
  // Also helps ensure different logic branches are covered
  group('Game State', () {
    var manager = GameManager(initialGameState: GameState.empty);
    setUp(() {
      manager = GameManager(initialGameState: GameState.empty, randomSeed: 123);
      manager.newGame();
    });
    test('Guess is correct', () {
      manager.submitPlayerGuess(manager.answer);
      expect(manager.isPlayerWinner, isTrue);
      expect(manager.isGameOver, isTrue);
      expect(manager.isPlayerGuessHigh, isFalse);
      expect(manager.isPlayerGuessLow, isFalse);
    });
    test('Guess is above answer', () {
      manager.submitPlayerGuess(manager.answer + 1);
      expect(manager.isPlayerWinner, isFalse);
      expect(manager.isGameOver, isFalse);
      expect(manager.isPlayerGuessHigh, isTrue);
    });
    test('Guess is below answer', () {
      manager.submitPlayerGuess(manager.answer - 1);
      expect(manager.isPlayerWinner, isFalse);
      expect(manager.isGameOver, isFalse);
      expect(manager.isPlayerGuessLow, isTrue);
    });
    test('Guess is negative', () {
      expect(() => manager.submitPlayerGuess(-1), throwsRangeError);
    });
    test('Guess is out of bounds', () {
      expect(() => manager.submitPlayerGuess(GameState.answerMin - 1), throwsRangeError);
      expect(() => manager.submitPlayerGuess(GameState.answerMax + 1), throwsRangeError);
    });
    test('Guess limit is reached', () {
      for (int i = 0; i < GameState.triesMax; i++) {
        manager.submitPlayerGuess(GameState.answerMin);
      }
      expect(manager.isPlayerWinner, isFalse);
      expect(manager.isGameOver, isTrue);
    });
    test('AI Guess is correct', () {
      manager.submitAiGuess(manager.answer);
      expect(manager.isAiWinner, isTrue);
      expect(manager.isGameOver, isTrue);
    });
    test('AI Guess is above answer', () {
      manager.submitAiGuess(manager.answer + 1);
      expect(manager.isAiWinner, isFalse);
      expect(manager.isGameOver, isFalse);
    });
    test('AI Guess is below answer', () {
      manager.submitAiGuess(manager.answer - 1);
      expect(manager.isAiWinner, isFalse);
      expect(manager.isGameOver, isFalse);
    });
    test('New game state', () {
      expect(manager.isPlayerWinner, isFalse);
      expect(manager.isAiWinner, isFalse);
      expect(manager.isGameOver, isFalse);
      expect(manager.isPlayerGuessHigh, isFalse);
      expect(manager.isPlayerGuessLow, isTrue);
      expect(manager.isOutOfTries, isFalse);
      expect(manager.triesCount, equals(0));
    });
    test('Play again state is reset', () {
      manager.submitPlayerGuess(manager.answer + 1);
      manager.submitAiGuess(manager.answer - 1);
      manager.submitPlayerGuess(manager.answer);
      expect(manager.isPlayerWinner, isTrue);
      manager.newGame();
      expect(manager.isAiWinner, isFalse);
      expect(manager.isGameOver, isFalse);
      expect(manager.isPlayerGuessHigh, isFalse);
      expect(manager.isPlayerGuessLow, isTrue);
      expect(manager.isOutOfTries, isFalse);
      expect(manager.triesCount, equals(0));
    });
  });
}
