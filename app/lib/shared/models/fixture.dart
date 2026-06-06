enum FixtureStatus { scheduled, live, completed, postponed }

enum FixtureStage {
  group,
  roundOf16,
  quarterFinal,
  semiFinal,
  final_;

  bool get isKnockout => this != FixtureStage.group;
}

class Fixture {
  final String id;
  final int matchday;
  final FixtureStage stage;
  final String homeTeam;
  final String awayTeam;
  final String? homeCrestUrl;
  final String? awayCrestUrl;
  final DateTime kickoffTime;
  final DateTime guessLockTime;
  final FixtureStatus status;
  final int? homeScore;
  final int? awayScore;
  final bool? wentToPenalties;

  const Fixture({
    required this.id,
    required this.matchday,
    required this.stage,
    required this.homeTeam,
    required this.awayTeam,
    this.homeCrestUrl,
    this.awayCrestUrl,
    required this.kickoffTime,
    required this.guessLockTime,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.wentToPenalties,
  });

  bool get isLocked => DateTime.now().isAfter(guessLockTime);
  bool get isUpcoming => status == FixtureStatus.scheduled && !isLocked;
  bool get isCompleted => status == FixtureStatus.completed;

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      id: json['id'] as String,
      matchday: json['matchday'] as int,
      stage: _parseStage(json['stage'] as String),
      homeTeam: json['home_team'] as String,
      awayTeam: json['away_team'] as String,
      homeCrestUrl: json['home_crest_url'] as String?,
      awayCrestUrl: json['away_crest_url'] as String?,
      kickoffTime: DateTime.parse(json['kickoff_time'] as String),
      guessLockTime: DateTime.parse(json['guess_lock_time'] as String),
      status: _parseStatus(json['status'] as String),
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
      wentToPenalties: json['went_to_penalties'] as bool?,
    );
  }

  static FixtureStage _parseStage(String s) => switch (s) {
        'round_of_16' => FixtureStage.roundOf16,
        'quarter_final' => FixtureStage.quarterFinal,
        'semi_final' => FixtureStage.semiFinal,
        'final' => FixtureStage.final_,
        _ => FixtureStage.group,
      };

  static FixtureStatus _parseStatus(String s) => switch (s) {
        'live' => FixtureStatus.live,
        'completed' => FixtureStatus.completed,
        'postponed' => FixtureStatus.postponed,
        _ => FixtureStatus.scheduled,
      };
}
