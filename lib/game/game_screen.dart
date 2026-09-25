import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'assets.dart';
import 'game_engine.dart';
import 'game_painter.dart';
import 'game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameState state = GameState();
  late final GameEngine engine;
  final FocusNode focusNode = FocusNode();
  final Map<String, ui.Image> images = {};
  bool loading = true;

  static const assetList = [
    GameAssets.background,
    GameAssets.platformLarge,
    GameAssets.platformMedium,
    GameAssets.platformRocky,
    GameAssets.player,
    GameAssets.skeleton,
    GameAssets.coin,
  ];

  @override
  void initState() {
    super.initState();
    state.reset();
    engine = GameEngine(state);
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    for (final path in assetList) {
      try {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        final frame = await codec.getNextFrame();
        images[path] = frame.image;
        codec.dispose();
      } catch (_) {
        // Se algum asset estiver faltando, o jogo usa o desenho de fallback.
      }
    }

    if (!mounted) return;
    setState(() => loading = false);
    engine.start();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    engine.dispose();
    focusNode.dispose();
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: KeyboardListener(
          focusNode: focusNode,
          onKeyEvent: (event) {
            final pressed = event is KeyDownEvent || event is KeyRepeatEvent;

            if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.keyA) {
              engine.setLeft(pressed);
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.keyD) {
              engine.setRight(pressed);
            }
            if (pressed &&
                (event.logicalKey == LogicalKeyboardKey.space ||
                    event.logicalKey == LogicalKeyboardKey.arrowUp)) {
              engine.jump();
            }
            if (pressed && event.logicalKey == LogicalKeyboardKey.escape) {
              engine.togglePause();
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              const referenceWidth = 1100.0;
              final scale = (size.width / referenceWidth).clamp(.55, 1.4).toDouble();
              engine.setViewport(Size(size.width / scale, size.height / scale));

              return AnimatedBuilder(
                animation: state,
                builder: (context, _) {
                  if (loading) {
                    return const ColoredBox(
                      color: Color(0xff07191b),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: GamePainter(
                          state: state,
                          images: images,
                          scale: scale,
                        ),
                      ),
                      _Hud(state: state, onPause: engine.togglePause),
                      _Controls(engine: engine),
                      if (state.lastEvent != null && state.eventFor > 0 && !state.paused)
                        _EventToast(text: state.lastEvent!),
                      if (state.paused)
                        _Overlay(
                          title: 'JOGO PAUSADO',
                          subtitle: 'Você pode continuar ou reiniciar a fase.',
                          button: 'CONTINUAR',
                          onPressed: engine.togglePause,
                          secondaryButton: 'REINICIAR',
                          onSecondaryPressed: engine.restart,
                        ),
                      if (state.finished)
                        _Overlay(
                          title: 'FASE CONCLUÍDA! 🎉',
                          subtitle: 'Você chegou ao final.\n\n🪙 ${state.collectedCoins} moedas   •   ⭐ ${state.score.toInt()} pontos',
                          button: 'JOGAR NOVAMENTE',
                          onPressed: engine.restart,
                        ),
                      if (state.gameOver)
                        _Overlay(
                          title: 'GAME OVER',
                          subtitle: 'Você perdeu todas as vidas.\n\n⭐ ${state.score.toInt()} pontos   •   🪙 ${state.collectedCoins} moedas',
                          button: 'TENTAR NOVAMENTE',
                          onPressed: engine.restart,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  final GameState state;
  final VoidCallback onPause;

  const _Hud({required this.state, required this.onPause});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 14,
      right: 14,
      child: Row(
        children: [
          _StatCard(icon: Icons.favorite_rounded, value: '${state.lives}', label: 'VIDAS'),
          const SizedBox(width: 8),
          _StatCard(icon: Icons.monetization_on_rounded, value: '${state.collectedCoins}', label: 'MOEDAS'),
          const SizedBox(width: 8),
          _StatCard(icon: Icons.star_rounded, value: '${state.score.toInt()}', label: 'PONTOS'),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPause,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                width: 54,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff294f55), Color(0xff11292d)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(.32)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: Icon(
                  state.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 76),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.20)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 7, offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              Text(label, style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(.70), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final GameEngine engine;

  const _Controls({required this.engine});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18,
      right: 18,
      bottom: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _HoldButton(icon: Icons.arrow_back_rounded, onChanged: engine.setLeft),
          const SizedBox(width: 12),
          _HoldButton(icon: Icons.arrow_forward_rounded, onChanged: engine.setRight),
          const Spacer(),
          _TapButton(icon: Icons.keyboard_arrow_up_rounded, onTap: engine.jump),
        ],
      ),
    );
  }
}

class _HoldButton extends StatelessWidget {
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _HoldButton({required this.icon, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onChanged(true),
      onTapUp: (_) => onChanged(false),
      onTapCancel: () => onChanged(false),
      child: _gameButton(icon, 70),
    );
  }
}

class _TapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _gameButton(icon, 84),
    );
  }
}

Widget _gameButton(IconData icon, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff315f62), Color(0xff173334)],
      ),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(.48), width: 2),
      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6))],
    ),
    alignment: Alignment.center,
    child: Icon(icon, color: Colors.white, size: size * .55),
  );
}

class _EventToast extends StatelessWidget {
  final String text;

  const _EventToast({required this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 74,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.56),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(.14)),
            ),
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ),
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String button;
  final VoidCallback onPressed;
  final String? secondaryButton;
  final VoidCallback? onSecondaryPressed;

  const _Overlay({
    required this.title,
    this.subtitle,
    required this.button,
    required this.onPressed,
    this.secondaryButton,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withOpacity(.70),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff1d4c44), Color(0xff0c2323)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.22), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 28, offset: Offset(0, 14))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: .4),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(.86), fontSize: 16, height: 1.4),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffd5a842),
                    foregroundColor: const Color(0xff172218),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(button, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              if (secondaryButton != null && onSecondaryPressed != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSecondaryPressed,
                  child: Text(secondaryButton!, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
