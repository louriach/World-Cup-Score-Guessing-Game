class Guess {
  final String id;
  final String userId;
  final String fixtureId;
  final int homeScoreGuess;
  final int awayScoreGuess;
  final bool predictsPenalties;
  final int? pointsEarned;
  final DateTime submittedAt;
  final DateTime updatedAt;

  const Guess({
    required this.id,
    required this.userId,
    required this.fixtureId,
    required this.homeScoreGuess,
    required this.awayScoreGuess,
    required this.predictsPenalties,
    this.pointsEarned,
    required this.submittedAt,
    required this.updatedAt,
  });

  factory Guess.fromJson(Map<String, dynamic> json) {
    return Guess(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fixtureId: json['fixture_id'] as String,
      homeScoreGuess: json['home_score_guess'] as int,
      awayScoreGuess: json['away_score_guess'] as int,
      predictsPenalties: json['predicts_penalties'] as bool? ?? false,
      pointsEarned: json['points_earned'] as int?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
