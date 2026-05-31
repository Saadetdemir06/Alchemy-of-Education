class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class AdventureChapter {
  final int id;
  final String title;
  final String subtitle;
  final String story;
  final String explanation;
  final String memoryTip;
  final String question;
  final List<String> options;
  final int correctIndex;
  final bool isBoss;
  final List<QuizQuestion> finalQuiz;

  const AdventureChapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.story,
    required this.explanation,
    required this.memoryTip,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.isBoss = false,
    this.finalQuiz = const [],
  });
}

class AdventureProgress {
  final int gold;
  final int xp;
  final int unlockedChapter;
  final Set<int> completedChapters;

  const AdventureProgress({
    required this.gold,
    required this.xp,
    required this.unlockedChapter,
    required this.completedChapters,
  });

  AdventureProgress copyWith({
    int? gold,
    int? xp,
    int? unlockedChapter,
    Set<int>? completedChapters,
  }) {
    return AdventureProgress(
      gold: gold ?? this.gold,
      xp: xp ?? this.xp,
      unlockedChapter: unlockedChapter ?? this.unlockedChapter,
      completedChapters: completedChapters ?? this.completedChapters,
    );
  }
}