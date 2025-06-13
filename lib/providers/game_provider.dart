import 'package:flutter/foundation.dart';
import '../game/models/game_state.dart';
import '../game/models/player_model.dart';
import '../game/models/card_model.dart';
import '../game/services/card_service.dart';
import '../game/services/ai_service.dart';
import '../game/services/audio_service.dart';
import '../constants/app_constants.dart';

class GameProvider extends ChangeNotifier {
  late GameState _gameState;
  late final CardService _cardService;
  late final AIService _aiService;
  late final AudioService _audioService;

  GameProvider() {
    _cardService = CardService();
    _aiService = AIService();
    _audioService = AudioService();
    _initializeNewGame();
  }

  GameState get gameState => _gameState;

  Player get player => _gameState.player;
  Player get opponent => _gameState.opponent;
  GamePhase get currentPhase => _gameState.phase;
  bool get isPlayerTurn => _gameState.isPlayerTurn;
  bool get isGameOver => _gameState.isGameOver;
  String? get gameMessage => _gameState.gameMessage;

  void _initializeNewGame() {
    _gameState = GameState.newGame(
      playerName: 'Игрок',
      opponentName: 'Компьютер',
      towerHeight: AppConstants.defaultTowerHeight,
      wallHeight: AppConstants.defaultWallHeight,
      resourceCount: AppConstants.defaultResourceCount,
      resourceProduction: AppConstants.defaultResourceProduction,
      towerVictory: AppConstants.towerVictoryHeight,
      resourceVictory: AppConstants.resourceVictoryAmount,
    );

    _initializeDeck();
    _dealInitialCards();
  }

  void _initializeDeck() {
    final allCards = _cardService.getAllCards();
    _gameState = _gameState.copyWith(deck: allCards);
    _shuffleDeck();
  }

  void _shuffleDeck() {
    final shuffledDeck = List<CardModel>.from(_gameState.deck);
    shuffledDeck.shuffle();
    _gameState = _gameState.copyWith(deck: shuffledDeck);
  }

  void _dealInitialCards() {
    // Раздаем начальные карты игроку
    final playerCards = <CardModel>[];
    final opponentCards = <CardModel>[];

    for (int i = 0; i < AppConstants.handSize; i++) {
      if (_gameState.deck.isNotEmpty) {
        playerCards.add(_gameState.deck.removeAt(0));
      }
      if (_gameState.deck.isNotEmpty) {
        opponentCards.add(_gameState.deck.removeAt(0));
      }
    }

    _gameState = _gameState.copyWith(
      player: _gameState.player.copyWith(hand: playerCards),
      opponent: _gameState.opponent.copyWith(hand: opponentCards),
    );
  }

  // Начинает новую игру
  void startNewGame() {
    _initializeNewGame();
    _audioService.playBackgroundMusic();
    notifyListeners();
  }

  // Сыграть карту
  Future<void> playCard(CardModel card) async {
    if (!_canPlayCard(card)) return;

    final currentPlayer = _gameState.currentPlayer;
    final opponent = _gameState.currentOpponent;

    // Тратим ресурсы
    currentPlayer.spendResources(card);

    // Применяем эффекты карты
    _applyCardEffects(card, currentPlayer, opponent);

    // Убираем карту из руки
    final newHand = List<CardModel>.from(currentPlayer.hand);
    newHand.remove(card);

    // Обновляем состояние
    _updatePlayerState(currentPlayer, newHand);

    // Устанавливаем сообщение о сыгранной карте
    _gameState = _gameState.copyWith(
      lastPlayedCardName: card.name,
      gameMessage: '${currentPlayer.name} сыграл карту "${card.name}"',
    );

    // Проигрываем звук
    _audioService.playCardSound();

    // Проверяем условия окончания игры
    _gameState.checkGameEnd();

    if (!_gameState.isGameOver) {
      // Добираем карту
      _drawCard(currentPlayer);

      // Переходим к следующему ходу, если карта не дает дополнительный ход
      if (!card.canPlayAgain) {
        await _nextTurn();
      }
    } else {
      _handleGameEnd();
    }

    notifyListeners();
  }

  bool _canPlayCard(CardModel card) {
    return _gameState.isPlayerTurn && 
           _gameState.phase == GamePhase.playerTurn &&
           _gameState.currentPlayer.canPlayCard(card);
  }

  void _applyCardEffects(CardModel card, Player currentPlayer, Player opponent) {
    for (final effect in card.effects) {
      _applyEffect(effect, currentPlayer, opponent);
    }
  }

  void _applyEffect(CardEffect effect, Player currentPlayer, Player opponent) {
    switch (effect.target) {
      case 'self':
        _applyEffectToPlayer(effect, currentPlayer);
        break;
      case 'enemy':
        _applyEffectToPlayer(effect, opponent);
        break;
      case 'both':
        _applyEffectToPlayer(effect, currentPlayer);
        _applyEffectToPlayer(effect, opponent);
        break;
    }
  }

