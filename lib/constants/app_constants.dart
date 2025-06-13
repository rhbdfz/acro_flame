class AppConstants {
  // Заголовок приложения
  static const String appTitle = 'Arcomage';

  // Базовые настройки игры
  static const int defaultTowerHeight = 15;
  static const int defaultWallHeight = 5;
  static const int defaultResourceCount = 5;
  static const int defaultResourceProduction = 2;

  // Условия победы
  static const int towerVictoryHeight = 50;
  static const int resourceVictoryAmount = 100;

  // Размеры компонентов
  static const double cardWidth = 120.0;
  static const double cardHeight = 180.0;
  static const double cardRadius = 10.0;
  static const double buildingWidth = 60.0;
  static const double buildingHeight = 100.0;

  // Цвета ресурсов
  static const int brickColor = 0xFFB22222; // Красный - кирпичи
  static const int gemColor = 0xFF1E90FF; // Синий - самоцветы
  static const int recruitColor = 0xFF228B22; // Зеленый - рекруты

  // Задержка между ходами ИИ (в миллисекундах)
  static const int aiThinkingDelay = 800;

  // Количество карт в руке
  static const int handSize = 6;

  // Пути к ресурсам
  static const String assetsPath = 'assets/';
  static const String imagesPath = 'assets/images/';
  static const String cardsPath = 'assets/images/cards/';
  static const String brickCardsPath = 'assets/images/cards/brick/';
  static const String gemCardsPath = 'assets/images/cards/gem/';
  static const String recruitCardsPath = 'assets/images/cards/recruit/';
  static const String buildingsPath = 'assets/images/buildings/';
  static const String uiPath = 'assets/images/ui/';
  static const String backgroundsPath = 'assets/images/backgrounds/';
  static const String effectsPath = 'assets/images/effects/';
  static const String audioPath = 'assets/audio/';
  static const String musicPath = 'assets/audio/music/';
  static const String soundsPath = 'assets/audio/effects/';
  static const String dataPath = 'assets/data/';

  // Звуковые эффекты
  static const String drawCardSound = 'card_draw.mp3';
  static const String playCardSound = 'card_play.mp3';
  static const String buildSound = 'build.mp3';
  static const String damageSound = 'damage.mp3';
  static const String resourceSound = 'resource.mp3';
  static const String victorySound = 'victory.mp3';
  static const String defeatSound = 'defeat.mp3';

  // Фоновая музыка
  static const String backgroundMusic = 'background_music.mp3';

  // Пути к JSON данным
  static const String cardsJsonPath = 'assets/data/cards.json';
}