import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'game_config.dart';
import 'level.dart';
import 'models.dart';

class GameState extends ChangeNotifier {
  Offset player = const Offset(GameConfig.respawnX, GameConfig.respawnY);
  double velocityX = 0;
  double velocityY = 0;
  bool grounded = false;
  bool facingRight = true;
  bool leftPressed = false;
  bool rightPressed = false;
  bool jumpRequested = false;
  bool paused = false;
  bool finished = false;
  bool gameOver = false;

  double cameraX = 0;
  double score = 0;
  int lives = GameConfig.startingLives;
  int collectedCoins = 0;
  double invulnerableFor = 0;
  double damageFlashFor = 0;
  double elapsed = 0;
  int frame = 0;
  String? lastEvent;
  double eventFor = 0;

  late List<PlatformData> platforms;
  late List<CoinData> coins;
  late List<EnemyData> enemies;

  void reset() {
    player = const Offset(GameConfig.respawnX, GameConfig.respawnY);
    velocityX = 0;
    velocityY = 0;
    grounded = false;
    facingRight = true;
    leftPressed = false;
    rightPressed = false;
    jumpRequested = false;
    paused = false;
    finished = false;
    gameOver = false;
    cameraX = 0;
    score = 0;
    lives = GameConfig.startingLives;
    collectedCoins = 0;
    invulnerableFor = 0;
    damageFlashFor = 0;
    elapsed = 0;
    frame = 0;
    lastEvent = null;
    eventFor = 0;
    platforms = LevelData.platforms();
    coins = LevelData.coins();
    enemies = LevelData.enemies();
    notifyListeners();
  }

  void togglePause() {
    if (finished || gameOver) return;
    paused = !paused;
    leftPressed = false;
    rightPressed = false;
    jumpRequested = false;
    notifyListeners();
  }

  void showEvent(String message, {double duration = 1.0}) {
    lastEvent = message;
    eventFor = duration;
  }
}