  void _applyEffectToPlayer(CardEffect effect, Player player) {
    switch (effect.type) {
      case 'tower':
        player.tower = (player.tower + effect.value).clamp(0, 999);
        break;
      case 'wall':
        player.wall = (player.wall + effect.value).clamp(0, 999);
        break;
      case 'damage':
        _applyDamage(player, effect.value.abs());
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

  void _applyDamage(Player player, int damage) {
    int remainingDamage = damage;

    // Сначала урон по стене
    if (player.wall > 0) {
      final wallDamage = remainingDamage.clamp(0, player.wall);
      player.wall -= wallDamage;
      remainingDamage -= wallDamage;
    }

    // Оставшийся урон по башне
    if (remainingDamage > 0) {
      player.tower = (player.tower - remainingDamage).clamp(0, 999);
    }

    _audioService.playDamageSound();
  }

  void _updatePlayerState(Player player, List<CardModel> newHand) {
    if (player.id == 'player') {
      _gameState = _gameState.copyWith(
        player: player.copyWith(hand: newHand),
      );
    } else {
      _gameState = _gameState.copyWith(
        opponent: player.copyWith(hand: newHand),
      );
    }
  }

  void _drawCard(Player player) {
    if (_gameState.deck.isEmpty) {
      _reshuffleDeck();
    }

    if (_gameState.deck.isNotEmpty && player.hand.length < AppConstants.handSize) {
      final newCard = _gameState.deck.removeAt(0);
      final newHand = List<CardModel>.from(player.hand);
      newHand.add(newCard);
      _updatePlayerState(player, newHand);
      _audioService.playDrawSound();
    }
  }

  void _reshuffleDeck() {
    if (_gameState.discardPile.isNotEmpty) {
      final newDeck = List<CardModel>.from(_gameState.discardPile);
      newDeck.shuffle();
      _gameState = _gameState.copyWith(
        deck: newDeck,
        discardPile: <CardModel>[],
      );
    }
  }

  // Сбросить карту
  void discardCard(CardModel card) {
    if (!_gameState.isPlayerTurn || _gameState.phase != GamePhase.playerTurn) {
      return;
    }

    final player = _gameState.player;
    final newHand = List<CardModel>.from(player.hand);
    newHand.remove(card);

    final newDiscardPile = List<CardModel>.from(_gameState.discardPile);
    newDiscardPile.add(card);

    _gameState = _gameState.copyWith(
      player: player.copyWith(hand: newHand),
      discardPile: newDiscardPile,
      gameMessage: 'Игрок сбросил карту "${card.name}"',
    );

    // Добираем новую карту
    _drawCard(player);

    // Переходим к следующему ходу
    _nextTurn();
    notifyListeners();
  }

  // Следующий ход
  Future<void> _nextTurn() async {
    _gameState.nextTurn();

    if (!_gameState.isPlayerTurn) {
      // Ход ИИ
      await Future.delayed(const Duration(milliseconds: AppConstants.aiThinkingDelay));
      await _makeAIMove();
    }
  }

  // Ход ИИ
  Future<void> _makeAIMove() async {
    final aiDecision = _aiService.makeDecision(_gameState);

    if (aiDecision.shouldPlayCard && aiDecision.cardToPlay != null) {
      await playCard(aiDecision.cardToPlay!);
    } else if (aiDecision.cardToDiscard != null) {
      final opponent = _gameState.opponent;
      final newHand = List<CardModel>.from(opponent.hand);
      newHand.remove(aiDecision.cardToDiscard!);

      final newDiscardPile = List<CardModel>.from(_gameState.discardPile);
      newDiscardPile.add(aiDecision.cardToDiscard!);

      _gameState = _gameState.copyWith(
        opponent: opponent.copyWith(hand: newHand),
        discardPile: newDiscardPile,
        gameMessage: 'Компьютер сбросил карту',
      );

      _drawCard(opponent);
      await _nextTurn();
      notifyListeners();
    }
  }

  void _handleGameEnd() {
    if (_gameState.result == GameResult.playerWins) {
      _gameState.player.wins++;
      _audioService.playVictorySound();
    } else {
      _audioService.playDefeatSound();
    }
  }

  // Переключение звука
  void toggleSound() {
    _gameState = _gameState.copyWith(soundEnabled: !_gameState.soundEnabled);
    _audioService.setSoundEnabled(_gameState.soundEnabled);
    notifyListeners();
  }

  // Переключение музыки
  void toggleMusic() {
    _gameState = _gameState.copyWith(musicEnabled: !_gameState.musicEnabled);
    _audioService.setMusicEnabled(_gameState.musicEnabled);
    notifyListeners();
  }

  // Пауза/возобновление игры
  void togglePause() {
    if (_gameState.phase == GamePhase.paused) {
      _gameState = _gameState.copyWith(phase: GamePhase.playing);
    } else if (_gameState.phase == GamePhase.playing || 
               _gameState.phase == GamePhase.playerTurn) {
      _gameState = _gameState.copyWith(phase: GamePhase.paused);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
