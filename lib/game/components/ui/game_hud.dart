import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../../../providers/game_provider.dart';
import '../../../constants/app_constants.dart';

class GameHUD extends Component with TapCallbacks {
  late GameProvider gameProvider;

  // UI элементы
  late TextComponent turnText;
  late TextComponent phaseText;
  late TextComponent messageText;
  late ButtonComponent pauseButton;
  late ButtonComponent soundButton;
  late ButtonComponent musicButton;
  late ButtonComponent newGameButton;

  // Панели
  late RectangleComponent topPanel;
  late RectangleComponent messagePanel;
  late RectangleComponent gameOverPanel;

  GameState? _lastGameState;

  GameHUD({
    required Vector2 position,
    required Vector2 size,
    super.priority = 100,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setupHUD();
  }

  @override
  void onMount() {
    super.onMount();

    try {
      gameProvider = Provider.of<GameProvider>(
        findGame()!.buildContext!,
        listen: false,
      );
    } catch (e) {
      print('Ошибка получения GameProvider: $e');
    }
  }

  Future<void> _setupHUD() async {
    await _setupTopPanel();
    await _setupMessagePanel();
    await _setupGameOverPanel();
  }

  Future<void> _setupTopPanel() async {
    const panelHeight = 50.0;

    // Верхняя панель
    topPanel = RectangleComponent(
      size: Vector2(size.x, panelHeight),
      position: Vector2.zero(),
      paint: Paint()
        ..color = const Color(0xFF1A1A2E).withOpacity(0.9)
        ..style = PaintingStyle.fill,
      priority: 1,
    );
    add(topPanel);

    // Информация о ходе
    turnText = TextComponent(
      text: 'Ход: 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(10, 15),
      priority: 2,
    );
    add(turnText);

    // Фаза игры
    phaseText = TextComponent(
      text: 'Ход игрока',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.gold,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(150, 15),
      priority: 2,
    );
    add(phaseText);

    // Кнопки управления
    await _setupControlButtons();
  }

  Future<void> _setupControlButtons() async {
    const buttonSize = 35.0;
    const buttonSpacing = 45.0;
    final startX = size.x - (buttonSpacing * 4) - 10;

    // Кнопка паузы
    pauseButton = ButtonComponent(
      text: '⏸️',
      position: Vector2(startX, 7.5),
      size: Vector2(buttonSize, buttonSize),
      onPressed: _onPausePressed,
      priority: 2,
    );
    add(pauseButton);

    // Кнопка звука
    soundButton = ButtonComponent(
      text: '🔊',
      position: Vector2(startX + buttonSpacing, 7.5),
      size: Vector2(buttonSize, buttonSize),
      onPressed: _onSoundPressed,
      priority: 2,
    );
    add(soundButton);

    // Кнопка музыки
    musicButton = ButtonComponent(
      text: '🎵',
      position: Vector2(startX + buttonSpacing * 2, 7.5),
      size: Vector2(buttonSize, buttonSize),
      onPressed: _onMusicPressed,
      priority: 2,
    );
    add(musicButton);

    // Кнопка новой игры
    newGameButton = ButtonComponent(
      text: '🔄',
      position: Vector2(startX + buttonSpacing * 3, 7.5),
      size: Vector2(buttonSize, buttonSize),
      onPressed: _onNewGamePressed,
      priority: 2,
    );
    add(newGameButton);
  }

  Future<void> _setupMessagePanel() async {
    const panelHeight = 60.0;
    final panelY = size.y / 2 - panelHeight / 2;

    // Панель сообщений
    messagePanel = RectangleComponent(
      size: Vector2(size.x - 200, panelHeight),
      position: Vector2(100, panelY),
      paint: Paint()
        ..color = const Color(0xFF2C2C54).withOpacity(0.95)
        ..style = PaintingStyle.fill,
      priority: 5,
    );
    messagePanel.opacity = 0.0; // Скрыта по умолчанию

    // Рамка панели сообщений
    final messageBorder = RectangleComponent(
      size: Vector2(size.x - 200, panelHeight),
      position: Vector2.zero(),
      paint: Paint()
        ..color = Colors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
      priority: 1,
    );
    messagePanel.add(messageBorder);

    // Текст сообщения
    messageText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2((size.x - 200) / 2, panelHeight / 2),
      anchor: Anchor.center,
      priority: 2,
    );
    messagePanel.add(messageText);

    add(messagePanel);
  }

