import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'game/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No navegador, a rotação é controlada pela janela.
  // No celular, mantemos a orientação horizontal do jogo.
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(const ForestNinjaApp());
}

class ForestNinjaApp extends StatelessWidget {
  const ForestNinjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Forest Ninja Adventure',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const GameScreen(),
    );
  }
}
