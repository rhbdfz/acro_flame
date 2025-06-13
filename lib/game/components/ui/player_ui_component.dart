import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player_model.dart';
import '../../../providers/game_provider.dart';
import '../../../constants/app_constants.dart';

class PlayerUIComponent extends Component {
  final bool isPlayer;

  late GameProvider gameProvider;
  late RectangleComponent backgroundPanel;
  late TextComponent nameText;
  late List<ResourceDisplay> resourceDisplays;
  late List<GeneratorDisplay> generatorDisplays;

  Player? _lastPlayer;

  PlayerUIComponent({
    required Vector2 position,
    required this.isPlayer,
    super.priority = 90,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setupUI();
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

  Future<void> _setupUI() async {
    const panelWidth = 300.0;
    const panelHeight = 100.0;

    // Фоновая панель
    backgroundPanel = RectangleComponent(
      size: Vector2(panelWidth, panelHeight),
      position: Vector2.zero(),
      paint: Paint()
        ..color = const Color(0xFF1A1A2E).withOpacity(0.9)
        ..style = PaintingStyle.fill,
      priority: 1,
    );
    add(backgroundPanel);

    // Рамка панели
    final borderPanel = RectangleComponent(
      size: Vector2(panelWidth, panelHeight),
      position: Vector2.zero(),
      paint: Paint()
        ..color = Colors.gold.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
      priority: 2,
    );
    add(borderPanel);

    // Имя игрока
    nameText = TextComponent(
      text: isPlayer ? 'Игрок' : 'Компьютер',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(10, 5),
      priority: 3,
    );
    add(nameText);

    // Отображение ресурсов
    resourceDisplays = [];
    await _setupResourceDisplays();

    // Отображение генераторов
    generatorDisplays = [];
    await _setupGeneratorDisplays();
  }

  Future<void> _setupResourceDisplays() async {
    const double startX = 10;
    const double startY = 25;
    const double spacing = 90;

    final resourceConfigs = [
      ResourceConfig('🧱', 'Кирпичи', AppConstants.brickColor),
      ResourceConfig('💎', 'Самоцветы', AppConstants.gemColor),
      ResourceConfig('⚔️', 'Рекруты', AppConstants.recruitColor),
    ];

    for (int i = 0; i < resourceConfigs.length; i++) {
      final config = resourceConfigs[i];
      final display = ResourceDisplay(
        icon: config.icon,
        label: config.label,
        color: Color(config.color),
        position: Vector2(startX + (i * spacing), startY),
        priority: 3,
      );

      resourceDisplays.add(display);
      add(display);
    }
  }

  Future<void> _setupGeneratorDisplays() async {
    const double startX = 10;
    const double startY = 55;
    const double spacing = 90;

    final generatorConfigs = [
      ResourceConfig('⛏️', 'Каменоломня', AppConstants.brickColor),
      ResourceConfig('🔮', 'Магия', AppConstants.gemColor),
      ResourceConfig('🏰', 'Подземелье', AppConstants.recruitColor),
    ];

    for (int i = 0; i < generatorConfigs.length; i++) {
      final config = generatorConfigs[i];
      final display = GeneratorDisplay(
        icon: config.icon,
        label: config.label,
        color: Color(config.color),
        position: Vector2(startX + (i * spacing), startY),
        priority: 3,
      );

      generatorDisplays.add(display);
      add(display);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePlayerInfo();
  }

  void _updatePlayerInfo() {
    final currentPlayer = isPlayer ? gameProvider.player : gameProvider.opponent;

    if (_playerChanged(currentPlayer)) {
      _updateDisplays(currentPlayer);
      _lastPlayer = currentPlayer.copyWith();
    }
  }

  bool _playerChanged(Player newPlayer) {
    if (_lastPlayer == null) return true;

    return _lastPlayer!.bricks != newPlayer.bricks ||
        _lastPlayer!.gems != newPlayer.gems ||
        _lastPlayer!.recruits != newPlayer.recruits ||
        _lastPlayer!.quarry != newPlayer.quarry ||
        _lastPlayer!.magic != newPlayer.magic ||
        _lastPlayer!.dungeon != newPlayer.dungeon ||
        _lastPlayer!.name != newPlayer.name;
  }

  void _updateDisplays(Player player) {
    // Обновляем имя
    nameText.text = player.name;

    // Обновляем ресурсы
    if (resourceDisplays.length >= 3) {
      resourceDisplays[0].updateValue(player.bricks);
      resourceDisplays[1].updateValue(player.gems);
      resourceDisplays[2].updateValue(player.recruits);
    }

    // Обновляем генераторы
    if (generatorDisplays.length >= 3) {
      generatorDisplays[0].updateValue(player.quarry);
      generatorDisplays[1].updateValue(player.magic);
      generatorDisplays[2].updateValue(player.dungeon);
    }
  }

  // Анимация подсветки при ходе игрока
  void setActivePlayer(bool isActive) {
    if (isActive) {
      final glowEffect = ColorEffect(
        Colors.gold.withOpacity(0.3),
        const Offset(0.3, 0),
        EffectController(duration: 1.0, infinite: true, alternate: true),
      );

      backgroundPanel.add(glowEffect);
    } else {
      // Убираем эффекты свечения
      backgroundPanel.children.whereType<ColorEffect>().forEach((effect) {
        effect.removeFromParent();
      });
    }
  }
}

class ResourceConfig {
  final String icon;
  final String label;
  final int color;

  const ResourceConfig(this.icon, this.label, this.color);
}

class ResourceDisplay extends Component {
  final String icon;
  final String label;
  final Color color;

  late TextComponent iconText;
  late TextComponent valueText;
  late TextComponent labelText;

  int _lastValue = 0;

  ResourceDisplay({
    required this.icon,
    required this.label,
    required this.color,
    required Vector2 position,
    required int priority,
  }) : super(position: position, priority: priority);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Иконка
    iconText = TextComponent(
      text: icon,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      position: Vector2.zero(),
      priority: 1,
    );
    add(iconText);

    // Значение
    valueText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 0),
      priority: 1,
    );
    add(valueText);

    // Подпись (опционально, для отладки)
    if (false) { // Отключено для экономии места
      labelText = TextComponent(
        text: label,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8,
          ),
        ),
        position: Vector2(0, 18),
        priority: 1,
      );
      add(labelText);
    }
  }

  void updateValue(int newValue) {
    if (newValue != _lastValue) {
      valueText.text = '$newValue';

      // Анимация изменения
      if (newValue > _lastValue) {
        _playIncreaseAnimation();
      } else if (newValue < _lastValue) {
        _playDecreaseAnimation();
      }

      _lastValue = newValue;
    }
  }

  void _playIncreaseAnimation() {
    final scaleEffect = ScaleEffect.by(
      Vector2.all(1.2),
      EffectController(duration: 0.3, alternate: true),
    );

    final glowEffect = ColorEffect(
      Colors.green.withOpacity(0.7),
      const Offset(0.5, 0),
      EffectController(duration: 0.5),
    );

    valueText.add(scaleEffect);
    valueText.add(glowEffect);
  }

  void _playDecreaseAnimation() {
    final shakeEffect = MoveByEffect(
      Vector2(2, 0),
      EffectController(duration: 0.1, alternate: true, repeatCount: 3),
    );

    final colorEffect = ColorEffect(
      Colors.red.withOpacity(0.7),
      const Offset(0.5, 0),
      EffectController(duration: 0.5),
    );

    valueText.add(shakeEffect);
    valueText.add(colorEffect);
  }
}

class GeneratorDisplay extends ResourceDisplay {
  GeneratorDisplay({
    required String icon,
    required String label,
    required Color color,
    required Vector2 position,
    required int priority,
  }) : super(
    icon: icon,
    label: label,
    color: color,
    position: position,
    priority: priority,
  );

  @override
  void _playIncreaseAnimation() {
    // Для генераторов - анимация строительства
    final pulseEffect = ScaleEffect.by(
      Vector2.all(1.3),
      EffectController(duration: 0.4, alternate: true),
    );

    final glowEffect = ColorEffect(
      Colors.blue.withOpacity(0.8),
      const Offset(0.6, 0),
      EffectController(duration: 0.6),
    );

    iconText.add(pulseEffect);
    valueText.add(glowEffect);
  }
}