  Future<void> _setupGameOverPanel() async {
    const panelWidth = 400.0;
    const panelHeight = 300.0;
    final panelX = (size.x - panelWidth) / 2;
    final panelY = (size.y - panelHeight) / 2;

    // Панель окончания игры
    gameOverPanel = RectangleComponent(
      size: Vector2(panelWidth, panelHeight),
      position: Vector2(panelX, panelY),
      paint: Paint()
        ..color = const Color(0xFF1A1A2E).withOpacity(0.98)
        ..style = PaintingStyle.fill,
      priority: 10,
    );
    gameOverPanel.opacity = 0.0; // Скрыта по умолчанию

    // Рамка панели
    final gameOverBorder = RectangleComponent(
      size: Vector2(panelWidth, panelHeight),
      position: Vector2.zero(),
      paint: Paint()
        ..color = Colors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
      priority: 1,
    );
    gameOverPanel.add(gameOverBorder);

    add(gameOverPanel);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateHUD();
  }

  void _updateHUD() {
    final currentState = gameProvider.gameState;

    if (_gameStateChanged(currentState)) {
      _updateDisplay(currentState);
      _lastGameState = currentState.copyWith();
    }
  }

  bool _gameStateChanged(GameState newState) {
    if (_lastGameState == null) return true;

    return _lastGameState!.currentTurn != newState.currentTurn ||
        _lastGameState!.phase != newState.phase ||
        _lastGameState!.isPlayerTurn != newState.isPlayerTurn ||
        _lastGameState!.gameMessage != newState.gameMessage ||
        _lastGameState!.result != newState.result ||
        _lastGameState!.soundEnabled != newState.soundEnabled ||
        _lastGameState!.musicEnabled != newState.musicEnabled;
  }

  void _updateDisplay(GameState gameState) {
    // Обновляем информацию о ходе
    turnText.text = 'Ход: ${gameState.currentTurn}';

    // Обновляем фазу игры
    phaseText.text = _getPhaseText(gameState);

    // Обновляем кнопки
    _updateButtons(gameState);

    // Показываем сообщения
    if (gameState.gameMessage != null && gameState.gameMessage!.isNotEmpty) {
      _showMessage(gameState.gameMessage!);
    }

    // Показываем панель окончания игры
    if (gameState.isGameOver) {
      _showGameOverPanel(gameState);
    } else {
      _hideGameOverPanel();
    }
  }

  String _getPhaseText(GameState gameState) {
    switch (gameState.phase) {
      case GamePhase.playerTurn:
        return 'Ход игрока';
      case GamePhase.aiTurn:
        return 'Ход компьютера';
      case GamePhase.paused:
        return 'Пауза';
      case GamePhase.gameOver:
        return 'Игра окончена';
      default:
        return 'Игра';
    }
  }

  void _updateButtons(GameState gameState) {
    // Обновляем иконки кнопок
    soundButton.updateText(gameState.soundEnabled ? '🔊' : '🔇');
    musicButton.updateText(gameState.musicEnabled ? '🎵' : '🎶');
    pauseButton.updateText(gameState.phase == GamePhase.paused ? '▶️' : '⏸️');
  }

  void _showMessage(String message) {
    messageText.text = message;

    // Анимация появления
    final fadeIn = OpacityEffect.fadeIn(
      EffectController(duration: 0.3),
    );

    messagePanel.add(fadeIn);

    // Автоматически скрываем через 3 секунды
    Future.delayed(const Duration(seconds: 3), () {
      _hideMessage();
    });
  }

  void _hideMessage() {
    final fadeOut = OpacityEffect.fadeOut(
      EffectController(duration: 0.3),
    );

    messagePanel.add(fadeOut);
  }

