import 'package:json_annotation/json_annotation.dart';
import 'card_model.dart';

part 'player_model.g.dart';

@JsonSerializable()
class Player {
  String id;
  String name;

  // Ресурсы
  int bricks;
  int gems;
  int recruits;

  // Генераторы ресурсов
  int quarry;
  int magic;
  int dungeon;

  // Строения
  int tower;
  int wall;

  // Карты в руке
  List<CardModel> hand;

  // Количество побед
  int wins;

  // Является ли игрок компьютером
  bool isAI;

  Player({
    required this.id,
    required this.name,
    this.bricks = 5,
    this.gems = 5,
    this.recruits = 5,
    this.quarry = 2,
    this.magic = 2,
    this.dungeon = 2,
    this.tower = 15,
    this.wall = 5,
    this.hand = const [],
    this.wins = 0,
    this.isAI = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  // Проверяет, может ли игрок сыграть карту
  bool canPlayCard(CardModel card) {
    switch (card.type) {
      case CardType.brick:
        return bricks >= card.cost;
      case CardType.gem:
        return gems >= card.cost;
      case CardType.recruit:
        return recruits >= card.cost;
    }
  }

  // Тратит ресурсы на карту
  void spendResources(CardModel card) {
    switch (card.type) {
      case CardType.brick:
        bricks -= card.cost;
        break;
      case CardType.gem:
        gems -= card.cost;
        break;
      case CardType.recruit:
        recruits -= card.cost;
        break;
    }
  }

  // Генерирует ресурсы в начале хода
  void generateResources() {
    bricks += quarry;
    gems += magic;
    recruits += dungeon;
  }

  // Проверяет условия победы
  bool hasWon(int towerVictory, int resourceVictory) {
    return tower >= towerVictory || 
           bricks >= resourceVictory || 
           gems >= resourceVictory || 
           recruits >= resourceVictory;
  }

  // Проверяет условия поражения
  bool hasLost() {
    return tower <= 0;
  }

  // Копирование с изменениями
  Player copyWith({
    String? id,
    String? name,
    int? bricks,
    int? gems,
    int? recruits,
    int? quarry,
    int? magic,
    int? dungeon,
    int? tower,
    int? wall,
    List<CardModel>? hand,
    int? wins,
    bool? isAI,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      bricks: bricks ?? this.bricks,
      gems: gems ?? this.gems,
      recruits: recruits ?? this.recruits,
      quarry: quarry ?? this.quarry,
      magic: magic ?? this.magic,
      dungeon: dungeon ?? this.dungeon,
      tower: tower ?? this.tower,
      wall: wall ?? this.wall,
      hand: hand ?? List<CardModel>.from(this.hand),
      wins: wins ?? this.wins,
      isAI: isAI ?? this.isAI,
    );
  }

  @override
  String toString() {
    return 'Player{name: $name, tower: $tower, wall: $wall, bricks: $bricks, gems: $gems, recruits: $recruits}';
  }
}
