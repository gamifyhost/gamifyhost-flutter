/// GamifyHost Flutter SDK — embed the GamifyHost game widget in your Flutter app.
///
/// ## Quick start
///
/// ```dart
/// import 'package:gamifyhost_games/gamifyhost_games.dart';
///
/// GamifyHostWidget(
///   config: GamifyHostConfig(
///     publicKey: 'pk_live_abc123',
///     userId: 'user_12345',
///   ),
/// )
/// ```
library;

export 'src/gamifyhost_api.dart';
export 'src/gamifyhost_config.dart';
export 'src/gamifyhost_controller.dart';
export 'src/gamifyhost_widget.dart';
