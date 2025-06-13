import 'dart:math';
import '../models/game_state.dart';
import '../models/player_model.dart';
import '../models/card_model.dart';

class AIDecision {
  final bool shouldPlayCard;
  final CardModel? cardToPlay;
  final CardModel? cardToDiscard;
  final double confidence;
  final String reasoning;

  const AIDecision({
    required this.shouldPlayCard,
    this.cardToPlay,
    this.cardToDiscard,
    this.confidence = 0.5,
    this.reasoning = '',
  });
}

class AIService {
  static const double _aggressiveness = 0.7;
  static const double _defensiveness = 0.5;
  static const double _greediness = 0.6;
  final Random _random = Random();

  // Принимает решение о ходе ИИ
  AIDecision makeDecision(GameState gameState) {
    final aiPlayer = gameState.opponent;
    final humanPlayer = gameState.player;

    if (aiPlayer.hand.isEmpty) {
      return const AIDecision(
        shouldPlayCard: false,
        reasoning: 'Нет карт в руке',
      );
    }

    // Анализируем каждую карту в руке
    final cardAnalyses = <CardModel, double>{};

    for (final card in aiPlayer.hand) {
      if (aiPlayer.canPlayCard(card)) {
        final score = _evaluateCard(card, gameState);
        cardAnalyses[card] = score;
      }
    }

    if (cardAnalyses.isEmpty) {
      // Нет карт, которые можно сыграть - сбрасываем наименее полезную
      final cardToDiscard = _selectCardToDiscard(aiPlayer.hand);
      return AIDecision(
        shouldPlayCard: false,
        cardToDiscard: cardToDiscard,
        reasoning: 'Нет доступных карт для игры',
      );
    }

    // Выбираем лучшую карту
    final bestCard = cardAnalyses.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final bestScore = cardAnalyses[bestCard]!;

    // Решаем, стоит ли играть лучшую карту
    final shouldPlay = bestScore > 0.3 || _isUrgentSituation(gameState);

    if (shouldPlay) {
      return AIDecision(
        shouldPlayCard: true,
        cardToPlay: bestCard,
        confidence: bestScore,
        reasoning: 'Выбрана лучшая карта: ${bestCard.name}',
      );
    } else {
      final cardToDiscard = _selectCardToDiscard(aiPlayer.hand);
      return AIDecision(
        shouldPlayCard: false,
        cardToDiscard: cardToDiscard,
        reasoning: 'Ни одна карта не подходит для игры',
      );
    }
  }

  // Оценивает полезность карты
  double _evaluateCard(CardModel card, GameState gameState) {
    double score = 0.0;

    final aiPlayer = gameState.opponent;
    final humanPlayer = gameState.player;

    // Симулируем применение карты
    final simulatedAI = _simulateCardEffects(card, aiPlayer, humanPlayer, true);
    final simulatedHuman = _simulateCardEffects(card, aiPlayer, humanPlayer, false);

    // Оцениваем результат для ИИ
    score += _evaluateVictoryChance(simulatedAI, gameState) * 2.0;
    score += _evaluateDefensiveValue(simulatedAI, simulatedHuman) * _defensiveness;
    score += _evaluateOffensiveValue(simulatedAI, simulatedHuman) * _aggressiveness;
    score += _evaluateResourceValue(simulatedAI, gameState) * _greediness;
    score += _evaluateSpecialEffects(card) * 0.3;

    // Штрафы
    score -= _evaluateRisk(simulatedAI, simulatedHuman) * 0.5;
    score -= _evaluateResourceCost(card, aiPlayer) * 0.2;

    // Добавляем немного случайности
    score += (_random.nextDouble() - 0.5) * 0.1;

    return score.clamp(0.0, 1.0);
  }

  // Симулирует применение эффектов карты
  Player _simulateCardEffects(CardModel card, Player aiPlayer, Player humanPlayer, bool isAI) {
    final targetPlayer = isAI ? aiPlayer : humanPlayer;
    final simulatedPlayer = targetPlayer.copyWith();

    for (final effect in card.effects) {
      _applySimulatedEffect(effect, simulatedPlayer, isAI ? humanPlayer : aiPlayer);
    }

    return simulatedPlayer;
  }

  void _applySimulatedEffect(CardEffect effect, Player player, Player opponent) {
    switch (effect.target) {
      case 'self':
        _applyEffectToSimulatedPlayer(effect, player);
        break;
      case 'enemy':
        _applyEffectToSimulatedPlayer(effect, opponent);
        break;
      case 'both':
        _applyEffectToSimulatedPlayer(effect, player);
        _applyEffectToSimulatedPlayer(effect, opponent);
        break;
    }
  }

  void _applyEffectToSimulatedPlayer(CardEffect effect, Player player) {
    switch (effect.type) {
      case 'tower':
        player.tower = (player.tower + effect.value).clamp(0, 999);
        break;
      case 'wall':
        player.wall = (player.wall + effect.value).clamp(0, 999);
        break;
      case 'damage':
        _applySimulatedDamage(player, effect.value.abs());
        break;
      case 'bricks':
        player.bricks = (player.bricks + effect.value).clamp(0, 999);
        break;
      case 'gems':
        player.gems = (player.gems + effect.value).clamp(0, 999);
        break;
      case 'recruits':
        player.recruits = (player.recruits + effect.value).clamp(0, 999);
        break;
      case 'quarry':
        player.quarry = (player.quarry + effect.value).clamp(0, 999);
        break;
      case 'magic':
        player.magic = (player.magic + effect.value).clamp(0, 999);
        break;
      case 'dungeon':
        player.dungeon = (player.dungeon + effect.value).clamp(0, 999);
        break;
    }
  }

