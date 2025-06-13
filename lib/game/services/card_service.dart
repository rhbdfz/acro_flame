import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/card_model.dart';
import '../../constants/app_constants.dart';

class CardService {
  static CardService? _instance;
  List<CardModel>? _allCards;

  CardService._internal();

  factory CardService() {
    _instance ??= CardService._internal();
    return _instance!;
  }

  // Загружает все карты из JSON файла
  Future<List<CardModel>> loadCards() async {
    if (_allCards != null) {
      return _allCards!;
    }

    try {
      final String cardsJson = await rootBundle.loadString(AppConstants.cardsJsonPath);
      final List<dynamic> cardsList = json.decode(cardsJson);

      _allCards = cardsList.map((cardJson) => CardModel.fromJson(cardJson)).toList();
      return _allCards!;
    } catch (e) {
      // Если файл не найден, создаем дефолтные карты
      _allCards = _createDefaultCards();
      return _allCards!;
    }
  }

  // Получает все карты (синхронно, если уже загружены)
  List<CardModel> getAllCards() {
    return _allCards ?? _createDefaultCards();
  }

  // Создает дефолтные карты для игры
  List<CardModel> _createDefaultCards() {
    return [
      // Кирпичные карты (строительство)
      ..._createBrickCards(),
      // Самоцветные карты (магия)
      ..._createGemCards(),
      // Карты рекрутов (армия)
      ..._createRecruitCards(),
    ];
  }

