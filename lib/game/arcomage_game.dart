import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'components/ui/game_hud.dart';
import 'components/ui/player_ui_component.dart';
import 'components/cards/card_component.dart';
import 'components/cards/hand_component.dart';
import 'components/buildings/building_component.dart';
import 'models/game_state.dart';
import 'services/audio_service.dart';
import '../providers/game_provider.dart';
import '../constants/app_constants.dart';

class ArcomageGame extends FlameGame with KeyboardEvents, TapCallbacks {
  late GameProvider gameProvider;
  late AudioService audioService;

  // UI компоненты
  late GameHUD gameHUD;
  late PlayerUIComponent playerUI;
  late PlayerUIComponent opponentUI;
  late HandComponent playerHand;
  late HandComponent opponentHand;

  // Компоненты строений
  late BuildingComponent playerTower;
  late BuildingComponent playerWall;
  late BuildingComponent opponentTower;
  late BuildingComponent opponentWall;

  // Фоновые компоненты
  late SpriteComponent background;

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Инициализируем сервисы
    audioService = AudioService();
    await audioService.initialize();

    // Загружаем спрайты и настраиваем камеру
    await _loadAssets();
    await _setupComponents();

    // Добавляем компоненты на сцену
    await _addComponents();
  }

  Future<void> _loadAssets() async {
    // Предзагружаем основные изображения
    try {
      // Фон
      await images.load('${AppConstants.backgroundsPath}game_background.png');

      // UI элементы
      await images.load('${AppConstants.uiPath}card_back.png');
      await images.load('${AppConstants.uiPath}resource_panel.png');

      // Строения
      await images.load('${AppConstants.buildingsPath}tower.png');
      await images.load('${AppConstants.buildingsPath}wall.png');

      // Эффекты
      await images.load('${AppConstants.effectsPath}damage_effect.png');
      await images.load('${AppConstants.effectsPath}build_effect.png');

    } catch (e) {
      // Если изображения не найдены, игра продолжит работу без них
      print('Предупреждение: Некоторые изображения не загружены: $e');
    }
  }

  Future<void> _setupComponents() async {
    // Настраиваем фон
    background = SpriteComponent(
      sprite: await _loadSpriteOrDefault('${AppConstants.backgroundsPath}game_background.png'),
      size: size,
      position: Vector2.zero(),
      priority: 0,
    );

    // Настраиваем HUD
    gameHUD = GameHUD(
      position: Vector2.zero(),
      size: size,
      priority: 100,
    );

    // Настраиваем UI игроков
    playerUI = PlayerUIComponent(
      position: Vector2(20, size.y - 120),
      isPlayer: true,
      priority: 90,
    );

    opponentUI = PlayerUIComponent(
      position: Vector2(20, 20),
      isPlayer: false,
      priority: 90,
    );

    // Настраиваем руки игроков
    playerHand = HandComponent(
      position: Vector2(size.x / 2 - 360, size.y - 200),
      isPlayer: true,
      priority: 80,
    );

    opponentHand = HandComponent(
      position: Vector2(size.x / 2 - 360, 20),
      isPlayer: false,
      priority: 80,
    );

    // Настраиваем строения игрока
    playerTower = BuildingComponent(
      buildingType: BuildingType.tower,
      position: Vector2(size.x - 150, size.y - 250),
      isPlayer: true,
      priority: 70,
    );

    playerWall = BuildingComponent(
      buildingType: BuildingType.wall,
      position: Vector2(size.x - 100, size.y - 150),
      isPlayer: true,
      priority: 70,
    );

    // Настраиваем строения противника
    opponentTower = BuildingComponent(
      buildingType: BuildingType.tower,
      position: Vector2(size.x - 150, 100),
      isPlayer: false,
      priority: 70,
    );

    opponentWall = BuildingComponent(
      buildingType: BuildingType.wall,
      position: Vector2(size.x - 100, 200),
      isPlayer: false,
      priority: 70,
    );
  }

  Future<void> _addComponents() async {
    // Добавляем компоненты в определенном порядке
    await addAll([
      background,
      playerTower,
      playerWall,
      opponentTower,
      opponentWall,
      playerUI,
      opponentUI,
      playerHand,
      opponentHand,
      gameHUD,
    ]);
  }

  Future<Sprite> _loadSpriteOrDefault(String path) async {
    try {
      return await loadSprite(path);
    } catch (e) {
      // Создаем простой цветной прямоугольник, если изображение не найдено
      return _createDefaultSprite();
    }
  }

  Sprite _createDefaultSprite() {
    // Создаем простое изображение по умолчанию
    final paint = Paint()..color = const Color(0xFF333333);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), paint);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(100, 100);
    return Sprite(image);
  }

  @override
  void onMount() {
    super.onMount();

    // Получаем ссылку на провайдер
    gameProvider = Provider.of<GameProvider>(
      findGame()!.buildContext!,
      listen: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Обновляем компоненты на основе состояния игры
    _updateComponentsFromGameState();
  }

  void _updateComponentsFromGameState() {
    if (gameProvider.gameState.phase == GamePhase.gameOver) {
      _handleGameEnd();
    }
  }

  void _handleGameEnd() {
    // Логика окончания игры
    if (gameProvider.gameState.result == GameResult.playerWins) {
      audioService.playVictorySound();
    } else {
      audioService.playDefeatSound();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Передаем события касания компонентам
    print('Tap detected at: ${event.localPosition}');
  }

  // Обработка клавиатурных событий
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      // Пауза игры или выход
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      // Какое-то действие по пробелу
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // Методы для взаимодействия с картами
  void onCardTapped(CardComponent cardComponent) {
    if (gameProvider.isPlayerTurn && cardComponent.isPlayerCard) {
      gameProvider.playCard(cardComponent.cardModel);
    }
  }

  void onCardDoubleTapped(CardComponent cardComponent) {
    if (gameProvider.isPlayerTurn && cardComponent.isPlayerCard) {
      gameProvider.discardCard(cardComponent.cardModel);
    }
  }

  // Эффекты анимации
  Future<void> playCardAnimation(Vector2 from, Vector2 to) async {
    // Анимация полета карты
    final cardSprite = SpriteComponent(
      sprite: await _loadSpriteOrDefault('${AppConstants.uiPath}card_back.png'),
      size: Vector2(AppConstants.cardWidth, AppConstants.cardHeight),
      position: from,
      priority: 99,
    );

    add(cardSprite);

    // Анимация движения
    final moveEffect = MoveToEffect(
      to,
      EffectController(duration: 0.5),
    );

    cardSprite.add(moveEffect);

    // Удаляем после анимации
    await Future.delayed(const Duration(milliseconds: 500));
    cardSprite.removeFromParent();
  }

  Future<void> playDamageAnimation(Vector2 position) async {
    try {
      final damageEffect = SpriteComponent(
        sprite: await loadSprite('${AppConstants.effectsPath}damage_effect.png'),
        size: Vector2(64, 64),
        position: position,
        priority: 95,
      );

      add(damageEffect);

      // Анимация исчезновения
      final fadeEffect = OpacityEffect.fadeOut(
        EffectController(duration: 1.0),
      );

      damageEffect.add(fadeEffect);

      // Удаляем после анимации
      await Future.delayed(const Duration(milliseconds: 1000));
      damageEffect.removeFromParent();
    } catch (e) {
      print('Ошибка анимации урона: $e');
    }
  }

  Future<void> playBuildAnimation(Vector2 position) async {
    try {
      final buildEffect = SpriteComponent(
        sprite: await loadSprite('${AppConstants.effectsPath}build_effect.png'),
        size: Vector2(64, 64),
        position: position,
        priority: 95,
      );

      add(buildEffect);

      // Анимация исчезновения
      final fadeEffect = OpacityEffect.fadeOut(
        EffectController(duration: 1.0),
      );

      buildEffect.add(fadeEffect);

      // Удаляем после анимации
      await Future.delayed(const Duration(milliseconds: 1000));
      buildEffect.removeFromParent();
    } catch (e) {
      print('Ошибка анимации строительства: $e');
    }
  }

  @override
  void onRemove() {
    audioService.dispose();
    super.onRemove();
  }
}