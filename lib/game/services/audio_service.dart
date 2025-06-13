import 'package:flame_audio/flame_audio.dart';
import '../../constants/app_constants.dart';

class AudioService {
  static AudioService? _instance;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _musicLoaded = false;

  AudioService._internal();

  factory AudioService() {
    _instance ??= AudioService._internal();
    return _instance!;
  }

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  // Инициализация аудио сервиса
  Future<void> initialize() async {
    try {
      // Предзагружаем звуковые эффекты
      await _preloadSounds();

      // Запускаем фоновую музыку
      if (_musicEnabled) {
        await playBackgroundMusic();
      }
    } catch (e) {
      print('Ошибка инициализации аудио: $e');
    }
  }

  // Предзагрузка звуковых эффектов
  Future<void> _preloadSounds() async {
    try {
      final sounds = [
        AppConstants.drawCardSound,
        AppConstants.playCardSound,
        AppConstants.buildSound,
        AppConstants.damageSound,
        AppConstants.resourceSound,
        AppConstants.victorySound,
        AppConstants.defeatSound,
      ];

      for (final sound in sounds) {
        await FlameAudio.audioCache.load('${AppConstants.soundsPath}$sound');
      }
    } catch (e) {
      print('Ошибка предзагрузки звуков: $e');
    }
  }

  // Воспроизведение фоновой музыки
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled || _musicLoaded) return;

    try {
      await FlameAudio.bgm.play('${AppConstants.musicPath}${AppConstants.backgroundMusic}');
      _musicLoaded = true;
    } catch (e) {
      print('Ошибка воспроизведения фоновой музыки: $e');
    }
  }

  // Остановка фоновой музыки
  Future<void> stopBackgroundMusic() async {
    try {
      await FlameAudio.bgm.stop();
      _musicLoaded = false;
    } catch (e) {
      print('Ошибка остановки фоновой музыки: $e');
    }
  }

  // Звук при взятии карты
  Future<void> playDrawSound() async {
    if (!_soundEnabled) return;
    _playSound(AppConstants.drawCardSound);
  }

  // Звук при игре карты
  Future<void> playCardSound() async {
    if (!_soundEnabled) return;
    _playSound(AppConstants.playCardSound);
  }

  // Звук строительства
  Future<void> playBuildSound() async {
    if (!_soundEnabled) return;
    _playSound(AppConstants.buildSound);
  }

  // Звук урона
  Future<void> playDamageSound() async {
    if (!_soundEnabled) return;
    _playSound(AppConstants.damageSound);
  }

  // Звук получения ресурсов
  Future<void> playResourceSound() async {
    if (!_soundEnabled) return;
    _playSound(AppConstants.resourceSound);
  }

  // Звук победы
  Future<void> playVictorySound() async {
    if (!_soundEnabled) return;
    _playSound(AppConstants.victorySound);
  }

  // Звук поражения
  Future<void> playDefeatSound() async {
    if (!_soundEnabled) return;
    _playSound(AppConstants.defeatSound);
  }

  // Универсальный метод воспроизведения звука
  Future<void> _playSound(String soundFile) async {
    try {
      await FlameAudio.play('${AppConstants.soundsPath}$soundFile');
    } catch (e) {
      print('Ошибка воспроизведения звука $soundFile: $e');
    }
  }

  // Включение/выключение звуковых эффектов
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  // Включение/выключение музыки
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;

    if (enabled && !_musicLoaded) {
      playBackgroundMusic();
    } else if (!enabled && _musicLoaded) {
      stopBackgroundMusic();
    }
  }

  // Установка громкости звуковых эффектов
  Future<void> setSoundVolume(double volume) async {
    try {
      // Flame Audio не предоставляет прямого API для установки громкости эффектов
      // Этот метод можно расширить при необходимости
    } catch (e) {
      print('Ошибка установки громкости звуков: $e');
    }
  }

  // Установка громкости музыки
  Future<void> setMusicVolume(double volume) async {
    try {
      await FlameAudio.bgm.audioPlayer.setVolume(volume);
    } catch (e) {
      print('Ошибка установки громкости музыки: $e');
    }
  }

  // Пауза/возобновление музыки
  Future<void> pauseMusic() async {
    if (_musicLoaded) {
      try {
        await FlameAudio.bgm.pause();
      } catch (e) {
        print('Ошибка паузы музыки: $e');
      }
    }
  }

  Future<void> resumeMusic() async {
    if (_musicLoaded && _musicEnabled) {
      try {
        await FlameAudio.bgm.resume();
      } catch (e) {
        print('Ошибка возобновления музыки: $e');
      }
    }
  }

  // Очистка ресурсов
  void dispose() {
    try {
      FlameAudio.bgm.stop();
      FlameAudio.audioCache.clearAll();
      _musicLoaded = false;
    } catch (e) {
      print('Ошибка очистки аудио ресурсов: $e');
    }
  }
}
