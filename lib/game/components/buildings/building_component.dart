import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum BuildingType {
  tower,
  wall,
}

class BuildingComponent extends PositionComponent {
  final BuildingType buildingType;
  final bool isPlayer;
  late Paint _paint;

  BuildingComponent({
    required this.buildingType,
    required this.isPlayer,
    Vector2? position,
    Vector2? size,
    super.priority = 70,
  }) : super(
    position: position ?? Vector2.zero(),
    size: size ?? Vector2(50, 50),
    anchor: Anchor.center,
  ) {
    _initializePaint();
  }

  void _initializePaint() {
    switch (buildingType) {
      case BuildingType.tower:
        _paint = Paint()
          ..color = isPlayer ? Colors.blue : Colors.red
          ..style = PaintingStyle.fill;
        break;
      case BuildingType.wall:
        _paint = Paint()
          ..color = isPlayer ? Colors.lightBlue : Colors.pink
          ..style = PaintingStyle.fill;
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (buildingType) {
      case BuildingType.tower:
      // Рисуем башню как прямоугольник с треугольной крышей
        final rect = Rect.fromLTWH(0, size.y * 0.3, size.x, size.y * 0.7);
        canvas.drawRect(rect, _paint);

        // Крыша башни
        final roofPath = Path()
          ..moveTo(size.x * 0.5, 0)
          ..lineTo(0, size.y * 0.3)
          ..lineTo(size.x, size.y * 0.3)
          ..close();
        canvas.drawPath(roofPath, _paint);
        break;

      case BuildingType.wall:
      // Рисуем стену как простой прямоугольник
        final rect = size.toRect();
        canvas.drawRect(rect, _paint);

        // Добавляем зубцы на стену
        final crenellationPaint = Paint()
          ..color = _paint.color
          ..style = PaintingStyle.fill;

        final crenellationWidth = size.x / 5;
        for (int i = 0; i < 5; i += 2) {
          final crenellationRect = Rect.fromLTWH(
              i * crenellationWidth,
              0,
              crenellationWidth,
              size.y * 0.2
          );
          canvas.drawRect(crenellationRect, crenellationPaint);
        }
        break;
    }

    // Добавляем обводку
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(size.toRect(), strokePaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Здесь можно добавить логику обновления, например анимации
  }

  // Метод для изменения размера здания
  void updateBuildingSize(double newHeight) {
    if (buildingType == BuildingType.tower) {
      size.y = newHeight;
    } else if (buildingType == BuildingType.wall) {
      size.y = newHeight;
    }
  }

  // Метод для получения текущей высоты здания
  double get buildingHeight => size.y;

  // Метод для получения типа здания в виде строки
  String get buildingTypeString {
    switch (buildingType) {
      case BuildingType.tower:
        return 'Башня';
      case BuildingType.wall:
        return 'Стена';
    }
  }
}
