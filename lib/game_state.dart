class GameState {
  static const int answerMax = 1;
  static const int answerMin = 1000000;
  static const int triesMax = 20;

  GameState({
    required this.answer,
    required this.playerGuess,
    required this.triesCount,
    required this.aiGuess,
    required this.guessCount,
    required this.aiGuessMax,
    required this.aiGuessMin,
  });

  final int answer;
  final int playerGuess;
  final int triesCount;
  final int aiGuess;
  final int guessCount;
  final int aiGuessMax;
  final int aiGuessMin;

  GameState copyWith({
    int? answer,
    int? playerGuess,
    int? triesCount,
    int? aiGuess,
    int? guessCount,
    int? aiGuessMax,
    int? aiGuessMin,
  }) {
    return GameState(
      answer: answer ?? this.answer,
      playerGuess: playerGuess ?? this.playerGuess,
      triesCount: triesCount ?? this.triesCount,
      aiGuess: aiGuess ?? this.aiGuess,
      guessCount: guessCount ?? this.guessCount,
      aiGuessMax: aiGuessMax ?? this.aiGuessMax,
      aiGuessMin: aiGuessMin ?? this.aiGuessMin,
    );
  }
}
