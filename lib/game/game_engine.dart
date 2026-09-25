import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_config.dart';
import 'game_state.dart';

class GameEngine {
  final GameState state;
  Timer? _timer;
  Size viewport = Size.zero;

  GameEngine(this.state);

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => update(1 / 60));
  }

  void dispose() => _timer?.cancel();

  void update(double dt) {
    if (state.paused || state.finished || state.gameOver) return;

    state.elapsed += dt;
    state.frame++;
    state.invulnerableFor = math.max(0.0, state.invulnerableFor - dt).toDouble();
    state.damageFlashFor = math.max(0.0, state.damageFlashFor - dt).toDouble();
    state.eventFor = math.max(0.0, state.eventFor - dt).toDouble();
    if (state.eventFor <= 0) state.lastEvent = null;

    _updatePlayer(dt);
    _updateEnemies(dt);
    _collectCoins();
    _checkEnemyHits();
    _checkFall();
    _updateCamera(dt);
    _checkGoal();

    state.notifyListeners();
  }

  void _updatePlayer(double dt) {
    double vx = state.velocityX;

    if (state.leftPressed && !state.rightPressed) {
      vx -= GameConfig.moveAcceleration * dt;
      state.facingRight = false;
    } else if (state.rightPressed && !state.leftPressed) {
      vx += GameConfig.moveAcceleration * dt;
      state.facingRight = true;
    } else {
      if (vx > 0) {
        vx = math.max(0, vx - GameConfig.friction * dt).toDouble();
      } else if (vx < 0) {
        vx = math.min(0, vx + GameConfig.friction * dt).toDouble();
      }
    }

    vx = vx.clamp(-GameConfig.maxMoveSpeed, GameConfig.maxMoveSpeed).toDouble();

    if (state.jumpRequested && state.grounded) {
      state.velocityY = GameConfig.jumpVelocity;
      state.grounded = false;
    }
    state.jumpRequested = false;

    final previous = state.player;
    double vy = state.velocityY + GameConfig.gravity * dt;
    Offset next = Offset(
      state.player.dx + vx * dt,
      state.player.dy + vy * dt,
    );

    state.grounded = false;
    final nextRect = _playerRectAt(next);

    // Colisão vertical com plataformas: pousar por cima.
    for (final platform in state.platforms) {
      final p = platform.rect;
      final previousBottom = _playerRectAt(previous).bottom;
      final nextBottom = nextRect.bottom;
      final horizontalOverlap = nextRect.right > p.left && nextRect.left < p.right;
      final crossedTop = previousBottom <= p.top && nextBottom >= p.top;

      if (horizontalOverlap && crossedTop && vy >= 0) {
        next = Offset(next.dx, p.top - GameConfig.playerHitboxHeight - GameConfig.playerHitboxOffsetY);
        vy = 0;
        state.grounded = true;
      }
    }

    state.velocityX = vx;
    state.velocityY = vy;
    state.player = Offset(
      next.dx.clamp(0.0, GameConfig.worldWidth - GameConfig.playerWidth).toDouble(),
      next.dy,
    );
  }

  Rect _playerRectAt(Offset position) {
    return Rect.fromLTWH(
      position.dx + GameConfig.playerHitboxOffsetX,
      position.dy + GameConfig.playerHitboxOffsetY,
      GameConfig.playerHitboxWidth,
      GameConfig.playerHitboxHeight,
    );
  }

  Rect get _playerRect => _playerRectAt(state.player);

  void _updateEnemies(double dt) {
    for (final enemy in state.enemies) {
      if (!enemy.alive) continue;

      var x = enemy.position.dx + enemy.velocityX * dt;
      if (x < enemy.leftLimit) {
        enemy.velocityX = enemy.velocityX.abs();
        x = enemy.leftLimit;
      } else if (x > enemy.rightLimit) {
        enemy.velocityX = -enemy.velocityX.abs();
        x = enemy.rightLimit;
      }
      enemy.position = Offset(x, enemy.position.dy);
    }
  }

  void _collectCoins() {
    final playerCenter = _playerRect.center;

    for (final coin in state.coins) {
      if (coin.collected) continue;
      final coinRect = Rect.fromCenter(
        center: coin.position,
        width: GameConfig.coinSize,
        height: GameConfig.coinSize,
      );
      if (_playerRect.overlaps(coinRect) || (coin.position - playerCenter).distance < 48) {
        coin.collected = true;
        state.collectedCoins++;
        state.score += GameConfig.coinValue;
        state.showEvent('+${GameConfig.coinValue} pontos', duration: .75);
      }
    }
  }

  void _checkEnemyHits() {
    if (state.invulnerableFor > 0) return;

    for (final enemy in state.enemies) {
      if (!enemy.alive) continue;

      final enemyRect = Rect.fromLTWH(
        enemy.position.dx + GameConfig.enemyHitboxPadding,
        enemy.position.dy + GameConfig.enemyHitboxPadding,
        GameConfig.enemyWidth - GameConfig.enemyHitboxPadding * 2,
        GameConfig.enemyHeight - GameConfig.enemyHitboxPadding * 2,
      );

      if (!_playerRect.overlaps(enemyRect)) continue;

      final playerBottom = _playerRect.bottom;
      final enemyTop = enemyRect.top;
      final stomp = state.velocityY > 0 &&
          playerBottom - enemyTop <= 28 &&
          _playerRect.center.dx > enemyRect.left - 10 &&
          _playerRect.center.dx < enemyRect.right + 10;

      if (stomp) {
        enemy.alive = false;
        state.velocityY = GameConfig.stompBounce;
        state.grounded = false;
        state.score += GameConfig.enemyValue;
        state.showEvent('+${GameConfig.enemyValue} pontos', duration: .9);
        return;
      }

      _loseLife(source: 'Inimigo');
      return;
    }
  }

  void _checkFall() {
    if (state.player.dy > GameConfig.worldHeight + GameConfig.fallDeathMargin) {
      _loseLife(source: 'Queda');
    }
  }

  void _checkGoal() {
    if (state.player.dx >= GameConfig.goalX) {
      state.finished = true;
      state.leftPressed = false;
      state.rightPressed = false;
      state.jumpRequested = false;
      state.velocityX = 0;
      state.velocityY = 0;
      state.showEvent('Fase concluída!', duration: 2);
    }
  }

  void _loseLife({required String source}) {
    if (state.invulnerableFor > 0 || state.gameOver || state.finished) return;

    state.lives = math.max(0, state.lives - 1).toInt();
    state.invulnerableFor = GameConfig.invulnerabilityTime;
    state.damageFlashFor = GameConfig.damageFlashTime;
    state.leftPressed = false;
    state.rightPressed = false;
    state.jumpRequested = false;

    final message = source == 'Queda' ? 'Você caiu! -1 vida' : 'Você sofreu dano! -1 vida';
    state.showEvent(message, duration: 1.2);

    if (state.lives <= 0) {
      state.gameOver = true;
      state.velocityX = 0;
      state.velocityY = 0;
      return;
    }

    state.player = const Offset(GameConfig.respawnX, GameConfig.respawnY);
    state.velocityX = 0;
    state.velocityY = 0;
    state.cameraX = 0;
    state.grounded = false;
  }

  void setViewport(Size size) => viewport = size;

  void setLeft(bool pressed) {
    if (state.paused || state.finished || state.gameOver) return;
    state.leftPressed = pressed;
  }

  void setRight(bool pressed) {
    if (state.paused || state.finished || state.gameOver) return;
    state.rightPressed = pressed;
  }

  void jump() {
    if (state.paused || state.finished || state.gameOver) return;
    state.jumpRequested = true;
  }

  void togglePause() => state.togglePause();

  void restart() => state.reset();

  void _updateCamera(double dt) {
    if (viewport.width <= 0) return;

    final maxCamera = math.max(0.0, GameConfig.worldWidth - viewport.width).toDouble();
    final target = (state.player.dx - viewport.width * .36 + GameConfig.cameraLead)
        .clamp(0.0, maxCamera)
        .toDouble();

    state.cameraX += (target - state.cameraX) * math.min(1, GameConfig.cameraSmooth * dt);
  }
}
