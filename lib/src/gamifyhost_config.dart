/// Configuration for the GamifyHost widget.
class GamifyHostConfig {
  /// Your GamifyHost public API key (e.g. `pk_live_abc123`).
  final String publicKey;

  /// The authenticated user's ID in your system.
  final String userId;

  /// Base URL for the GamifyHost API.
  /// Defaults to `https://api.gamifyhost.com`.
  final String apiUrl;

  /// URL where `widget.js` is hosted.
  /// Defaults to `https://cdn.jsdelivr.net/npm/@gamifyhost/gamifyhost-widget/dist/widget.js`.
  final String widgetUrl;

  /// Initial point balance to display before the API responds.
  final int initialBalance;

  const GamifyHostConfig({
    required this.publicKey,
    required this.userId,
    this.apiUrl = 'https://api.gamifyhost.com',
    this.widgetUrl =
        'https://cdn.jsdelivr.net/npm/@gamifyhost/gamifyhost-widget/dist/widget.js',
    this.initialBalance = 0,
  });

  GamifyHostConfig copyWith({
    String? publicKey,
    String? userId,
    String? apiUrl,
    String? widgetUrl,
    int? initialBalance,
  }) {
    return GamifyHostConfig(
      publicKey: publicKey ?? this.publicKey,
      userId: userId ?? this.userId,
      apiUrl: apiUrl ?? this.apiUrl,
      widgetUrl: widgetUrl ?? this.widgetUrl,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }
}
