import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'assets.dart';
import 'game_config.dart';
import 'game_state.dart';
import 'models.dart';

class GamePainter extends CustomPainter {
  final GameState state;
  final Map<String, ui.Image> images;
  final double scale;

  GamePainter({required this.state, required this.images, required this.scale});

  ui.Image? _image(String path) => images[path];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale, scale);
    final logicalSize = Size(size.width / scale, size.height / scale);

    _drawBackground(canvas, logicalSize);

    canvas.save();
    canvas.translate(-state.cameraX, 0);
    _drawWorld(canvas, logicalSize);
    canvas.restore();

    _drawVignette(canvas, logicalSize);

    if (state.damageFlashFor > 0) {
      final strength = (state.damageFlashFor / GameConfig.damageFlashTime).clamp(0.0, 1.0);
      final flash = Paint()..color = Colors.red.withOpacity(.24 * strength);
      canvas.drawRect(Offset.zero & logicalSize, flash);
    }

    canvas.restore();
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bg = _image(GameAssets.background);
    if (bg == null) {
      final paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff102f36), Color(0xff07191b)],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    final srcW = bg.width.toDouble();
    final srcH = bg.height.toDouble();
    final destAspect = size.width / size.height;
    final srcAspect = srcW / srcH;

    Rect src;
    if (srcAspect > destAspect) {
      final cropW = srcH * destAspect;
      src = Rect.fromLTWH((srcW - cropW) / 2, 0, cropW, srcH);
    } else {
      final cropH = srcW / destAspect;
      src = Rect.fromLTWH(0, (srcH - cropH) / 2, srcW, cropH);
    }

    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(bg, src, Offset.zero & size, paint);
  }

  void _drawWorld(Canvas canvas, Size size) {
    for (final platform in state.platforms) {
      _drawPlatform(canvas, platform);
    }

    for (final coin in state.coins) {
      if (!coin.collected) _drawCoin(canvas, coin.position);
    }

    for (final enemy in state.enemies) {
      if (enemy.alive) _drawEnemy(canvas, enemy);
    }

    _drawGoal(canvas);
    _drawPlayer(canvas);
  }

  void _drawPlatform(Canvas canvas, PlatformData platform) {
    final String asset;
    final double heightScale;

    switch (platform.type) {
      case PlatformType.large:
        asset = GameAssets.platformLarge;
        heightScale = 1.0;
        break;
      case PlatformType.medium:
        asset = GameAssets.platformMedium;
        heightScale = 1.0;
        break;
      case PlatformType.rocky:
        asset = GameAssets.platformRocky;
        heightScale = 1.0;
        break;
    }

    final image = _image(asset);
    if (image == null) {
      final fill = Paint()..color = const Color(0xff173a2c);
      canvas.drawRRect(
        RRect.fromRectAndRadius(platform.rect, const Radius.circular(12)),
        fill,
      );
      return;
    }

    final rect = platform.rect;
    final dest = Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * heightScale);
    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dest,
      paint,
    );
  }

  void _drawCoin(Canvas canvas, Offset center) {
    final image = _image(GameAssets.coin);
    if (image == null) return;

    final pulse = 1 + mathSin(state.elapsed * 5) * .06;
    final size = GameConfig.coinSize * pulse;
    final dest = Rect.fromCenter(center: center, width: size, height: size);
    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dest,
      paint,
    );

    final glow = Paint()..color = Colors.amber.withOpacity(.11);
    canvas.drawCircle(center, size * .72, glow);
  }

  void _drawEnemy(Canvas canvas, EnemyData enemy) {
    final image = _image(GameAssets.skeleton);
    if (image == null) return;

    final bob = mathSin(state.elapsed * 7 + enemy.position.dx * .01) * 2.2;
    final dest = Rect.fromLTWH(
      enemy.position.dx,
      enemy.position.dy - bob,
      GameConfig.enemyWidth,
      GameConfig.enemyHeight,
    );

    _drawImage(canvas, image, dest, flipX: enemy.velocityX < 0);
  }

  void _drawPlayer(Canvas canvas) {
    final image = _image(GameAssets.player);
    if (image == null) return;

    final moving = state.velocityX.abs() > 35;
    final bob = state.grounded && moving ? mathSin(state.elapsed * 18) * 2.0 : 0.0;
    final jumpTilt = state.velocityY < -80 ? -0.03 : state.velocityY > 120 ? 0.03 : 0.0;

    final dest = Rect.fromLTWH(
      state.player.dx - 8,
      state.player.dy - 10 + bob,
      GameConfig.playerWidth,
      GameConfig.playerHeight,
    );

    final opacity = state.invulnerableFor > 0 && (state.frame ~/ 5).isEven ? .42 : 1.0;

    canvas.save();
    canvas.translate(dest.center.dx, dest.center.dy);
    canvas.rotate(jumpTilt);
    canvas.translate(-dest.center.dx, -dest.center.dy);
    _drawImage(canvas, image, dest, flipX: !state.facingRight, opacity: opacity);
    canvas.restore();
  }

  void _drawGoal(Canvas canvas) {
    const x = GameConfig.goalX;
    final polePaint = Paint()..color = const Color(0xffd7d9dd);
    final flagPaint = Paint()..color = const Color(0xfff2be45);
    final glow = Paint()..color = Colors.amber.withOpacity(.12);

    canvas.drawCircle(const Offset(x + 20, 330), 50, glow);
    canvas.drawRect(const Rect.fromLTWH(x, 280, 7, 220), polePaint);
    canvas.drawPath(
      Path()
        ..moveTo(x + 7, 282)
        ..lineTo(x + 88, 310)
        ..lineTo(x + 7, 338)
        ..close(),
      flagPaint,
    );
  }

  void _drawImage(
    Canvas canvas,
    ui.Image image,
    Rect dest, {
    bool flipX = false,
    double opacity = 1,
  }) {
    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..color = Colors.white.withOpacity(opacity);

    if (!flipX) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        dest,
        paint,
      );
      return;
    }

    canvas.save();
    canvas.translate(dest.center.dx * 2, 0);
    canvas.scale(-1, 1);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dest,
      paint,
    );
    canvas.restore();
  }

  void _drawVignette(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: .85,
        colors: [Colors.transparent, Colors.black.withOpacity(.28)],
        stops: const [0.68, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  double mathSin(double value) {
    // Pequena função local para animações sem importar outra biblioteca.
    // Usa a mesma fórmula de seno de forma suficiente para o balanço visual.
    return _fastSin(value);
  }

  double _fastSin(double x) {
    // Série de Taylor curta: suficiente para valores pequenos/animados.
    final twoPi = 6.28318530718;
    x %= twoPi;
    var y = x;
    if (y > 3.14159265359) y -= twoPi;
    final x2 = y * y;
    return y * (1 - x2 / 6 + (x2 * x2) / 120 - (x2 * x2 * x2) / 5040);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
