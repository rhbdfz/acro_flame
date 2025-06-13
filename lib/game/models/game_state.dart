import 'package:json_annotation/json_annotation.dart';
import 'player_model.dart';
import 'card_model.dart';

part 'game_state.g.dart';

enum GamePhase {
  @JsonValue('menu')
  menu,
  @JsonValue('playing')
  playing,
  @JsonValue('player_turn')
  playerTurn,
  @JsonValue('ai_turn')
  aiTurn,
  @JsonValue('game_over')
  gameOver,
  @JsonValue('paused')
  paused,
}

enum GameResult {
  @JsonValue('none')
  none,
  @JsonValue('player_wins')
  playerWins,
  @JsonValue('ai_wins')
  aiWins,
  @JsonValue('draw')
  draw,
}

enum VictoryCondition {
  @JsonValue('tower')
  tower,
  @JsonValue('resources')
  resources,
  @JsonValue('destruction')
  destruction,
}

@JsonSerializable()
class GameState {
  Player player;
  Player opponent;

  GamePhase phase;
  GameResult result;
  VictoryCondition? victoryCondition;

  List<CardModel> deck;
  List<CardModel> discardPile;

  int currentTurn;
  bool isPlayerTurn;

  // Условия победы
  int towerVictoryHeight;
  int resourceVictoryAmount;

  // Настройки игры
  bool soundEnabled;
  bool musicEnabled;

  // Временные переменные
  String? lastPlayedCardName;
  String? gameMessage;

  GameState({
    required this.player,
    required this.opponent,
    this.phase = GamePhase.menu,
    this.result = GameResult.none,
    this.victoryCondition,
    this.deck = const [],
    this.discardPile = const [],
    this.currentTurn = 1,
    this.isPlayerTurn = true,
    this.towerVictoryHeight = 50,
    this.resourceVictoryAmount = 100,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.lastPlayedCardName,
    this.gameMessage,
  });

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  // Фабричный метод для создания новой игры
  factory GameState.newGame({
    required String playerName,
    required String opponentName,
    int towerHeight = 15,
    int wallHeight = 5,
    int resourceCount = 5,
    int resourceProduction = 2,
    int towerVictory = 50,
    int resourceVictory = 100,
  }) {
    return GameState(
      player: Player(
        id: 'player',
        name: playerName,
        tower: towerHeight,
        wall: wallHeight,
        bricks: resourceCount,
        gems: resourceCount,
        recruits: resourceCount,
        quarry: resourceProduction,
        magic: resourceProduction,
        dungeon: resourceProduction,
      ),
      opponent: Player(
        id: 'opponent',
        name: opponentName,
        tower: towerHeight,
        wall: wallHeight,
        bricks: resourceCount,
        gems: resourceCount,
        recruits: resourceCount,
        quarry: resourceProduction,
        magic: resourceProduction,
        dungeon: resourceProduction,
        isAI: true,
      ),
      towerVictoryHeight: towerVictory,
      resourceVictoryAmount: resourceVictory,
      phase: GamePhase.playing,
    );
  }

  // Получает текущего активного игрока
  Player get currentPlayer => isPlayerTurn ? player : opponent;

  // Получает противника текущего игрока
  Player get currentOpponent => isPlayerTurn ? opponent : player;

  // Проверяет, закончена ли игра
  bool get isGameOver => phase == GamePhase.gameOver;

  // Проверяет условия победы для любого игрока
  void checkGameEnd() {
    if (player.hasLost()) {
      result = GameResult.aiWins;
      victoryCondition = VictoryCondition.destruction;
      phase = GamePhase.gameOver;
      return;
    }

    if (opponent.hasLost()) {
      result = GameResult.playerWins;
      victoryCondition = VictoryCondition.destruction;
      phase = GamePhase.gameOver;
      return;
    }

    if (player.hasWon(towerVictoryHeight, resourceVictoryAmount)) {
      result = GameResult.playerWins;
      victoryCondition = player.tower >= towerVictoryHeight 
          ? VictoryCondition.tower 
          : VictoryCondition.resources;
      phase = GamePhase.gameOver;
      return;
    }

    if (opponent.hasWon(towerVictoryHeight, resourceVictoryAmount)) {
      result = GameResult.aiWins;
      victoryCondition = opponent.tower >= towerVictoryHeight 
          ? VictoryCondition.tower 
          : VictoryCondition.resources;
      phase = GamePhase.gameOver;
      return;
    }
  }

  // Переключает ход между игроками
  void nextTurn() {
    isPlayerTurn = !isPlayerTurn;
    if (isPlayerTurn) {
      currentTurn++;
      player.generateResources();
    } else {
      opponent.generateResources();
    }

    phase = isPlayerTurn ? GamePhase.playerTurn : GamePhase.aiTurn;
  }

  // Копирование с изменениями
  GameState copyWith({
    Player? player,
    Player? opponent,
    GamePhase? phase,
    GameResult? result,
    VictoryCondition? victoryCondition,
    List<CardModel>? deck,
    List<CardModel>? discardPile,
    int? currentTurn,
    bool? isPlayerTurn,
    int? towerVictoryHeight,
    int? resourceVictoryAmount,
    bool? soundEnabled,
    bool? musicEnabled,
    String? lastPlayedCardName,
    String? gameMessage,
  }) {
    return GameState(
      player: player ?? this.player.copyWith(),
      opponent: opponent ?? this.opponent.copyWith(),
      phase: phase ?? this.phase,
      result: result ?? this.result,
      victoryCondition: victoryCondition ?? this.victoryCondition,
      deck: deck ?? List<CardModel>.from(this.deck),
      discardPile: discardPile ?? List<CardModel>.from(this.discardPile),
      currentTurn: currentTurn ?? this.currentTurn,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
      towerVictoryHeight: towerVictoryHeight ?? this.towerVictoryHeight,
      resourceVictoryAmount: resourceVictoryAmount ?? this.resourceVictoryAmount,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      lastPlayedCardName: lastPlayedCardName ?? this.lastPlayedCardName,
      gameMessage: gameMessage ?? this.gameMessage,
    );
  }

  @override
  String toString() {
    return 'GameState{phase: $phase, turn: $currentTurn, isPlayerTurn: $isPlayerTurn}';
  }
}
