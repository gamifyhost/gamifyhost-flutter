import 'dart:convert';
import 'package:http/http.dart' as http;
import 'gamifyhost_config.dart';

/// Exception thrown when a GamifyHost API call fails.
class GamifyHostApiException implements Exception {
  /// HTTP status code (0 if the request didn't reach the server).
  final int statusCode;

  /// Error message from the API or client.
  final String message;

  const GamifyHostApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GamifyHostApiException($statusCode): $message';
}

/// Pagination metadata returned by paginated endpoints.
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}

/// A paginated response containing a list of items and pagination metadata.
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResponse({required this.data, required this.meta});
}

/// A game available for the partner.
class GameInfo {
  final String gameType;
  final String name;
  final String description;
  final int pointsToUnlock;
  final String status;
  final String? imageUrl;

  const GameInfo({
    required this.gameType,
    required this.name,
    required this.description,
    required this.pointsToUnlock,
    required this.status,
    this.imageUrl,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    return GameInfo(
      gameType: json['gameType'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsToUnlock: json['pointsToUnlock'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// Game configuration details.
class GameConfig {
  final String gameType;
  final String name;
  final String description;
  final int pointsToUnlock;
  final String status;
  final Map<String, dynamic> config;

  const GameConfig({
    required this.gameType,
    required this.name,
    required this.description,
    required this.pointsToUnlock,
    required this.status,
    required this.config,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      gameType: json['gameType'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsToUnlock: json['pointsToUnlock'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      config: (json['config'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// A user's point balance.
class UserBalance {
  final String userId;
  final int totalPoints;
  final String? displayName;

  const UserBalance({
    required this.userId,
    required this.totalPoints,
    this.displayName,
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      userId: json['userId'] as String? ?? '',
      totalPoints: json['totalPoints'] as int? ?? 0,
      displayName: json['displayName'] as String?,
    );
  }
}

/// A leaderboard entry.
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final int totalPoints;
  final int totalRewardsWon;
  final int gamesPlayed;
  final int score;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.totalPoints,
    required this.totalRewardsWon,
    required this.gamesPlayed,
    required this.score,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 0,
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      totalPoints: json['totalPoints'] as int? ?? 0,
      totalRewardsWon: json['totalRewardsWon'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
    );
  }
}

/// A game play record.
class PlayRecord {
  final String playId;
  final String gameType;
  final int pointsSpent;
  final String rewardTier;
  final String rewardType;
  final int rewardValue;
  final String rewardLabel;
  final Map<String, dynamic> outcome;
  final String playedAt;

  const PlayRecord({
    required this.playId,
    required this.gameType,
    required this.pointsSpent,
    required this.rewardTier,
    required this.rewardType,
    required this.rewardValue,
    required this.rewardLabel,
    required this.outcome,
    required this.playedAt,
  });

  factory PlayRecord.fromJson(Map<String, dynamic> json) {
    return PlayRecord(
      playId: json['playId'] as String? ?? '',
      gameType: json['gameType'] as String? ?? '',
      pointsSpent: json['pointsSpent'] as int? ?? 0,
      rewardTier: json['rewardTier'] as String? ?? '',
      rewardType: json['rewardType'] as String? ?? '',
      rewardValue: json['rewardValue'] as int? ?? 0,
      rewardLabel: json['rewardLabel'] as String? ?? '',
      outcome: (json['outcome'] as Map<String, dynamic>?) ?? {},
      playedAt: json['playedAt'] as String? ?? '',
    );
  }
}

/// HTTP client for the GamifyHost public SDK API.
///
/// All endpoints are authenticated with your public key (`pk_test_...` or
/// `pk_live_...`) sent via the `X-API-Key` header.
///
/// ```dart
/// final api = GamifyHostApi(config: GamifyHostConfig(
///   publicKey: 'pk_live_abc123',
///   userId: 'user_12345',
/// ));
///
/// final balance = await api.getUserBalance();
/// print(balance.totalPoints);
///
/// api.dispose();
/// ```
class GamifyHostApi {
  final GamifyHostConfig config;
  final http.Client _client;

  /// Creates an API client.
  ///
  /// Pass an optional [httpClient] for testing or custom transport.
  GamifyHostApi({required this.config, http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'X-API-Key': config.publicKey,
        'Content-Type': 'application/json',
      };

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    final base = Uri.parse(config.apiUrl);
    return base.replace(
      path: '${base.path}/v1$path',
      queryParameters: queryParams,
    );
  }

  Future<Map<String, dynamic>> _get(String path,
      [Map<String, String>? queryParams]) async {
    final response = await _client.get(_uri(path, queryParams), headers: _headers);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GamifyHostApiException(
        statusCode: response.statusCode,
        message: body['message'] as String? ?? 'Unknown error',
      );
    }
    return body;
  }

  /// List all active games for your app.
  Future<List<GameInfo>> getGames() async {
    final body = await _get('/games');
    final list = body['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => GameInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get configuration for a specific game type.
  ///
  /// [gameType] must be one of: `NEON_WHEEL`, `COSMIC_SLOTS`, `ENIGMA_BOXES`.
  Future<GameConfig> getGameConfig(String gameType) async {
    final body = await _get('/games/$gameType/config');
    return GameConfig.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Get the current user's point balance.
  ///
  /// Uses the [userId] from [config] by default. Pass [userId] to override.
  Future<UserBalance> getUserBalance({String? userId}) async {
    final uid = userId ?? config.userId;
    final body = await _get('/users/$uid/sdk-balance');
    return UserBalance.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Get the leaderboard.
  ///
  /// [page] starts at 1. [limit] range is 1–100 (default 20).
  Future<PaginatedResponse<LeaderboardEntry>> getLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    final body = await _get('/leaderboard', {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    final list = body['data'] as List<dynamic>? ?? [];
    final meta = PaginationMeta.fromJson(
        body['meta'] as Map<String, dynamic>? ?? {});
    return PaginatedResponse(
      data: list
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: meta,
    );
  }

  /// Get the play history for a user.
  ///
  /// Uses the [userId] from [config] by default. Pass [userId] to override.
  /// [page] starts at 1. [limit] range is 1–100 (default 20).
  Future<PaginatedResponse<PlayRecord>> getUserPlays({
    String? userId,
    int page = 1,
    int limit = 20,
  }) async {
    final uid = userId ?? config.userId;
    final body = await _get('/users/$uid/plays', {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    final list = body['data'] as List<dynamic>? ?? [];
    final meta = PaginationMeta.fromJson(
        body['meta'] as Map<String, dynamic>? ?? {});
    return PaginatedResponse(
      data: list
          .map((e) => PlayRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: meta,
    );
  }

  /// Release resources. Call this when you're done with the API client.
  void dispose() {
    _client.close();
  }
}