  void _showGameOverPanel(GameState gameState) {
    // Очищаем предыдущий контент
    gameOverPanel.children.whereType<TextComponent>().forEach((component) {
      component.removeFromParent();
    });
    gameOverPanel.children.whereType<ButtonComponent>().forEach((component) {
      component.removeFromParent();
    });

    // Заголовок
    final titleText = TextComponent(
      text: _getGameOverTitle(gameState),
      textRenderer: TextPaint(
        style: TextStyle(
          color: _getGameOverColor(gameState),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(200, 50),
      anchor: Anchor.center,
      priority: 2,
    );
    gameOverPanel.add(titleText);

    // Описание победы
    final descriptionText = TextComponent(
      text: _getVictoryDescription(gameState),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      position: Vector2(200, 100),
      anchor: Anchor.center,
      priority: 2,
    );
    gameOverPanel.add(descriptionText);

    // Статистика
    final statsText = TextComponent(
      text: _getGameStats(gameState),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      position: Vector2(200, 150),
      anchor: Anchor.center,
      priority: 2,
    );
    gameOverPanel.add(statsText);

    // Кнопка новой игры
    final restartButton = ButtonComponent(
      text: 'Новая игра',
      position: Vector2(150, 220),
      size: Vector2(100, 40),
      onPressed: _onNewGamePressed,
      priority: 2,
    );
    gameOverPanel.add(restartButton);

    // Анимация появления
    final fadeIn = OpacityEffect.fadeIn(
      EffectController(duration: 0.5),
    );

    gameOverPanel.add(fadeIn);
  }

  void _hideGameOverPanel() {
    if (gameOverPanel.opacity > 0) {
      final fadeOut = OpacityEffect.fadeOut(
        EffectController(duration: 0.3),
      );

      gameOverPanel.add(fadeOut);
    }
  }

  String _getGameOverTitle(GameState gameState) {
    switch (gameState.result) {
      case GameResult.playerWins:
        return 'ПОБЕДА!';
      case GameResult.aiWins:
        return 'ПОРАЖЕНИЕ';
      default:
        return 'ИГРА ОКОНЧЕНА';
    }
  }

  Color _getGameOverColor(GameState gameState) {
    switch (gameState.result) {
      case GameResult.playerWins:
        return Colors.green;
      case GameResult.aiWins:
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  String _getVictoryDescription(GameState gameState) {
    final condition = gameState.victoryCondition;
    if (condition == null) return '';

    switch (condition) {
      case VictoryCondition.tower:
        return 'Победа строительством башни!';
      case VictoryCondition.resources:
        return 'Победа накоплением ресурсов!';
      case VictoryCondition.destruction:
        return 'Победа разрушением башни противника!';
    }
  }

  String _getGameStats(GameState gameState) {
    final player = gameState.player;
    final opponent = gameState.opponent;

    return 'Ходов сыграно: ${gameState.currentTurn}\n'
        'Башня игрока: ${player.tower}\n'
        'Башня компьютера: ${opponent.tower}\n'
        'Побед игрока: ${player.wins}';
  }

  // Обработчики событий кнопок
  void _onPausePressed() {
    gameProvider.togglePause();
  }

  void _onSoundPressed() {
    gameProvider.toggleSound();
  }

  void _onMusicPressed() {
    gameProvider.toggleMusic();
  }

  void _onNewGamePressed() {
    gameProvider.startNewGame();
  }
}

// Простой компонент кнопки
class ButtonComponent extends RectangleComponent with TapCallbacks {
  String _text;
  final VoidCallback onPressed;
  late TextComponent textComponent;
  bool _isPressed = false;

  ButtonComponent({
    required String text,
    required Vector2 position,
    required Vector2 size,
    required this.onPressed,
    super.priority = 1,
  }) : _text = text,
        super(
        position: position,
        size: size,
        paint: Paint()
          ..color = const Color(0xFF4A4A4A)
          ..style = PaintingStyle.fill,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Текст кнопки
    textComponent = TextComponent(
      text: _text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      priority: 1,
    );
    add(textComponent);

    // Рамка кнопки
    final border = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
      priority: 1,
    );
    add(border);
  }

  void updateText(String newText) {
    _text = newText;
    textComponent.text = newText;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    _isPressed = true;
    _updateAppearance();
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (_isPressed) {
      _isPressed = false;
      _updateAppearance();
      onPressed();
    }
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    _updateAppearance();
    return true;
  }

  void _updateAppearance() {
    paint = Paint()
      ..color = _isPressed
          ? const Color(0xFF6A6A6A)
          : const Color(0xFF4A4A4A)
      ..style = PaintingStyle.fill;
  }
}