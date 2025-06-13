import 'package:json_annotation/json_annotation.dart';

part 'card_model.g.dart';

enum CardType {
  @JsonValue('brick')
  brick,
  @JsonValue('gem')
  gem,
  @JsonValue('recruit')
  recruit,
}

enum CardRarity {
  @JsonValue('common')
  common,
  @JsonValue('uncommon')
  uncommon,
  @JsonValue('rare')
  rare,
}

@JsonSerializable()
class CardEffect {
  final String type;
  final int value;
  final String? target; // 'self', 'enemy', 'both'
  final String? condition; // условие для эффекта

  const CardEffect({
    required this.type,
    required this.value,
    this.target = 'self',
    this.condition,
  });

  factory CardEffect.fromJson(Map<String, dynamic> json) => _$CardEffectFromJson(json);
  Map<String, dynamic> toJson() => _$CardEffectToJson(this);
}

@JsonSerializable()
class CardModel {
  final int id;
  final String name;
  final String description;
  final CardType type;
  final int cost;
  final CardRarity rarity;
  final List<CardEffect> effects;
  final String imagePath;
  final bool canPlayAgain;
  final String? flavorText;

  const CardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.cost,
    required this.rarity,
    required this.effects,
    required this.imagePath,
    this.canPlayAgain = false,
    this.flavorText,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);
  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  // Получает цвет карты по типу
  int get typeColor {
    switch (type) {
      case CardType.brick:
        return 0xFFB22222;
      case CardType.gem:
        return 0xFF1E90FF;
      case CardType.recruit:
        return 0xFF228B22;
    }
  }

  // Получает иконку типа ресурса
  String get typeIcon {
    switch (type) {
      case CardType.brick:
        return '🧱';
      case CardType.gem:
        return '💎';
      case CardType.recruit:
        return '⚔️';
    }
  }

  // Получает описание эффектов карты
  String get effectsDescription {
    return effects.map((effect) {
      final prefix = _getEffectPrefix(effect);
      final suffix = _getEffectSuffix(effect);
      final value = effect.value > 0 ? '+${effect.value}' : '${effect.value}';
      return '$prefix$value $suffix';
    }).join(', ');
  }

  String _getEffectPrefix(CardEffect effect) {
    switch (effect.target) {
      case 'enemy':
        return 'Враг: ';
      case 'both':
        return 'Все: ';
      default:
        return '';
    }
  }

  String _getEffectSuffix(CardEffect effect) {
    switch (effect.type) {
      case 'tower':
        return 'башня';
      case 'wall':
        return 'стена';
      case 'damage':
        return 'урон';
      case 'bricks':
        return 'кирпичи';
      case 'gems':
        return 'самоцветы';
      case 'recruits':
        return 'рекруты';
      case 'quarry':
        return 'каменоломня';
      case 'magic':
        return 'магия';
      case 'dungeon':
        return 'подземелье';
      default:
        return effect.type;
    }
  }

  @override
  String toString() {
    return 'Card{id: $id, name: $name, type: $type, cost: $cost}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