  List<CardModel> _createBrickCards() {
    return [
      // Простые строительные карты
      const CardModel(
        id: 1,
        name: 'Каменщик',
        description: '+1 стена',
        type: CardType.brick,
        cost: 1,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.brickCardsPath}mason.png',
        effects: [CardEffect(type: 'wall', value: 1)],
        flavorText: 'Каждый камень важен в строительстве крепости.',
      ),
      const CardModel(
        id: 2,
        name: 'Рабочий',
        description: '+2 стена, +1 каменоломня',
        type: CardType.brick,
        cost: 2,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.brickCardsPath}worker.png',
        effects: [
          CardEffect(type: 'wall', value: 2),
          CardEffect(type: 'quarry', value: 1),
        ],
      ),
      const CardModel(
        id: 3,
        name: 'Архитектор',
        description: '+3 башня',
        type: CardType.brick,
        cost: 3,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.brickCardsPath}architect.png',
        effects: [CardEffect(type: 'tower', value: 3)],
      ),
      const CardModel(
        id: 4,
        name: 'Склад',
        description: '+4 стена, +2 кирпичи',
        type: CardType.brick,
        cost: 4,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.brickCardsPath}warehouse.png',
        effects: [
          CardEffect(type: 'wall', value: 4),
          CardEffect(type: 'bricks', value: 2),
        ],
      ),
      const CardModel(
        id: 5,
        name: 'Крепость',
        description: '+5 башня, +3 стена',
        type: CardType.brick,
        cost: 8,
        rarity: CardRarity.rare,
        imagePath: '${AppConstants.brickCardsPath}fortress.png',
        effects: [
          CardEffect(type: 'tower', value: 5),
          CardEffect(type: 'wall', value: 3),
        ],
      ),
      const CardModel(
        id: 6,
        name: 'Школа строителей',
        description: '+2 каменоломня',
        type: CardType.brick,
        cost: 5,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.brickCardsPath}school.png',
        effects: [CardEffect(type: 'quarry', value: 2)],
      ),
      const CardModel(
        id: 7,
        name: 'Стена',
        description: '+6 стена',
        type: CardType.brick,
        cost: 3,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.brickCardsPath}wall.png',
        effects: [CardEffect(type: 'wall', value: 6)],
      ),
      const CardModel(
        id: 8,
        name: 'Башня',
        description: '+8 башня',
        type: CardType.brick,
        cost: 5,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.brickCardsPath}tower.png',
        effects: [CardEffect(type: 'tower', value: 8)],
      ),
    ];
  }

  List<CardModel> _createGemCards() {
    return [
      // Магические карты
      const CardModel(
        id: 101,
        name: 'Ученик мага',
        description: '+1 башня, +1 магия',
        type: CardType.gem,
        cost: 1,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.gemCardsPath}apprentice.png',
        effects: [
          CardEffect(type: 'tower', value: 1),
          CardEffect(type: 'magic', value: 1),
        ],
      ),
      const CardModel(
        id: 102,
        name: 'Кристалл',
        description: '+3 башня',
        type: CardType.gem,
        cost: 2,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.gemCardsPath}crystal.png',
        effects: [CardEffect(type: 'tower', value: 3)],
      ),
      const CardModel(
        id: 103,
        name: 'Волшебник',
        description: '+4 башня, +1 самоцветы',
        type: CardType.gem,
        cost: 4,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.gemCardsPath}wizard.png',
        effects: [
          CardEffect(type: 'tower', value: 4),
          CardEffect(type: 'gems', value: 1),
        ],
      ),
      const CardModel(
        id: 104,
        name: 'Молния',
        description: '5 урона вражеской стене',
        type: CardType.gem,
        cost: 3,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.gemCardsPath}lightning.png',
        effects: [CardEffect(type: 'damage', value: 5, target: 'enemy')],
      ),
      const CardModel(
        id: 105,
        name: 'Магическая школа',
        description: '+2 магия',
        type: CardType.gem,
        cost: 6,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.gemCardsPath}magic_school.png',
        effects: [CardEffect(type: 'magic', value: 2)],
      ),
      const CardModel(
        id: 106,
        name: 'Огненный шар',
        description: '8 урона врагу',
        type: CardType.gem,
        cost: 7,
        rarity: CardRarity.rare,
        imagePath: '${AppConstants.gemCardsPath}fireball.png',
        effects: [CardEffect(type: 'damage', value: 8, target: 'enemy')],
      ),
      const CardModel(
        id: 107,
        name: 'Исцеление',
        description: '+6 башня, +3 стена',
        type: CardType.gem,
        cost: 5,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.gemCardsPath}heal.png',
        effects: [
          const CardEffect(type: 'tower', value: 6),
          const CardEffect(type: 'wall', value: 3),
        ],
      ),
      const CardModel(
        id: 108,
        name: 'Магический удар',
        description: '10 урона башне врага',
        type: CardType.gem,
        cost: 12,
        rarity: CardRarity.rare,
        imagePath: '${AppConstants.gemCardsPath}magic_strike.png',
        effects: [const CardEffect(type: 'tower', value: -10, target: 'enemy')],
      ),
    ];
  }

  List<CardModel> _createRecruitCards() {
    return [
      // Армейские карты
      const CardModel(
        id: 201,
        name: 'Лучник',
        description: '2 урона',
        type: CardType.recruit,
        cost: 1,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.recruitCardsPath}archer.png',
        effects: [const CardEffect(type: 'damage', value: 2, target: 'enemy')],
      ),
      const CardModel(
        id: 202,
        name: 'Солдат',
        description: '3 урона',
        type: CardType.recruit,
        cost: 2,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.recruitCardsPath}soldier.png',
        effects: [const CardEffect(type: 'damage', value: 3, target: 'enemy')],
      ),
      const CardModel(
        id: 203,
        name: 'Рыцарь',
        description: '4 урона, +2 стена',
        type: CardType.recruit,
        cost: 4,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.recruitCardsPath}knight.png',
        effects: [
          const CardEffect(type: 'damage', value: 4, target: 'enemy'),
          const CardEffect(type: 'wall', value: 2),
        ],
      ),
      const CardModel(
        id: 204,
        name: 'Атака',
        description: '6 урона',
        type: CardType.recruit,
        cost: 3,
        rarity: CardRarity.common,
        imagePath: '${AppConstants.recruitCardsPath}attack.png',
        effects: [const CardEffect(type: 'damage', value: 6, target: 'enemy')],
      ),
      const CardModel(
        id: 205,
        name: 'Казарма',
        description: '+2 подземелье, +1 рекрут',
        type: CardType.recruit,
        cost: 6,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.recruitCardsPath}barracks.png',
        effects: [
          const CardEffect(type: 'dungeon', value: 2),
          const CardEffect(type: 'recruits', value: 1),
        ],
      ),
      const CardModel(
        id: 206,
        name: 'Дракон',
        description: '12 урона',
        type: CardType.recruit,
        cost: 15,
        rarity: CardRarity.rare,
        imagePath: '${AppConstants.recruitCardsPath}dragon.png',
        effects: [const CardEffect(type: 'damage', value: 12, target: 'enemy')],
      ),
      const CardModel(
        id: 207,
        name: 'Берсерк',
        description: '8 урона, играть снова',
        type: CardType.recruit,
        cost: 8,
        rarity: CardRarity.rare,
        imagePath: '${AppConstants.recruitCardsPath}berserker.png',
        canPlayAgain: true,
        effects: [const CardEffect(type: 'damage', value: 8, target: 'enemy')],
      ),
      const CardModel(
        id: 208,
        name: 'Эльф',
        description: '1 урон, играть снова',
        type: CardType.recruit,
        cost: 2,
        rarity: CardRarity.uncommon,
        imagePath: '${AppConstants.recruitCardsPath}elf.png',
        canPlayAgain: true,
        effects: [const CardEffect(type: 'damage', value: 1, target: 'enemy')],
      ),
    ];
  }

  // Получает карты по типу
  List<CardModel> getCardsByType(CardType type) {
    return getAllCards().where((card) => card.type == type).toList();
  }

  // Получает карты по редкости
  List<CardModel> getCardsByRarity(CardRarity rarity) {
    return getAllCards().where((card) => card.rarity == rarity).toList();
  }

  // Создает колоду для игры (с повторениями)
  List<CardModel> createGameDeck() {
    final allCards = getAllCards();
    final deck = <CardModel>[];

    // Добавляем карты в зависимости от редкости
    for (final card in allCards) {
      switch (card.rarity) {
        case CardRarity.common:
          // Обычные карты - 4 копии
          for (int i = 0; i < 4; i++) {
            deck.add(card);
          }
          break;
        case CardRarity.uncommon:
          // Необычные карты - 2 копии
          for (int i = 0; i < 2; i++) {
            deck.add(card);
          }
          break;
        case CardRarity.rare:
          // Редкие карты - 1 копия
          deck.add(card);
          break;
      }
    }

    deck.shuffle();
    return deck;
  }

  // Форматирует эффекты карты в читаемый текст
  String formatCardEffects(CardModel card) {
    if (card.effects.isEmpty) {
      return card.description;
    }

    final effects = card.effects.map((effect) {
      String prefix = '';
      String suffix = '';
      String value = '';

      switch (effect.target) {
        case 'enemy':
          prefix = 'Враг: ';
          break;
        case 'both':
          prefix = 'Все: ';
          break;
        default:
          prefix = '';
      }

      switch (effect.type) {
        case 'tower':
          suffix = ' башня';
          break;
        case 'wall':
          suffix = ' стена';
          break;
        case 'damage':
          suffix = ' урон';
          break;
        case 'bricks':
          suffix = ' кирпичи';
          break;
        case 'gems':
          suffix = ' самоцветы';
          break;
        case 'recruits':
          suffix = ' рекруты';
          break;
        case 'quarry':
          suffix = ' каменоломня';
          break;
        case 'magic':
          suffix = ' магия';
          break;
        case 'dungeon':
          suffix = ' подземелье';
          break;
        default:
          suffix = ' ${effect.type}';
      }

      if (effect.value > 0) {
        value = '+${effect.value}';
      } else {
        value = '${effect.value}';
      }

      return '$prefix$value$suffix';
    }).join(', ');

    return effects;
  }
}
