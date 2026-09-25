import 'package:flutter/material.dart';
import 'models.dart';

class LevelData {
  static List<PlatformData> platforms() {
    return const [
      PlatformData(Rect.fromLTWH(0, 500, 720, 120), type: PlatformType.large),
      PlatformData(Rect.fromLTWH(810, 430, 260, 46), type: PlatformType.medium),
      PlatformData(Rect.fromLTWH(1135, 350, 300, 46), type: PlatformType.rocky),
      PlatformData(Rect.fromLTWH(1485, 445, 260, 46), type: PlatformType.medium),
      PlatformData(Rect.fromLTWH(1800, 500, 620, 120), type: PlatformType.large),
      PlatformData(Rect.fromLTWH(1930, 388, 250, 46), type: PlatformType.medium),
      PlatformData(Rect.fromLTWH(2220, 300, 210, 46), type: PlatformType.rocky),
      PlatformData(Rect.fromLTWH(2500, 412, 280, 46), type: PlatformType.medium),
      PlatformData(Rect.fromLTWH(2860, 500, 520, 120), type: PlatformType.large),
      PlatformData(Rect.fromLTWH(2990, 382, 240, 46), type: PlatformType.rocky),
      PlatformData(Rect.fromLTWH(3280, 285, 210, 46), type: PlatformType.medium),
      PlatformData(Rect.fromLTWH(3520, 405, 300, 46), type: PlatformType.rocky),
      PlatformData(Rect.fromLTWH(3820, 500, 480, 120), type: PlatformType.large),
      PlatformData(Rect.fromLTWH(3955, 370, 210, 46), type: PlatformType.medium),
    ];
  }

  static List<CoinData> coins() {
    return [
      CoinData(const Offset(330, 430)),
      CoinData(const Offset(405, 350)),
      CoinData(const Offset(865, 365)),
      CoinData(const Offset(950, 365)),
      CoinData(const Offset(1200, 285)),
      CoinData(const Offset(1290, 285)),
      CoinData(const Offset(1545, 380)),
      CoinData(const Offset(1625, 380)),
      CoinData(const Offset(1955, 338)),
      CoinData(const Offset(2050, 338)),
      CoinData(const Offset(2245, 250)),
      CoinData(const Offset(2505, 345)),
      CoinData(const Offset(2605, 345)),
      CoinData(const Offset(2925, 430)),
      CoinData(const Offset(3035, 315)),
      CoinData(const Offset(3130, 315)),
      CoinData(const Offset(3320, 238)),
      CoinData(const Offset(3600, 340)),
      CoinData(const Offset(3700, 340)),
      CoinData(const Offset(3890, 430)),
      CoinData(const Offset(4020, 330)),
    ];
  }

  static List<EnemyData> enemies() {
    return [
      EnemyData(position: const Offset(540, 415), leftLimit: 450, rightLimit: 650),
      EnemyData(position: const Offset(1210, 265), leftLimit: 1145, rightLimit: 1400),
      EnemyData(position: const Offset(1990, 410), leftLimit: 1840, rightLimit: 2340),
      EnemyData(position: const Offset(2580, 322), leftLimit: 2510, rightLimit: 2750),
      EnemyData(position: const Offset(3040, 410), leftLimit: 2900, rightLimit: 3380),
      EnemyData(position: const Offset(3610, 325), leftLimit: 3540, rightLimit: 3790),
    ];
  }
}
