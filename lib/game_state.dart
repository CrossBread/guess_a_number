class GameState {
  static const int answerMin = 1;
  static const int answerMax = 1000000;
  static const int triesMax = 20;

  const GameState({
    required this.answer,
    required this.playerGuess,
    required this.triesCount,
    required this.aiGuess,
    required this.aiGuessCount,
    required this.aiGuessMax,
    required this.aiGuessMin,
  });

  final int answer;
  final int playerGuess;
  final int triesCount;
  final int aiGuess;
  final int aiGuessCount;
  final int aiGuessMax;
  final int aiGuessMin;

  GameState copyWith({
    int? answer,
    int? playerGuess,
    int? triesCount,
    int? aiGuess,
    int? aiGuessCount,
    int? aiGuessMax,
    int? aiGuessMin,
  }) {
    return GameState(
      answer: answer ?? this.answer,
      playerGuess: playerGuess ?? this.playerGuess,
      triesCount: triesCount ?? this.triesCount,
      aiGuess: aiGuess ?? this.aiGuess,
      aiGuessCount: aiGuessCount ?? this.aiGuessCount,
      aiGuessMax: aiGuessMax ?? this.aiGuessMax,
      aiGuessMin: aiGuessMin ?? this.aiGuessMin,
    );
  }

  static const GameState empty = GameState(
    answer: 0,
    playerGuess: 0,
    triesCount: 0,
    aiGuess: 0,
    aiGuessCount: 0,
    aiGuessMax: answerMax,
    aiGuessMin: answerMin,
  );
}
