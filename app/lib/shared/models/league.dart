class League {
  final String id;
  final String name;
  final String joinCode;
  final String joinPhrase;
  final String adminUserId;
  final DateTime createdAt;

  const League({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.joinPhrase,
    required this.adminUserId,
    required this.createdAt,
  });

  factory League.fromJson(Map<String, dynamic> json) => League(
        id: json['id'] as String,
        name: json['name'] as String,
        joinCode: json['join_code'] as String,
        joinPhrase: json['join_phrase'] as String,
        adminUserId: json['admin_user_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class LeagueMember {
  final String id;
  final String leagueId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int gamesGuessed;
  final DateTime joinedAt;

  const LeagueMember({
    required this.id,
    required this.leagueId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalPoints,
    required this.gamesGuessed,
    required this.joinedAt,
  });

  factory LeagueMember.fromJson(Map<String, dynamic> json) => LeagueMember(
        id: json['id'] as String,
        leagueId: json['league_id'] as String,
        userId: json['user_id'] as String,
        username: json['users']['username'] as String,
        avatarUrl: json['users']['avatar_url'] as String?,
        totalPoints: json['total_points'] as int,
        gamesGuessed: json['games_guessed'] as int,
        joinedAt: DateTime.parse(json['joined_at'] as String),
      );
}