  void _applySimulatedDamage(Player player, int damage) {
    int remainingDamage = damage;

    if (player.wall > 0) {
      final wallDamage = remainingDamage.clamp(0, player.wall);
      player.wall -= wallDamage;
      remainingDamage -= wallDamage;
    }

    if (remainingDamage > 0) {
      player.tower = (player.tower - remainingDamage).clamp(0, 999);
    }
  }

  // Оценивает шанс на победу
  double _evaluateVictoryChance(Player aiPlayer, GameState gameState) {
    double score = 0.0;

    // Проверяем близость к победе по башне
    final towerProgress = aiPlayer.tower / gameState.towerVictoryHeight;
    if (towerProgress >= 1.0) {
      return 1.0; // Немедленная победа
    }
    score += towerProgress * 0.8;

    // Проверяем близость к победе по ресурсам
    final maxResource = [aiPlayer.bricks, aiPlayer.gems, aiPlayer.recruits].reduce(max);
    final resourceProgress = maxResource / gameState.resourceVictoryAmount;
    if (resourceProgress >= 1.0) {
      return 1.0; // Немедленная победа
    }
    score += resourceProgress * 0.6;

    return score;
  }

  // Оценивает оборонительную ценность
  double _evaluateDefensiveValue(Player aiPlayer, Player humanPlayer) {
    double score = 0.0;

    // Оцениваем улучшение обороны
    score += aiPlayer.wall * 0.01;
    score += aiPlayer.tower * 0.005;

    // Больше очков, если ИИ в опасности
    if (aiPlayer.tower < 10) {
      score *= 2.0;
    }
    if (aiPlayer.wall < 3) {
      score *= 1.5;
    }

    return score;
  }

  // Оценивает атакующую ценность
  double _evaluateOffensiveValue(Player aiPlayer, Player humanPlayer) {
    double score = 0.0;

    // Оцениваем потенциальный урон противнику
    if (humanPlayer.tower < aiPlayer.tower) {
      score += 0.3; // Агрессивность, если ИИ впереди
    }

    // Больше очков за урон, если противник близок к победе
    if (humanPlayer.tower >= gameState.towerVictoryHeight * 0.8) {
      score += 0.5;
    }

    final maxHumanResource = [humanPlayer.bricks, humanPlayer.gems, humanPlayer.recruits].reduce(max);
    if (maxHumanResource >= gameState.resourceVictoryAmount * 0.8) {
      score += 0.5;
    }

    return score;
  }

  // Оценивает ценность ресурсов
  double _evaluateResourceValue(Player aiPlayer, GameState gameState) {
    double score = 0.0;

    // Оцениваем производство ресурсов
    score += aiPlayer.quarry * 0.1;
    score += aiPlayer.magic * 0.1;
    score += aiPlayer.dungeon * 0.1;

    // Оцениваем накопление ресурсов
    score += aiPlayer.bricks * 0.005;
    score += aiPlayer.gems * 0.005;
    score += aiPlayer.recruits * 0.005;

    return score;
  }

  // Оценивает специальные эффекты карты
  double _evaluateSpecialEffects(CardModel card) {
    double score = 0.0;

    // Дополнительный ход очень ценен
    if (card.canPlayAgain) {
      score += 0.4;
    }

    // Множественные эффекты ценнее
    if (card.effects.length > 1) {
      score += card.effects.length * 0.05;
    }

    return score;
  }

  // Оценивает риски от игры карты
  double _evaluateRisk(Player aiPlayer, Player humanPlayer) {
    double risk = 0.0;

    // Риск, если ИИ станет слишком уязвимым
    if (aiPlayer.wall < 2 && aiPlayer.tower < 8) {
      risk += 0.3;
    }

    return risk;
  }

  // Оценивает стоимость ресурсов
  double _evaluateResourceCost(CardModel card, Player aiPlayer) {
    double cost = 0.0;

    switch (card.type) {
      case CardType.brick:
        cost = card.cost / (aiPlayer.bricks + 1);
        break;
      case CardType.gem:
        cost = card.cost / (aiPlayer.gems + 1);
        break;
      case CardType.recruit:
        cost = card.cost / (aiPlayer.recruits + 1);
        break;
    }

    return cost;
  }

  // Проверяет, находится ли ИИ в критической ситуации
  bool _isUrgentSituation(GameState gameState) {
    final aiPlayer = gameState.opponent;
    final humanPlayer = gameState.player;

    // Критически низкая башня
    if (aiPlayer.tower <= 5) {
      return true;
    }

    // Противник близок к победе
    if (humanPlayer.tower >= gameState.towerVictoryHeight * 0.9) {
      return true;
    }

    final maxHumanResource = [humanPlayer.bricks, humanPlayer.gems, humanPlayer.recruits].reduce(max);
    if (maxHumanResource >= gameState.resourceVictoryAmount * 0.9) {
      return true;
    }

    return false;
  }

  // Выбирает карту для сброса
  CardModel _selectCardToDiscard(List<CardModel> hand) {
    if (hand.isEmpty) {
      throw StateError('Нет карт для сброса');
    }

    // Приоритет сброса: самые дорогие карты или с наименьшей полезностью
    final sortedCards = List<CardModel>.from(hand);
    sortedCards.sort((a, b) {
      // Сначала по стоимости
      final costCompare = b.cost.compareTo(a.cost);
      if (costCompare != 0) return costCompare;

      // Потом по редкости (редкие карты сбрасываем неохотно)
      final rarityA = a.rarity == CardRarity.rare ? 2 : (a.rarity == CardRarity.uncommon ? 1 : 0);
      final rarityB = b.rarity == CardRarity.rare ? 2 : (b.rarity == CardRarity.uncommon ? 1 : 0);
      return rarityA.compareTo(rarityB);
    });

    return sortedCards.first;
  }
}
