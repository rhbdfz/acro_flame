import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../arcomage_game.dart';
import '../../models/card_model.dart';
import '../../services/card_service.dart';
import '../../../constants/app_constants.dart';

class CardComponent extends RectangleComponent with TapCallbacks, HoverCallbacks {
  final CardModel cardModel;
  final bool isPlayerCard;
  final bool isRevealed;

  late TextComponent nameText;
  late TextComponent costText;
  late TextComponent descriptionText;
  late RectangleComponent costCircle;
  late RectangleComponent cardFrame;

  bool _isHovered = false;
  bool _isSelected = false;

  CardComponent({
    required this.cardModel,
    required Vector2 position,
    this.isPlayerCard = true,
    this.isRevealed = true,
    super.priority = 50,
  }) : super(
    position: position,
    size: Vector2(AppConstants.cardWidth, AppConstants.cardHeight),
    paint: Paint()..color = const Color(0xFF2C2C54),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Настраиваем внешний вид карты
    _setupCardAppearance();

    if (isRevealed) {
      await _setupCardContent();
    } else {
      await _setupCardBack();
    }
  }

  void _setupCardAppearance() {
    // Рамка карты
    cardFrame = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()
        ..color = Color(cardModel.typeColor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    add(cardFrame);

    // Фон карты
    paint = Paint()..color = _getBackgroundColor();

    // Скругленные углы
    // В Flame можно использовать RoundedRectangleComponent, но для простоты используем обычный
  }

  Color _getBackgroundColor() {
    if (!isRevealed) {
      return const Color(0xFF8B4513); // Коричневый для рубашки
    }

    switch (cardModel.type) {
      case CardType.brick:
        return const Color(0xFF4A1810); // Темно-красный
      case CardType.gem:
        return const Color(0xFF0F2A44); // Темно-синий
      case CardType.recruit:
        return const Color(0xFF1B4332); // Темно-зеленый
    }
  }

  Future<void> _setupCardContent() async {
    // Название карты
    nameText = TextComponent(
      text: cardModel.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(8, 8),
      priority: 1,
    );
    add(nameText);

    // Стоимость карты
    costCircle = RectangleComponent(
      size: Vector2(24, 24),
      position: Vector2(size.x - 32, 8),
      paint: Paint()..color = Color(cardModel.typeColor),
    );
    add(costCircle);

    costText = TextComponent(
      text: '${cardModel.cost}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x - 24, 14),
      anchor: Anchor.center,
      priority: 1,
    );
    add(costText);

    // Иконка типа ресурса
    final typeIcon = TextComponent(
      text: cardModel.typeIcon,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
      position: Vector2(8, 30),
      priority: 1,
    );
    add(typeIcon);

    // Описание эффектов
    final cardService = CardService();
    final effectsText = cardService.formatCardEffects(cardModel);

    descriptionText = TextComponent(
      text: effectsText,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
        ),
      ),
      position: Vector2(8, size.y - 60),
      priority: 1,
    );
    add(descriptionText);

    // Редкость карты (цветная полоска)
    final rarityColor = _getRarityColor();
    final rarityStripe = RectangleComponent(
      size: Vector2(size.x, 4),
      position: Vector2(0, size.y - 8),
      paint: Paint()..color = rarityColor,
    );
    add(rarityStripe);

    // Флэйвор текст (если есть)
    if (cardModel.flavorText != null) {
      final flavorText = TextComponent(
        text: cardModel.flavorText!,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 8,
            fontStyle: FontStyle.italic,
          ),
        ),
        position: Vector2(8, size.y - 30),
        priority: 1,
      );
      add(flavorText);
    }

    // Индикатор "играть снова"
    if (cardModel.canPlayAgain) {
      final playAgainIndicator = TextComponent(
        text: '↻',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x - 20, size.y - 30),
        priority: 1,
      );
      add(playAgainIndicator);
    }
  }

  Future<void> _setupCardBack() async {
    // Рубашка карты
    final backText = TextComponent(
      text: 'ARCOMAGE',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      priority: 1,
    );
    add(backText);

    // Декоративный узор
    final pattern = TextComponent(
      text: '⚜',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 24,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2 - 30),
      anchor: Anchor.center,
      priority: 1,
    );
    add(pattern);
  }

  Color _getRarityColor() {
    switch (cardModel.rarity) {
      case CardRarity.common:
        return Colors.grey;
      case CardRarity.uncommon:
        return Colors.blue;
      case CardRarity.rare:
        return Colors.purple;
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (isPlayerCard && isRevealed) {
      _onCardTapped();
    }
    return true;
  }

  // @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    if (isPlayerCard && isRevealed) {
      _onCardDoubleTapped();
    }
    // return true;
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
    _updateCardAppearance();
    // return true;
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    _updateCardAppearance();
    // return true;
  }

  void _onCardTapped() {
    // Находим игровой компонент и вызываем обработчик
    final game = findParent<ArcomageGame>();
    game?.onCardTapped(this);
  }

  void _onCardDoubleTapped() {
    // Сброс карты
    final game = findParent<ArcomageGame>();
    game?.onCardDoubleTapped(this);
  }

  void setSelected(bool selected) {
    _isSelected = selected;
    _updateCardAppearance();
  }

  void _updateCardAppearance() {
    // Эффект наведения и выбора
    double scale = 1.0;
    Color borderColor = Color(cardModel.typeColor);
    double strokeWidth = 3.0;

    if (_isSelected) {
      scale = 1.1;
      borderColor = Colors.yellow;
      strokeWidth = 4.0;
    } else if (_isHovered) {
      scale = 1.05;
      borderColor = Colors.white;
      strokeWidth = 3.5;
    }

    // Применяем трансформации
    this.scale = Vector2.all(scale);
    cardFrame.paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }

  // Анимация игры карты
  Future<void> playCardAnimation() async {
    // Анимация уменьшения и исчезновения
    final scaleEffect = ScaleEffect.by(
      Vector2.all(0.1),
      EffectController(duration: 0.3),
    );

    final fadeEffect = OpacityEffect.fadeOut(
      EffectController(duration: 0.3),
    );

    add(scaleEffect);
    add(fadeEffect);

    // Ждем завершения анимации
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Анимация появления карты
  Future<void> playAppearAnimation() async {
    // Начинаем с невидимой карты
    opacity = 0.0;
    scale = Vector2.all(0.1);

    // Анимация появления
    final scaleEffect = ScaleEffect.by(
      Vector2.all(10.0),
      EffectController(duration: 0.4),
    );

    final fadeEffect = OpacityEffect.fadeIn(
      EffectController(duration: 0.4),
    );

    add(scaleEffect);
    add(fadeEffect);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Проверяем, можно ли сыграть карту
    _updatePlayability();
  }

  void _updatePlayability() {
    // Эта логика будет обновляться через провайдер
    // Здесь можно добавить визуальные индикаторы доступности карты
  }
}