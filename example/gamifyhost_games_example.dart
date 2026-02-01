import 'package:flutter/material.dart';
import 'package:gamifyhost_games/gamifyhost_games.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GamifyHost Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD125F4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _controller = GamifyHostController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GamifyHost Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: GamifyHostWidget(
        config: const GamifyHostConfig(
          publicKey: 'pk_test_your_key_here',
          userId: 'user_12345',
          apiUrl: 'https://api.gamifyhost.com',
          initialBalance: 5000,
        ),
        controller: _controller,
        onReady: () => debugPrint('GamifyHost widget loaded'),
        onError: (error) => debugPrint('GamifyHost error: $error'),
      ),
    );
  }
}
