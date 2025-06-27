import 'dart:async' as async;
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ... [All previous code up to FruitNinjaGame class definition remains unchanged] ...

class FruitNinjaGame extends FlameGame with HasCollisionDetection {
  static const String pauseOverlay = 'PauseMenu';
  static const String gameOverOverlay = 'GameOverMenu';

  final FruitNinjaGameMode mode;
  final Function onExitMenu;

  final Random _rand = Random();

  int score = 0, lives = 3;
  int timeLeft = 60; // seconds (for timed)
  int bestClassic = 0, bestTimed = 0;
  bool isGameOver = false;
  bool isPaused = false;

  late Timer _spawnTimer;
  async.Timer? _timerCountdown;

  List<FruitComponent> fruits = [];
  List<BombComponent> bombs = [];
  List<PowerUpComponent> powerUps = [];

  List<Vector2> _swipePath = [];

  FruitNinjaGame(this.mode, {required this.onExitMenu});

  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll([
      'apple.png', 'banana.png', 'kiwi.png', 'watermelon.png', 'bomb.png', 'star.png'
    ]);
    await FlameAudio.audioCache.loadAll([
      'slice.wav', 'fail.wav', 'bg_music.mp3', 'powerup.wav', 'hit_bomb.wav'
    ]);
    overlays.remove(gameOverOverlay);
    overlays.remove(pauseOverlay);
    await _loadHighScores();

    _spawnTimer = Timer(0.7, repeat: true, onTick: _launchFruits)..start();
    add(ScreenHitbox());
    score = 0;
    lives = 3;
    timeLeft = 60;
    isGameOver = false;
    isPaused = false;
    if (mode == FruitNinjaGameMode.timed) {
      _timerCountdown = async.Timer.periodic(const Duration(seconds: 1), (timer) {
        if (isPaused || isGameOver) return;
        timeLeft -= 1;
        if (timeLeft <= 0) {
          timeLeft = 0;
          _gameOver();
        }
      });
    }
  }

  // ...[rest of code remains unchanged, except change .periodic/.cancel to async.Timer]...

  void _gameOver() async {
    if (isGameOver) return;
    isGameOver = true;
    isPaused = true;
    await _saveHighScores();
    overlays.add(gameOverOverlay);
    _timerCountdown?.cancel();
    FlameAudio.play('fail.wav', volume: 0.7);
  }

  void _resume() {
    isPaused = false;
    _spawnTimer.start();
    if (mode == FruitNinjaGameMode.timed && !isGameOver) {
      _timerCountdown = async.Timer.periodic(const Duration(seconds: 1), (timer) {
        if (isPaused || isGameOver) return;
        timeLeft -= 1;
        if (timeLeft <= 0) {
          timeLeft = 0;
          _gameOver();
        }
      });
    }
    overlays.remove(pauseOverlay);
    FlameAudio.bgm.resume();
  }

  void _restart() {
    score = 0;
    lives = 3;
    timeLeft = 60;
    isGameOver = false;
    isPaused = false;
    overlays.remove(gameOverOverlay);
    overlays.remove(pauseOverlay);
    fruits.clear();
    bombs.clear();
    powerUps.clear();
    _spawnTimer.start();
    if (mode == FruitNinjaGameMode.timed) {
      _timerCountdown = async.Timer.periodic(const Duration(seconds: 1), (timer) {
        if (isPaused || isGameOver) return;
        timeLeft -= 1;
        if (timeLeft <= 0) {
          timeLeft = 0;
          _gameOver();
        }
      });
    }
  }
}
