import 'package:flutter/material.dart';

enum PlatformType { large, medium, rocky }

class PlatformData {
  final Rect rect;
  final PlatformType type;

  const PlatformData(this.rect, {this.type = PlatformType.medium});
}

class CoinData {
  final Offset position;
  bool collected;

  CoinData(this.position, {this.collected = false});
}

class EnemyData {
  Offset position;
  final double leftLimit;
  final double rightLimit;
  double velocityX;
  bool alive;

  EnemyData({
    required this.position,
    required this.leftLimit,
    required this.rightLimit,
    this.velocityX = GameEnemyDefaults.speed,
    this.alive = true,
  });
}

class GameEnemyDefaults {
  static const double speed = 82;
}
