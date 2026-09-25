class GameConfig {
  // =========================================================
  // FÍSICA — VOCÊ PODE AJUSTAR AQUI
  // =========================================================
  static const double gravity = 1850;
  static const double moveAcceleration = 2100;
  static const double maxMoveSpeed = 390;
  static const double friction = 2500;
  static const double jumpVelocity = -720;

  // =========================================================
  // PERSONAGEM
  // =========================================================
  static const double playerWidth = 82;
  static const double playerHeight = 100;
  static const double playerHitboxWidth = 61;
  static const double playerHitboxHeight = 84;
  static const double playerHitboxOffsetX = 10;
  static const double playerHitboxOffsetY = 8;

  // =========================================================
  // INIMIGO
  // =========================================================
  static const double enemyWidth = 78;
  static const double enemyHeight = 89;
  static const double enemyHitboxPadding = 7;
  static const double stompBounce = -470;
  static const double enemyPatrolSpeed = 82;

  // =========================================================
  // MOEDA
  // =========================================================
  static const double coinSize = 40;
  static const int coinValue = 10;
  static const int enemyValue = 50;

  // =========================================================
  // CÂMERA
  // =========================================================
  static const double cameraLead = 120;
  static const double cameraSmooth = 7.5;

  // =========================================================
  // JOGO
  // =========================================================
  static const int startingLives = 3;
  static const double invulnerabilityTime = 1.1;
  static const double damageFlashTime = 0.40;
  static const double respawnX = 120;
  static const double respawnY = 416;
  static const double fallDeathMargin = 140;
  static const double worldWidth = 4300;
  static const double worldHeight = 620;
  static const double goalX = 4100;
  static const double groundY = 500;
}
